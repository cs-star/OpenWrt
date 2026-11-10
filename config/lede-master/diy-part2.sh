#!/bin/bash
# OpenWrt/LEDE build hook: run after feeds update/install.
set -eu

log() { printf '[diy-part2] %s\n' "$*"; }
die() { printf '[diy-part2] ERROR: %s\n' "$*" >&2; exit 1; }

[ -f "include/toplevel.mk" ] || die "请在 OpenWrt 源码根目录执行此脚本。"

# ---------------------------------------------------------------------------
# 1. 默认主题 → Argon（兼容 bootstrap / design）
# ---------------------------------------------------------------------------
if [ -d "feeds/luci/collections" ]; then
  find feeds/luci/collections -type f -name 'Makefile' 2>/dev/null | while read -r mf; do
    if grep -qE 'luci-theme-(bootstrap|design)' "$mf"; then
      sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$mf"
      sed -i 's/luci-theme-design/luci-theme-argon/g' "$mf"
      log "已修改主题依赖: $mf"
    fi
  done
fi

# lean default-settings 里也可能写死主题
settings_file="package/lean/default-settings/files/zzz-default-settings"
if [ -f "$settings_file" ]; then
  sed -i "s|luci-theme-bootstrap|luci-theme-argon|g" "$settings_file" 2>/dev/null || true
  sed -i "s|luci-theme-design|luci-theme-argon|g" "$settings_file" 2>/dev/null || true
  # 强制默认主题
  if grep -q "mediaurlbase" "$settings_file"; then
    sed -i "s|/luci-static/bootstrap|/luci-static/argon|g" "$settings_file" 2>/dev/null || true
    sed -i "s|/luci-static/design|/luci-static/argon|g" "$settings_file" 2>/dev/null || true
  else
    # 追加一条设置默认主题的命令（若文件结构允许）
    if ! grep -q "luci.main.mediaurlbase" "$settings_file"; then
      printf "\nuci set luci.main.mediaurlbase='/luci-static/argon'\nuci commit luci\n" >> "$settings_file" || true
    fi
  fi
  log "default-settings 默认主题已指向 Argon"
fi

# ---------------------------------------------------------------------------
# 2. 固件版本日期（@BUILD_DATE@）
# ---------------------------------------------------------------------------
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
# 4. 默认 LAN IP → 192.168.100.253
# ---------------------------------------------------------------------------
DEFAULT_IP="192.168.100.253"

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
# 5. 默认时区 Asia/Shanghai
# ---------------------------------------------------------------------------
if [ -f "$cfg_gen" ]; then
  sed -i "s/timezone='UTC'/timezone='CST-8'/g" "$cfg_gen" || true
  sed -i "s/zonename='UTC'/zonename='Asia\/Shanghai'/g" "$cfg_gen" || true
  if ! grep -q "zonename" "$cfg_gen"; then
    sed -i "/timezone=/a\ \t\tset system.@system[-1].zonename='Asia/Shanghai'" "$cfg_gen" 2>/dev/null || true
  fi
  log "默认时区已设置为 Asia/Shanghai (CST-8)"
fi

if [ -f "$settings_file" ]; then
  sed -i "s/timezone='UTC'/timezone='CST-8'/g" "$settings_file" 2>/dev/null || true
  sed -i "s/zonename='UTC'/zonename='Asia\/Shanghai'/g" "$settings_file" 2>/dev/null || true
fi

# ---------------------------------------------------------------------------
# 6. 主机名（可选）
# ---------------------------------------------------------------------------
# 如需修改主机名，取消下面注释：
# if [ -f "$cfg_gen" ]; then
#   sed -i "s/hostname='OpenWrt'/hostname='OpenWrt-X86'/g" "$cfg_gen" || true
#   log "主机名已修改"
# fi

log "构建后自定义步骤完成。"
