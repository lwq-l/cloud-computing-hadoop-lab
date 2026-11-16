# 第6章网络与存储虚拟化：CNB 教学说明

课程仓库：https://cnb.cool/cloud-computing-lab/cloud-computing-hadoop-lab

- **学生完整指导书**：[labs/07-网络和存储虚拟化综合实践.md](labs/07-网络和存储虚拟化综合实践.md)
- **学习通发布正文**：[labs/学习通发布正文-第6章实践作业四.md](labs/学习通发布正文-第6章实践作业四.md)
- **环境检查**：scripts/ch06/check-env.sh
- **Docker虚拟网络**：scripts/ch06/network-demo.sh
- **网络受限时的回环HTTP备用实验**：scripts/ch06/network-fallback.py
- **网络机制模拟**：scripts/ch06/network-sim.py
- **稀疏文件、快照与链接克隆概念演示**：scripts/ch06/storage-demo.py
- **云存储三类型演示**：scripts/ch06/cloud-storage-demo.py
- **资源清理**：scripts/ch06/cleanup.sh
- **教师核查**：scripts/ch06/verify-ch06.sh

## 教师端优先执行

在CNB的**实验容器终端**逐条输入：

~~~bash
cd /workspace
~~~

~~~bash
bash scripts/ch06/check-env.sh
~~~

~~~bash
bash scripts/ch06/verify-ch06.sh
~~~

最后一条脚本会创建带唯一标识的临时Docker资源，并在退出时清理该脚本创建的容器、网络和卷。不执行全局清理，也不重置第三至五章的数据。

**运行边界与通过标准**：

1. 环境检查PASS，Docker客户端/服务端可用。
2. 网络示例允许两种合格结果：真实自定义bridge网络通信成功并显示 `MODE=BRIDGE_VERIFIED`，或者在CNB网络受限时显示 `BRIDGE_UNAVAILABLE` / `BRIDGE_UNUSABLE` / `invalid IP`，并用Python完成回环HTTP（200）与应用层拒绝访问（403）的备用实验。**仅网络创建成功不能视为网络通信成功；备用HTTP不代表Docker网络隔离成功。**
3. Python虚拟交换模拟、稀疏文件/快照/克隆概念模拟、云存储三类型示例均应输出PASS；当前还没有第六章修订版在CNB中的实测结果。
4. Docker数据卷写入、由其他临时容器读取，返回ch6-volume-ok。
5. 清理脚本只影响本章资源，退出时不留本章测试容器和卷。

**教师端检查记录（2026-11-16）**：用户CNB终端已确认 Docker 29.9.2 运行、基础镜像拉取成功、bridge网络对象和容器创建成功，但容器出现 `ContainerIP=invalid IP`，同网DNS请求报 `wget: bad address`，因此**原版教师验收在第三项中断，并未通过**。现已升级脚本，遇到无效IP或实际通信失败会运行本机回环HTTP与应用访问规则的备用实验。**修订版尚未在CNB再次实测，正式判定前请重新同步、运行教师验收。**

## 第六章与PPT的对应关系

- 网络分类：虚拟网卡、软件虚拟交换、硬件设备虚拟化、虚拟网络；
- 网络实现：Docker bridge（实际教学容器网络），VLAN/VPN/SDN/NFV（概念与示意，不配置真实设备）；
- 存储功能：稀疏文件代表精简配置思想，独立备份副本示意快照用途，差异映射示意链接克隆（两者不等于真实阵列特性）；
- 存储实现：主机级、设备级、网络级存储虚拟化对比分析；
- 云存储：文件、对象、块的本地教学示例，不连接收费服务。

## 面向班级发布前

需要确认学生账号能单独导入仓库、启动云原生开发和运行Docker。CNB代码备份主要针对工作区，Docker容器、卷和临时环境不保证在工作区回收后长期保留。学生应及时保留截图、分析题和最终PDF。

不要让学生使用教师个人临时WebIDE网址。班级统一使用课程仓库入口及学生自己的可开发仓库。
