#!/bin/bash
REMOTE_CODE_DIR="/opt/mytest_online"
REMOTE_IP="192.168.76.102"
VERSION=${git_version}
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
if [ "$deploy_choice" == "deploy" ];then
    if [ "$GIT_COMMIT" == "$GIT_PREVIOUS_SUCCESSFUL_COMMIT" ];then
        echo "版本$VSERSOIN已部署过，回滚即可"
        exit 1
    else
        main
    fi
elif [ "$deploy_choice" == "rollback" ];then
        lns
fi
