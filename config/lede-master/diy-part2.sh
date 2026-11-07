#!/bin/bash
# OpenWrt/LEDE build hook: run after feeds update/install.
set -eu

log() { printf '[diy-part2] %s\n' "$*"; }
die() { printf '[diy-part2] ERROR: %s\n' "$*" >&2; exit 1; }

[ -f "include/toplevel.mk" ] || die "请在 OpenWrt 源码根目录执行此脚本。"

# ---------------------------------------------------------------------------
# 1. 默认主题：Bootstrap → Argon
# ---------------------------------------------------------------------------
luci_collection="feeds/luci/collections/luci/Makefile"
if [ -f "$luci_collection" ] && grep -q 'luci-theme-bootstrap' "$luci_collection"; then
  sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$luci_collection"
  log "默认 LuCI 主题依赖已切换为 luci-theme-argon。"
else
  log "主题依赖无需修改，或当前 feeds 中不存在 LuCI collection 文件。"
fi

# ---------------------------------------------------------------------------
# 2. 固件版本日期（@BUILD_DATE@）
# ---------------------------------------------------------------------------
settings_file="package/lean/default-settings/files/zzz-default-settings"
build_date="$(date +%Y.%m.%d)"
if [ -f "$settings_file" ]; then
  if grep -q '@BUILD_DATE@' "$settings_file"; then
    sed -i "s/@BUILD_DATE@/$build_date/g" "$settings_file"
    log "已设置固件构建日期：$build_date"
  else
    log "未发现 @BUILD_DATE@ 占位符，跳过版本日期替换。"
  fi
else
  log "未找到 $settings_file，跳过版本日期替换。"
fi

# ---------------------------------------------------------------------------
# 3. 源码标识
# ---------------------------------------------------------------------------
release_file="package/base-files/files/etc/openwrt_release"
if [ -f "$release_file" ]; then
  if grep -q '^DISTRIB_SOURCECODE=' "$release_file"; then
    sed -i "s|^DISTRIB_SOURCECODE=.*|DISTRIB_SOURCECODE='lede'|" "$release_file"
  else
    printf "DISTRIB_SOURCECODE='lede'\n" >> "$release_file"
  fi
  log "已设置固件源码标识：lede。"
else
  log "未找到 $release_file，跳过源码标识设置。"
fi

# ---------------------------------------------------------------------------
# 4. 默认 LAN IP → 192.168.100.222
# ---------------------------------------------------------------------------
DEFAULT_IP="192.168.100.222"

cfg_gen="package/base-files/files/bin/config_generate"
if [ -f "$cfg_gen" ]; then
  sed -i "s/192\.168\.[0-9]\+\.1/$DEFAULT_IP/g" "$cfg_gen"
  log "config_generate 默认 IP 已改为 $DEFAULT_IP"
else
  log "未找到 $cfg_gen，跳过 IP 修改。"
fi

if [ -f "$settings_file" ]; then
  sed -i "s/192\.168\.[0-9]\+\.1/$DEFAULT_IP/g" "$settings_file" || true
  log "default-settings 中的 IP 已同步为 $DEFAULT_IP"
fi

# ---------------------------------------------------------------------------
# 5. 主机名（可选）
# ---------------------------------------------------------------------------
# 如需修改主机名，取消下面注释：
# if [ -f "$cfg_gen" ]; then
#   sed -i "s/hostname='OpenWrt'/hostname='OpenWrt-X86'/g" "$cfg_gen" || true
#   log "主机名已修改"
# fi

log "构建后自定义步骤完成。"
