# 第5章《计算虚拟化》实践作业（三）— CNB 教学入口

**状态：学生指导书及代码已编写，待教师在 CNB 实际完成 Docker 运行验收；尚未正式向全班发布。**

适用：云计算技术及应用；180分钟；100分；浏览器 WebIDE + Linux 终端；无需本机虚拟机。

## 学生学习资料

- **主指导书：** [第5章计算虚拟化综合实践](labs/06-计算虚拟化综合实践.md)
- [Docker镜像定义](labs/ch05/Dockerfile)
- [原理模拟程序](scripts/virtualization/simulate.py)
- [环境检查](scripts/virtualization/check-env.sh)
- [专用清理脚本](scripts/virtualization/cleanup.sh)

## 教师首次验收（在 CNB 自己的工作区中）

~~~bash
cd /workspace
bash scripts/virtualization/check-env.sh
python3 scripts/virtualization/simulate.py
docker pull alpine:3.22
docker build -f labs/ch05/Dockerfile -t ch5-image:1.0 .
docker run --rm ch5-image:1.0
docker run -d --name ch5-demo alpine:3.22 sh -c 'while :; do sleep 10; done'
docker run -d --name ch5-limited --cpus=0.50 --memory=128m --pids-limit=64 alpine:3.22 sh -c 'while :; do sleep 10; done'
docker inspect --format 'NanoCpus={{.HostConfig.NanoCpus}} Memory={{.HostConfig.Memory}}' ch5-limited
docker exec ch5-limited sh -c 'cat /sys/fs/cgroup/cpu.max 2>/dev/null || true; cat /sys/fs/cgroup/memory.max 2>/dev/null || true'
docker volume create ch5-data
docker run --rm -v ch5-data:/lesson alpine:3.22 sh -c 'echo chapter5-volume-ok > /lesson/record.txt'
docker run --rm -v ch5-data:/lesson alpine:3.22 cat /lesson/record.txt
bash scripts/virtualization/cleanup.sh
~~~

请逐条执行，不要一次性批量粘贴。确认：
- 预检查 PASS；
- 模拟程序 PASS；
- 自定义镜像输出 CH5_IMAGE_OK；
- 资源限制参数和 cgroup 观察正常；
- Volume 可跨临时容器读取；
- 清理脚本成功。

若 Docker 不可用，请检查 CNB 仓库根目录 .cnb.yml 的 services 是否包括 docker；不要让学生自行安装 Docker daemon。Docker Hub 拉取受网络条件影响，必要时由教师将已验证的基础镜像通过可信仓库存储后再发给全班。

**注意：** Docker 是容器化技术，不能等同于 Xen/KVM 虚拟机。本实验不安装/启动真实VM，也不会修改之前第三、四章的HDFS脚本。

## CNB 与 GitHub 源仓库同步

本文件及本章脚本首发在 GitHub 源仓库的 main 分支。如果 CNB 已从该仓库导入，且随后在 CNB 单独新增了学生指导文件，请不要执行 git reset --hard 或直接整体覆盖 README。

教师应从源仓库 FETCH_HEAD **只检出本章新增文件**并提交到 CNB；具体操作见本次工作完成时的教师迁移命令。

仓库：
- CNB 学生仓库：https://cnb.cool/cloud-computing-lab/cloud-computing-hadoop-lab
- 源仓库：https://github.com/lwq-l/cloud-computing-hadoop-lab
