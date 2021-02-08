#!/bin/sh
version=$(sudo rpm sudo -qi | egrep "Version" | cut -d':' -f2 | sed -e 's/\s*//g' )
release=$(sudo rpm sudo -qi | egrep "Release" | cut -d':' -f2 | sed -e 's/\s*//g' )
echo "$version $release"
if [[ $version != '1.8.23' || $release != '10.el7' ]];then
    sudo yum update sudo -y
fi
