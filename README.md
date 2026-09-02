# skills-manager

用于集中管理个人 Codex skills 的轻量仓库。

## 目录结构

```text
.
├── skills/       # 个人 skills，每个 skill 使用独立目录
├── templates/    # 创建 skill 时可复用的模板
└── scripts/      # 校验、安装或同步等辅助脚本
```

每个 skill 建议采用以下结构：

```text
skills/<skill-name>/
├── SKILL.md      # 必需：skill 说明与执行规则
├── scripts/      # 可选：辅助脚本
├── references/   # 可选：参考资料
└── assets/       # 可选：静态资源
```

## 使用方式

1. 在 `skills/` 下创建独立的 skill 目录。
2. 编写并维护该目录中的 `SKILL.md`。
3. 本地验证后，将 skill 安装或同步到 Codex skills 目录。

当前项目保持最小化，后续按实际需要补充模板和自动化脚本。
