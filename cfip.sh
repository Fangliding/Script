#!/bin/bash

# IPv4 CIDR 段
ipv4_cidrs=(
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "108.162.192.0/18"
    "131.0.72.0/22"
    "141.101.64.0/18"
    "162.158.0.0/15"
    "172.64.0.0/13"
    "173.245.48.0/20"
    "188.114.96.0/20"
    "190.93.240.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
)

# IPv6 CIDR 段
ipv6_cidrs=(
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
)

# 函数：清除指定目标的规则
clear_rules() {
    local command=$1
    local target=("${!2}")

    for cidr in "${target[@]}"; do
        $command -t nat -D OUTPUT -d "$cidr" -j DNAT --to-destination "$3" 2>/dev/null
    done
}

# 函数：添加新的重定向规则
add_rules() {
    local command=$1
    local target=("${!2}")

    for cidr in "${target[@]}"; do
        $command -t nat -A OUTPUT -d "$cidr" -j DNAT --to-destination "$3"
    done
}

# 函数：清空指定类型的规则
flush_rules() {
    local command=$1
    local target=("${!2}")

    for cidr in "${target[@]}"; do
        $command -t nat -D OUTPUT -d "$cidr" -j DNAT 2>/dev/null
    done
}

# 参数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -4)
            if [[ -n "$2" ]]; then
                ipv4_address=$2
                shift 2
            else
                echo "Error: -4 option requires an argument."
                exit 1
            fi
            ;;
        -6)
            if [[ -n "$2" ]]; then
                ipv6_address=$2
                shift 2
            else
                echo "Error: -6 option requires an argument."
                exit 1
            fi
            ;;
        -F)
            flush_all=true
            if [[ -n "$2" ]]; then
                case $2 in
                    4)
                        flush_ipv4=true
                        shift 2
                        ;;
                    6)
                        flush_ipv6=true
                        shift 2
                        ;;
                    *)
                        echo "未知选项 $2"
                        exit 1
                        ;;
                esac
            else
                shift 1
            fi
            ;;
        *)
            echo "未知选项 $1"
            exit 1
            ;;
    esac
done

# 如果指定了 -F 参数
if [[ "$flush_all" == true ]]; then
    if [[ "$flush_ipv4" == true ]]; then
        echo "清空所有 IPv4 规则"
        flush_rules iptables ipv4_cidrs[@]
    elif [[ "$flush_ipv6" == true ]]; then
        echo "清空所有 IPv6 规则"
        flush_rules ip6tables ipv6_cidrs[@]
    else
        echo "清空所有 IPv4 和 IPv6 规则"
        flush_rules iptables ipv4_cidrs[@]
        flush_rules ip6tables ipv6_cidrs[@]
    fi
    exit 0
fi

# 如果指定了 IPv4 地址
if [[ -n "$ipv4_address" ]]; then
    echo "处理 IPv4 重定向到 $ipv4_address"
    clear_rules iptables ipv4_cidrs[@] "$ipv4_address"
    add_rules iptables ipv4_cidrs[@] "$ipv4_address"
fi

# 如果指定了 IPv6 地址
if [[ -n "$ipv6_address" ]]; then
    echo "处理 IPv6 重定向到 $ipv6_address"
    clear_rules ip6tables ipv6_cidrs[@] "$ipv6_address"
    add_rules ip6tables ipv6_cidrs[@] "$ipv6_address"
fi

echo "操作完成！"
