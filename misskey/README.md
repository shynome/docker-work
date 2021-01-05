### 修改配置

#### 修改 postgres 的密码

修改 `docker-compose.yml` 中的 `POSTGRES_PASSWORD` 为更复杂的密码, 可以使用 `openssl rand -base64 16` 生成一个强密码
然后修改 `config/default.yml` 中的 `db pass` 为上一步中的强密码

#### 修改域名

修改 `caddy/misskey.conf` 中的 `example.tld` 为你要使用的域名  
修改 `config/default.yml` 中的 `example.tld` 为你要使用的域名

### 初始化

- `cd /work/misskey`
- `make misskey-init` 创建各种数据存储目录
- `make misskey-update` 创建数据库和 redis 服务
- `make misskey-upgrade` 往数据库中填充数据
- 将 `/work/misskey/docker-compose.yml` 中的 `misskey` 中的 `replicas` 的数量改为 `1`
- `make misskey-update` 正式运行服务

### 升级 misskey

升级 misskey 会暂停服务进行升级

- `cd /work/misskey`
- `docker pull misskey/misskey:12.49.1` 下载对应版本后会有个 sha256 的长串, 编辑 misskey_version 的时候也要加上去, 避免 `make update` 的时候又通过网络检查该版本号是否有新的镜像了, 这样会造成不必要的等待时间
- 编辑 `Makefile` 中的 `misskey_version`
- `make misskey-upgrade` 进行数据迁移
- `make misskey-update` 应用最新版的 misskey
- `make ls` 查看 misskey_misskey 状态是否正常
