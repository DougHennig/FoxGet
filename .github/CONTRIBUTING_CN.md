# 如何帮助 FoxGet

## 报告 bug

- 如果 bug 已被报告，请检查 [issues](https://github.com/DougHennig/FoxGet/issues)。

- 如果您无法在其中找到解决该问题的方法，请创建一个新问题。请务必包含标题和清晰的描述、尽可能多的相关信息以及代码示例或可执行测试用例，以演示未发生的预期行为。

## 修复 bug 或添加增强的功能

- Fork 项目：请参阅 [guide](https://www.dataschool.io/how-to-contribute-on-github/)，了解如何设置和使用 fork。

- 有关创建新安装程序的信息，请参阅 README.md/README_CN.md 中的 _创建安装包_ 主题。

- 如果您要更改 FoxGet UI 或 FoxGet.prg，且这是一个新的主要版本，请编辑 *BuildProcess\ProjectSettings.txt* 中的版本设置。

- 在 *ChangeLog.md/ChangeLog_CN.md* 的顶部描述更改。

- 如果尚未安装 VFPX Deployment，请安装它：从 “Thor”菜单中选择 “Check for Updates”，选择 VFPX Deployment 的复选框，然后单击 “Install”。

- 启动 VFP 9（不是 VFP Advanced）并将 进入项目文件夹。

- 运行 VFPX Deployment 工具创建安装文件：从 Thor - ToolsApplication菜单中选择 VFPX Project Deployment。或者，执行 ```EXECSCRIPT(_screen.cThorDispatcher, 'Thor_Tool_DeployVFPXProject')```.

- 提交更改。

- Push 至你的 fork.

- 创建 pull request；确保描述清楚地说明问题和解决方案或增强功能。

----
最后更新: 2023-12-28