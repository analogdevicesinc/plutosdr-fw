#~/bin/sh
# This resets a connected pluto, loads firmware into ram, and boots it
#

#default IP address
ipaddr=192.168.2.1

if [ ! -f ./build/pluto.dfu ] ; then
    echo no file to upload
    exit
fi

ssh_cmd()
{
    sshpass -v -panalog ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null -oCheckHostIP=no root@${ipaddr} "$1" 2>/dev/null
    if [ "$?" -ne "0" ] ; then
	echo ssh command $1 failed
	exit
    fi
}
ssh_cmd "device_reboot ram"

lines=0
attempt=0
while [ "${lines}" -le "8" -a "${attempt}" -le "10" ] 
do
    lines=$(sudo dfu-util -l -d 0456:b673,0456:b674 | wc -l)
    if [ "${lines}" -le "8" ] ; then
	sleep 1
    fi
    ((attempt++))
done

# -R resets/terminates the dfu after we are done
sudo dfu-util -R -d 0456:b673,0456:b674 -D ./build/pluto.dfu -a firmware.dfu
