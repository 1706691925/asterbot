#!/bin/bash

# 设置颜色和样式
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 进度条函数
show_progress() {
    local width=50
    local progress=0
    local i

    echo -n "["
    for ((i=0; i<width; i++)); do
        echo -n " "
    done
    echo -n "] 0%"

    for ((i=1; i<=width; i++)); do
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
echo -e "${CYAN}${BOLD}智能机器人部署系统 - 高级安装向导${NC}"
echo -e "${CYAN}开发者：1. 夜屿 (QQ: 1706691925) | 2. 烤花生啊 (QQ: 2823264360) | 群：1003909914${NC}\n"

# 系统初始化检查
echo -e "${CYAN}[1/4]${NC} 系统初始化检查..."
show_progress

# 配置系统环境
echo -e "\n${CYAN}[2/4]${NC} 配置系统环境..."

# 更新软件包列表
echo -e "${YELLOW}更新系统软件包列表...${NC}"
apt-get update &> /dev/null

# 检查 git 是否已安装
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓ git 已安装: $(git --version)${NC}"
else
    # 安装 git
    echo -e "${YELLOW}安装 git...${NC}"
    if ! apt-get install -y git &> /dev/null; then
        echo -e "${RED}apt 安装 git 失败${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ git 安装成功: $(git --version)${NC}"
fi



show_progress

# Docker 服务检查和启动函数
check_docker_service() {
    echo -e "${YELLOW}检查 Docker 服务状态...${NC}"

    # 如果 Docker 已经在运行，直接返回
    if docker info &> /dev/null; then
        echo -e "${GREEN}Docker 服务已在运行${NC}"
        return 0
    fi

    # 检查 Docker 是否安装
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker 未安装，请先安装 Docker${NC}"
        return 1
    fi

    # 启动 Docker 服务
    echo -e "${YELLOW}启动 Docker 服务...${NC}"
    systemctl start docker.service || {
        echo -e "${RED}Docker 启动失败，查看详细日志：${NC}"
        journalctl -xe --unit docker.service | tail -n 20
        return 1
    }

    # 等待服务就绪，设置超时
    for i in {1..5}; do
        if docker info &> /dev/null; then
            echo -e "${GREEN}Docker 服务已就绪${NC}"
            return 0
        fi
        echo -n "."
        sleep 2
    done

    echo -e "${RED}Docker 服务启动超时${NC}"
    return 1
}

# 重启 Docker 服务并等待就绪
echo -e "\n${CYAN}[4/4]${NC} 应用配置并启动服务..."
systemctl daemon-reload
systemctl restart docker

# 等待 Docker 服务就绪，设置超时
echo -e "${YELLOW}等待 Docker 服务就绪...${NC}"
for i in {1..60}; do
    if docker info &> /dev/null; then
        break
    fi
    sleep 2
done

# 切换到根目录
cd /root || exit 1
echo -e "\n${BOLD}开始部署 AstrBot...${NC}"

# 删除可能存在的旧目录
if [ -d "/AstrBot" ]; then
    rm -rf /AstrBot
fi

# 拉取指定的官方镜像
echo -e "${YELLOW}拉取官方 AstrBot 镜像...${NC}"
docker pull soulter/astrbot:latest || {
    echo -e "${RED}拉取镜像失败${NC}"
    exit 1
}


# 创建文件夹
mkdir astrbot

#开始部署
echo -e "${YELLOW}创建docker容器...${NC}"
sudo docker run -itd -p 6180-6200:6180-6200 -p 11451:11451 -v $PWD/data:/AstrBot/data -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro --name astrbot soulter/astrbot:latest


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
✨ 部署完成！AstrBot 已成功启动 ✨
EOF
echo -e "${NC}"

echo -e "${CYAN}==================================${NC}"
echo -e "${BOLD}管理面板访问地址：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:6185${NC}"
echo -e "${BLUE}▶ http://localhost:6185${NC}"

echo -e "${BOLD}如果你是nat服务器的管理面板访问地址：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:外部端口${NC}"

echo -e "\n${YELLOW}默认凭据：${NC}"
echo -e "用户名：${BOLD}astrbot${NC}"
echo -e "密码：  ${BOLD}astrbot${NC}"

echo -e "${BLUE}▶ 请在服务器nat转发界面转发6185端口并且放行6185端口${NC}"
echo -e "${CYAN}==================================${NC}"

echo -e "\n${GREEN}服务状态：${NC}"
cd /astrbot && docker compose ps

echo -e "\n${YELLOW}提示：${NC}"
echo -e "1. 如需查看日志，请使用命令：${BOLD}docker compose logs -f${NC}"
echo -e "2. 如需停止服务，请使用命令：${BOLD}docker compose down${NC}"
echo -e "3. 如需重启服务，请使用命令：${BOLD}docker compose restart${NC}"
    
# 执行 napcatqq.sh
for i in {15..1}; do
    echo -ne "\r${YELLOW}您有 ${i} 秒钟来记录IP，时间结束开始安装 napcatqq...${NC}"
    sleep 1
done
echo -e "\n${GREEN}时间结束，开始安装...${NC}"

# 确保 napcatqq.sh 脚本存在并可执行
if [ -f "napcatqq.sh" ]; then
    bash napcatqq.sh
    # 或者直接使用 ./napcatqq.sh，如果路径正确且文件可执行
    # ./napcatqq.sh
else
    echo -e "${RED}脚本 napcatqq.sh 不存在，请检查路径或文件是否存在${NC}"
    exit 1
fi


exit 0