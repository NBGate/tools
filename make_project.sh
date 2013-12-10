#!/bin/bash

WORKDIR=$(cd "$(dirname "$0")";cd ..;pwd)
COCOS2DX_DIR=$WORKDIR/cocos2d-x
COCOS2DX_APP_DIR=$COCOS2DX_DIR/cocos2dx/platform/android/java
CREATOR_SCRIPT_DIR=$COCOS2DX_DIR/tools/project-creator
SCRIPT=$CREATOR_SCRIPT_DIR/create_project.py

usage(){
cat << EOF
usage: $0 [options]

OPTIONS:
-p	project name
-t	android target(et. android-10)
-h	this help
EOF
}

TARGET=android-10
while getopts "p:t:h" OPTION; do
    case "$OPTION" in
        p)
            PROJECT=$(echo $OPTARG)
            ;;
        t)
            TARGET=$(echo $OPTARG)
            ;;
        h)
            usage
            exit 0
            ;;
        ?)
            ;;
    esac
done

if [ -z "${PROJECT+aaa}" ]; then usage;exit 1;fi

cd $CREATOR_SCRIPT_DIR
PACKAGE="game.nbgate.$PROJECT"
LANG=cpp
$SCRIPT -project $PROJECT -package $PACKAGE -language $LANG
if [ $? -ne 0 ]; then exit 1;fi
cd -

PROJECT_DIR=$COCOS2DX_DIR/projects/$PROJECT
TARGETPROJECT_DIR=$WORKDIR/$PROJECT
mv $PROJECT_DIR $TARGETPROJECT_DIR
if [ $? -ne 0 ]; then echo "error: mv project from $PROJECT_DIR to target path $TARGETPROJECT_DIR failed";exit 1;fi

APPDIR=$TARGETPROJECT_DIR/proj.android
cd $APPDIR
sed -i 's/COCOS2DX_ROOT="$DIR\/..\/..\/.."/COCOS2DX_ROOT="$DIR\/..\/..\/cocos2d-x"/' $APPDIR/build_native.sh
grep 'DIR/../../cocos2d-x' $APPDIR/build_native.sh > /dev/null
if [ $? -ne 0 ]; then echo "error: rewrite COCOS2DX_ROOT in build_native.sh failed.";exit 1;fi
sed -i 's/..\/..\/..\/cocos2dx/..\/..\/cocos2d-x\/cocos2dx/' $APPDIR/project.properties
grep '../../cocos2d-x' $APPDIR/project.properties > /dev/null
if [ $? -ne 0 ]; then echo "error: rewrite android.library.reference.1 failed in file project.properties.";exit 1;fi

if [ -f $WORKDIR/tools/build.sh.android ]; then cp $WORKDIR/tools/build.sh.android $APPDIR/build.sh;fi

android update project -n $PROJECT -p $APPDIR -t $TARGET

