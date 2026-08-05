#!/bin/sh

# 复制项目的文件到对应docker路径，便于一键生成镜像。
usage() {
	echo "Usage: sh copy.sh"
	exit 1
}


# copy sql
echo "begin copy sql "
cp ../sql/ry_20260402.sql ./mysql/db
cp ../sql/book_config_20260311.sql ./mysql/db

# copy html
echo "begin copy html "
cp -r ../book-ui/dist/** ./nginx/html/dist


# copy jar
echo "begin copy book-gateway "
cp ../book-gateway/target/book-gateway.jar ./book/gateway/jar

echo "begin copy book-auth "
cp ../book-auth/target/book-auth.jar ./book/auth/jar

echo "begin copy book-visual "
cp ../book-visual/book-monitor/target/book-visual-monitor.jar  ./book/visual/monitor/jar

echo "begin copy book-modules-system "
cp ../book-modules/book-system/target/book-modules-system.jar ./book/modules/system/jar

echo "begin copy book-modules-file "
cp ../book-modules/book-file/target/book-modules-file.jar ./book/modules/file/jar

echo "begin copy book-modules-job "
cp ../book-modules/book-job/target/book-modules-job.jar ./book/modules/job/jar

echo "begin copy book-modules-gen "
cp ../book-modules/book-gen/target/book-modules-gen.jar ./book/modules/gen/jar

