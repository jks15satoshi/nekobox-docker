# NekoBox w/ Docker

[NekoBox](https://github.com/wyapx/nekobox) 的 Docker 镜像。

[![Run linter](https://github.com/jks15satoshi/nekobox-docker/actions/workflows/lint.yml/badge.svg)](https://github.com/jks15satoshi/nekobox-docker/actions/workflows/lint.yml)
[![GHCR](https://img.shields.io/badge/Registry-GHCR-blue?logo=docker)](https://github.com/jks15satoshi/nekobox-docker/pkgs/container/nekobox)
[![Docker Hub](https://img.shields.io/badge/Registry-Docker_Hub-blue?logo=docker)](https://hub.docker.com/r/jks15satoshi/nekobox)

## 构建说明

CI 流程会在每天 0 时（UTC）自动执行，检查 NekoBox 在 PyPI 中的最新版本以及 GitHub 存储库 `main` 分支的最新提交，以分别构建下述标签的镜像：

- `latest`, `<release>[-rev.x]`：最新的已发布版本，基于 PyPI 中的最新版本构建。

  ![Docker Image Version (tag)](https://img.shields.io/docker/v/jks15satoshi/nekobox/latest?label=latest&color=blue)

  - `release` 为 NekoBox 的发布版本号；
  - `rev.x` 为镜像修订版本，在此镜像更新且 NekoBox 未发布新版本时追加。
  > 示例：`0.1.0` `0.1.0-post.1` `0.1.0-post.1-rev.1`
- `unstable`, `<release>-<short_commit_sha>[-rev.x]`：最新的非稳定版本，基于存储库 `main` 分支的最新提交构建。

  ![Docker Image Version (tag)](https://img.shields.io/docker/v/jks15satoshi/nekobox/unstable?label=unstable&color=orange)

  - `release` 为 NekoBox 的发布版本号；
  - `short_commit_sha` 为 GitHub 存储库 `main` 分支的最新提交的 7 位短哈希值；
  - `rev.x` 为镜像修订版本，在此镜像更新且 NekoBox 未创建新提交时追加。
  > 示例：`0.1.0-a1b2b3d` `0.1.0-a1b2b3d-rev.1`

> [!WARNING]
> 对于非稳定版本镜像，任何可能的非预期行为皆**合乎预期**。除非你十分清楚自己的行为，否则请勿将其用于生产环境。请自行承担使用非稳定版本的风险。
>
> 本项目不接受来自非稳定版本的任何问题反馈。

CI 流程默认基于 Python 3.12 构建镜像。默认包含 `audio` 可选包。

## 部署

- 使用 `docker run`

  ```shell
  docker run -itd \
    --name nekobox \
    -e NEKOBOX_UIN=<your_account_id> \
    -e NEKOBOX_SIGN_SERVER=<sign_server_url> \
    -v <path_to_nekobox>:/nekobox \
    --restart unless-stopped \
    ghcr.io/jks15satoshi/nekobox:latest
  ```

- 使用 Docker Compose

  ```yml
  services:
    nekobox:
      image: ghcr.io/jks15satoshi/nekobox:latest
      container_name: nekobox
      environment:
        - NEKOBOX_UIN=<your_account_id>
        - NEKOBOX_SIGN_SERVER=<sign_server_url>
      volumes:
        - <path_to_nekobox>:/nekobox
      restart: unless-stopped
  ```

## 配置

你可以通过指定环境变量或 `nekobox.ini` 文件来配置服务器，使用配置文件需要挂载 `/nekobox` 目录并将配置文件置于挂载根目录中。无论配置文件是否存在，都必须指定环境变量 `NEKOBOX_UIN` 以告知 NekoBox 实例应使用什么账号运行。

如果 `nekobox.ini` 文件不存在，或指定的 `NEKOBOX_UIN` 在 NekoBox 实例中的账号列表中不存在，则会尝试通过 `nekobox gen` 命令创建或更新配置文件后运行，配置参数服从下列环境变量：

| 变量名称                | 说明             | 必选 | 默认值              | 可选值                                      |
|-------------------------|------------------|------|---------------------|---------------------------------------------|
| `NEKOBOX_UIN`           | 账号 ID          | true |                     |                                             |
| `NEKOBOX_SIGN_SERVER`   | 签名服务器 URL   | true |                     |                                             |
| `NEKOBOX_PROTOCOL_TYPE` | 协议类型         |      | `remote`            | `remote` `windows` `macos` `linux`          |
| `NEKOBOX_AUTH_TOKEN`    | 服务器认证 token |      | 由 NekoBox 随机生成 |                                             |
| `NEKOBOX_BIND_ADDR`     | 服务器绑定地址   |      | `127.0.0.1`         |                                             |
| `NEKOBOX_BIND_PORT`     | 服务器绑定端口   |      | `7777`              |                                             |
| `NEKOBOX_DEPLOY_PATH`   | 服务器部署路径   |      |                     |                                             |
| `NEKOBOX_LOG_LEVEL`     | 日志等级         |      | `INFO`              | `DEBUG` `INFO` `WARNING` `ERROR` `CRITICAL` |

每次生成或更新配置时，都会根据当前配置生成摘要，以便在后续运行时检查配置是否发生变化。当配置发生变化时，会自动更新配置，以确保 NekoBox 实例始终服从环境变量的配置。

> [!TIP]
> 需要注意，如果没有指定认证 token，每次更新配置都会生成新的认证 token，此时客户端（bot 端）也需要同步更新认证 token 以避免认证失败。你可以在环境变量中指定认证 token 以避免 token 变化。

## 运行选项

可以使用以下环境变量控制运行选项：

| 变量名称              | 说明               | 默认值  | 可选值         |
|-----------------------|--------------------|---------|----------------|
| `NEKOBOX_FILE_QRCODE` | 使用文件保存二维码 | `false` | `true` `false` |

## 调用 NekoBox CLI

一些操作（例如删除配置等）可能无法通过镜像入口脚本实现，此时你可能会希望通过 NekoBox CLI 手动操作，你可以通过以下命令实现：

```shell
docker exec -it nekobox nekobox <args>
```

例如删除配置就可以这样操作：

```shell
$ docker exec -it nekobox nekobox delete 100
账号 100 的配置已删除
```

具体的 CLI 用法请参见 [NekoBox 文档](https://github.com/wyapx/nekobox#cli-%E5%B7%A5%E5%85%B7)，或者执行：

```shell
docker exec -it nekobox nekobox --help
```

## 手动构建

如果你希望自行构建镜像，可以通过以下命令进行构建：

```shell
git clone https://github.com/jks15satoshi/nekobox-docker.git
cd nekobox-docker
docker build -t nekobox .
```

构建时，可以按需传入构建参数，参数列表如下：

| 参数名称                    | 说明                  | 默认值        | 备注                                                                      |
|-----------------------------|-----------------------|---------------|---------------------------------------------------------------------------|
| `BASE_TAG`                  | Python 镜像标签       | `3.12-alpine` |                                                                           |
| `NEKOBOX_VERSION`           | 指定 NekoBox 版本     |               |                                                                           |
| `NEKOBOX_UNSTABLE`          | 是否构建非稳定版本    | `false`       | 为 `true` 时将无视 `NEKOBOX_VERSION` 参数，直接拉取存储库 `main` 分支代码 |
| `NEKOBOX_OPTIONAL_DEPS`     | 安装 NekoBox 可选依赖 | `audio`       | 以逗号分隔的字符串，留空表示不安装可选依赖。目前仅支持 `audio`。          |

## 许可协议

本项目使用 [AGPL-3.0 协议](./LICENSE) 开放源代码。
