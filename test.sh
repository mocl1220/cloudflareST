#!/usr/bin/env bash
export LANG=zh_CN.UTF-8
URL=https://speed.cloudflare.com/__down?bytes=100000000
#https://speedtest.poorhub.pro/cf.7z
FILE="./IPlus.txt"

if [ -n "$1" ];then
	URL=$1
fi
if [ -n "$2" ];then
	FILE=$2
fi

echo "清空temp.txt"
rm temp.txt
rm ~/workervless/yxip.txt

./CloudflareST -n 200 -dn 10 -url $URL -tl 200 -sl 10 -f $FILE
echo "重新生成yxip"
cat result.csv | cut -d ',' -f 1 | sed '1d' >> temp.txt
while read -r line; do
	ip=$(echo $line)
	result=$(mmdblookup --file /usr/share/GeoIP/GeoLite2-Country.mmdb --ip $ip country names zh-CN | sed "/./{s/\"//g;s/<utf8_string>//g}")
	echo $ip:443#$result >> ~/workervless/yxip.txt
done < temp.txt
echo "优选结果如下：\n------------------------------------------------------------------------------"
cat ~/workervless/yxip.txt

echo "开始推送"
cd ~/workervless/
git add yxip.txt
git commit -m '自动生成ip'
git push
