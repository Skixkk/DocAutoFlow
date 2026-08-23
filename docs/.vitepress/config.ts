/*
 * @Author: Skixkk skixkk7@gmail.com
 * @Date: 2026-08-23 22:26:32
 * @LastEditors: Skixkk skixkk7@gmail.com
 * @LastEditTime: 2026-08-23 23:53:36
 * @FilePath: \DocAutoFlow\docs\.vitepress\config.ts
 * @Description: config.ts
 */

import { defineConfig } from 'vitepress'


// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/DocAutoFlow/',
  lang: 'en-US',

  head: [
    // add icon
    ['link', {
      rel: 'icon',
      href: 'https://runsme-com.github.io/favicon.ico'
    }]
  ],

  title: "DocAutoFlow",
  description: "Docx‑Markdown‑Watcher",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: {
      dark: 'https://runsme-com.github.io/favicon.ico',
      light: 'https://runsme-com.github.io/light-icon.png',
    },

    lastUpdated: {
      text: 'Updated at',
      formatOptions: {
        dateStyle: 'full',
        timeStyle: 'medium'
      }
    },

    // 网站标题
    siteTitle: 'DocAutoFlow',
    // aside: 'left',
    // lastUpdatedText: "最后更新于(基于Git)",
    search: {
      provider: 'local'
    },

    nav: [
      // 一级目录 1
      { text: 'Home', link: '/' },
      {
        text: 'Start',
        items: [
          { text: 'Start', link: '/start' },
          { text: 'Config', link: '/config' }
        ]
      },
      // 一级目录 2
      { text: 'Team & Contributors', link: '/team' } // 指向我们新建的 team.md
    ],

    sidebar: [
      {
        // text: 'started',
        items: [
          { text: 'Start', link: '/start' },
          { text: 'Guide', link: '/guide' },
          { text: 'Config', link: '/config' },
          { text: 'Link', link: '/link' },
          { text: 'Our Team', link: '/our-team' }
        ]
      }
    ],


    // 定义切换页面上方显示的文字
    // docFooter: {
    //   prev: 'Pagina prior',
    //   next: 'Proxima pagina'
    // },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/Skixkk/DocAutoFlow' }
    ],

    // 在 github 上编辑页面的链接 定义根路径 + docs/ 下的 route，即可实现访问
    editLink: {
      pattern: 'https://github.com/Skixkk/DocAutoFlow/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },

    footer: {
      copyright: 'Open source · <a href="https://github.com/Skixkk/DocAutoFlow/blob/main/LICENSE">MIT</a> · © 2026 <a href="https://github.com/Skixkk">Skixkk</a>. All rights reserved.'
    }
  }
})
