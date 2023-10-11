#!/bin/bash
#
# Copyright 2018(c) Analog Devices, Inc.
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#    - Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    - Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in
#      the documentation and/or other materials provided with the
#      distribution.
#    - Neither the name of Analog Devices, Inc. nor the names of its
#      contributors may be used to endorse or promote products derived
#      from this software without specific prior written permission.
#    - The use of this software may or may not infringe the patent rights
#      of one or more patent holders.  This license does not release you
#      from the requirement that you obtain separate licenses from these
#      patent holders to use this software.
#
# THIS SOFTWARE IS PROVIDED BY ANALOG DEVICES "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED.
#
# IN NO EVENT SHALL ANALOG DEVICES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, INTELLECTUAL PROPERTY
# RIGHTS, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

TARGET=$1
TARGET_VERSIONS=$2

MANIFEST=buildroot/output/legal-info/manifest.csv
MANIFEST_SORT=/tmp/manifest.??
sort ${MANIFEST} > ${MANIFEST_SORT}

PACKAGE=1
VERSION=2
LICENSE=3
LICENSE_FILES=4
SOURCE_ARCHIVE=5
SOURCE_SITE=6

FILE=build/LICENSE.html

html_header () {
	echo "<!DOCTYPE html>" > ${FILE}
	echo "<html class=\"no-js\" lang=\"en\">" >> ${FILE}
	echo "<head>" >> ${FILE}
	echo "<meta charset=\"utf-8\">" >> ${FILE}
	echo "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> ${FILE}
	echo "<meta http-equiv=\"x-ua-compatible\" content=\"ie=edge\">" >> ${FILE}
	echo "<title>$1</title>" >> ${FILE}
	echo "<link type=\"text/css\" href=\"./img/style.css\" rel=\"stylesheet\">" >> ${FILE}
	echo "<link rel=\"apple-touch-icon\" href=\"apple-touch-icon.png\">" >> ${FILE}
	echo "<link rel=\"shortcut icon\" href=\"img/favicon.ico\" type=\"image/x-icon\">" >> ${FILE}
	echo "<link type=\"text/css\" href=\"./img/style.css\" rel=\"stylesheet\">" >> ${FILE}
	echo "</head>" >> ${FILE}
	echo "<body>" >> ${FILE}
	echo "<!--[if lte IE 11]>" >> ${FILE}
	echo "<p class=\"browserupgrade\">You are using an <strong>outdated</strong> browser. Please <a href=\"http://browsehappy.com/\">upgrade your browser</a> to improve your experience and security.</p>" >> ${FILE}
	echo "<![endif]-->" >> ${FILE}

	echo "<header id=\"top\">" >> ${FILE}
	echo "<a href=\"http://www.analog.com\">" >> ${FILE}
	echo "<img src=\"img/ADI_Logo_AWP.png\" alt=\"Analog Devices logo\" />" >> ${FILE}
	echo "</a>" >> ${FILE}
	echo "<div class=\"anchor\">" >> ${FILE}
	echo "<a href=\"./index.html\" title=\"Index\">Index</a>" >> ${FILE}
	echo "</div>" >> ${FILE}

	echo "</header>" >> ${FILE}
	echo "<hr>" >> ${FILE}
}

html_footer () {
	echo "</body>" >> ${FILE}
	echo "</html>" >> ${FILE}
}

html_h1 () {
	echo "<h1>$1</h1>" >> ${FILE}
}

html_h1_id () {
	echo "<div class=\"anchor\"><a href=\"#version\">Back to list</a> | <a href=\"#top\">Back to top</a></div>" >> ${FILE}
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
	# get the file, but html sanitize a few things
	find $1 -type f -exec cat {} + | sed -e "s/\o14//g" -e "s/\o302\o251/\&copy;/g" -e "s/'/\&#39;/g" -e "s/</\&lt;/g" -e "s/>/\&gt;/g" >> ${FILE}
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
	html_li "Source Site: <a href=\"${3}\">${3}</a>"
	html_li_stop
}

strstr () {
	echo $1 | grep --quiet $2
}

# package_table_items $((var++)) Linux $(get_version linux) "GPLv2" "https://github.com/analogdevicesinc/linux"
#                     1          2     3                    4       5
package_table_items () {
	url=$5

	command curl -h > /dev/null 2>&1
	if [ "$?" = "0" ] ; then
		if $(strstr $url sourceforge) ; then
			url=$(echo ${url} | sed -e 's/downloads\.//' -e 's/project/projects/')
		fi
		while [ 1 ] ; do
			if $(strstr $url "ftp://") ; then
				break
			fi
			# We should use curl's -L, but then we couldn't track things
			tmp=$(curl -IsS $url)
			if [ $(echo "$tmp" | head -1 | grep -E "301|302" | wc -l) -gt 0 ] ; then
				_url=$url
				url=$(echo "$tmp" | grep -i "Location:" | awk '{print $2}' | sed -e 's/^[ \t]*//;s/[ \t]*$//')
				url=${url%$'\r'}
				if [[ $url != http* ]] ; then
					url=$_url
					break
				fi
			elif [ $(echo "$tmp" | head -1 | grep "404" | wc -l) -gt 0 ] ; then
				url=$(echo $url | sed 's#/[^/]*$##' )
			elif [ $(echo "$tmp" | head -1 | grep "200" | wc -l) -gt 0 ] ; then
				break
			else
				echo "<tr><td>err: ${url}</td><td>" $(echo "$tmp" | head -1) "</td></tr>" >> ${FILE}
				echo unknown error while trying ${url}
				echo "${tmp}"
				break
			fi
		done
	fi

	echo "<tr>" >> ${FILE}
	echo "<td><a href=\"#P${1}\">${2}</a></td>" >> ${FILE}
	echo "<td><a href=\"#P${1}\">${4}</a></td>" >> ${FILE}
	echo "<td>${3}</td>" >> ${FILE}
	echo -n "<td><a href=\"${url}\">" >> ${FILE}
	if $(strstr $5 github) ; then
		echo -n "Github" >> ${FILE}
	elif $(strstr $5 sourceforge) ; then
		echo -n "SourceForge" >> ${FILE}
	elif $(strstr $5 freedesktop) ; then
		echo -n "Freedesktop" >> ${FILE}
	elif $(strstr $5 debian) ; then
		echo -n "Debian Project" >> ${FILE}
	elif $(strstr $5 kernel) ; then
		echo -n "Kernel.org" >> ${FILE}
	else
		echo -n "Project" >> ${FILE}
	fi
	echo "</a></td>" >> ${FILE}
	echo "</tr>" >> ${FILE}
}

# Borrowed concepts from :
# https://github.com/chadbraunduin/markdown.bash/blob/master/markdown.sh
# MIT License
# Copyright (c) 2016 Chad Braun-Duin
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
convert_md2html () {
temp_file="/tmp/markdown.$$"
cat "$1" > "$temp_file"
# All of this below business is for reference-style links and images
# We need to loop across newlines and not spaces
IFS='
'
refs=$(sed -nr "/\[.+\]/p" "$1")
for ref in $refs
do
	ref=$(echo -n "$ref" | sed "s/^.*\[/\[/")
	ref_id=$(echo -n "$ref" | sed -nr "s/^\[(.+)\].*/\1/p" | tr -d '\n')
	ref_url=$(echo -n "$ref" | sed -nr "s/^\[.+\]\((.+)/\1/p" | cut -d' ' -f1 | tr -d '\n')
	ref_title=$(echo -n "$ref" | sed -nr "s/^\[.+\](.+) \"(.+)\"/\2/p" | sed 's@|@!@g' | tr -d '\n' | sed 's/).*$//')
	# reference-style image using the label
	sed -ri "s|!\[([^]]+)\]\[($ref_id)\]|<img src=\"$ref_url\" title=\"$ref_title\" alt=\"\1\" />|gI" "$temp_file"
	# reference-style link using the label
	sed -ri "s|\[($ref_id)\].*\($ref_url \"$ref_title\"\)|<a href=\"$ref_url\" title=\"$ref_title\">\1</a>|gI" "$temp_file"
	# implicit reference-style
	sed -ri "s|!\[($ref_id)\]\[\]|<img src=\"$ref_url\" title=\"$ref_title\" alt=\"\1\" />|gI" "$temp_file"
	# implicit reference-style
	sed -ri "s|\[($ref_id)\]\[\]|<a href=\"$ref_url\" title=\"$ref_title\">\1</a>|gI" "$temp_file"
done

# delete the reference lines
sed -ri "/^\[.+\]: +/d" "$temp_file"
sed -nri "/^# /,/^# /  { /^# /d ; p } " "$temp_file"
sed -ri -e 's/^$/<p>/' "$temp_file"
cat ${temp_file}
rm ${temp_file}
}

### main

html_header "${TARGET} Legal Information"

html_h1 "Legal Information"
html_h1 "${TARGET} Firmware $(get_version device-fw)"

convert_md2html LICENSE.md >> ${FILE}

echo "<div class=\"boxed\">" >> ${FILE}
html_h2 "Written Offer"

echo "<p>As described above, the firmware included in the ${TARGET} contains copyrighted software that is released and distributed under many licenses, including the GPL.
A copy of the licenses are included in this file (below)." >> ${FILE}
if [ "$TARGET" == "PlutoSDR" ] ; then
echo "You may obtain the complete Corresponding Source code from us for a period of three years after our last shipment of this product, which will be no earlier than " >> ${FILE}
date --date="3 years 6 months" +"%d%b%Y" >> ${FILE}
echo ", by sending a money order or check for \$15 (USD) to:</p>
<pre>
Director, Open Source Program Office
Analog Devices
Citypoint
65 Haymarket Terrace
Edinburgh EH5 3PN
United Kingdom
</pre>
<p>Please write “<i>source for the ${TARGET}</i>” in the memo line of your payment.
Since the source does not fit on a DVD-RW, it will be delivered on a USB Thumb drive (hence the higher cost than just DVD or CD).</p>
<p><b>You will also find the source on-line, and are encouraged to obtain it for zero cost, at the project web sites.</b></p>
</div>" >> ${FILE}
else # not PlutoSDR
echo "Since you, the end user built this from source, for ${TARGET}, and didn't get a binary, there is no requirement for a written offer.
</div>" >> ${FILE}
fi

html_h2 "NO WARRANTY"

echo "<pre>" >> ${FILE}
cat LICENSE.md | sed  -n '1,/# NO WARRANTY/!p' | sed "1d" >> ${FILE}
echo "</pre>" >> ${FILE}

### Table of packages
html_h1 "Open source components/packages:"

var=0
echo "<p id=\"version\"><strong>Version Information:</strong></p>" >> ${FILE}
echo "<table>" >> ${FILE}
echo "<thead>" >> ${FILE}
echo "<tr>" >> ${FILE}
echo "<th>Package</th>" >> ${FILE}
echo "<th>License</th>" >> ${FILE}
echo "<th>Version</th>" >> ${FILE}
echo "<th>Location</th>" >> ${FILE}
echo "</tr>" >> ${FILE}
echo "</thead>" >> ${FILE}
echo "<tbody>" >> ${FILE}
package_table_items $((var++)) Linux $(get_version linux) "GPLv2" "https://github.com/analogdevicesinc/linux"
package_table_items $((var++)) U-Boot $(get_version u-boot-xlnx) "GPLv2" "https://github.com/analogdevicesinc/u-boot-xlnx"
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

        package_table_items $((var++)) $package $version $license $source_site

done < "${MANIFEST_SORT}"

echo "</tbody>" >> ${FILE}
echo "</table>" >> ${FILE}

var=0
### Linux
html_hr
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
done < "${MANIFEST_SORT}"

html_footer

rm ${MANIFEST_SORT}
