---
prev: false

next: 
  text: 'Guide'
  link: '/guide'
---

# Quick Start

## 前提条件

下载&安装：

- vscode
- powershell
- pandoc
- LibreOffice

## Start

```Bash
git clone https://github.com/Skixkk/DocAutoFlow

cd DocAutoFlow/markdown

echo the first text > hi.md

./watch-md2pdf.ps1
```

接下来自动 扫描 你电脑安装的 pandoc 所在目录 & LibreOffice 所在录，并自动配置

自动扫描 脚本所在目录（绝对路径），作为 .md 所在目录（也就是要求脚本与目录在通用目录下），之后会在同目录下生成 `.docx` 和 `.pdf` 文件（如果 需要 `/dist` 下生成可以 自行编写脚本/AI编写/提 issue）,或者手动填写目录覆盖 脚本自动扫描的的目录

- 需要你按提示 手动将 clone 到本地的 [pandoc_docx_template](https://github.com/Achuan-2/pandoc_docx_template) 下的 `/templates` 目录粘贴到 终端中，然后 回车（按下`enter`键）

## tips

- 如果需要重置目录：直接删除`config.json`，脚本会重新走一遍初始化向导；或 修改 `config.json` 下的 `watchDir` 后面的参数
- [pandoc_docx_template](https://github.com/Achuan-2/pandoc_docx_template) 下的 `/templates` 提供的 pandoc docx template(可以根据 [作者 `@Achuan-2`](https://github.com/Achuan-2) 提供的 `/template` 下的任意 一个 `.docx` 文件内容，进行自定义适合自己的 pandoc docx template )
