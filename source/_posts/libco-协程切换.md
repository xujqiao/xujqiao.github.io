---
title: "libco协程概览-协程切换"
date: 2025-06-01 10:03:00
categories:
  - 技术
tags:
  - "libco"
  - "协程"
---

## 如何实现协程切换

上文提到，协程的切换完全由用户控制，协程的切换类似函数调用，一般在程序遇到阻塞和运行结束时进行切换，如：rpc。
落到代码实现，程序一般在调用系统函数时出现阻塞，如：read，write，connect等。
假设，实现协程切换的函数是`co_resume(curr_co, pending_co)`，作用是从`curr_co`切换到`pending_co`。
那么当程序调用系统函数后，需要立即调用`co_resume`，让出当前CPU，直到系统函数返回时才恢复当前协程并继续执行。
基于上述想法，很自然会产生下面的代码片段。

```c++
// co1
...
read(fd, buffer, buffer_length);
co_resume(self_co, main_co);
printf(buffer);
...

// co2
...
write(fd, buffer, buffer_length);
co_resume(self_co, main_co);
printf("ok");
...

// main_co
...
co1 = co_create(xxf1);
co2 = co_create(xxf2);
co_eventloop(); // 管理co的函数
...
```

存在优化的空间吗？存在！上述片段，每次调用系统函数后面都跟着`co_resume`
既然我们知道每次调用系统函数都必然会跟着`co_resume`,能否把`co_resume`"嵌入"系统函数中呢？
答案是肯定的，应用的技术叫`hook`。

## `hook`介绍

`hook`，本意是钩子，计算机领域可理解成在原有的实现里添加钩子，达到调用原有实现时会通过钩子触发外部的目的。
比如git hook，在commit时添加hook，以检查commit log是否符合规范。
本例中的用法更像**包装器**，即原有的调用被修改成调用预设的包装函数，再由包装函数调用具体的函数，所以这里应该叫`hijack`。


```
   caller           caller
      |                |
   call func        call func
      |                |
+-----v----+       +---v-----+
|          |       | wrapper |
| function |<******|function |
+----------+       +---------+
```

如上图所示，caller在调用function时，实际调用的函数被劫持成wrapper function，再由wrapper function来调用function，
整个过程caller毫无感知，其原有调用方式完全没有变化。


## `libco`的`hook`

程序从代码到可执行文件的过程中，需要经历编译和链接，编译是把高级语言转换成机器能识别的语言，链接则是补全编译过程中未找到的函数路径。
补全的方式有两种，一种是静态，把依赖的库文件打包至最终的二进制文件中；另一种则是动态，在执行时再加载库文件。
一般而言，用户编写的业务代码，除非需要支持热加载，一般采用静态链接。而依赖的标准库函数、系统库，一般是动态链接。
这里要`hook`的函数是系统调用，就是系统库的函数，也就是动态链接。
动态链接的方式也有多种，其中`libco`采用的方式，我认为是比较优秀的。

回到上图，以`read`为例，我们要实现的功能如下所示。

```c++
// int read(int fildes, void *buf, size_t nbyte); // sys_read

int read(int fildes, void *buf, size_t nbyte) { // my_read
  int ret = read(fides, buf, nbyte); // call sys_read
  co_yield(self, main_co);
  ....
}
```

定义一个与系统函数`read`同名的函数，函数体里，调用系统函数`sys_read`，并在调用结束后，追加调用`co_yield`。
这样，业务方在编写代码时，调用的依然是相同签名的`read`，且无任何感知。
这样的代码虽然可以编译通过，但是个无限递归的死循环，因为函数体里调用的`read`并不是`sys_read`，而是`my_read`，但我们希望其调用的是`sys_read`。
因此，需要一个方式可以指定调用系统库的`read`。

如下，是`libco`的`hook`代码

```c++
// hookread.cpp
#include <dlfcn.h>
#include <unistd.h>

#include <iostream>

#include "hookread.h"

typedef ssize_t (*read_pfn_t)(int fildes, void *buf, size_t nbyte);

static read_pfn_t g_sys_read_func = (read_pfn_t)dlsym(RTLD_NEXT,"read");

ssize_t read( int fd, void *buf, size_t nbyte ){
    std::cout << "进入 hook read\n";
    return g_sys_read_func(fd, buf, nbyte);
}

void co_enable_hook_sys(){
    std::cout << "可 hook\n";
}

// hookread.h
ssize_t read( int fd, void *buf, size_t nbyte );

void co_enable_hook_sys();
```

可以看到，上述使用了`dlsym(RTLD_NEXT,"read")`来加载系统read。
原因是使用了特殊的`RTLD_NEXT`，其允许在预期的库加载顺序里跳过当前lib而加载其他库的目标函数，达到包装器的作用。
为了让业务代码能调用到`my_read`，需要将当前lib添加到业务二进制里面，这里有两种方式，一种是修改编译命令，将当前lib添加到业务二进制的编译路径里
另一种是**主动侵入**业务代码，告诉业务二进制当前会调用被修改后的函数。`libco`选择的是后者，就是`co_enable_hook_sys`的作用。
虽然此举有侵入业务代码的嫌疑，但详细比较来看，这种未必不是好的选择，反而让调用方显示的了解接下来的调用会调用被hook的函数，尽管不用修改调用方式。

使用`RTLD_NEXT``hijack`其他函数时，尤其是系统函数，需要避免循环调用。假设`hijack``malloc`时，就不能在包装函数里显式or隐式调用`malloc`，比如`printf`。


[dlsym(3) — Linux manual page](https://man7.org/linux/man-pages/man3/dlsym.3.html)
[运行时链接编程接口](https://docs.oracle.com/cd/E19253-01/819-7050/6n918j8n4/index.html#chapter3-fig-15)
[libco源码解析(8) hook机制探究](https://blog.csdn.net/weixin_43705457/article/details/106895038)

### 待补充

上下文的结构,堆和栈的对应

------

CC BY-NC-SA 4.0

本作品采用[知识共享署名-非商业性使用-相同方式共享 4.0 国际许可协议](https://creativecommons.org/licenses/by-nc-sa/4.0/)进行许可。

本作品由[xujqiao](https://github.com/xujqiao/weblog)创作，由[xujqiao](https://github.com/xujqiao/weblog)确认，转载请注明版权。
