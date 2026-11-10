#!/bin/bash
# OpenWrt/LEDE build hook: run before feeds update.
set -eu

log() { printf '[diy-part1] %s\n' "$*"; }
die() { printf '[diy-part1] ERROR: %s\n' "$*" >&2; exit 1; }

[ -f "include/toplevel.mk" ] || die "请在 OpenWrt 源码根目录执行此脚本。"

# ---------------------------------------------------------------------------
# 1. 拉取 Argon 主题（唯一主题）
# ---------------------------------------------------------------------------
ARGON_DIR="package/luci-theme-argon"
if [ ! -d "$ARGON_DIR" ]; then
  log "正在克隆 luci-theme-argon ..."
  git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git "$ARGON_DIR"
  log "luci-theme-argon 已添加"
else
  log "luci-theme-argon 已存在，跳过克隆"
fi

ARGON_CONFIG_DIR="package/luci-app-argon-config"
if [ ! -d "$ARGON_CONFIG_DIR" ]; then
  log "正在克隆 luci-app-argon-config ..."
  git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git "$ARGON_CONFIG_DIR" || log "luci-app-argon-config 克隆失败（可忽略）"
fi

# ---------------------------------------------------------------------------
# 2. 删除其它主题（源码树内）
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

log "构建前自定义步骤完成（仅保留 Argon）。"
