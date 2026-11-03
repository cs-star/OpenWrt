#!/bin/bash
# OpenWrt/LEDE build hook: run before feeds update.
# This hook is intentionally idempotent and safe to execute repeatedly.
set -eu

log() { printf '[diy-part1] %s\n' "$*"; }
die() { printf '[diy-part1] ERROR: %s\n' "$*" >&2; exit 1; }

# The workflow runs this script from the OpenWrt source root.
[ -f "include/toplevel.mk" ] || die "请在 OpenWrt 源码根目录执行此脚本。"

# Optional custom feed. Enable only after verifying compatibility with
# the selected source branch; do not add duplicate feed entries.
# FEED_LINE='src-git lienol https://github.com/Lienol/openwrt-package'
# if [ -f feeds.conf.default ] && ! grep -Fqx "$FEED_LINE" feeds.conf.default; then
#   printf '%s\n' "$FEED_LINE" >> feeds.conf.default
# fi

# Optional package removals. Confirm package paths before enabling.
# rm -rf package/lean/{samba4,luci-app-samba4,luci-app-ttyd}

log "构建前自定义步骤完成。"
