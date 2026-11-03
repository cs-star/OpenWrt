#!/bin/bash
#========================================================================================================================
# diy-part2.sh (After Update feeds) - X86 / lede-master
# Default IP: 192.168.100.222 | Theme: Argon | Kernel: 6.18
#========================================================================================================================

# 默认主题改为 Argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile 2>/dev/null || true

# 内核版本改为 6.18（lede 当前 x86 默认也是 6.18，具体小版本由源码决定，如 6.18.x）
sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' target/linux/x86/Makefile

# 发行版信息
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true
echo "DISTRIB_SOURCECODE='lede'" >> package/base-files/files/etc/openwrt_release 2>/dev/null || true

# 默认 IP → 192.168.100.222
sed -i 's/192.168.1.1/192.168.100.222/g' package/base-files/files/bin/config_generate
sed -i 's/192.168.1.1/192.168.100.222/g' package/lean/default-settings/files/zzz-default-settings 2>/dev/null || true

# 可选：修改主机名
# sed -i 's/hostname='\''OpenWrt'\''/hostname='\''LEDE'\''/g' package/base-files/files/bin/config_generate

# 可选：修改时区（默认已是 CST）
# sed -i "s/timezone='UTC'/timezone='CST-8'/" package/base-files/files/bin/config_generate
