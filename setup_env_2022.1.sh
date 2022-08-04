export CROSS_COMPILE=arm-linux-gnueabihf-
VITIS_BIN=:/tools/Xilinx/Vitis/2022.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin
if [ -z "$(echo $PATH | grep -e ${VITIS_BIN})" ] ; then
        export PATH=$PATH:${VITIS_BIN}
else
        echo "Vitis is already on PATH"
fi
export VIVADO_SETTINGS=/tools/Xilinx/Vitis/2022.1/settings64.sh
export ADI_IGNORE_VERSION_CHECK=1
export VIVADO_VERSION=v2022.1
export VIVADO_SETTINGS=/tools/Xilinx/Vivado/2022.1/settings64.sh

# check if buildroot patches to Vitis are applied
if ! grep -q "/tools/Xilinx/"  /tools/Xilinx/Vitis/2022.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/bin/arm-linux-gnueabihf-gcc; then
	echo "WARNING: buildroot patches for Vitis 2022.1 have to be applied!"
fi

# check if ld.so.conf exists in /tools/Xilinx/Vitis/2022.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/cortexa9t2hf-neon-xilinx-linux-gnueabi/etc
LD_SO_CONF_PATH=/tools/Xilinx/Vitis/2022.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/cortexa9t2hf-neon-xilinx-linux-gnueabi/etc/ld.so.conf
if [ -f "$LD_SO_CONF_PATH" ]; then
	echo "WARNING: remove ${LD_SO_CONF_PATH}!"
fi

# check if libc.a exists
LIBC_PATH=/tools/Xilinx/Vitis/2022.1/gnu/aarch32/lin/gcc-arm-linux-gnueabi/cortexa9t2hf-neon-xilinx-linux-gnueabi/usr/lib/libc.a
if [ ! -f "$LIBC_PATH" ]; then
	echo "WARNING: $LIBC_PATH does not exist! It has to be copied from a Windows installation of Vitis 2022.1."
fi
