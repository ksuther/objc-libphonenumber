#!/bin/bash
#Downloads the latest sources for libphonenumber and closure-library and builds a standalone JavaScript file for libphonenumber
#Does not include the as-you-type formatter

DOWNLOAD_DIR=$1
CWD=`pwd`

echo "Checking out libphonenumber..."
svn checkout http://libphonenumber.googlecode.com/svn/trunk/ $DOWNLOAD_DIR/libphonenumber

echo "Checking out closure-library..."
svn checkout http://closure-library.googlecode.com/svn/trunk/ $DOWNLOAD_DIR/closure-library

echo "Downloading closure-compiler..."
curl -f -L http://closure-compiler.googlecode.com/files/compiler-latest.zip > $DOWNLOAD_DIR/compiler-latest.zip
unzip -o -d $DOWNLOAD_DIR $DOWNLOAD_DIR/compiler-latest.zip compiler.jar

echo "Compiling libphonenumber..."
cd $DOWNLOAD_DIR
closure-library/closure/bin/build/closurebuilder.py \
    --root=closure-library \
    --namespace="i18n.phonenumbers.PhoneNumberUtil" \
    --output_mode=compiled \
    --compiler_jar=compiler.jar \
    libphonenumber/javascript/i18n/phonenumbers/metadata.js \
    libphonenumber/javascript/i18n/phonenumbers/phonemetadata.pb.js \
    libphonenumber/javascript/i18n/phonenumbers/phonenumber.pb.js \
    libphonenumber/javascript/i18n/phonenumbers/phonenumberutil.js \
        > $CWD/libphonenumber.js