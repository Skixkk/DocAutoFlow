---
layout: page
title: Team
---

<!--
 * @Author: Skixkk skixkk7@gmail.com
 * @Date: 2026-08-23 23:00:40
 * @LastEditors: Skixkk skixkk7@gmail.com
 * @LastEditTime: 2026-08-23 23:00:54
 * @FilePath: \DocAutoFlow\docs\team.md
 * @Description: our team
-->

<script setup>
import {
  VPTeamPage,
  VPTeamPageTitle,
  VPTeamMembers
} from 'vitepress/theme'

const members = [
  {
    avatar: 'https://avatars.githubusercontent.com/u/314187173?s=400&u=06f057f085552f24b6b56c234ec2ccbe7a681d73&v=4',
    name: 'runsme-com',
    title: 'open source',
    links: [
      { icon: 'github', link: 'https://github.com/runsme-com' }
    ]
  }
]
</script>

<VPTeamPage>
  <VPTeamPageTitle>
    <template #title>
      Our Team
    </template>
    <template #lead>
      Join us via email: opensource@runsme.com
    </template>
  </VPTeamPageTitle>
  <VPTeamMembers :members />
</VPTeamPage>
