#!/bin/bash

# 配置 Swiftly
. "$HOME/.swiftly/env.sh"

# 部署脚本
PROJECT_DIR=$(pwd)

# (自定义)定义打包后文件存放的目录
BUILD_PRO="$PROJECT_DIR/.build/x86_64-swift-linux-musl/release/HelloVapor"

# (自定义)定义服务器上项目部署的目录
DEPLOY_DIR="/www/wwwroot/vaporblog.oldbird.run/"

# (自定义)定义远程服务器的 IP 地址和用户名
SERVER="root@106.52.236.186"

# (自定义)定义 SSH 端口
SSH_PORT=2002

# (自定义)Supervisor 程序名
SUPERVISOR_NAME="vaporblog-oldbird-run"



BUILD_PUBLIC="${PROJECT_DIR}/Public"
BUILD_RESOURCE="${PROJECT_DIR}/Resources"

# 进入项目目录
cd $PROJECT_DIR

# 查看 swift 版本列表
swiftly list

# 1. 编译 linux 项目
xcrun --toolchain swift swift build --swift-sdk x86_64-swift-linux-musl -c release --verbose || { echo "项目构建失败，已退出"; exit 1; }

echo "项目打包成功"

# 2. 停止项目运行
ssh -p $SSH_PORT $SERVER "supervisorctl stop $SUPERVISOR_NAME" || true

# 3. 上传到服务器中
scp -P $SSH_PORT $BUILD_PRO $SERVER:$DEPLOY_DIR || { echo "rsync 上传失败，已退出"; exit 1; }

# Public Resources 和 环境参数文件 文件上传
rsync -avz -e "ssh -p $SSH_PORT" .env .env.production $BUILD_PUBLIC $BUILD_RESOURCE $SERVER:$DEPLOY_DIR || { echo "rsync 上传失败，已退出"; exit 1; }

# 4. 重启项目supervisor
ssh -p $SSH_PORT $SERVER "supervisorctl start $SUPERVISOR_NAME"

echo "部署完成"