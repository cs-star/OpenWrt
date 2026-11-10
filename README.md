# 云编译 OpenWrt（仅 X86 / lede）

[![Build](https://github.com/cs-star/OpenWrt/actions/workflows/build-x86.yml/badge.svg)](https://github.com/cs-star/OpenWrt/actions/workflows/build-x86.yml)
[![License](https://img.shields.io/github/license/cs-star/OpenWrt)](LICENSE)

利用 **GitHub Actions** 在线编译固件，无需本地搭建编译环境。

> **原作者仓库**：[xinlingduyu/build-openwrt](https://github.com/xinlingduyu/build-openwrt)  
> 本仓库在原作者基础上精简为 **lede + X86_64** 专用版本。

## 视频使用教程

**推荐观看**（原作者推荐的操作教程）：

- 标题：省时省力！OpenWrt固件全自动编译方法
- 作者：实用技能（@shiyongjineng）
- 链接：[https://www.youtube.com/watch?v=6j4ofS0GT38](https://www.youtube.com/watch?v=6j4ofS0GT38)

视频涵盖完整操作流程：注册账号、生成 Token、Fork 仓库、添加 Secrets、设置权限、修改配置、开始编译、下载固件等。

## 当前支持

| 项目 | 说明 |
|------|------|
| 源码 | [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) `master`（**每次构建自动拉取最新**） |
| 架构 | **X86_64** 通用设备 |
| 默认 IP | `192.168.100.253` |
| 主题 | **仅 Argon**（其它主题已移除） |
| 默认时区 | Asia/Shanghai (CST-8) |
| 默认账号 | `root`（密码为空，首次登录后请立即修改） |
| 自动编译 | 每周一自动构建一次（也可手动触发） |

## 使用方法

### 1. 权限设置（仅首次）

Repository → **Settings** → **Actions** → **General** → Workflow permissions → 勾选 **Read and write permissions** → Save。

### 2. 修改配置（可选）

| 文件 | 作用 |
|------|------|
| [`config/lede-master/config`](config/lede-master/config) | 软件包与目标（`.config`） |
| [`config/lede-master/diy-part1.sh`](config/lede-master/diy-part1.sh) | 拉取 Argon，删除其它主题 |
| [`config/lede-master/diy-part2.sh`](config/lede-master/diy-part2.sh) | 强制默认 Argon、IP、时区等 |

本地可用 `make menuconfig` 生成 `.config` 后覆盖 `config/lede-master/config`。

### 3. 开始编译

**手动触发：**
1. 打开 **Actions**
2. 左侧选择 **X86设备编译固件 (lede-master)**
3. 点击 **Run workflow** → **Run workflow**

**自动触发：** 每周一 UTC 02:00（北京时间 10:00）自动编译。

### 4. 下载固件

编译成功后（通常 2~5 小时，视 Runner 负载）：

- **Actions** 页面可下载 Artifact（保留 7 天）
- **Releases** 会自动发布（标签形如 `x86-YYYYMMDD_HHMM`）

## 目录结构

```
.
├── .github/workflows/build-x86.yml   # 编译工作流（始终拉取最新源码）
├── config/
│   ├── README.md
│   └── lede-master/
│       ├── config                    # .config（X86_64，仅 luci-theme-argon）
│       ├── diy-part1.sh              # 拉取 Argon，删除其它主题
│       └── diy-part2.sh              # 默认 IP / 仅 Argon / 时区
└── README.md
```

## 说明与注意事项

- **每次构建都会重新 `git clone` 最新的 lede `master` 分支**，确保使用最新源码。
- **主题策略**：只保留 **Argon**。bootstrap / design / material / openwrt 等主题目录会在构建过程中删除，`.config` 中也会关闭对应选项。
- Argon 从 [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon) 自动拉取。
- 工作流仅编译 **X86_64**。
- 启用 **ccache** 加速二次编译。
- 默认 LAN IP：`192.168.100.253`，时区：Asia/Shanghai。
- 内核版本跟随源码分支，不在脚本中强制覆盖。
- 编译失败时自动降级为单线程 `V=s` 以便定位问题。

## 常见问题

**Q: 编译时间过长 / 失败？**  
A: GitHub Runner 负载波动较大。可重试，或精简 `config` 中不需要的包。

**Q: 界面里还能选其它主题吗？**  
A: 不能。其它主题已从源码与配置中移除，固件内只有 Argon。

**Q: 如何添加第三方插件？**  
A: 在 `diy-part1.sh` 中添加 feed 或 `git clone` 到 `package/`，然后在 `config` 中启用对应 `CONFIG_PACKAGE_xxx=y`。

**Q: 想改默认 IP？**  
A: 编辑 `config/lede-master/diy-part2.sh`，修改 `DEFAULT_IP` 变量即可。

## 致谢

- 原作者仓库：[xinlingduyu/build-openwrt](https://github.com/xinlingduyu/build-openwrt)
- 视频教程：实用技能（@shiyongjineng）
- 源码： [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)
- 主题： [jerrykuku/luci-theme-argon](https://github.com/jerrykuku/luci-theme-argon)

## License

GPL-2.0
