#!/bin/bash
read -p "输入平台缩写:" sx
read -p "输入要更改代码:" dm
h5b=`echo $dm | awk -F ',' '{print $1}'`
if [ $sx == ng ]
then 
y=`cat /d/gitee/ng/android_2019.txt | awk -F ',' '{print $6","$7}'| sed 's/\"//'`
h5a=`echo $y | awk -F ',' '{print $1}'`
sed -i "s/$y/$dm/g" /d/gitee/ng/android_2019.txt
sed -i "s/$y/$dm/g" /d/gitee/ng/ios_2019.txt
sed -i "s/$h5a/$h5b/g" /d/gitee/ng/h5_release.txt
sed -i "s/$y/$dm/g" /d/github/ng/android_2019.txt
sed -i "s/$y/$dm/g" /d/github/ng/ios_2019.txt
sed -i "s/$h5a/$h5b/g" /d/github/ng/h5_release.txt

elif [ $sx == c7 ]
then
y=`cat /d/gitee/c7/android_2020.txt | awk -F ',' '{print $6","$7}'| sed 's/\"//'`
h5a=`echo $y | awk -F ',' '{print $1}'`
sed -i "s/$y/$dm/g" /d/gitee/c7/android_2020.txt
sed -i "s/$y/$dm/g" /d/gitee/c7/ios_2018.txt
sed -i "s/$h5a/$h5b/g" /d/gitee/c7/h5_release.txt
sed -i "s/$y/$dm/g" /d/github/c7/android_2020.txt
sed -i "s/$y/$dm/g" /d/github/c7/ios_2018.txt
sed -i "s/$h5a/$h5b/g" /d/github/c7/h5_release.txt
elif [ $sx == 28 ]
then
y=`cat /d/gitee/28quan/300/dk28quan_android.txt | awk -F ',' '{print $6","$7","$8}'| sed 's/\"//'`
h5a=`echo $y | awk -F ',' '{print $1}'`
sed -i "s/$y/$dm/g" /d/gitee/28quan/300/dk28quan_android.txt
sed -i "s/$y/$dm/g" /d/gitee/28quan/300/dk28quan_ios.txt
sed -i "s/$h5a/$h5b/g" /d/gitee/28quan/300/h5_release.txt
sed -i "s/$y/$dm/g" /d/github/28quan/300/dk28quan_android.txt
sed -i "s/$y/$dm/g" /d/github/28quan/300/dk28quan_ios.txt
sed -i "s/$h5a/$h5b/g" /d/github/28quan/300/h5_release.txt

fi
