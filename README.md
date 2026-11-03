# 云编译OpenWrt

在线云编译，利用它可以省去本地搭建或者购买服务器的时间成本，你只需要使用本仓库的代码，按照下方的使用方法，修改一些参数，即可开始编译openwrt，等待几个小时后，你就可以下载固件了。

说明：当前仓库**仅保留 lede-master 源码编译**（其它源码分支已禁用），同时集成了打包img镜像的功能。

- lede源码：    https://github.com/coolsnowwolf/lede  （唯一支持）

### 操作教程由“实用技能”提供 @shiyongjineng

## 使用方法

1，注册账号

2，设置权限（GH_TOKEN 等）

3，设置config
- 进入 config/lede-master 文件夹。

4，添加插件或主题
- 进入 config/lede-master ，修改 diy-part2.sh

5，开始编译
- Actions 中选择 通用设备编译固件 或 电视盒子编译+IMG打包

当前仅支持 lede-master 源码。
