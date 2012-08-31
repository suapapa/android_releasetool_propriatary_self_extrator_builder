#!/bin/bash

SOURCE_GIT_PATH=$1
SOURCE_HEAD=$2
INSTALLER=installer.templete
DECOMPRESSER=decompress_after_accept_license.templete

echo "Cleaning up existing payload..."
rm -rf payload*

mkdir payload
PAYLOAD_DIR=`realpath payload`

echo "Copying source archive to payload from $SOURCE_GIT_PATH..."
pushd $SOURCE_GIT_PATH &> /dev/null

mkdir -p out
OUT_VERSION=`git rev-parse --short $SOURCE_HEAD`
OUT_VERSION=$OUT_VERSION`date +_%Y%m%d`
OUT=out/samsung_exynos4_proprietary_$OUT_VERSION.run

git archive $SOURCE_HEAD -o $PAYLOAD_DIR/files.tar
popd &> /dev/null

echo "Copying LICENSE.txt to payload..."
cp $SOURCE_GIT_PATH/LICENSE.txt $PAYLOAD_DIR

echo "Copying installer to payload from $INSTALLER"
cp $INSTALLER $PAYLOAD_DIR/installer


echo "Making self-extractor..."
pushd $PAYLOAD_DIR &> /dev/null
tar cf ../payload.tar ./*
popd &> /dev/null

if [ -e "payload.tar" ]; then
    gzip payload.tar

    if [ -e "payload.tar.gz" ]; then
        cat $DECOMPRESSER payload.tar.gz > $OUT
    else
        echo "payload.tar.gz does not exist"
        exit 1
    fi
else
    echo "payload.tar does not exist"
    exit 1
fi

rm -rf payload*
chmod +x $OUT
echo "Done. made $OUT"
