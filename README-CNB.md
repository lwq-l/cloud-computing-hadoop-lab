# 国内网页实验环境迁移说明（CNB 候选方案）

> 状态：**已准备配置，尚未完成 CNB 平台实际登录、迁移与运行验收**。
> 请不要把本文件视为“已上线的学生入口”。

本仓库保留原有 GitHub Codespaces 入口，并另外提供 CNB 云原生开发的
`.cnb.yml` 试运行配置。CNB 可在同一网站托管 Git 仓库、构建 Docker 镜像、
提供浏览器内 VS Code 与 Linux 终端。仓库原有镜像为
`ghcr.io/apache/hadoop:3.5.0`；**国内平台能否拉取、是否能运行 Hadoop
必须先由教师验证**。

## 迁移步骤（教师）

1. 登录 https://cnb.cool ，在个人组织内创建仓库或使用官方代码导入工具：
   https://cnb.cool/cnb/plugins/cnbcool/code-import
2. 源仓库为 `https://github.com/lwq-l/cloud-computing-hadoop-lab`，
   导入其 `main` 分支，确保下列文件完整。
3. 在 CNB 仓库分支页面点击“云原生开发”。`.cnb.yml` 将申请 4 vCPU/8GiB，
   使用 `.devcontainer/Dockerfile` 构建镜像，并执行
   `bash scripts/preflight-cnb.sh`。
4. 选择 WebIDE 中的 **CNB** 终端（双容器模式时为开发容器终端），
   确认 `pwd` 位于仓库根目录，执行下面的验收命令。
5. **未完成验收前，不向学生发布可运行承诺。**

### 第3章——HDFS 基础

```bash
bash scripts/preflight-cnb.sh
bash scripts/start-hdfs.sh
jps
hdfs dfsadmin -report
hdfs dfs -mkdir -p /cloudlab/input
hdfs dfs -put -f data/hello.txt /cloudlab/input/
hdfs dfs -cat /cloudlab/input/hello.txt
hdfs fsck /cloudlab/input/hello.txt -files -blocks -locations
bash scripts/stop-hdfs.sh
```

验收标准：版本正确；NameNode、DataNode、SecondaryNameNode
启动；`Live datanodes (1)`；上传、读取成功。

学生资料：
- `labs/01-HDFS基础操作.md`
- `labs/02-NameNode与DataNode.md`
- `labs/03-Block与副本机制.md`

### 第4章——硬件、三 DataNode、负载均衡综合实践

```bash
bash scripts/multinode/setup-multinode.sh
bash scripts/multinode/start-multinode.sh
bash scripts/multinode/status-multinode.sh
. "$HOME/hadoop-multi/activate.sh"
hdfs dfs -mkdir -p /multilab/input
hdfs dfs -put -f data/hello.txt /multilab/input/
hdfs fsck /multilab/input/hello.txt -files -blocks -locations
bash scripts/multinode/stop-one-datanode.sh 2
bash scripts/multinode/status-multinode.sh
hdfs dfs -cat /multilab/input/hello.txt
bash scripts/multinode/start-one-datanode.sh 2
bash scripts/multinode/status-multinode.sh
bash scripts/loadbalance/start-lb.sh
bash scripts/loadbalance/test-lb.sh normal
bash scripts/loadbalance/stop-server.sh B
bash scripts/loadbalance/test-lb.sh failover
bash scripts/loadbalance/start-server.sh B
bash scripts/loadbalance/test-lb.sh recovered
bash scripts/loadbalance/stop-lb.sh
bash scripts/multinode/stop-multinode.sh
```

验收标准：实际状态显示 `Live datanodes (3)`、三副本、
停掉第二个 DataNode 后仍可读取、恢复到3个 DataNode；
负载均衡测试出现 `PASS: normal`、`PASS: failover`、
`PASS: recovered`。

学生资料：`labs/04-多节点HDFS与副本容错.md`、
`labs/05-云计算硬件资源与负载均衡综合实践.md`。
**注意：原来的指导书部分内容仍写着 GitHub Codespaces，
而且第四章原稿有过时的客户端激活命令。迁移验收后必须同步修改。**

## 数据保存与班级使用警告

- CNB 的开发工作区可能在闲置时被回收。现有脚本把单节点 HDFS 写入
  `$HOME/hdfs-data`，把多节点 HDFS 写入 `$HOME/hadoop-multi`，
  这些都在仓库 `/workspace` **以外**；不能假定会自动持久保存。
- CNB 的工作区自动备份面向 `/workspace` 未提交变更，
  且存在 **100MB** 的文件及备份体积限制；不能把这等同于 HDFS
  数据可靠持久化。学生必须及时保存实验截图和 PDF 报告，
  避免关闭窗口后失去运行时数据。
- 一个分支的工作区备份只保留一份。**不能让全班共用同一仓库的
  同一分支执行实验**；应为每名学生提供独立仓库或独立分支。
- 需核实组织的免费核时余额和并发额度。4核环境每学生运行3小时
  预计消耗12核时，30名学生为360核时，另外计入镜像构建和其他使用。
  平台官方标示每组织每月1600核时免费云原生开发额度，实际以账号为准。
- CNB 对基于 Dockerfile 的自定义镜像提供“双容器”运行模式，
  WebIDE 默认 CNB 终端连接开发容器，不要误用 code-server 容器。
- 教师应先使用两个独立测试学生身份核实并发、访问权限、脚本输出、
  工作空间回收与重建行为，再发布给全班。

平台官方文档：
- https://docs.cnb.cool/zh/workspaces/custom-dev-env.html
- https://docs.cnb.cool/zh/guide/migration-tools.html
- https://docs.cnb.cool/zh/workspaces/file-keeper.html
- https://docs.cnb.cool/zh/saas/pricing.html
