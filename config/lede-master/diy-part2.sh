#!/bin/bash
# OpenWrt/LEDE build hook: run after feeds update/install.
set -eu

log() { printf '[diy-part2] %s\n' "$*"; }
die() { printf '[diy-part2] ERROR: %s\n' "$*" >&2; exit 1; }

[ -f "include/toplevel.mk" ] || die "请在 OpenWrt 源码根目录执行此脚本。"

# ---------------------------------------------------------------------------
# 1. 再次清理其它主题目录（feeds 更新后可能重新出现）
# ---------------------------------------------------------------------------
for t in \
  luci-theme-bootstrap \
  luci-theme-design \
  luci-theme-material \
  luci-theme-openwrt \
  luci-theme-openwrt-2020 \
  luci-theme-netgear \
  luci-theme-pink \
  luci-theme-purple
do
  for base in package feeds; do
    found=$(find "$base" -type d -name "$t" 2>/dev/null | head -n 5 || true)
    if [ -n "$found" ]; then
      echo "$found" | while read -r d; do
        rm -rf "$d"
        log "已删除主题目录: $d"
      done
    fi
  done
done

# ---------------------------------------------------------------------------
# 2. 默认主题强制为 Argon
# ---------------------------------------------------------------------------
if [ -d "feeds/luci/collections" ]; then
  find feeds/luci/collections -type f -name 'Makefile' 2>/dev/null | while read -r mf; do
    if grep -qE 'luci-theme-' "$mf"; then
      sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$mf"
      sed -i 's/luci-theme-design/luci-theme-argon/g' "$mf"
      sed -i 's/luci-theme-material/luci-theme-argon/g' "$mf"
      log "主题依赖已统一为 Argon: $mf"
    fi
  done
fi

# target.mk 里 lede 可能写死默认主题
if [ -f "include/target.mk" ]; then
  sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' include/target.mk 2>/dev/null || true
  sed -i 's/luci-theme-design/luci-theme-argon/g' include/target.mk 2>/dev/null || true
  log "include/target.mk 默认主题已指向 Argon"
fi

settings_file="package/lean/default-settings/files/zzz-default-settings"
if [ -f "$settings_file" ]; then
  sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' "$settings_file" 2>/dev/null || true
  sed -i 's/luci-theme-design/luci-theme-argon/g' "$settings_file" 2>/dev/null || true
  sed -i 's|/luci-static/bootstrap|/luci-static/argon|g' "$settings_file" 2>/dev/null || true
  sed -i 's|/luci-static/design|/luci-static/argon|g' "$settings_file" 2>/dev/null || true
  if ! grep -q "luci.main.mediaurlbase" "$settings_file"; then
    printf "\nuci set luci.main.mediaurlbase='/luci-static/argon'\nuci commit luci\n" >> "$settings_file" || true
  fi
  log "default-settings 默认主题已指向 Argon"
fi

# ---------------------------------------------------------------------------
# 3. .config 只保留 Argon，关闭其它主题
# ---------------------------------------------------------------------------
if [ -f .config ]; then
  # 确保 Argon 开启
  if grep -q '^CONFIG_PACKAGE_luci-theme-argon=y' .config; then
    :
  elif grep -q 'CONFIG_PACKAGE_luci-theme-argon' .config; then
    sed -i 's/.*CONFIG_PACKAGE_luci-theme-argon.*/CONFIG_PACKAGE_luci-theme-argon=y/' .config
  else
    echo 'CONFIG_PACKAGE_luci-theme-argon=y' >> .config
  fi

  # 关闭其它主题
  for t in bootstrap design material openwrt openwrt-2020 netgear pink purple; do
    if grep -q "CONFIG_PACKAGE_luci-theme-$t" .config; then
      sed -i "s/^CONFIG_PACKAGE_luci-theme-$t=y/# CONFIG_PACKAGE_luci-theme-$t is not set/" .config
      sed -i "s/^CONFIG_PACKAGE_luci-theme-$t=m/# CONFIG_PACKAGE_luci-theme-$t is not set/" .config
    else
      echo "# CONFIG_PACKAGE_luci-theme-$t is not set" >> .config
    fi
  done
  log ".config 已设置为仅启用 luci-theme-argon"
fi

# ---------------------------------------------------------------------------
# 4. 固件版本日期（@BUILD_DATE@）
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
# 5. 源码标识
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
# 6. 默认 LAN IP → 192.168.100.253
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
# 7. 默认时区 Asia/Shanghai
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

log "构建后自定义步骤完成（仅 Argon 主题）。"
