# 云编译OpenWrt (仅 X86)

在线云编译，利用它可以省去本地搭建或者购买服务器的时间成本。

**当前仓库仅支持：**
- 源码：**lede-master** (https://github.com/coolsnowwolf/lede)
- 架构：**X86_64 通用设备**
- 已完全禁用：电视盒子编译、官方/其它源码分支

### 使用方法

1. 设置权限（Settings → Secrets → Actions → GH_TOKEN，并开启 Workflow permissions）
2. 修改配置：进入 `config/lede-master/` 编辑 `config` 和 `diy-part1.sh` / `diy-part2.sh`
3. 开始编译：
   - 点击 **Actions**
   - 选择 **X86设备编译固件 (lede-master)**
   - 点击 **Run workflow**

等待几个小时后下载固件即可。

> 注意：当前 `build-x86.yml` 为简化版，建议使用完整工作流文件覆盖（见仓库 Artifacts 或下方提供的完整文件）。
