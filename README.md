# NekoBox w/ Docker

[NekoBox](https://github.com/wyapx/nekobox) 的 Docker 镜像。

## 构建说明

CI 流程会在每天 0 时（UTC）自动运行检查 PyPI 中 `nekobox` 的最新版本，当存在更新版本发布则会使用新版本构建 Docker 镜像，版本标签与 PyPI 版本号保持一致；如果镜像文件更新而 nekobox 包尚未更新，则会以 `-post.x` 版本标签进行构建。

CI 流程基于 Python 3.12 构建镜像。包含 `audio` 可选包。

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

## 手动构建

如果你希望自行构建镜像，可以通过以下命令进行构建：

```shell
git clone https://github.com/jks15satoshi/nekobox-docker.git
cd nekobox-docker
docker build -t nekobox .
```

构建时，可以按需传入构建参数，参数列表如下：

| 参数名称   | 说明              | 默认值        |
|------------|-------------------|---------------|
| `base_tag` | Python 镜像标签   | `3.12-alpine` |
| `version`  | 指定 NekoBox 版本 |               |

## 许可协议

本项目使用 [AGPL-3.0 协议](./LICENSE) 开放源代码。
