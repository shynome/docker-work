### 修改配置

#### 修改 postgres 的密码

修改 `docker-compose.yml` 中的 `POSTGRES_PASSWORD` 为更复杂的密码, 可以使用 `openssl rand -base64 16` 生成一个强密码
然后修改 `config/default.yml` 中的 `db pass` 为上一步中的强密码

#### 修改域名

修改 `docker-compose.yml` 中的 `example.tld` 为你要使用的域名    
修改 `config/default.yml` 中的 `example.tld` 为你要使用的域名

在 `docker-compose.yml` 的域名修改处有一些说明
```yaml
    labels:
        - traefik.enable=true
        - traefik.http.routers.misskey.rule=Host(`example.tld`)
        - traefik.http.services.misskey.loadbalancer.server.port=3000
        # 下面三条规则是https跳转的, 如果运行在cdn后面的话注释掉这些
        - traefik.http.routers.misskey-http.rule=Host(`example.tld`)
        - traefik.http.routers.misskey-http.middlewares=http2s@file
        - traefik.http.routers.misskey-http.service=noop@internal
        # 自己有证书的话使用这个, 没有的话使用下面那个自动续签. 还有种情况cf开启TLS Full(strict)模式也是需要手动提供证书的
        - traefik.http.routers.misskey.tls=true
        # acme 自动续签
        # - traefik.http.routers.misskey.tls.certresolver=myresolver
```

一共只有三种情况我都写出来好了

##### 单机部署+自动续签证书

```yaml
    labels:
        - traefik.enable=true
        - traefik.http.routers.misskey.rule=Host(`example.tld`)
        - traefik.http.services.misskey.loadbalancer.server.port=3000
        # 下面三条规则是https跳转的, 如果运行在cdn后面的话注释掉这些
        - traefik.http.routers.misskey-http.rule=Host(`example.tld`)
        - traefik.http.routers.misskey-http.middlewares=http2s@file
        - traefik.http.routers.misskey-http.service=noop@internal
        # acme 自动续签
        - traefik.http.routers.misskey.tls.certresolver=myresolver
```

##### 单机部署+已有证书

已有证书放在 `traefik/ssl` 目录下, 在 `traefik/conf.d/tls.yml` 文件中添加索引

```yaml
    labels:
        - traefik.enable=true
        - traefik.http.routers.misskey.rule=Host(`example.tld`)
        - traefik.http.services.misskey.loadbalancer.server.port=3000
        # 下面三条规则是https跳转的, 如果运行在cdn后面的话注释掉这些
        - traefik.http.routers.misskey-http.rule=Host(`example.tld`)
        - traefik.http.routers.misskey-http.middlewares=http2s@file
        - traefik.http.routers.misskey-http.service=noop@internal
        # 使用已有证书
        - traefik.http.routers.misskey.tls=true
```

##### cdn部署

cdn证书放在 `traefik/ssl` 目录下, 在 `traefik/conf.d/tls.yml` 文件中添加索引

```yaml
    labels:
        - traefik.enable=true
        - traefik.http.routers.misskey.rule=Host(`example.tld`)
        - traefik.http.services.misskey.loadbalancer.server.port=3000
        # cf开启TLS Full(strict)模式也是需要手动提供证书的, 不是 strict 模式的话注释掉这个
        - traefik.http.routers.misskey.tls=true
```

### 初始化

- `cd /work/misskey`
- `make misskey-init` 创建各种数据存储目录
- `make misskey-update` 创建数据库和redis服务
- `make misskey-upgrade` 往数据库中填充数据
- 将 `/work/misskey/docker-compose.yml` 中的 `misskey` 中的 `replicas` 的数量改为 `1`
- `make misskey-update` 正式运行服务

### 升级 misskey

升级 misskey 需要暂停服务升级

- `cd /work/misskey`
- `docker pull misskey/misskey:12.49.1` 下载对应版本后会有个 sha256 的长串, 编辑 misskey_version 的时候也要加上去, 避免 `make update` 的时候又通过网络检查该版本号是否有新的镜像了, 这样会造成不必要的等待时间
- 编辑 `Makefile` 中的 `misskey_version`
- `make misskey-upgrade` 进行数据迁移
- `make misskey-update` 应用最新版的 misskey
- `make ls` 查看 misskey_misskey 状态是否正常
