#!/bin/sh

# 复制项目的文件到对应docker路径，便于一键生成镜像。
usage() {
	echo "Usage: sh copy.sh"
	exit 1
}


# copy sql
echo "begin copy sql "
cp ../sql/ry_20260402.sql ./mysql/db
cp ../sql/rail_config_20260311.sql ./mysql/db

# copy html
echo "begin copy html "
cp -r ../rail-ui/dist/** ./nginx/html/dist


# copy jar
echo "begin copy rail-gateway "
cp ../rail-gateway/target/rail-gateway.jar ./rail/gateway/jar

echo "begin copy rail-auth "
cp ../rail-auth/target/rail-auth.jar ./rail/auth/jar

echo "begin copy rail-visual "
cp ../rail-visual/rail-monitor/target/rail-visual-monitor.jar  ./rail/visual/monitor/jar

echo "begin copy rail-modules-system "
cp ../rail-modules/rail-system/target/rail-modules-system.jar ./rail/modules/system/jar

echo "begin copy rail-modules-file "
cp ../rail-modules/rail-file/target/rail-modules-file.jar ./rail/modules/file/jar

echo "begin copy rail-modules-job "
cp ../rail-modules/rail-job/target/rail-modules-job.jar ./rail/modules/job/jar

echo "begin copy rail-modules-gen "
cp ../rail-modules/rail-gen/target/rail-modules-gen.jar ./rail/modules/gen/jar

