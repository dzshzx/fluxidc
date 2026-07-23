# FluxIDC

> [IDC Flare](https://idcflare.com/) 社区的第三方客户端

FluxIDC 是为 [IDC Flare](https://idcflare.com/) 社区打造的移动客户端,fork 自
[FluxDO](https://github.com/Lingyan000/fluxdo)(Linux.do 的第三方客户端)并适配
idcflare.com,基于 Flutter 开发。打包目标为 Android 与 iOS。

## 下载

<a href="https://github.com/dzshzx/fluxidc/releases"><img alt="Get it on GitHub" src="https://img.shields.io/github/v/release/dzshzx/fluxidc?style=for-the-badge&logo=github&label=GitHub%20Releases" /></a>

- **Android**:从 [Releases](https://github.com/dzshzx/fluxidc/releases) 下载
  `fluxidc-<架构>.apk`(常见设备选 arm64-v8a),可与原版 FluxDO 并存安装;
  应用内置更新检查,指向本仓库 Releases。
- **iOS**:无签名 ipa 需自签安装(AltStore / SideStore 等)。

## 与上游 FluxDO 的差异

- 站点后端切换为 idcflare.com(登录、深链、剪贴板话题识别、
  connect.idcflare.com 信任等级页)
- 独立应用身份:应用名 **IDCFlare**,applicationId
  `com.github.lingyan000.fluxdo.idcflare`,与原版并存安装
- 应用图标与应用内品牌视觉按 IDC Flare 官方 logo 重绘
  (经典/现代两套图标,含 Android 主题图标;可用 `scripts/gen_idcflare_icons.sh` 再生成)
- 关闭 linux.do 专属生态功能(CDK / LDC)
- CI 构建矩阵裁剪为 Android + iOS

## 特性

- **Material Design 3**:现代化 UI 设计,支持动态取色与深色模式
- **完整论坛功能**:浏览话题、发帖回复、搜索、通知、书签、浏览历史
- **Markdown 编辑器**:富文本编辑与 1:1 预览
- **图片支持**:上传、查看、保存,动图原生解码
- **DOH 代理**:集成 Rust 实现的 DNS over HTTPS(防污染,支持 ECH)
- **实时通知**:MessageBus 实时消息推送

## 快速开始

### 前置要求

- Flutter SDK ^3.10.4(版本以 `.fvmrc` 为准)
- Rust 工具链(用于编译 DOH 代理等原生组件)
- Android SDK / Xcode

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/dzshzx/fluxidc.git
   cd fluxidc
   git submodule update --init --recursive
   ```

2. **初始化工作区**
   ```bash
   melos bootstrap
   ```

3. **同步项目状态**(pub get、l10n 生成、代理证书资源)
   ```bash
   just sync
   ```

4. **构建**
   ```bash
   flutter build apk --release --target-platform android-arm64 --dart-define=cronetHttpNoPlay=true
   ```
   Release 签名需在 `android/key.properties` 配置自己的 keystore(见
   `android/app/build.gradle.kts`,缺省回落 debug 签名)。

## 开发

- [开发环境与日常命令](docs/development.md)
- [发版与 iOS IPA](docs/release.md)

## 关于 IDC Flare

[IDC Flare](https://idcflare.com/) 是域名、主机等信息的集散地社区。
本项目为非官方客户端,与 IDC Flare 官方无直接关联。

## 问题反馈

- 提交 [Issue](https://github.com/dzshzx/fluxidc/issues)

## 开源协议

本项目基于 [GPL-3.0](LICENSE) 协议开源。

## 致谢

- 上游项目 [FluxDO](https://github.com/Lingyan000/fluxdo) 及其作者
  [@Lingyan000](https://github.com/Lingyan000) —— 本项目的全部基础
- [IDC Flare](https://idcflare.com/) 社区
