# 第5章《计算虚拟化》实践作业（三）

**课程正式指导资料。** 教师端已通过 CNB Docker 环境、教学镜像构建、容器创建与运行、Docker 配额参数读取及数据卷读写等核心功能的实测。学生实际可否启动个人工作区、工作区回收后的数据保留情况，仍以各自账号和教师安排为准。

课程：《云计算技术及应用》；180分钟；100分；个人独立完成；浏览器上机；提交 PDF 实验报告。

## 学生入口与学习资料

CNB 课程仓库：https://cnb.cool/cloud-computing-lab/cloud-computing-hadoop-lab

- 第五章完整学生指导：labs/06-计算虚拟化综合实践.md
- 教学镜像：labs/ch05/Dockerfile
- 理论机制模拟：scripts/virtualization/simulate.py
- 环境检查：scripts/virtualization/check-env.sh
- 本章清理：scripts/virtualization/cleanup.sh

学生登录 CNB 后，需进入教师提供的**个人可开发仓库或个人工作区**。不能将教师的临时 WebIDE 地址作为全班共用入口。正式课程要求与截止时间以学习通作业模块为准。

## 教师已完成的功能验证

依据 2026年11月3日 CNB 终端运行记录：

| 项目 | 已有结果 |
|---|---|
| Docker 服务 | Client 29.6.2；Server 29.6.2-7 |
| 教学模型程序 | PASS: CH5 conceptual simulation complete. |
| Alpine基础镜像 | alpine:3.22 拉取成功 |
| 自定义镜像 | CH5_IMAGE_OK |
| 后台容器 | ch5-demo 可运行，docker exec 正常 |
| CPU、内存与进程数配置 | NanoCpus=500000000；MemoryBytes=134217728；PidsLimit=64 |
| 数据卷 | chapter5-volume-ok 跨容器读取成功 |

**重要：** 当前环境报告 Cgroup driver=none、cgroup version=1。配额参数配置成功并不证明内核已经对 CPU、内存和进程数实施强制限制。第五章任务五按“配置读取、环境观察、机制解释”考核，不设置高负载/耗尽测试。

## 复测方法

在 CNB 开发容器终端逐条运行：

~~~bash
cd /workspace
bash scripts/virtualization/check-env.sh
python3 scripts/virtualization/simulate.py
~~~

如果需要独立复测本章完整操作，可以运行以下**教师辅助核查脚本**：

~~~bash
bash scripts/virtualization/verify-ch05.sh
~~~

该脚本使用带唯一后缀的临时容器、镜像标签和数据卷，退出时清理自身创建的资源，不删除其他章节数据。**脚本已提交源码，尚无来自CNB的新一轮运行记录；其输出不能提前标注通过。** 也可以按上述学生指导书逐项测试。

正式上机过程中如遇镜像拉取或 Docker 服务连接问题，保留错误输出并联系教师，不要求学生自行安装 Docker、修改宿主机或创建虚拟机。

## 教学说明

Docker 容器不是 Xen/KVM 虚拟机。资源配额是容器管理配置，不能据此证明 Xen/KVM 的 CPU、内存或 I/O 虚拟化机制。学生报告应如实说明观察到的现象与技术边界。

GitHub 源仓库：https://github.com/lwq-l/cloud-computing-hadoop-lab
