#!/bin/bash

# Usage:
#    $ ./builder $ANDROID_ROOT/vendor/samsung_slsi/exynos4x12 \
#	m/ics \
#	vendor/samsung_slsi/exynos4x12 \
#       vendor_samsung_slsi_exynos4x12

SOURCE_GIT_PATH=$1
SOURCE_HEAD=$2
EXTRACT_TO=$3
OUTPUT_PREFIX=$4

DECOMPRESSER=decompress_after_accept_license.templete

echo "Cleaning up existing payload..."
rm -rf payload*

mkdir payload
mkdir -p out
PAYLOAD_DIR=`realpath payload`


echo "Copying source archive to payload from $SOURCE_GIT_PATH..."
pushd $SOURCE_GIT_PATH &> /dev/null

OUT_VERSION=`date +%Y%m%d`
OUT_VERSION="$OUT_VERSION"_`git rev-parse --short $SOURCE_HEAD`
OUT="out/$OUTPUT_PREFIX"_"$OUT_VERSION.run"

git archive $SOURCE_HEAD -o $PAYLOAD_DIR/files.tar
popd &> /dev/null


echo "Copying LICENSE.txt to payload..."
cp $SOURCE_GIT_PATH/LICENSE.txt $PAYLOAD_DIR


echo "Copying installer to payload..."
cat > $PAYLOAD_DIR/installer  << EOF
#!/bin/bash

CDIR=\$1
INSTALL_PATH=\$CDIR/$EXTRACT_TO
mkdir -p \$INSTALL_PATH

echo "Installing files to \$INSTALL_PATH..."
tar -xvf ./files.tar -C \$INSTALL_PATH
EOF
chmod +x $PAYLOAD_DIR/installer


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
