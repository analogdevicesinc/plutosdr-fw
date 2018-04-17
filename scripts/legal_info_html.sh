#!/bin/bash

TARGET=$1
TARGET_VERSIONS=$2

MANIFEST=buildroot/output/legal-info/manifest.csv

PACKAGE=1
VERSION=2
LICENSE=3
LICENSE_FILES=4
SOURCE_ARCHIVE=5
SOURCE_SITE=6

FILE=build/LICENSE.html

html_header () {
	echo "<!DOCTYPE html>" > ${FILE}
	echo "<html>" >> ${FILE}
	echo "<head>" >> ${FILE}
	echo "<title>$1</title>" >> ${FILE}
	echo "<link type=\"text/css\" href=\"./img/style.css\" rel=\"stylesheet\">" >> ${FILE}
	echo "</head>" >> ${FILE}
	echo "<body>" >> ${FILE}
}

html_footer () {
	echo "</body>" >> ${FILE}
	echo "</html>" >> ${FILE}
}

html_h1 () {
	echo "<h1>$1</h1>" >> ${FILE}
}

html_h1_id () {
	echo "<h1 id=\"P$2\">$1</h1>" >> ${FILE}
}

html_h2 () {
	echo "<h2>$1</h2>" >> ${FILE}
}

html_p () {
	echo "<p>$1</p>" >> ${FILE}
}

html_pre_file () {
	echo "<pre>" >> ${FILE}
	find $1 -type f -exec cat {} + >> ${FILE}
	echo "</pre>" >> ${FILE}
}

html_li () {
	echo "<li>$1</li>" >> ${FILE}
}

html_li_start () {
	echo "<ul>" >> ${FILE}
}

html_li_stop () {
	echo "</ul>" >> ${FILE}
}

html_hr () {
	echo "<hr>" >> ${FILE}
}

get_column () {
	echo ${1} | cut -d \" -f $(expr ${2} \* 2)
}

get_version () {
	cat ${TARGET_VERSIONS} | grep ${1} | cut -d ' ' -f2
}

package_list_items () {
	html_li_start
	html_li "Version: ${1}"
	html_li "License: ${2}"
	html_li "Source Site: ${3}"
	html_li_stop
}

### main

html_header "${TARGET} Legal Information"

html_h1 "Legal Information"
html_h1 "${TARGET} Firmware $(get_version device-fw)"

echo "<pre>" >> ${FILE}
cat LICENSE.md | sed -n '/#/I,/#/I  { s/#.*//g; p }' >> ${FILE}
echo "</pre>" >> ${FILE}

html_h2 "NO WARRANTY"

echo "<pre>" >> ${FILE}
cat LICENSE.md | sed  -n '1,/# NO WARRANTY/!p' >> ${FILE}
echo "</pre>" >> ${FILE}

### Table of packages
html_h1 "Open source components/packages:"

var=0
html_li_start
# Buidlroot external or local packages
html_li "<a href=\"#P$((var++))\">linux</a>"
html_li "<a href=\"#P$((var++))\">u-boot</a>"

while read -r line
do
	package=$(get_column "${line}" $PACKAGE)

	if [ "$package" == "PACKAGE" ];then
		continue
	fi
	html_li "<a href=\"#P$((var++))\">$package</a>"
done < "$MANIFEST"
html_li_stop
html_hr

var=0
### Linux
html_h1_id "Package: linux" "$((var++))"
package_list_items $(get_version linux) "GPLv2" "https://github.com/analogdevicesinc/linux"
html_h2 "License:"
html_pre_file linux/COPYING
html_hr
### U-Boot
html_h1_id "Package: u-boot" "$((var++))"
package_list_items $(get_version u-boot-xlnx) "GPLv2" "https://github.com/analogdevicesinc/u-boot-xlnx"
html_h2 "License:"
html_pre_file u-boot-xlnx/Licenses/gpl-2.0.txt
html_hr

#### All other  Buildroot Packages
while read -r line
do
	package=$(get_column "${line}" $PACKAGE)

	if [ "$package" == "PACKAGE" ];then
		continue
	fi

	version=$(get_column "${line}" $VERSION)
	license_file=$(get_column "${line}" $LICENSE_FILES)
	license=$(get_column "${line}" $LICENSE)
	source_site=$(get_column "${line}" $SOURCE_SITE)

	html_h1_id "Package: $package" "$((var++))"

	package_list_items $version $license $source_site

	html_h2 "License:"
	html_pre_file "$(dirname $MANIFEST)/licenses/$package-$version/"
	html_hr
done < "$MANIFEST"

html_footer
