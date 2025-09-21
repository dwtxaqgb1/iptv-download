FROM python:3.9-alpine
WORKDIR /app
# 安装下载依赖和时区工具
RUN apk add --no-cache curl tzdata
# 设置时区（和本地一致，避免定时时间偏差）
ENV TZ=Asia/Shanghai
# 复制启动脚本到容器
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh
# 创建容器内下载目录
RUN mkdir -p /downloads
# 容器启动时执行的命令
CMD ["/app/start.sh"]
