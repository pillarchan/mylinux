#!/bin/bash
if [ $# -lt 1 ];then
    echo "need a group id"
    exit 2
fi
PROJECT_ID=$1
sed -ri 's@[[:space:]]+@@g' project.txt
PROJECT_NAME_LIST=$(cat project.txt)


echo $PROJECT_ID
for i in ${PROJECT_NAME_LIST[@]};do
    curl --request POST --header "PRIVATE-TOKEN: <your-token>" \
         --header "Content-Type: application/json" --data '{ "name": '$i', "description": "", "path": '$i', "namespace_id": '$PROJECT_ID', "initialize_with_readme": "true"}' \
         --url 'https://gitlab.example.com/api/v4/projects/'
done
