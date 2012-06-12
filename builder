#!/bin/bash

SOURCE_GIT_PATH=$1
SOURCE_HEAD=$2
INSTALLER=installer.templete
DECOMPRESSER=decompress_after_accept_license.templete
OUT=selfextract.bsx


echo "Cleaning up existing payload..."
PAYLOAD_DIR=`realpath payload`
rm -rf $PAYLOAD_DIR
rm payload.tar.gz
mkdir $PAYLOAD_DIR

echo "Copying source archive to payload from $SOURCE_GIT_PATH..."
pushd $SOURCE_GIT_PATH &> /dev/null
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

chmod +x $OUT
echo "Done. made $OUT"
