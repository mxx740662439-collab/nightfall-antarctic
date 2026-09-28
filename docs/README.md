# 夜幕——无尽弹幕·南极分部：GitHub Pages 部署包

这是已导出的 Godot Web 游戏，无需在 GitHub 上编译。

## 部署
1. 解压本包，将全部文件上传到 GitHub 仓库根目录。不要只上传 index.html，也不要上传 ZIP 本身当作网页。
2. 仓库 Settings → Pages → Build and deployment，选择 Deploy from a branch。
3. 选择 main 分支与 / (root)，保存并等待部署完成。
4. 打开 GitHub Pages 显示的网址。文件名大小写及相对路径必须保持不变。

若放入 docs 文件夹，则在 Pages 设置中选择 /docs。
本包包含 .nojekyll，上传时请保留此隐藏文件。

## 入口与依赖
index.html 是入口；index.js、index.wasm、index.pck、音频 worklet 与 zh-pixel.woff 需放在同一目录。
index.pck 包含游戏逻辑及运行资源；antarctic_shift.wav 是可单独播放的音乐副本。
这是 Compatibility / 单线程 Web 导出，不需要服务器后端或 npm 安装。
请通过 HTTPS 网站访问。直接双击本地 HTML 可能受浏览器限制。
游戏开始后才播放音乐，以适应浏览器音频策略。

## 操作
鼠标移动；自动向上攻击；X / 右键发动破夜；M 切换五关与无尽模式。
1/2/3 选难度；回车开始；回车、空格或点击推进对话；P 暂停。

实际 GitHub Pages 部署未在此工作区执行；本包使用现有可运行 Web 构建。
文件校验值见 SHA256SUMS.txt。字体许可见 font-license.txt。
