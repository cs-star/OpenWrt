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
| 默认 IP | `192.168.100.222` |
| 默认主题 | Argon |
| 默认账号 | `root`（密码为空，首次登录后请立即修改） |
| 自动编译 | 每周一自动构建一次（也可手动触发） |

## 使用方法

### 1. 权限设置（仅首次）

Repository → **Settings** → **Actions** → **General** → Workflow permissions → 勾选 **Read and write permissions** → Save。

### 2. 修改配置（可选）

| 文件 | 作用 |
|------|------|
| [`config/lede-master/config`](config/lede-master/config) | 软件包与目标（`.config`） |
| [`config/lede-master/diy-part1.sh`](config/lede-master/diy-part1.sh) | feeds 更新前钩子（可添加 feed、删除包） |
| [`config/lede-master/diy-part2.sh`](config/lede-master/diy-part2.sh) | feeds 更新后钩子（默认 IP、主题、版本信息等） |

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
│       ├── config                    # .config（X86_64）
│       ├── diy-part1.sh              # feeds 更新前
│       └── diy-part2.sh              # feeds 更新后 / 默认 IP 等
└── README.md
```

## 说明与注意事项

- **每次构建都会重新 `git clone` 最新的 lede `master` 分支**，确保使用最新源码。
- 工作流仅编译 **X86_64**。
- `diy-part2.sh` 会将默认 LAN IP 设为 `192.168.100.222`，并尽量切换默认主题为 Argon。
- 内核版本跟随源码分支，不在脚本中强制覆盖。
- 不编译 Docker / dockerd；OpenClash 等插件以 `config` 中选项为准。
- 依赖安装已改为仓库内固定列表（原短链接已失效）。
- 编译失败时可在 Actions 日志中查看完整输出（失败时会降级为单线程 `V=s`）。
- 构建日志会显示当前拉取的源码提交哈希与提交信息，方便核对版本。

## 常见问题

**Q: 编译时间过长 / 失败？**  
A: GitHub Runner 负载波动较大。可重试，或精简 `config` 中不需要的包。

**Q: 如何添加第三方插件？**  
A: 在 `diy-part1.sh` 中添加 feed 或 `git clone` 到 `package/`，然后在 `config` 中启用对应 `CONFIG_PACKAGE_xxx=y`。

**Q: 想改默认 IP？**  
A: 编辑 `config/lede-master/diy-part2.sh`，搜索 `192.168.100.222` 替换即可。

**Q: 如何确认用的是最新源码？**  
A: 查看 Actions 日志中「Clone latest lede source」步骤，会显示最新提交哈希与提交信息。

## 致谢

- 原作者仓库：[xinlingduyu/build-openwrt](https://github.com/xinlingduyu/build-openwrt)
- 视频教程：实用技能（@shiyongjineng）
- 源码： [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede)

## License

GPL-2.0
