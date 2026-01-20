#!/bin/bash

# Configuration
IMAGE_NAME="zhousir11/discord-follower"
TAG="amd64-V1.5.1"
CONTAINER_NAME="discord-follower"
DATA_DIR="/opt/discord-follower/data"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Discord Follower 一键安装/更新脚本 ===${NC}"

# 1. Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}未检测到 Docker，正在安装...${NC}"
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    echo -e "${GREEN}Docker 安装完成${NC}"
else
    echo -e "${GREEN}Docker 已安装${NC}"
fi

# 2. Prepare Directories
echo -e "${YELLOW}正在准备数据目录...${NC}"
mkdir -p "$DATA_DIR/logs"
if [ ! -f "$DATA_DIR/config_store.json" ]; then
    echo "{}" > "$DATA_DIR/config_store.json"
    echo -e "已创建初始配置文件"
else
    echo -e "保留现有配置文件"
fi
if [ ! -f "$DATA_DIR/binance_follower.db" ]; then
    touch "$DATA_DIR/binance_follower.db"
    echo -e "已创建空数据库文件"
else
    echo -e "保留现有数据库"
fi

# 3. Pull Image
FULL_IMAGE="$IMAGE_NAME:$TAG"
echo -e "${YELLOW}正在拉取最新镜像: $FULL_IMAGE ...${NC}"
docker pull "$FULL_IMAGE"

# 4. Remove Old Container
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo -e "${YELLOW}正在停止并移除旧容器...${NC}"
    docker rm -f $CONTAINER_NAME 2>/dev/null
fi

# 5. Run New Container
echo -e "${YELLOW}正在启动新容器...${NC}"
docker run -d --name $CONTAINER_NAME \
  --restart always \
  -p 8000:8000 \
  -v "$DATA_DIR/config_store.json":/app/config_store.json \
  -v "$DATA_DIR/binance_follower.db":/app/binance_follower.db \
  -v "$DATA_DIR/logs":/app/logs \
  "$FULL_IMAGE"

# 6. Success Message
if [ $? -eq 0 ]; then
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}✅ 安装/更新成功！${NC}"
    echo -e "容器名称: $CONTAINER_NAME"
    echo -e "镜像版本: $TAG"
    echo -e "访问地址: http://服务器IP:8000/"
    echo -e "${GREEN}==========================================${NC}"
else
    echo -e "${RED}❌ 启动失败，请检查上方错误信息${NC}"
fi
