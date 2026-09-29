# 实验一：HDFS 基础操作

## 1. 实验目标

掌握 HDFS Shell 的基本命令，并能够区分 Linux 本地文件系统与 HDFS。

## 2. 环境检查

```bash
java -version
hadoop version
bash scripts/start-hdfs.sh
jps
```

记录 Hadoop 与 Java 版本。确认 `jps` 中至少出现 NameNode、DataNode、SecondaryNameNode。

## 3. 查看与创建目录

```bash
hdfs dfs -ls /
hdfs dfs -mkdir -p /cloudlab/input
hdfs dfs -ls /cloudlab
```

**思考：** `hdfs dfs -ls /` 中的 `/` 和 Linux 的 `ls /` 是否是同一个目录？

## 4. 创建本地文件

```bash
echo "Hello Hadoop" > hello.txt
cat hello.txt
ls -l hello.txt
```

此时 `hello.txt` 位于 Linux 本地文件系统。

## 5. 上传到 HDFS

```bash
hdfs dfs -put -f hello.txt /cloudlab/input/
hdfs dfs -ls /cloudlab/input
```

## 6. 从 HDFS 读取文件

```bash
hdfs dfs -cat /cloudlab/input/hello.txt
```

## 7. 删除 HDFS 文件

```bash
hdfs dfs -rm /cloudlab/input/hello.txt
hdfs dfs -ls /cloudlab/input
```

## 8. 提交要求

提交 3 张关键截图：

1. `hadoop version` 与 `jps`；
2. 创建目录并上传成功；
3. `hdfs dfs -cat` 读取成功。

并用 80–120 字说明“本地文件系统”和“HDFS”路径的区别。
