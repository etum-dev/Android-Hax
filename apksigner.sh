#!/usr/bin/env bash
#Check if buildtools in path, else prompt user.
if ! command -v apksigner &>/dev/null; then
                                echo "APKSigner is not in path, please add it"
fi
if ! command -v zipalign &>/dev/null; then
                                echo "Zipalign not in path, please add it"
fi

if [ -z "$1" ]; then
        echo "usage: $0 your-app.apk"
        exit 1
fi
mkdir -p whatever
DIR=whatever
DN=`dirname "$1"`
BN=`basename "$1"`
OUT="$DN/repacked-$BN"
OUT_ALIGNED="$DN/aligned-$BN"
OUT_SIGNED="$DN/signed-$BN"
KEYFILE="/home/miku/my-release-key.keystore"
# Debug mode
set -x

# Repack without the META-INF in case it was already signed
# and flag resources.arsc as no-compress:
function repack(){
                                echo $1
                                unzip -q "$1" -d "$DIR"
                                pushd .
                                cd $DIR

                                rm -rf "$DIR/META-INF"
                                #rm "resources.arsc"
                                zip -n "resources.arsc" -r ../repacked.$$.apk *

                                popd

                                mv "$DIR/../repacked.$$.apk" "$OUT"
}
# Align
function align(){
                                rm -f "$OUT_ALIGNED"
                                zipalign -p -v 4 "$OUT" "$OUT_ALIGNED"
                                zipalign -vc 4 "$OUT_ALIGNED"
                                apksigner sign -verbose -ks $KEYFILE --out "$OUT_SIGNED" "$OUT_ALIGNED"
}
# Cleanup
repack "$1"
align
echo == Done: $OUT_ALIGNED
