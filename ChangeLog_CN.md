# FoxGet Package Manager

FoxGet 是 VFP 的软件包管理器，类似于 .NET 的 NuGet 软件包管理器。

## 发布
### 2024-10-06

- Packages.dbf 被替换为 Packages.xml，以便于比较和合并。

- 合并了拉取请求 #7，提供了 FoxGetPackages.dbf 的自动更新。

- 添加了一个清除过滤器按钮。

- 更新了安装程序版本。

- 修复了一个错误，该错误在没有已安装包时点击 *仅显示已安装的包* 时会导致错误。在这种情况下，列表现在显示为空，而不是显示所有包。

- 更好地处理了解压下载文件失败的情况。

- FoxGet 在安装时不再向项目中添加已存在的文件，也不再在卸载时尝试删除它。

- 卸载包时现在会进行日志记录。

- 下载包文件时不再出现错误 35（注意：这实际上是 VFPXInternet.prg 中的更改，该文件是 [VFPX Framework](https://github.com/VFPX/VFPXFramework) 的一部分）。感谢 Christof Wollenhaupt 的修复。

### 2024-08-24

* 更新安装程序版本。

### 2024-07-21

* 添加了 VFPX Framework 安装程序。
* 更新至最新 VFPX Framework 版本。

### 2024-01-30

* 添加了 fpCefSharp、Format 和 VFP2C32 的安装程序。
* 实施 VFPX Framework。

### 2024-01-07

* 添加了对 MyPackages(自定义软件包列表)的支持，这对测试或私人软件包非常有用。
* 添加了对本地安装程序 PRG 的支持。
* 添加了对复制提取文件子目录的支持。
* 修复了一些小错误。

### 2023-12-28

* 初次发布

