#!/bin/bash 

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# 显示赞助商信息函数
show_sponsor() {
    echo -e "${CYAN}============ 赞助商广告区 ============${NC}"
    echo -e "${BOLD}▶ 北川云（beichuan.cloud）${NC}"
    echo -e "  ${BLUE}超低价香港大埔区服务器，2-2每月仅需15元！8-8仅需45元！${NC}"
    echo -e "  ${GREEN}https://beichuan.cloud${NC}"

    echo -e "${BOLD}▶ 小路互联（plyl.xiaolu.icu）${NC}"
    echo -e "  ${BLUE}超低价idc服务器货源${NC}"
    echo -e "  ${GREEN}https://plyl.xiaolu.icu/${NC}"

    echo -e "${BOLD}▶ 广告位招租${NC}" 
    echo -e "${CYAN}=====================================${NC}\n"
}

# 下载安装脚本函数
download_script() {
    local script_name=$1
    # 使用 raw 链接
    local url="https://gitee.com/yeyv123/asterbot/raw/master/${script_name}.sh"
    
    if curl -s -o "${script_name}.sh" "$url"; then
        # 使用 sed 删除 Windows 换行符（\r）
        sed -i 's/\r//' "${script_name}.sh"
        chmod +x "${script_name}.sh"
        return 0
    else
        return 1
    fi
}

# 显示隐私协议并确认
confirm_privacy_agreement() {
    echo -e "${CYAN}说明：${NC}"
    echo -e "在使用本系统前，您需要同意我们的说明。\n请确认是否同意："
    echo -e "本安装脚本内容大部分来自于网络，部分借鉴于小馒头在gitee的开源项目https://gitee.com/mc_cloud/mccloud_bot，如有侵权请联系开发者"
    echo -e "本脚本未经大量测试，可能有很多未知名的bug，所产生的后果由使用者承担"

    echo -e "1. 同意继续安装（自动同意将在 15 秒后执行）"
    echo -e "2. 不同意退出安装（按 CTRL+C 退出）"
    
    # 15 秒倒计时自动同意协议
    for i in {15..1}; do
        echo -ne "\r${YELLOW}您有 ${i} 秒钟来决定是否同意，自动同意将继续安装...${NC}"
        sleep 1
    done
    echo -e "\n${GREEN}自动同意协议，开始安装...${NC}"
}

# 显示总体欢迎界面
clear
echo -e "${CYAN}${BOLD}"
cat << "EOF"
██████╗ ███████╗██╗ ██████╗██╗  ██╗██╗   ██╗ █████╗ ███╗   ██╗ 
██╔══██╗██╔════╝██║██╔════╝██║  ██║██║   ██║██╔══██╗████╗  ██║ 
██████╔╝█████╗  ██║██║     ███████║██║   ██║███████║██╔██╗ ██║ 
██╔══██╗██╔══╝  ██║██║     ██╔══██║██║   ██║██╔══██║██║╚██╗██║ 
██████╔╝███████╗██║╚██████╗██║  ██║╚██████╔╝██║  ██║██║ ╚████║ 
╚═════╝ ╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝ 
EOF
echo -e "${NC}"
echo -e "${BLUE}${BOLD}AsterBot 集成安装系统${NC}\n"
echo -e "${YELLOW}版权所有：北川云-夜屿 & 烤花生啊${NC}"
echo -e "${YELLOW}作者：夜屿 qq:1706691925, 烤花生啊 qq:2823264360${NC}"
echo -e "${YELLOW}QQ群：1003909914${NC}\n"

# 显示赞助商信息（开始时显示倒计时）
show_sponsor

# 显示隐私协议并自动同意
confirm_privacy_agreement

# 下载所需的脚本
echo -e "\n${CYAN}正在下载安装脚本...${NC}"
scripts=("docker" "astrbot" "gewechat" "napcatqq" "bot")
for script in "${scripts[@]}"; do
    echo -e "下载 ${script}.sh..."
    if download_script "$script"; then
        echo -e "${GREEN}✓ ${script}.sh 下载成功${NC}"
    else
        echo -e "${RED}✗ ${script}.sh 下载失败${NC}"
        exit 1
    fi
done

# 配置 bot 命令
echo -e "\n${CYAN}配置 bot 命令...${NC}"
mv bot.sh /usr/local/bin/bot
chmod +x /usr/local/bin/bot
if [ -f /usr/local/bin/bot ]; then
    echo -e "${GREEN}✓ bot 命令配置成功${NC}"
else
    echo -e "${RED}✗ bot 命令配置失败${NC}"
fi

# 执行 Docker 安装
echo -e "\n${CYAN}[1/4] 开始安装 Docker 环境...${NC}"
if ! bash docker.sh; then
    echo -e "${RED}Docker 安装失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker 安装完成${NC}"
sleep 2

# 执行 AstrBot 安装
echo -e "\n${CYAN}[2/4] 开始安装 AstrBot...${NC}"
if ! bash astrbot.sh; then
    echo -e "${RED}AstrBot 安装失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AstrBot 安装完成${NC}"
sleep 2

# 执行 Gewechat 安装
echo -e "\n${CYAN}[3/4] 开始安装 Gewechat...${NC}"
if ! bash gewechat.sh; then
    echo -e "${RED}Gewechat 安装失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Gewechat 安装完成${NC}"
sleep 2

# 执行 Napcat QQ 安装
echo -e "\n${CYAN}[4/4] 开始安装 Napcat QQ...${NC}"
if ! bash napcatqq.sh; then
    echo -e "${RED}Napcat QQ 安装失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Napcat QQ 安装完成${NC}"
sleep 2

# 获取本地IP
LOCAL_IP=$(ip addr show | grep -w inet | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1)
if echo "$LOCAL_IP" | grep -q "^17"; then
    SERVER_IP=$LOCAL_IP
else
    LOCAL_IP=$(echo "$LOCAL_IP" | grep ^192)
    SUBNET=$(echo "$LOCAL_IP" | cut -d. -f3)
    SERVER_IP=$(ifconfig | grep -B1 "inet 17" | grep inet | awk '{print $2}' | grep "^17.*\.${SUBNET}\.")
fi

# 获取 Napcat QQ 的 WebUI Token
NAPCAT_TOKEN=$(docker exec napcat /bin/bash -c "cat /napcat/config/webui.json" 2>/dev/null | grep -o '"token": "[^"]*"' | cut -d'"' -f4)
if [ -z "$NAPCAT_TOKEN" ]; then
    NAPCAT_TOKEN="napcat"
fi

# 显示最终的安装完成信息
clear
echo -e "${GREEN}${BOLD}"
cat << "EOF"
✨ MCloud 智能机器人集成系统安装完成 ✨
EOF
echo -e "${NC}"

echo -e "${CYAN}=====================================${NC}"
echo -e "${BOLD}AstrBot 管理面板：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:6185${NC}"
echo -e "用户名：${YELLOW}astrbot${NC}"
echo -e "密码：  ${YELLOW}astrbot${NC}"

echo -e "\n${BOLD}Gewechat API 地址：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:2531/v2/api/{接口名}${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:2532/download/{文件路径}${NC}"

echo -e "\n${BOLD}Napcat QQ 管理面板：${NC}"
echo -e "${BLUE}▶ http://${SERVER_IP}:6099/webui/${NC}"
echo -e "Token：${BOLD}${NAPCAT_TOKEN}${NC}"
echo -e "${BLUE}▶ WebSocket: ws://${SERVER_IP}:6099${NC}"
echo -e "${BLUE}▶ HTTP API: http://${SERVER_IP}:3001${NC}"
echo -e "${CYAN}=====================================${NC}"

echo -e "\n${GREEN}服务状态：${NC}"
docker ps

echo -e "\n${YELLOW}常用命令：${NC}"
echo -e "1. 查看 AstrBot 日志：${BOLD}cd /AstrBot && docker compose logs -f${NC}"
echo -e "2. 查看 Gewechat 日志：${BOLD}docker logs -f gewe${NC}"
echo -e "3. 查看 Napcat QQ 日志：${BOLD}docker logs -f napcat${NC}"
echo -e "4. 重启所有服务：${BOLD}cd /AstrBot && docker compose restart && docker restart gewe napcat${NC}"

# 清理下载的脚本（保留 bot.sh）
rm -f docker.sh astrbot.sh gewechat.sh napcatqq.sh

# 显示 bot 命令使用提示
echo -e "\n${YELLOW}bot 命令使用说明：${NC}"
echo -e "直接输入 ${BOLD}bot${NC} 即可管理所有机器人服务包括日志查看"
echo -e "${CYAN}========================${NC}\n"

exit 0
