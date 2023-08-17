#!/bin/bash
REMOTE_CODE_DIR="/opt/mytest/"
REMOTE_IP="192.168.76.102"
VERSION=${BUILD_ID}
package(){
    tar zcf web_${VERSION}.tar.gz ./*
}

copy_code(){
    scp web_${VERSION}.tar.gz $REMOTE_IP:$REMOTE_CODE_DIR
    rm -f web_${VERSION}.tar.gz
}

deploy(){
    ssh $REMOTE_IP "cd $REMOTE_CODE_DIR;mkdir web_${VERSION};tar xf web_${VERSION}.tar.gz -C web_${VERSION};rm -f web_${VERSION}.tar.gz"
}

lns(){
    ssh $REMOTE_IP "cd $REMOTE_CODE_DIR;rm -rf html;ln -s web_${VERSION} html"
}

main(){
    package
    copy_code
    deploy
    lns
}
main
