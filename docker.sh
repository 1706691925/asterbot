#!/bin/bash

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 开发者信息
echo -e "${BLUE}开发者：夜屿 (QQ: 1706691925) / 烤花生啊 (QQ群: 1003909914)${NC}"

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}错误：请使用 root 用户运行此脚本${NC}"
    exit 1
fi

# 安装必要的系统工具
echo -e "${CYAN}安装必要的系统工具...${NC}"
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg lsb-release

# 卸载Ubuntu默认安装的docker，
echo -e "${CYAN}卸载Ubuntu默认安装的docker...${NC}"
sudo apt-get remove docker docker-engine docker.io containerd runc


#添加阿里源 GPG key（推荐使用阿里的gpg KEY）
echo -e "${CYAN}添加阿里源 GPG key...${NC}"
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg


#添加 apt 源:阿里apt源
echo -e "${CYAN}添加 apt 源:阿里apt源 GPG key...${NC}"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


#更新源
echo -e "${CYAN}更新源 GPG key...${NC}"
sudo apt update
sudo apt-get update

#安装最新版本的Docker
echo -e "${CYAN}安装最新版本的Docker GPG key...${NC}"
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo docker version

# 启动Docker服务
echo -e "${CYAN}启动Docker服务...${NC}"
systemctl start docker
systemctl enable docker

# 配置Docker镜像加速
echo -e "${CYAN}配置Docker镜像加速...${NC}"
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://docker.1panel.live"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF



# 如果Docker服务启动失败，清理并重新初始化
if ! systemctl is-active docker >/dev/null 2>&1; then
    echo -e "${YELLOW}Docker服务启动失败，尝试清理并重新初始化...${NC}"
    systemctl stop docker
    rm -rf /var/lib/docker
    mkdir -p /var/lib/docker
    chmod 711 /var/lib/docker
    systemctl start docker
fi

# 等待Docker服务就绪
echo -e "${YELLOW}等待Docker服务就绪...${NC}"
counter=0
while [ $counter -lt 30 ]; do
    if docker info &> /dev/null; then
        echo -e "${GREEN}Docker服务已就绪${NC}"
        break
    fi
    echo -n "."
    sleep 1
    counter=$((counter + 1))
done

# 验证Docker安装
echo -e "${CYAN}验证Docker安装...${NC}"
if docker --version; then
    echo -e "${GREEN}Docker 安装成功！${NC}"

    # 显示Docker版本信息
    echo -e "\n${YELLOW}Docker 版本信息：${NC}"
    docker --version
    echo -e "\n${YELLOW}Docker Compose 版本信息：${NC}"
    docker compose version

    # 显示Docker服务状态
    echo -e "\n${YELLOW}Docker 服务状态：${NC}"
    systemctl status docker --no-pager
else
    echo -e "${RED}Docker 安装失败，请检查错误信息${NC}"
    exit 1
fi

# 测试Docker镜像拉取
echo -e "\n${CYAN}测试Docker镜像拉取...${NC}"
if docker pull hello-world &> /dev/null; then
    echo -e "${GREEN}镜像拉取测试成功！${NC}"
else
    echo -e "${YELLOW}镜像拉取测试失败，但不影响使用${NC}"
fi

# 安装完成
echo -e "\n${GREEN}Docker环境配置完成！${NC}"
echo -e "${BLUE}系统将在5秒后继续...${NC}"
sleep 5
bash astrbot.sh

exit 0
