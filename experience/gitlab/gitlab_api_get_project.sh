#!/bin/bash
if [ $# -lt 2 ];then
	echo "need a project id"
	exit 2;
fi
PROJECT_ID_FROM=$1
PROJECT_ID_TO=$2
curl --header "PRIVATE-TOKEN: c3uqMc2iuAM_i4b8novz" "https://gitlab.example.com/api/v4/groups/$PROJECT_ID_FROM/projects" | jq .[].name > project.txt
sed -ri 's@[[:space:]]+@@g' project.txt

echo $PROJECT_ID
for i in $(cat project.txt);do
    curl --request POST --header "PRIVATE-TOKEN: <your-token>" \
         --header "Content-Type: application/json" --data '{ "name": '$i', "description": "", "path": '$i', "namespace_id": '$PROJECT_ID_TO', "initialize_with_readme": "true"}' \
         --url 'https://gitlab.example.com/api/v4/projects/'
done
