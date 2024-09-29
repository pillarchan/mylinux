#!/bin/bash
ITEMS=(
"chengbao"
"pingtai"
"pinshu")
WORKDIR="/manifests/games"
HARBOR="harbor.myharbor.com/game"

to_build(){
    for app in ${ITEMS[@]};do
        docker build -f dockerfile/game_deploy.yml --build-arg app=${app} -t ${HARBOR}/${app}:v1 ${WORKDIR}
    done
}


to_build
