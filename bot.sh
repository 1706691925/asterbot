#!/bin/bash

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m'

# 显示菜单
show_menu() {
    clear
    # 显示赞助商信息
    echo -e "${CYAN}=============================== 赞助商广告区 =============================${NC}"
    echo -e "${BOLD}▶ 北川云（beichuan.cloud）${NC}"
    echo -e "  ${BLUE}超低价香港大埔区服务器，2-2每月仅需15元！8-8仅需45元！${NC}"
    echo -e "  ${GREEN}https://beichuan.cloud${NC}"

    echo -e "${BOLD}▶ 小路互联（plyl.xiaolu.icu）${NC}"
    echo -e "  ${BLUE}超低价idc服务器货源${NC}"
    echo -e "  ${GREEN}https://plyl.xiaolu.icu/${NC}"

    echo -e "${BOLD}▶ 广告位招租${NC}" 
    echo -e "${CYAN}=========================================================================${NC}\n"
    echo -e "===========================AsterBot管理命令行============================"
    echo -e "(1) 启动/重启BOT框架服务              (8) 查看BOT框架日志"
    echo -e "(2) 停止BOT框架服务                   (9) 清理所有日志"
    echo -e "(3) 启动/重启QQ机器人                 (10) 进入BOT框架终端"
    echo -e "(4) 停止QQ机器人                      (11) 进入QQ机器人终端"
    echo -e "(5) 启动/重启微信机器人               (12) 进入微信机器人终端"
    echo -e "(6) 停止微信机器人                    (13) 查看QQ机器人日志"
    echo -e "(7) 一键重启所有服务                  (14) 查看微信机器人日志"
    echo -e "(15) 重新安装框架"
    echo -e "(0) 退出"
    echo -e "======================================================================"
    echo -e "\n请输入命令编号: "
}

# 执行命令并显示结果
execute_command() {
    echo -e "\n${CYAN}执行命令中...${NC}"
    if eval "$1"; then
        echo -e "${GREEN}命令执行成功！${NC}"
    else
        echo -e "${RED}命令执行失败！${NC}"
    fi
    echo -e "\n${YELLOW}按回车键继续...${NC}"
    read -r
}

# 主程序
main() {
    while true; do  # 无限循环
        show_menu
        read -r choice

        case $choice in
            1)
                execute_command "docker restart astrbot"
                ;;
            2)
                execute_command "docker stop astrbot"
                ;;
            3)
                execute_command "docker restart napcat"
                ;;
            4)
                execute_command "docker stop napcat"
                ;;
            5)
                execute_command "docker restart gewe"
                ;;
            6)
                execute_command "docker stop gewe"
                ;;
            7)
                echo -e "${CYAN}正在重启所有服务...${NC}"
                systemctl restart docker
                echo -e "${GREEN}所有服务已重启！${NC}"
                sleep 2
                ;;
            8)
                # 将日志查看命令放到后台执行，这样可以继续显示菜单
                echo -e "${YELLOW}日志查看已启动，按 Ctrl+C 退出日志查看${NC}"
                sleep 1
                docker logs -f astrbot &  # 在后台查看日志
                ;;
            9)
                echo -e "${YELLOW}正在清理所有服务的日志...${NC}"
                docker logs --truncate 0 astrbot > /dev/null 2>&1
                docker logs --truncate 0 napcat > /dev/null 2>&1
                docker logs --truncate 0 gewe > /dev/null 2>&1
                echo -e "${GREEN}日志清理完成！${NC}"
                sleep 2
                ;;
            10)
                echo -e "${YELLOW}输入 exit 退出终端${NC}"
                sleep 2
                docker exec -it astrbot /bin/bash || {
                    echo -e "${RED}无法进入终端，请确保容器正在运行${NC}"
                    sleep 2
                }
                ;;
            11)
                echo -e "${YELLOW}输入 exit 退出终端${NC}"
                sleep 2
                docker exec -it napcat /bin/bash || {
                    echo -e "${RED}无法进入终端，请确保容器正在运行${NC}"
                    sleep 2
                }
                ;;
            12)
                echo -e "${YELLOW}输入 exit 退出终端${NC}"
                sleep 2
                docker exec -it gewe /bin/bash || {
                    echo -e "${RED}无法进入终端，请确保容器正在运行${NC}"
                    sleep 2
                }
                ;;
            13)
                # 在后台查看日志
                echo -e "${YELLOW}日志查看已启动，按 Ctrl+C 退出日志查看${NC}"
                sleep 1
                docker logs -f napcat &  # 在后台查看日志
                ;;
            14)
                # 在后台查看日志
                echo -e "${YELLOW}日志查看已启动，按 Ctrl+C 退出日志查看${NC}"
                sleep 1
                docker logs -f gewe &  # 在后台查看日志
                ;;
            15)
                echo -e "${RED}警告：这将重新安装整个框架！${NC}"
                echo -e "${YELLOW}是否继续？[y/N]${NC} "
                read -r confirm
                if [[ $confirm =~ ^[Yy]$ ]]; then
                    execute_command "wget -qO- https://gitee.com/yeyv123/asterbot/raw/master/install.sh | sed 's/\r//' | bash"
                else
                    echo -e "${BLUE}已取消重装${NC}"
                fi
                ;;
            0)
                echo -e "${GREEN}感谢使用！再见！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选项！${NC}"
                sleep 2
                ;;
        esac
    done  # 结束循环
}

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}错误：请使用 root 用户运行此脚本${NC}"
    exit 1
fi

# 显示开发者信息
echo -e "${CYAN}开发者：夜屿 (QQ: 1706691925) & 烤花生啊 (QQ: 2823264360, QQ 群: 1003909914)${NC}"

# 启动主程序
main "$@"
