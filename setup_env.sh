#!/bin/sh
#
# print out a few things to make it easier for people to set up their environment
#

PREFIX=/opt/Xilinx

XILINX_REV=$(grep -e "set[[:space:]]*REQUIRED_VIVADO_VERSION" $(find ./hdl -name adi_project_xilinx.tcl) | awk '{print $NF}' | sed 's/"//g')
echo trying to find Vivado $XILINX_REV

echo "this can take a minute or two, please wait"

for f in $(find ${PREFIX} -name vivado -executable -type f | grep ${XILINX_REV})
do
	b=$(file ${f} | grep ELF)
	if [ ! -z "${b}" ] ; then
		BITS=$(echo $b | sed 's/ /\n/g' | grep bit | sed 's/-bit//')
	fi
done
GCC=$(dirname $(find ${PREFIX} -name arm-linux-gnueabihf-gcc | grep ${XILINX_REV} ))
SET=$(find ${PREFIX} -name settings${BITS}.sh | grep ${XILINX_REV} | grep Vivado)

if [ -z "${CROSS_COMPILE}" ] ; then
	echo "export CROSS_COMPILE=arm-linux-gnueabihf-"A
else
	if [ "${CROSS_COMPILE}" != "arm-linux-gnueabihf-" ] ; then
		echo "export CROSS_COMPILE=arm-linux-gnueabihf-"
		echo "#CROSS_COMPILE currently set to \"${CROSS_COMPILE}\""
	else
		echo "#CROSS_COMPILE set properly"
	fi
fi
if [ -z "$(echo $PATH | grep -e ${GCC})" ] ; then
	echo "export PATH=\$PATH:${GCC}"
else
	echo "#gcc already on PATH"
fi
if [ -z "${VIVADO_SETTINGS}" ] ; then
	echo "export VIVADO_SETTINGS=${SET}"
else
	if [ "${VIVADO_SETTINGS}" != "${SET}" ] ; then
		echo "export VIVADO_SETTINGS=${SET}"
		echo "#VIVADO_SETTINGS currently set to \"${VIVADO_SETTINGS}\""
	else
		echo "#VIVADO_SETTINGS set properly"
	fi
fi
echo "Copy/paste those into your environment"
