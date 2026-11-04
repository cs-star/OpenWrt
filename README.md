# 云编译 OpenWrt（仅 X86 / lede）

利用 GitHub Actions 在线编译固件，无需本地搭建编译环境。

## 当前支持

| 项目 | 说明 |
|------|------|
| 源码 | [coolsnowwolf/lede](https://github.com/coolsnowwolf/lede) `master` |
| 架构 | **X86_64** 通用设备 |
| 默认 IP | `192.168.100.222` |
| 默认主题 | Argon |


## 使用方法

1. **权限**  
   Repository → Settings → Actions → General → Workflow permissions → 勾选 **Read and write permissions**。

2. **修改配置（可选）**  
   - 软件包与目标：`config/lede-master/config`  
   - 编译前钩子：`config/lede-master/diy-part1.sh`  
   - 编译后钩子：`config/lede-master/diy-part2.sh`（默认 IP、主题、版本信息等）

3. **开始编译**  
   - 打开 **Actions**  
   - 选择 **X86设备编译固件 (lede-master)**  
   - 点击 **Run workflow**

4. **下载固件**  
   编译成功后：  
   - Actions 页面可下载 Artifact（保留 7 天）  
   - Releases 会自动发布（标签形如 `x86-YYYYMMDD_HHMM`）

编译通常需要数小时，视 GitHub Runner 负载而定。

## 目录结构

```
.
├── .github/workflows/build-x86.yml   # 唯一编译工作流
├── config/
│   ├── README.md
│   └── lede-master/
│       ├── config                    # .config（X86_64）
│       ├── diy-part1.sh              # feeds 更新前
│       └── diy-part2.sh              # feeds 更新后 / 默认 IP 等
└── README.md
```

## 说明

- 工作流固定克隆 lede `master`，仅编译 X86_64。
- `diy-part2.sh` 会将默认 LAN IP 设为 `192.168.100.222`，并尽量切换默认主题为 Argon。
- 内核版本跟随源码分支，不在脚本中强制覆盖。
- 不编译 Docker / dockerd；OpenClash 等插件以 `config` 中选项为准。
