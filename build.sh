#!/bin/bash

# 定义变量
PROJECT_NAME="iptv-download"
REPO_URL="https://github.com/dwtxaqgb1/iptv-download.git"
IMAGE_NAME="iptv-download"
CONTAINER_NAME="iptv-download"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未安装Docker，请先安装Docker"
    exit 1
fi

# 克隆或更新代码
if [ ! -d "$PROJECT_NAME" ]; then
    echo "克隆项目仓库..."
    git clone "$REPO_URL" "$PROJECT_NAME" || {
        echo "克隆仓库失败"
        exit 1
    }
else
    echo "更新项目代码..."
    cd "$PROJECT_NAME" && git pull && cd .. || {
        echo "更新代码失败"
        exit 1
    }
fi

# 构建镜像
echo "构建Docker镜像..."
cd "$PROJECT_NAME" || exit 1
docker build -t "$IMAGE_NAME" . || {
    echo "构建镜像失败"
    exit 1
}
cd ..

# 停止并删除现有容器
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "停止并删除现有容器..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# 运行新容器（类似你要求的格式）
echo "启动新容器..."
docker run -d \
    -p $PORT:$PORT \
    --restart=always \
    --name="$CONTAINER_NAME" \
    "$IMAGE_NAME"

# 显示结果
echo "部署完成！"
docker ps -f name="$CONTAINER_NAME"
