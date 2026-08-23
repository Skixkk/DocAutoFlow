<!--
 * @Author: Skixkk skixkk7@gmail.com
 * @Date: 2026-08-23 18:03:25
 * @LastEditors: Skixkk skixkk7@gmail.com
 * @LastEditTime: 2026-08-23 23:35:51
 * @FilePath: \DocAutoFlow\README.md
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
-->
<!--
 * @Author: Skixkk skixkk7@gmail.com
 * @Date: 2026-08-23 18:03:25
 * @LastEditors: Skixkk skixkk7@gmail.com
 * @LastEditTime: 2026-08-23 23:31:17
 * @FilePath: \DocAutoFlow\README.md
 * @Description: README
-->
# DocAutoFlow

[![Deploy VitePress site to Pages](https://github.com/Skixkk/DocAutoFlow/actions/workflows/deploy.yml/badge.svg)](https://github.com/Skixkk/DocAutoFlow/actions/workflows/deploy.yml)

Powershell 基于 Pandoc + LibreOffice 实现的 Markdown 自动流水线实时预览（Word,pdf）&导出工具(加入其他功能请提 issue 或 查看 结尾的 优秀项目/组合)

## 解决了什么问题

当我们在使用 markdown 的时候，无法实时生成 docx 来进行预览，需要 频繁切换 vscode 和 word 来实现查看效果，这大大打折了科研/编码/白领~~🐂🐎~~生产效率。

此项目以及其简单粗暴的方式借助 `Powershell + Pandoc + LibreOffice` 解决了 markdown 不能在 vscode 预览 docx 效果的问题，配置教程可见如下 bilibili 教程或继续阅读下面内容。

- [bilibili 教程 预留位](https://www.bilibili.com/)

### 这是一个 preview version

- 基于 powershell 编写脚本
- 基于 pandoc 及 pandoc doc 模板 [pandoc_docx_template](https://github.com/Achuan-2/pandoc_docx_template) 下的 `/templates` 提供的 pandoc docx template
- 基于 LibreOffice CLI 实现 docx 转 pdf

基于 pdf 这一固定 格式，来在 vscode 使用预览 docx 效果的问题，或者 markdown 直接预览 pdf

替代：如果你会编写 LaTeX 来写论文/文章，完全可以用 LaTeX Workshop (Author：James Yu) 来编写 tex，实时预览 pdf，后面也会出 markdown 转 tex + tex 的模板，再转出 docx 和 pdf。

## 前提条件

下载&安装：

- vscode
- powershell
- pandoc
- LibreOffice

## Quick Start

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

## version

- powershell
- vscode 插件
- electron 构建桌面应用
- markdown 转 tex + tex 的模板，再转出 docx 和 pdf。

## 原理： markdown 转 docx 转 pdf 实现预览 docx 模板效果

```Bash
pandoc resume.md -o resume.docx  --reference-doc "D:\\My_File\\Product\\pandoc_docx_template\\pandoc_docx_template-main\\pandoc_docx_template-main\\template_标题不编号-列表第二行顶格-合同.docx"
```

### md 转 docx

```bash
pandoc resume.md -o resume.docx  --reference-doc "D:\\My_File\\Product\\pandoc_docx_template\\pandoc_docx_template-main\\pandoc_docx_template-main\\template_标题不编号-列表第二行顶格-合同.docx"
soffice.exe --headless --convert-to pdf 1.docx --outdir ./
```

### docx 转 pdf

现在将这套逻辑写成 vscode plugin
在vscode 打开 markdown 文件，之后可以预览 pdf，预览的时候就进行第一次构建

### 监控 .md 文件的大小

实现 自动 生成和预览

## 其他优秀项目/组合

- LaTeX：vscode + LaTeX Workshop(Author: James Yu)
