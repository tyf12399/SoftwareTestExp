#!/bin/bash

# 检查testplans是否存在 
if [ ! -f ./testplans.alt/v3/v0.cov.universe ]; then
	echo "testplans not found!"
  exit 1
fi

# FaultSeed注释状态修改
uncomment() { sed -iE $1's|^/\* \(.*\) \*/$|\1|' ./versions.alt/versions.seeded/v3/FaultSeeds.h; }
comment() { sed -iE $1's|^.*$|/\* \0 \*/|' ./versions.alt/versions.seeded/v3/FaultSeeds.h; }

echo -n "bug号:"
read i
# 依次修改
if [ $i -ne 0 ]; then
	uncomment $i
	echo "添加第 $i 个bug"
	# 编译执行v3
	make -C ./versions.alt/versions.seeded/v3/ build
	comment $i
	# 执行测试用例
	while read -r line; do
	# echo "Grep results for $line :"
		eval "./versions.alt/versions.seeded/v3/grep.exe $line" 1>/dev/null 2>/dev/null
		# echo "--------"
	done < ./testplans.alt/v1/v0.cov.universe

	#获取覆盖率
	mkdir -p ./outputs.alt/outputs.seeded/v3/$i
	mv ./versions.alt/versions.seeded/v3/grep.gcno ./outputs.alt/outputs.seeded/v3/$i/grep.gcno
	mv ./versions.alt/versions.seeded/v3/grep.gcda ./outputs.alt/outputs.seeded/v3/$i/grep.gcda
	rm ./versions.alt/versions/seeded/v3/grep.exe
	gcov ./outputs.alt/outputs.seeded/v3/$i/grep.c
# done
fi
echo "finish!"

