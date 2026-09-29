# 实验二：1 个 NameNode + 3 个 DataNode 多节点 HDFS

## 一、实验目标

本实验在同一个 GitHub Codespace 中启动：

- 1 个 NameNode
- 3 个彼此独立的 DataNode
- HDFS 默认副本数：3

完成后应能观察到：

1. `Live datanodes (3)`
2. 一个 HDFS 文件块存在 3 个副本
3. 单独停止 1 个 DataNode 后，文件仍然能够正常读取
4. 理解 HDFS 副本机制与容错之间的关系

> 本实验不会修改第一阶段的单 DataNode 数据目录。进入实验二时会先停止实验一的 HDFS 进程，避免 9000/9870 端口冲突。

---

## 二、初始化实验二

第一次进入实验二时执行：

```bash
bash scripts/multinode/setup-multinode.sh
```

预期看到：

```text
Multi-node environment prepared:
  NameNode : RPC 9000 / Web 9870
  DataNode1: xfer 9866 / web 9864 / ipc 9867
  DataNode2: xfer 9966 / web 9964 / ipc 9967
  DataNode3: xfer 10066 / web 10064 / ipc 10067
```

---

## 三、启动多节点 HDFS

执行：

```bash
bash scripts/multinode/start-multinode.sh
```

启动完成后查看：

```bash
bash scripts/multinode/status-multinode.sh
```

重点寻找：

```text
Live datanodes (3)
```

如果出现 3，说明三个 DataNode 均已成功注册到 NameNode。

---

## 四、切换到实验二客户端配置

执行：

```bash
source scripts/multinode/activate.sh
```

然后检查：

```bash
echo $HADOOP_CONF_DIR
```

应该指向：

```text
/home/hadoop/hadoop-multi/conf/client
```

---

## 五、上传文件并验证 3 副本

创建测试目录：

```bash
hdfs dfs -mkdir -p /multilab/input
```

上传示例文件：

```bash
hdfs dfs -put -f data/hello.txt /multilab/input/
```

查看：

```bash
hdfs dfs -ls /multilab/input
```

查看 Block 和副本位置：

```bash
hdfs fsck /multilab/input/hello.txt -files -blocks -locations
```

重点观察：

```text
Average block replication: 3.0
```

以及一个 Block 后面出现 3 个 DataNode 位置信息。

---

## 六、停止 DataNode-2

执行：

```bash
bash scripts/multinode/stop-one-datanode.sh 2
```

再次查看：

```bash
bash scripts/multinode/status-multinode.sh
```

重点观察：

```text
Live datanodes (2)
```

---

## 七、验证节点故障后文件仍可读取

执行：

```bash
source scripts/multinode/activate.sh
hdfs dfs -cat /multilab/input/hello.txt
```

如果仍然能够看到：

```text
Hello Hadoop
Cloud Computing Lab
```

说明即使一个 DataNode 停止服务，客户端仍能从其他副本读取数据。

这就是 HDFS 副本机制最直观的容错现象。

---

## 八、恢复 DataNode-2

执行：

```bash
bash scripts/multinode/start-one-datanode.sh 2
```

再次查看：

```bash
bash scripts/multinode/status-multinode.sh
```

应重新看到：

```text
Live datanodes (3)
```

---

## 九、停止实验二

实验完成后执行：

```bash
bash scripts/multinode/stop-multinode.sh
```

如果之后想重新做实验一，可直接执行：

```bash
bash scripts/start-hdfs.sh
```

---

## 十、提交要求

提交 4 张截图：

1. `Live datanodes (3)`
2. `hdfs fsck` 显示 3 副本
3. 停止 DataNode-2 后显示 `Live datanodes (2)`
4. DataNode-2 停止后，`hdfs dfs -cat` 仍能成功读取文件

并回答：

> 为什么停止一个 DataNode 后，文件仍然能够读取？这说明 HDFS 的副本机制解决了什么问题？

建议 150–200 字。
