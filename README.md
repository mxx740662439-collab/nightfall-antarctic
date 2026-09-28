# 夜幕——无尽弹幕·南极分部：完整运行项目

本包包含可编辑的 Godot 游戏代码、场景、PNG 美术资源、字体、WAV 音频、对话/音乐文本记录，以及已经导出的网页版本。

## 直接部署 GitHub Pages
将解压后的目录上传到仓库。Settings → Pages → Deploy from a branch → main → /docs。
网页入口为 docs/index.html；无需重新编译。详细步骤见 docs/README.md。

## 编辑游戏
使用 Godot 4.5.1 打开根目录 project.godot。核心代码在 scripts/main.gd，主场景在 scenes/main.tscn。
assets/ 是实际图像/字体，audio/ 是音乐与提示音；ui/web_shell.html 是加载页模板。
texts/dialogue.json 是对白文本记录，texts/music.json 是乐曲编排记录。
当前运行时对白由 scripts/main.gd 中的常量驱动；只修改 JSON 不会自动修改游戏对白。
字体支持现有对白；添加新汉字时需补充字形。

## 重新导出
安装匹配 Godot 4.5.1 的导出模板；选择 Web preset 导出到 docs/index.html。
归档内导出配置已移除原工作区的绝对模板路径；保留单线程与 Compatibility 渲染设置。
已导出的 docs/ 可直接部署，不依赖本地 Godot 或 Blender。

本包包含全部运行所需资源；不包含 Blender 制作工程、参考图、生成缓存、历史截图及测试日志。
原始素材无需重新制作即可运行/部署，PNG、WAV 与 GDScript 均可独立编辑。
保留 assets/fonts/ 下的许可文件及 docs/font-license.txt。
文件校验值见 SHA256SUMS.txt。
