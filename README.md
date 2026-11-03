# 云计算技术及应用：Hadoop / HDFS 在线实验平台

## 国内浏览器上机入口（CNB）

正式课程仓库：https://cnb.cool/cloud-computing-lab/cloud-computing-hadoop-lab

使用 CNB 登录后，按教师安排进入个人可开发仓库/工作区，在浏览器内完成实验，不需要在本机安装虚拟机、Hadoop 或 Docker Desktop。不要将教师个人临时 WebIDE 链接作为全班共用入口。

- [第3、4章 CNB 上机指南](labs/CNB-第3章与第4章学生上机指南.md)
- [第5章《计算虚拟化》实践作业（三）](labs/06-计算虚拟化综合实践.md)
- [第五章启动与教师核查说明](README-CH05.md)

第三、四章 HDFS/负载均衡、第五章 Docker 镜像、容器、数据卷已完成教师端运行检查。当前 Docker 环境的 CPU/内存配额配置可读取，但尚未证明内核强制执行配额；第五章评分标准已作相应调整。学生须保留自己的截图和报告，工作区数据不能替代个人备份。

---

本仓库用于《云计算技术及应用》《分布式系统》课程的 Hadoop/HDFS 实践教学。

学生**不需要在本机安装 Linux、JDK 或 Hadoop**。点击下面的按钮即可在浏览器中启动 GitHub Codespaces 实验环境。

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/lwq-l/cloud-computing-hadoop-lab?quickstart=1)

## 实验目标

完成本实验后，应能够：

1. 识别 NameNode、DataNode、SecondaryNameNode 的基本职责；
2. 区分 Linux 本地文件系统与 HDFS 文件系统；
3. 使用 HDFS Shell 完成目录创建、上传、查看、读取和删除；
4. 使用 `hdfs dfsadmin -report` 查看 DataNode 状态；
5. 使用 `hdfs fsck` 观察文件 Block 与副本信息；
6. 解释 HDFS 为什么需要多节点和副本机制。

## 第一次进入 Codespaces

环境创建完成后，打开终端。正常情况下会自动完成 Hadoop 初始化。

先执行：

```bash
hadoop version
java -version
```

然后启动 HDFS：

```bash
bash scripts/start-hdfs.sh
```

检查进程：

```bash
jps
```

正常情况下可以看到：

```text
NameNode
DataNode
SecondaryNameNode
Jps
```

## HDFS 最小实验

查看 HDFS 根目录：

```bash
hdfs dfs -ls /
```

创建课程实验目录：

```bash
hdfs dfs -mkdir -p /cloudlab/input
```

创建一个本地文件：

```bash
echo "Hello Hadoop" > hello.txt
cat hello.txt
```

上传到 HDFS：

```bash
hdfs dfs -put -f hello.txt /cloudlab/input/
```

查看和读取：

```bash
hdfs dfs -ls /cloudlab/input
hdfs dfs -cat /cloudlab/input/hello.txt
```

查看文件块位置：

```bash
hdfs fsck /cloudlab/input/hello.txt -files -blocks -locations
```

查看 DataNode：

```bash
hdfs dfsadmin -report
```

删除文件：

```bash
hdfs dfs -rm /cloudlab/input/hello.txt
```

## NameNode Web UI

HDFS 启动后，推荐直接使用 **VS Code 集成浏览器** 访问 NameNode 页面，这种方式不依赖 Codespaces 外部端口认证。

1. 按 `Ctrl+Shift+P`（macOS 可用 `Cmd+Shift+P`）。
2. 搜索并执行 **Browser: Open Integrated Browser**。
3. 输入：

```text
http://127.0.0.1:9870/dfshealth.html
```

正常情况下即可看到 HDFS NameNode 管理页面。

也可以在终端先验证：

```bash
curl -I http://127.0.0.1:9870/
```

若返回 `HTTP/1.1 200` 或 `HTTP/1.1 302`，说明 NameNode Web 服务本身正常。

> 备用方式：Codespaces 仍会自动转发 9870 端口，但部分浏览器环境可能出现外部转发页面 401。课堂实验优先使用集成浏览器。

## 实验目录

- [实验一：HDFS 基础操作](labs/01-HDFS基础操作.md)
- [实验二：NameNode 与 DataNode](labs/02-NameNode与DataNode.md)
- [实验三：Block 与副本机制](labs/03-Block与副本机制.md)
- [实验报告模板](labs/实验报告模板.md)

## 常用脚本

```bash
bash scripts/start-hdfs.sh    # 启动 HDFS
bash scripts/stop-hdfs.sh     # 停止 HDFS
bash scripts/status.sh        # 查看 Hadoop Java 进程与 DataNode 状态
bash scripts/reset-hdfs.sh    # 清空并重新初始化 HDFS（会删除实验数据）
```

> **注意：** `reset-hdfs.sh` 会删除当前 HDFS 中的全部实验数据，只在需要完全重做实验时使用。

## 教学说明

本仓库默认采用**单机伪分布式 HDFS**。物理上只有一个 Codespace，但 NameNode、DataNode 和 SecondaryNameNode 作为独立 Java 进程运行，因此非常适合第一次学习 HDFS 的角色分工和基本命令。

由于默认只有一个 DataNode，`dfs.replication` 设置为 1。实验三会解释真实多节点集群为什么通常使用多个副本；后续可再扩展为多 DataNode 教师演示环境。


## 实验二：多节点 HDFS 与副本容错

第一阶段单节点实验完成后，可以进入实验二：

- 1 个 NameNode
- 3 个 DataNode
- HDFS 副本数 3
- 支持单独停止某一个 DataNode
- 验证节点故障后文件仍可读取

实验指导：

- [实验二：1 个 NameNode + 3 个 DataNode 多节点 HDFS](labs/04-多节点HDFS与副本容错.md)

首次初始化：

```bash
bash scripts/multinode/setup-multinode.sh
```

启动：

```bash
bash scripts/multinode/start-multinode.sh
```

查看状态：

```bash
bash scripts/multinode/status-multinode.sh
```


## 第4章综合实践作业（二）：硬件资源与负载均衡

[完整学生操作指导书（7个任务）](labs/05-云计算硬件资源与负载均衡综合实践.md)

无需安装Nginx，使用 Python 标准库模拟三个 Web 后端与轮询负载均衡：

```bash
bash scripts/loadbalance/start-lb.sh
bash scripts/loadbalance/test-lb.sh normal
bash scripts/loadbalance/stop-server.sh B
bash scripts/loadbalance/test-lb.sh failover
bash scripts/loadbalance/start-server.sh B
bash scripts/loadbalance/test-lb.sh recovered
bash scripts/loadbalance/stop-lb.sh
```

负载均衡器监听8080，三个后端分别监听8101、8102、8103。所有服务都位于同一个Codespace，不能替代真实多物理机故障实验。
