---
layout: home

hero:
  name: "DocAutoFlow"
  text: "Real time preview .docx"
  # tagline: vscode pandoc LibreOffice powershell
  actions:
    - theme: brand
      text: Get Started
      link: /start
    - theme: alt
      text: View on GitHub
      link: https://github.com/Skixkk/DocAutoFlow

# features:
#   - title: pandoc
#     details: https://pandoc.org/installing.html
#   - title: pandoc_docx_template
#     details: https://github.com/Achuan-2/pandoc_docx_template
#   - title: LibreOffice
#     details: https://www.libreoffice.org/
---

<!--
 * @Author: Skixkk skixkk7@gmail.com
 * @Date: 2026-08-23 22:26:32
 * @LastEditors: Skixkk skixkk7@gmail.com
 * @LastEditTime: 2026-08-23 22:31:09
 * @FilePath: \DocAutoFlow\docs\index.md
 * @Description: Homepage
-->

# Quick Start

```Bash
git clone https://github.com/Skixkk/DocAutoFlow

cd DocAutoFlow/markdown

echo the first text > hi.md

./watch-md2pdf.ps1
```

接下来自动 扫描 你电脑安装的 pandoc 所在目录 & LibreOffice 所在录，并自动配置

自动扫描 脚本所在目录（绝对路径），作为 .md 所在目录（也就是要求脚本与目录在通用目录下），之后会在同目录下生成 `.docx` 和 `.pdf` 文件（如果 需要 `/dist` 下生成可以 自行编写脚本/AI编写/提 issue）,或者手动填写目录覆盖 脚本自动扫描的的目录

- 需要你按提示 手动将 clone 到本地的 [pandoc_docx_template](https://github.com/Achuan-2/pandoc_docx_template) 下的 `/templates` 目录粘贴到 终端中，然后 回车（按下`enter`键）

## 前提条件

下载&安装：

- vscode
- powershell
- pandoc
- LibreOffice
