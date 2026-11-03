# 云编译OpenWrt (仅 X86)

在线云编译，利用它可以省去本地搭建或者购买服务器的时间成本。

**当前仓库仅支持：**
- 源码：lede-master (https://github.com/coolsnowwolf/lede)
- 架构：**X86_64 通用设备**
- 已禁用：电视盒子 / 其它源码分支

### 使用方法

1. 设置权限（GH_TOKEN 等，同之前）
2. 修改配置：进入 `config/lede-master/` 编辑 `config` 和 `diy-part*.sh`
3. 开始编译：Actions → **X86设备编译固件 (lede-master)** → Run workflow

等待编译完成后下载固件即可。
