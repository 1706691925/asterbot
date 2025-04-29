#!/bin/bash

# 设置颜色和样式
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 显示进度条
progress_bar() {
    local width=50
    local progress=0
    
    echo -n "["
    for ((i=0; i<width; i++)); do
        echo -n " "
    done
    echo -n "] 0%"
    
    for ((i=0; i<=width; i++)); do
        progress=$((i * 100 / width))
        echo -ne "\r["
        for ((j=0; j<i; j++)); do
            echo -n "▒"
        done
        for ((j=i; j<width; j++)); do
            echo -n " "
        done
        echo -n "] $progress%"
        sleep 0.1
    done
    echo
}

# 显示欢迎界面
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
██████╗ ███████╗██╗ ██████╗██╗   ██╗ █████╗ ███╗   ██╗
██╔══██╗██╔════╝██║██╔════╝██║   ██║██╔══██╗████╗  ██║
██████╔╝█████╗  ██║██║     ██║   ██║███████║██╔██╗ ██║
██╔══██╗██╔══╝  ██║██║     ██║   ██║██╔══██║██║╚██╗██║
██████╔╝███████╗██║╚██████╗╚██████╔╝██║  ██║██║ ╚████║
╚═════╝ ╚══════╝╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
EOF
echo -e "${NC}"
echo -e "${BLUE}${BOLD}QQ机器人部署系统 - 高级安装向导${NC}\n"

# 检查 Docker 是否安装
echo -e "${CYAN}[1/5]${NC} 正在检查 Docker 环境..."
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}未安装 Docker，正在安装中...${NC}"
    
    # 更新软件包列表
    apt-get update
    
    # 安装必需的软件包
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # 添加 Docker 官方 GPG 密钥
    curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # 添加 Docker 镜像源
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 更新软件包列表并安装 Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # 配置 Docker 镜像加速
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.1ms.run",
        "https://mirror.ccs.tencentyun.com",
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com"
    ]
}
EOF

    # 重启 Docker 服务
    systemctl daemon-reload
    systemctl restart docker
    
    # 等待 Docker 服务启动完成
    echo -e "${YELLOW}正在等待 Docker 服务就绪...${NC}"
    for i in {1..30}; do
        if docker info &> /dev/null; then
            echo -e "${GREEN}Docker 服务已成功启动${NC}"
            break
        fi
        echo -n "."
        sleep 1
    done
fi

# 进度条显示
progress_bar

# 输入 QQ 账号
echo -e "\n${CYAN}[2/5]${NC} 配置 QQ 账号..."

# 确保终端恢复正常
stty sane

# 清理输入缓存
read -t 1 -n 10000 discard 2>/dev/null || true

# 输入 QQ 账号并验证
while true; do
    exec 3</dev/tty
    printf "${CYAN}请输入 QQ 账号: ${NC}" >/dev/tty
    read -r QQ_ACCOUNT <&3
    exec 3<&-

    # 验证 QQ 账号格式
    if [[ "$QQ_ACCOUNT" =~ ^[1-9][0-9]{4,11}$ ]]; then
        printf "${GREEN}QQ 账号格式正确！${NC}\n" >/dev/tty
        break
    else
        printf "${RED}错误：请输入正确的 QQ 账号（5-12 位数字）${NC}\n" >/dev/tty
    fi
done

# 显示进度
progress_bar

# 配置 Docker 镜像加速器
echo -e "\n${CYAN}[3/5]${NC} 配置 Docker 镜像加速器..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
    "registry-mirrors": [
        "https://docker.1ms.run",
        "https://mirror.ccs.tencentyun.com",
        "https://hub-mirror.c.163.com",
        "https://mirror.baidubce.com"
    ],
    "dns": ["223.5.5.5", "223.6.6.6", "8.8.8.8"]
}
EOF

# 重启 Docker 服务
systemctl daemon-reload
systemctl restart docker
progress_bar

# 创建 Docker 网络
echo -e "\n${CYAN}[4/5]${NC} 配置 Docker 网络..."
if ! docker network inspect astrbot_default >/dev/null 2>&1; then
    docker network create astrbot_default
fi
progress_bar

# 启动容器
echo -e "\n${CYAN}[5/5]${NC} 启动 Napcat 容器..."
if docker ps -a | grep -q "napcat"; then
    docker rm -f napcat
fi

# 拉取镜像并启动容器
echo -e "${YELLOW}正在拉取 Docker 镜像...${NC}"
if ! docker pull mlikiowa/napcat-docker:latest; then
    echo -e "${RED}无法拉取镜像，请检查网络或稍后重试！${NC}"
    exit 1
fi

# 运行容器
docker run -d \
    -e ACCOUNT="$QQ_ACCOUNT" \
    -e WS_ENABLE=true \
    -e NAPCAT_GID=0 \
    -e NAPCAT_UID=0 \
    -p 3001:3001 \
    -p 6099:6099 \
    --name napcat \
    --network=astrbot_default \
    --restart=always \
    mlikiowa/napcat-docker:latest

# 等待容器启动
sleep 3

# 获取容器ID
CONTAINER_ID=$(docker ps -q -f name=napcat)

# 配置容器内文件
echo -e "\n${CYAN}配置文件...${NC}"
CONFIG_FILE="/napcat/config/napcat_${QQ_ACCOUNT}.json"
docker exec -i "$CONTAINER_ID" /bin/bash -c "cat > $CONFIG_FILE" << EOF
{
  "network": {
    "websocketClients": [
      {
        "enable": true,
        "url": "ws://${SERVER_IP}:6099/ws"
      }
    ]
  }
}
EOF

# 获取 WebUI Token
echo -e "${YELLOW}获取 WebUI Token...${NC}"
WEBUI_TOKEN="napcat"

# 获取 WebUI Token 配置
WEBUI_TOKEN=$(docker exec -i "$CONTAINER_ID" /bin/bash -c "cat /napcat/config/webui.json" 2>/dev/null | grep -o '"token": "[^"]*"' | cut -d'"' -f4)

# 获取本地IP
LOCAL_IP=$(ip addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)

# 显示完成信息
clear
echo -e "${GREEN}${BOLD}部署完成！Napcat 已成功启动！${NC}"
echo -e "${CYAN}=================================${NC}"
echo -e "${BOLD}服务信息：${NC}"
echo -e "${BLUE}▶ QQ 账号：${QQ_ACCOUNT}${NC}"
echo -e "${BLUE}▶ WebSocket 地址：ws://${SERVER_IP}:6099${NC}"
echo -e "${CYAN}=================================${NC}"

exit 0
