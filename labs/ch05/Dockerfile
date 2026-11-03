# 第5章教学镜像：不安装新软件，不暴露端口，不需要特权容器
FROM alpine:3.22
LABEL org.opencontainers.image.title="Cloud Computing Chapter 5 Lab"
WORKDIR /opt/lesson
COPY data/virtualization/lesson.txt /opt/lesson/lesson.txt
CMD ["sh", "-c", "echo 'CH5_IMAGE_OK'; cat /opt/lesson/lesson.txt"]
