#!/bin/bash

# 设置颜色和样式
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 进度条函数
show_progress() {
    local width=50  # 固定宽度为50个字符
    
    echo -n "[" 
    for ((i=0; i<width; i++)); do 
        echo -n " " 
    done
    echo -n "] 0%"
    
    for ((i=0; i<=width; i++)); do
        progress=$((i * 100 / width))
        echo -ne "\r["
        for ((j=0; j<i; j++)); do
            echo -n "▓"
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
 ██████╗ ███████╗██╗    ██╗███████╗ ██████╗██╗  ██╗ █████╗ ████████╗
██╔════╝ ██╔════╝██║    ██║██╔════╝██╔════╝██║  ██║██╔══██╗╚══██╔══╝
██║  ███╗█████╗  ██║ █╗ ██║█████╗  ██║     ███████║███████║   ██║   
██║   ██║██╔══╝  ██║███╗██║██╔══╝  ██║     ██╔══██║██╔══██║   ██║   
╚██████╔╝███████╗╚███╔███╔╝███████╗╚██████╗██║  ██║██║  ██║   ██║   
 ╚═════╝ ╚══════╝ ╚══╝╚══╝ ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   
  开发者：夜屿 (QQ: 1706691925) & 烤花生啊 (QQ: 2823264360, QQ 群: 1003909914)
EOF
echo -e "${NC}"
echo -e "${BLUE}${BOLD}微信机器人部署系统 - 高级安装向导${NC}\n"

# 检查 Docker 是否安装
echo -e "${CYAN}[1/5]${NC} 检查系统环境..."
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker 未安装，正在安装...${NC}"
    # 更新包列表
    apt-get update
    # 安装必要的包
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    # 添加 Docker 的官方 GPG 密钥
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    # 设置稳定版仓库
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    # 安装 Docker
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
fi
show_progress 100

# 检查并创建必要的目录
echo -e "\n${CYAN}[2/5]${NC} 创建必要目录..."
mkdir -p /root/temp
show_progress 50

# 配置 Docker 镜像加速
echo -e "\n${CYAN}[3/5]${NC} 配置 Docker 加速器..."
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
systemctl daemon-reload
systemctl restart docker
show_progress 100

# 拉取镜像
echo -e "\n${CYAN}[4/5]${NC} 拉取 Gewechat 镜像..."
docker pull registry.cn-chengdu.aliyuncs.com/tu1h/wechotd:alpine
docker tag registry.cn-chengdu.aliyuncs.com/tu1h/wechotd:alpine gewe

# 创建 Docker 网络（如果不存在）
if ! docker network inspect astrbot_default >/dev/null 2>&1; then
    docker network create astrbot_default
fi

# 启动容器
echo -e "\n${CYAN}[5/5]${NC} 启动 Gewechat 容器..."
if docker ps -a | grep -q "gewe"; then
    docker rm -f gewe
fi

mkdir -p /root/temp
docker run -itd \
    -v /root/temp:/root/temp \
    -p 2531:2531 \
    -p 2532:2532 \
    --name=gewe \
    gewe

# 设置开机自启
docker update --restart=always gewe

# 获取本地IP
LOCAL_IP=$(ip addr show | grep -w inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)

# 如果本地IP以17开头，直接使用
if echo "$LOCAL_IP" | grep -q "^17"; then
    SERVER_IP=$LOCAL_IP
else
    # 否则获取本地IP的第三段
    LOCAL_IP=$(echo "$LOCAL_IP" | grep ^192)
    SUBNET=$(echo "$LOCAL_IP" | cut -d. -f3)
    # 查找对应的 17X.${SUBNET} 开头的IP
    SERVER_IP=$(ifconfig | grep -B1 "inet 17" | grep inet | awk '{print $2}' | grep "^17.*\.${SUBNET}\.")
fi

# 显示完成界面
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
✨ 部署完成！Gewechat 已成功启动 ✨
EOF
echo -e "${NC}"

echo -e "${CYAN}==================================${NC}"
echo -e "${BOLD}API 服务调用地址：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:2531/v2/api/{接口名}${NC}"
echo -e "\n${BOLD}文件下载地址：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:2532/download/{接口返回的文件路径}${NC}"
echo -e "${CYAN}==================================${NC}"

echo -e "\n${GREEN}服务状态：${NC}"
docker ps | grep gewe

echo -e "\n${YELLOW}提示：${NC}"
echo -e "1. 如需查看日志，请使用命令：${BOLD}docker logs -f gewe${NC}"
echo -e "2. 如需停止服务，请使用命令：${BOLD}docker stop gewe${NC}"
echo -e "3. 如需重启服务，请使用命令：${BOLD}docker restart gewe${NC}"

exit 0
