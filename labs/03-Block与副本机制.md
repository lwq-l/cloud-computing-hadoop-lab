# 实验三：HDFS Block 与副本机制

## 1. 实验目标

观察 HDFS 文件的数据块信息，理解“文件—Block—DataNode”的映射关系以及副本机制的意义。

## 2. 准备测试文件

```bash
bash scripts/start-hdfs.sh
hdfs dfs -mkdir -p /cloudlab/blocks
hdfs dfs -put -f data/hello.txt /cloudlab/blocks/
```

## 3. 查看文件信息

```bash
hdfs dfs -ls -h /cloudlab/blocks
```

观察文件权限、所有者、大小、修改时间以及显示的副本数。

## 4. 查看 Block 与位置

```bash
hdfs fsck /cloudlab/blocks/hello.txt -files -blocks -locations
```

重点寻找：

- Number of data-nodes；
- Number of racks；
- Total blocks；
- Average block replication；
- Block 所在 DataNode。

## 5. 为什么当前副本数是 1？

本教学环境是**单机伪分布式 HDFS**，默认只有一个 DataNode，因此 `dfs.replication=1`。

真实多节点集群通常会配置多个副本，使相同数据块分布在不同 DataNode 上。当某个节点故障时，客户端仍有机会从其他副本读取数据。

## 6. 思考题

用 150–200 字回答：

> 为什么 HDFS 不把所有文件只保存在一个节点？副本机制主要解决什么问题？

回答应至少涉及：

- 单节点容量上限；
- 节点故障；
- 数据可用性；
- 容错；
- 多节点环境下的数据可靠性。
