# CNB 国内网页实验环境使用说明

> 状态：**第三、四章及第五章核心实验已完成教师端功能测试。** 学生必须使用具有开发权限的个人工作区；教师临时 WebIDE 地址不作为全班共享入口。
> 注意：CNB 的工作区回收与学生账户权限仍需在各学生账户中确认。

本仓库保留原有 GitHub Codespaces 入口，并另外提供 CNB 云原生开发的
`.cnb.yml` 云端开发配置。CNB 可在同一网站托管 Git 仓库、构建 Docker 镜像、
提供浏览器内 VS Code 与 Linux 终端。仓库原有镜像为
`ghcr.io/apache/hadoop:3.5.0`；教师已在 CNB 成功运行 Hadoop/HDFS 及负载均衡脚本。

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
5. 上机前应使用学生测试账号确认个人工作区启动权限、资源额度与重进后的数据情况。

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
