# huaweicloud-devkit → ClawHub Publisher

从 npm 拉取 `huaweicloud-devkit` 指定版本，发布到 [ClawHub](https://clawhub.ai) OpenClaw 插件市场。

## 前置条件

```bash
npm i -g clawhub
clawhub login
```

## 用法

```powershell
# 正式发布
.\publish.ps1 -Version 1.0.2-next.16

# 预览（不实际上传）
.\publish.ps1 -Version 1.0.2-next.16 -DryRun
```

## 流程

```
.\publish.ps1 -Version x.y.z
        │
        ▼
npm install huaweicloud-devkit@x.y.z
        │
        ▼
提取 node_modules/huaweicloud-devkit/plugins/huaweicloud-core/
        │  (npm package.json files 字段 → 包含此目录)
        ▼
补 openclaw.plugin.json（若 npm 包中缺失）
        │
        ▼
clawhub package publish
  --family bundle-plugin    --bundle-format codex
  --name huaweicloud-devkit --version x.y.z
        │
        ▼
ClawHub 上架 → openclaw plugins install clawhub:huaweicloud-devkit
```

## 文件

| 文件 | 说明 |
|------|------|
| `publish.ps1` | 一键发布脚本 |
| `openclaw.plugin.json` | OpenClaw 声明（npm 包缺少时的备用件） |
| `README.md` | 本文件 |