#!/bin/bash
#========================================================================================================================
# diy-part1.sh (Before Update feeds) - X86 / lede-master
#========================================================================================================================

# 可选：添加常用第三方 feed（按需取消注释）
# echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default
# echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages' >>feeds.conf.default
# echo 'src-git openclash https://github.com/vernesong/OpenClash' >>feeds.conf.default

# 清理不需要的包（可选）
# rm -rf package/lean/{samba4,luci-app-samba4}
