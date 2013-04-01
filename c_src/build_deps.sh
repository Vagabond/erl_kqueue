#!/bin/sh

set -e

VSN="1.0.6"
URL="http://mark.heily.com/sites/mark.heily.com/files/libkqueue-${VSN}.tar.gz"
FILE="libkqueue-${VSN}.tar.gz"
DIR="libkqueue-${VSN}"

if [ `basename $PWD` != "c_src" ]; then
	cd "c_src"
fi

case $1 in
	clean)
		rm $FILE
		rm -rf $DIR
		;;
	*)
		if [ ! -f $FILE ]; then
			curl -s $URL > $FILE
		fi

		if [ ! -d $DIR ]; then
			tar -xzf $FILE
		fi

		cd $DIR
		if [ ! -f config.mk ]; then
			./configure
		fi

		if [ ! -f libkqueue.a ]; then
			make
		fi
		;;
esac
