# 《云计算技术及应用》第3、4章 CNB 学生上机指南（教师端已验收）

> 本文为 CNB 平台教学指导。第三、四章实验已完成教师端功能验证。学生须进入教师安排的个人工作区操作；浏览器地址中的临时工作区不是全班共用入口。
>
> 上机需要：中国国内网络、浏览器、登录 CNB 的账号。无需在自己的电脑安装虚拟机、Linux、Java 或 Hadoop。

## 学生进入实验环境

1. 点击教师提供的 **CNB 正式仓库链接**，不要访问原 GitHub Codespaces 按钮。
2. 登录 CNB，并使用老师指定的个人仓库/个人分支。如果没有创建云原生开发权限，联系教师安排独立仓库；**不要让全班共用一个分支**。
3. 在分支页面点击 **云原生开发**，进入 WebIDE。自定义 Hadoop 镜像采用双容器方式时，打开命名为 **CNB** 的跨容器终端，而不是 code-server 自带终端。
4. 执行：
   ```bash
   pwd
   ls labs scripts data
   bash scripts/preflight-cnb.sh
   ```
   终端需要位于仓库根目录，例如 `/workspace`；如果不在仓库目录，先使用 `cd` 进入，而不是机械照抄原 Codespaces 路径。
5. 观察基本环境是否通过，必须看到 `PASS: basic tooling and chapter 3/4 scripts found.`。**这一输出仅表示环境命令和文件存在，并不意味着后续 HDFS 已运行通过。**

## 第3章实践作业（一）——HDFS 基础

终端依次输入命令：

```bash
java -version
hadoop version
bash scripts/start-hdfs.sh
jps
hdfs dfsadmin -report
```

应实际看到：NameNode、DataNode、SecondaryNameNode；`Live datanodes (1)`。

```bash
hdfs dfs -mkdir -p /cloudlab/input
hdfs dfs -put -f data/hello.txt /cloudlab/input/
hdfs dfs -ls /cloudlab/input
hdfs dfs -cat /cloudlab/input/hello.txt
hdfs fsck /cloudlab/input/hello.txt -files -blocks -locations
```

保留老师要求的截图，理解本地 Linux 文件与 HDFS 文件位置的区别。

第3章分项指导：`labs/01-HDFS基础操作.md`、`labs/02-NameNode与DataNode.md`、`labs/03-Block与副本机制.md`。

**结束第三章后，如果马上做第四章，请先停止单节点：**

```bash
bash scripts/stop-hdfs.sh
```

## 第4章实践作业（二）——服务器资源、HDFS 三节点和负载均衡

### 环境和资源观察

```bash
hostname
uname -a
nproc
free -h
df -h .
```

观察服务器的计算资源并完成老师发布的 RAID、DAS/NAS/SAN 理论分析题。

### HDFS 三节点与副本容错

```bash
bash scripts/multinode/setup-multinode.sh
bash scripts/multinode/start-multinode.sh
bash scripts/multinode/status-multinode.sh
```

实际输出应有 `Live datanodes (3)`。

**下面用单独的一条带英文句点的命令激活多节点客户端：**

```bash
. "$HOME/hadoop-multi/activate.sh"
```

```bash
hdfs dfs -mkdir -p /multilab/input
hdfs dfs -put -f data/hello.txt /multilab/input/
hdfs fsck /multilab/input/hello.txt -files -blocks -locations
```

重点观察三份副本。停止并恢复第二个 DataNode：

```bash
bash scripts/multinode/stop-one-datanode.sh 2
bash scripts/multinode/status-multinode.sh
hdfs dfs -cat /multilab/input/hello.txt
bash scripts/multinode/start-one-datanode.sh 2
bash scripts/multinode/status-multinode.sh
```

检查：运行时实际上出现在线节点数 `3 → 2 → 3`，停掉一个节点后仍可读到文件。

网络观察：

```bash
hostname -I
curl -I http://127.0.0.1:9870/
```

### 三台模拟 Web 服务的轮询与故障切换

```bash
bash scripts/loadbalance/start-lb.sh
bash scripts/loadbalance/status-lb.sh
bash scripts/loadbalance/test-lb.sh normal
bash scripts/loadbalance/stop-server.sh B
bash scripts/loadbalance/status-lb.sh
bash scripts/loadbalance/test-lb.sh failover
bash scripts/loadbalance/start-server.sh B
bash scripts/loadbalance/test-lb.sh recovered
bash scripts/loadbalance/stop-lb.sh
```

三个测试应分别出现 `PASS: normal`、`PASS: failover`、`PASS: recovered`。

**第四章综合实践提交**：按学习通最新发布要求准备 12 张真实截图、RAID 计算、服务器/存储方案、架构图、简答与总结，上传 PDF；只提交一份综合作业，无需把仓库里的 02/03/04/05 分别上交。

实验结束可以执行：

```bash
bash scripts/multinode/stop-multinode.sh
```

## 故障与作业保存注意事项

- Hadoop 三个 DataNode 只是同一开发环境中的三个**独立进程**，不是三台物理服务器。
- CNB 环境可能因闲置被销毁。HDFS 数据目录在 `$HOME` 下，默认**不属于 `/workspace` 代码自动备份范围**；关闭环境后 HDFS 数据可能丢失。
- 每个任务完成后，立刻把真实截图保存到**自己电脑**，在 Word 中逐步写报告，不要等最后才整理。
- 如看到 `Connection refused`，先检查 HDFS 状态和端口，不要运行 reset 脚本或删除 HDFS 数据目录。
- 发现环境无法打开、启动失败或反复重启，请保留终端错误截图，反馈老师。不要为了凑截图伪造运行结果。

**这是迁移适配说明，老师还需要在 CNB 上完成实际全流程测试后才能下发。**
