---
title: "LeetCode 5 - 最长回文子串"
date: 2021-05-16 12:00:00
categories:
  - 技术
tags:
  - "LeetCode"
  - "C++"
  - "字符串"
---

# LeetCode 5 - 最长回文子串

## 题目描述

给定一个字符串 `s`，找到 `s` 中最长的回文子串。

**示例 1：**
```
输入：s = "babad"
输出："bab" 或 "aba"
```

**示例 2：**
```
输入：s = "cbbd"
输出："bb"
```

<!-- more -->

## 解题思路

本题使用了一种基于**中心扩展**的巧妙解法。

### 核心思想

1. 回文串关于中心对称。遍历每个位置，以该位置为中心向两侧扩展，找到以该中心能扩展出的最长回文串。
2. 但回文串的中心可能是一个字符（奇数长度，如 `aba`），也可能是两个字符之间（偶数长度，如 `abba`）。
3. 预处理：将连续相同的字符压缩成一个"块"，因为相同的字符必然能构成回文的一部分，以块为单位扩展可以减少重复计算。

### 算法步骤

- 遍历字符串，对于每个位置 `i`：
  - 从 `i` 开始向右找到连续相同字符的区间 `[i, j]`
  - 将这个区间整体作为一个"回文中心"入队
  - `i` 跳到 `j + 1`
- 然后从队列中依次取出每个中心 `[left, right]`：
  - 如果当前回文长度 > 答案，更新答案
  - 尝试向两边扩展：若 `left-1` 与 `right+1` 字符相同，将扩展后的中心入队

这样每个位置最多入队一次，出队一次，时间复杂度 **O(n)**。

## 代码

```cpp
#include <iostream>
#include <string>
#include <queue>

using namespace std;

namespace ns5 {

    class Solution {
    public:
        string longestPalindrome(string s) {
            queue<int> palindromes;
            for (int i = 0; i < s.length();) {
                int j = i;
                while (j + 1 < s.length() && s[j] == s[j + 1]) {
                    ++j;
                }
                palindromes.push(i);
                palindromes.push(j);
                i = j + 1;
            }

            int left = -1, right = -1;
            int ansLeft = 0, ansRight = 0;
            while (!palindromes.empty()) {
                left = palindromes.front();
                palindromes.pop();
                right = palindromes.front();
                palindromes.pop();

                if (right - left > ansRight - ansLeft) {
                    ansRight = right;
                    ansLeft = left;
                }

                if (left == 0 || right == s.length() - 1) {
                    continue;
                }

                if (s[left - 1] == s[right + 1]) {
                    palindromes.push(left - 1);
                    palindromes.push(right + 1);
                }
            }

            return s.substr(ansLeft, ansRight - ansLeft + 1);
        }
    };

};
```

## 复杂度分析

- **时间复杂度**：O(n)，每个字符作为中心被处理一次
- **空间复杂度**：O(n)，队列中最多存放所有回文中心

## 总结

相比传统的"在每个位置向两边扩展"的 O(n²) 中心扩展法，上述解法通过**合并连续相同字符**减少了扩展次数，达到 O(n) 的时间复杂度，实现简洁且高效。
