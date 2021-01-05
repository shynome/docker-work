## 简介

这是我部署`misskey`的最佳实践

注: 后续也许会加入其他服务

## 初始化

- `git clone https://github.com/shynome/docker-work.git /work` 克隆本仓库到服务器上
- `curl -sSL https://get.docker.com | sh` 安装 docker    
  注: 国内可使用阿里云镜像 `curl -sSL https://get.docker.com | sh -s -- --mirror Aliyun`
- `apt install make` 安装 `make` 命令
- `cd /work && make swarm-init` docker swarm init

## 启动

- `make update` 部署服务, 会占用 80 和 443 端口
- `make ls` 查看服务是否启动完成, 耐心等待, 初次运行要下载镜像, 需要的时间比较久一点

如果特别久的话用 `docker service ps main_proxy` 查看是否 `ERROR` 一栏是否出现错误, 如果`STATE`一栏是 `Pending` 就说明还在拉取镜像, 继续等待即可    
如果有错的话用 `docker inspect 1g4` (`1g4`是 `ID` 一栏中的前三位) 查看错误的 Task 详情

## 部署 misskey

[点此跳转](./misskey/README.md)

## 重载caddyserver配置

```sh
cd /work
nano caddy/misskey.conf
make proxy-reload
```

### 查看日志

`docker service logs -f --since 0m main_proxy`

`-f` 保持前台运行
`--since 0m` 查看多少分钟钱的日志
`main_proxy` 哪个服务

### 手动运行容器

就是把 docker-compose.yml 里定义的配置都写上去, 执行有错的话会把错误直接输出到控制台

```sh
docker run \
    --rm -ti \
    -p 80:80 \
    -p 443:443 \
    -v /work/traefik:/etc/traefik:rslave \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --net main_default \
    --net main_link \
    traefik:v2.3.2@sha256:6e6d4dc5a19afe06778ca092cdbbb98e31cb9f9c313edafa23f81a0e6ddf8a23
```

## 主机迁移

打包 `/work` 目录即可.    
注意: 这样是不带日志, 容器镜像的, 到新服务器是要重新下载容器镜像的, 日志是会丢失掉的, 如果要打包这些的话, 把 docker 的 data-root 文件夹也打包过去即可

- `ssh old-server`
- `systemctl stop docker` 简单粗暴直接停止 `docker` 服务
- `tar -czvf /tmp/w.tgz -C /work .` 打包 `/work` 目录
- `exit` 回到本地
- `scp old-server:/tmp/w.tgz new-server:/tmp/w.tgz` 压缩包传到新服务器上
- `ssh new-server`
- `mkdir -p /work && tar -xzvf /tmp/w.tgz -C /work` 解压压缩包
- 执行 `初始化` 步骤
- `cd /work && make update` 启动 `proxy` 服务.
- `cd /work/misskey && make misskey-update` 启动 `misskey` 服务

## 一些碎语

- 使用的是`docker swarm`进行部署而不是`docker-compose`
- docker service network 性能不行, 几千并发就垮了, 要更高性能的话请直接继承本机网络或使用其他更好的方案
