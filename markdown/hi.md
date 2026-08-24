<!--
 * @Author: Skixkk skixkk7@gmail.com
 * @Date: 2026-08-23 18:15:39
 * @LastEditors: Skixkk skixkk7@gmail.com
 * @LastEditTime: 2026-08-25 01:35:49
 * @FilePath: \DocAutoFlow\markdown\hi.md
 * @Description: hi
-->
# hi

## one

### 1

- [runsme.com](https://github.com/runsme-com)

### `/markdown` 下可以删除的目录及文件

```Text
\DocAutoFlow\markdown
│   hi.md
│   
├───articles
│       sci.md
│       
└───folder
    │   chapter1.md
    │   chapter2.md
    │   
    └───tips
            tip_one.md
```

- 以上 文件和目录皆为演示所用，可以删除，并根据需求重新组织
- 另一种使用 脚本的方式，将 `watch-md2pdf.ps1` 脚本放在需要转换的 `.md` 所在的文件夹中，之后 使用 `powershell` 在  cd 到 `watch-md2pdf.ps1` 所处目录 执行 `./watch-md2pdf.ps1`

Attention:

- `watch-md2pdf.ps1` 会 递归探测 转换 所在文件夹及其子文件夹的全部 `.md` 并 生成 `.docx` `.pdf` 文件并在 没有 `Ctrl + C` 退出时，持续监控文件变化并进行转换，直到 使用  `Ctrl + C` 关闭，或关闭 所在执行终端，即 进程被 kill 了，才会停止 监控和转换。
