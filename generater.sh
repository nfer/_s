#!/bin/bash

function getProgName()
{
	FULLNAME=$0
	FILENAME=${FULLNAME##*/}
	echo $FILENAME
}

if [ $# != 1 ] ; then
	echo "USAGE: $(getProgName) YOURTHEMENAME"
	exit 1
fi

THEMENAME=$1

rm -rf ${THEMENAME}
mkdir ${THEMENAME}

declare -a excludeFolders=(
	"./.git/*"
	"./nfer/*"
	"./sass/*"
	)
declare -a excludeFiles=(
	"./CONTRIBUTING.md"
	"./codesniffer.ruleset.xml"
	"./.travis.yml"
	"./inc/wpcom.php"
	"./generater.sh"
	"./languages/_s.pot"
	"./README.md"
	)

FINDCMD="find . -type f"

# add exclude folders pattern
for i in "${excludeFolders[@]}"; do
	FINDCMD=${FINDCMD}" ! -path \""$i"\""
done

# add exclude files pattern
for i in "${excludeFiles[@]}"; do
	FINDCMD=${FINDCMD}" ! -wholename \""$i"\""
done

# cp files with path
declare -a files=(`eval ${FINDCMD}`)
for i in "${files[@]}"; do
	cp $i ${THEMENAME} --parents

	# Search for: `'_s'` and replace with: `'megatherium'`
	sed -i "s/'_s'/'${THEMENAME}'/g" ${THEMENAME}/$i

	# Search for: ` _s,` or ` _s$` and replace with: `megatherium,` or `megatherium`
	sed -i "s/ _s$/ ${THEMENAME}/g" ${THEMENAME}/$i
	sed -i "s/ _s,/ ${THEMENAME},/g" ${THEMENAME}/$i

	# Search for: `_s_` or `_s ` or `_s-` and replace with: `megatherium_,` or `megatherium ` or `megatherium-`
	sed -i "s/_s_/${THEMENAME}_/g" ${THEMENAME}/$i
	sed -i "s/_s /${THEMENAME} /g" ${THEMENAME}/$i
	sed -i "s/_s-/${THEMENAME}-/g" ${THEMENAME}/$i
done

# special operation for "./languages/_s.pot"
cp "./languages/_s.pot" ${THEMENAME}/"./languages/"${THEMENAME}".pot"
cp "./README.md" ${THEMENAME} --parents
