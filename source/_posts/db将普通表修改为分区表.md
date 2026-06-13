---
title: "db将普通表修改为分区表"
date: 2025-06-01 10:01:00
categories:
  - 技术
tags:
  - "PostgreSQL"
  - "分区表"
  - "pathman"
---

# pathman介绍

pathman是postgrespro公司开发的一款分区表功能的插件，不需要动用catalog，即可方便管理分区

<!-- more -->

## 安装pathman

> 本文参考[这篇文件](https://juejin.im/entry/581066a2bf22ec005841d07b)

```bash
$ git clone https://github.com/postgrespro/pg_pathman
$ export PATH=/home/digoal/pgsql9.6:$PATH

$ cd pg_pathman
$ make USE_PGXS=1
$ make USE_PGXS=1 install

$ cd $PGDATA
$ vi postgresql.conf
shared_preload_libraries = 'pg_pathman' 

$ pg_ctl restart -m fast

$ psql
postgres=# create extension pg_pathman;
CREATE EXTENSION

postgres=# \dx
                   List of installed extensions
    Name    | Version |   Schema   |         Description          
------------+---------+------------+------------------------------
 pg_pathman | 1.1     | public     | Partitioning tool ver. 1.1

```

## 创建分区表

```sql
create_range_partitions(
	relation       REGCLASS,  -- 主表OID
    attribute      TEXT,      -- 分区列名
    start_value    ANYELEMENT,  -- 开始值
    p_interval     ANYELEMENT,  -- 间隔；任意类型，适合任意类型的分区表
    p_count        INTEGER DEFAULT NULL,   --  分多少个区
    partition_data BOOLEAN DEFAULT TRUE)   --  是否立即将数据从主表迁移到分区, 不建议这么使用, 建议使用非堵塞式的迁移( 调用partition_table_concurrently() )
```

## 分裂分区表

```sql
split_range_partition(
	partition      REGCLASS,            -- 分区oid
	split_value    ANYELEMENT,          -- 分裂值
	partition_name TEXT DEFAULT NULL)   -- 分裂后新增的分区表名
```

## 删除分区表

删除单个分区
```sql
drop_range_partition(
	partition TEXT,   -- 分区名称
    delete_data BOOLEAN DEFAULT TRUE)  -- 是否删除分区数据，如果false，表示分区数据迁移到主表。  
```

删除所有分区
```sql
drop_partitions(
	parent      REGCLASS,
    delete_data BOOLEAN DEFAULT FALSE)
```

## 迁移数据

```sql
partition_table_concurrently(
	relation   REGCLASS,              -- 主表OID
	batch_size INTEGER DEFAULT 1000,  -- 一个事务批量迁移多少记录
	sleep_time FLOAT8 DEFAULT 1.0)    -- 获得行锁失败时，休眠多久再次获取，重试60次退出任务。
```

## 停止迁移任务

```sql
select stop_concurrent_part_task(relation REGCLASS);
```


## 查看后台数据迁移任务

```sql
select * from pathman_concurrent_part_tasks;
 userid | pid | dbid | relid | processed | status 
--------+-----+------+-------+-----------+--------
(0 rows)
```

# 流水日志表从普通表修改成分区表

## 在备机和主机中安全pathman

避免功能缺失，数据不同步

使用postgre用户切换到相应数据库下运行`create extension pg_pathman`

pg_pathman会在数据库下新建一些表和视图

## 修改为分区表


```sql
select create_range_partitions(
	't_crawler_stat_detail'::regclass,
	'f_create_time',
	'2019-11-01 00:00:00'::timestamp, -- 此处最好从1号开始，避免混淆
	interval '1 month',
	16,
	false
);
```

如果表的owner不是登陆用户，要不切换成登录用户再执行，要不修改表的owver

```sql
alter table t_crawler_stat_detail owner to xxxxxxx;
```


## 迁移数据

```sql
select partition_table_concurrently(
	't_crawler_stat_detail'::regclass,
	10000,
	1.0
);
```

后台任务

```sql
select * from pathman_concurrent_part_tasks;
```

迁移结束后，主表数据已经没有了，全部在分区中

```sql
select count(*) from only part_test;
```

## 分裂分区表

```sql
select split_range_partition(
	't_crawler_stat_detail_4'::regclass,              -- 分区oid
	'2020-02-16 00:00:00'::timestamp,     -- 分裂值
	't_crawler_stat_detail_4_2');                     -- 分区表名
```

## 禁用主表

```sql
select set_enable_parent(
	't_crawler_stat_detail'::regclass, 
	false
);
```