# 实验二：NameNode 与 DataNode 角色观察

## 1. 实验目标

通过命令输出和 Web UI 理解 NameNode 与 DataNode 的职责。

## 2. 启动并检查进程

```bash
bash scripts/start-hdfs.sh
jps
```

观察：

- NameNode
- DataNode
- SecondaryNameNode

> SecondaryNameNode **不是** NameNode 的实时热备节点，它主要参与检查点（checkpoint）相关工作。

## 3. 查看 DataNode 报告

```bash
hdfs dfsadmin -report
```

记录：

- Live datanodes 数量；
- DFS Used；
- DFS Remaining；
- DataNode Hostname。

## 4. 打开 NameNode Web UI

打开 Codespaces 的 **PORTS / 端口** 面板，找到 **9870**，点击浏览器图标。

在页面中观察：

- Overview；
- Datanodes；
- Utilities → Browse the file system。

## 5. 建立文件并观察

```bash
hdfs dfs -mkdir -p /cloudlab/roles
hdfs dfs -put -f data/hello.txt /cloudlab/roles/
hdfs dfs -ls /cloudlab/roles
```

然后在 Web UI 中找到同一个文件。

## 6. 思考题

1. NameNode 是否保存普通文件的真实内容？
2. DataNode 的主要职责是什么？
3. 如果没有 NameNode，客户端还能否知道一个 HDFS 文件由哪些 Block 构成、位于哪些节点？

请用 150 字左右回答。
