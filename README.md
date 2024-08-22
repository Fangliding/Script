# Script

记载一些个人随便弄的一些脚本

## cfip.sh

使用iptables重定向所有发往cloudflare的链接到指定的IP(如果机子比较灵车默认解析出的IP速度速度不理想)

```
-4 指定IPv4地址
-6 指定ipv6地址
-F 清空规则 后接4或者6只清空IPv4/IPv6的重定向
```
