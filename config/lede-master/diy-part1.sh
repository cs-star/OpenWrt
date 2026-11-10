#!/bin/bash
# OpenWrt/LEDE build hook: run before feeds update.
# This hook is intentionally idempotent and safe to execute repeatedly.
set -eu

log() { printf '[diy-part1] %s\n' "$*"; }
die() { printf '[diy-part1] ERROR: %s\n' "$*" >&2; exit 1; }

# The workflow runs this script from the OpenWrt source root.
[ -f "include/toplevel.mk" ] || die "请在 OpenWrt 源码根目录执行此脚本。"

# ---------------------------------------------------------------------------
# 拉取 Argon 主题（lede 默认源不一定自带可用版本）
# ---------------------------------------------------------------------------
ARGON_DIR="package/luci-theme-argon"
if [ ! -d "$ARGON_DIR" ]; then
  log "正在克隆 luci-theme-argon ..."
  git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon.git "$ARGON_DIR"
  log "luci-theme-argon 已添加到 $ARGON_DIR"
else
  log "luci-theme-argon 已存在，跳过克隆。"
fi

# 可选：Argon 配置插件
ARGON_CONFIG_DIR="package/luci-app-argon-config"
if [ ! -d "$ARGON_CONFIG_DIR" ]; then
  log "正在克隆 luci-app-argon-config ..."
  git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config.git "$ARGON_CONFIG_DIR" || log "luci-app-argon-config 克隆失败（可忽略）"
fi

# Optional custom feed. Enable only after verifying compatibility.
# FEED_LINE='src-git lienol https://github.com/Lienol/openwrt-package'
# if [ -f feeds.conf.default ] && ! grep -Fqx "$FEED_LINE" feeds.conf.default; then
#   printf '%s\n' "$FEED_LINE" >> feeds.conf.default
#   log "已添加自定义 feed"
# fi

# Optional package removals.
# rm -rf package/lean/{samba4,luci-app-samba4,luci-app-ttyd}

log "构建前自定义步骤完成。"
