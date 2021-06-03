#!/bin/bash

# What time zone switch to
TZONE="Europe/Minsk"

# Message displayed while console login in
MESSAGE="Unauthorized access to this machine is prohibited
Press <Ctrl-D> if you are not an authorized user!"

# Banner displayed while ssh login in
BANNER="********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
******************************************************************** "


function timezone_set {
	
	if ! command -v timedatectl &> /dev/null; then  # Check if timedatectl commant exists
                echo "timedatectl command not found"
                exit
        fi

        if  timedatectl | grep -q "$TZONE"; then

                echo "Time zone $TZONE is already set"
        else
                timedatectl set-timezone $TZONE
                echo "Time zone is switched to $TZONE"
        fi
}

function chronyd_on {

        if [[ $(systemctl is-enabled chronyd) == enabled ]];
        then
                echo "Chrony service is enabled!"
        else
                echo "Chrony service is disabled and inactive (dead). Enabling and activating..."
                systemctl enable --now chronyd &> /dev/null
        fi
}

function add_message {
	
	echo "Adding message of a day and banner text"
	
	echo "$MESSAGE" > /etc/motd
	echo "$BANNER" > /etc/issue

	sed -i 's!.*Banner.*!Banner /etc/issue!g' /etc/ssh/sshd_config	# Add banner file link to sshd_config
	systemctl restart sshd
}

function lv_create {
	
	echo "Creating logical volumes"
	
	# Install LVM2
	if yum list installed | grep -q "lvm2"; then
		echo "LVM2 is already installed! Nothing to do."
	else
		yum install lvm2 -y &> /dev/null
	fi
	
	#Create physical volume
	if ! pvs | grep -q "/dev/sdb"; then
		pvcreate /dev/sdb > /dev/null
	else
		echo "Physical volume on /dev/sdb is already exists"
	fi

	#Create volume group "data"
	if ! vgs | grep -q "data"; then
        	vgcreate data /dev/sdb > /dev/null
	else
        	echo "Volume group data is already exists"
	fi
	
	#Create logical volume "data01"
	if ! lvs | grep -q "data01"; then
		lvcreate -l 20%VG -n data01 data > /dev/null
	else
		echo "Logical volume data01 is already exists"
	fi
	
	#File system creation for LV data01
	if ! blkid /dev/mapper/data-data01 &> /dev/null; then
		mkfs.ext4 /dev/mapper/data-data01 &> /dev/null
	else
		echo "File system on logical volume data01 is already exists"
	fi

	#Create logical volume "data02"
	if ! lvs |  grep -q "data02"; then
                lvcreate -l 80%VG -n data02 data > /dev/null
        else
                echo "Logical volume data02 is already exists"
        fi
	
	#File system creation for LV data02
        if ! blkid /dev/mapper/data-data02 &> /dev/null; then
                mkfs.ext3 /dev/mapper/data-data02 &> /dev/null
        else
                echo "File system on logical volume data02 is already exists"
        fi
}

function mnt_lv {
	
	echo "Mounting logical volumes"
	
	#Mounting LV persistently
	if ! grep -q "/dev/mapper/data-data01" /etc/fstab; then
		echo "/dev/mapper/data-data01	/data01	ext4	defaults 0 0" >>/etc/fstab
	fi
	
	if ! grep -q "/dev/mapper/data-data02" /etc/fstab; then
                echo "/dev/mapper/data-data02   /data02 ext3    defaults 0 0" >>/etc/fstab
        fi
	

	#Mounting LV to their directories
	if ! grep -q "/dev/mapper/data-data01" /proc/mounts; then
		if [[ ! -d /data01 ]]; then
			mkdir /data01
		else
			echo "/data01 is already exists"
		fi
		mount /data01
	else
		echo "/data01 is already mounted"
	fi

	if ! grep -q "/dev/mapper/data-data02" /proc/mounts; then
                if [[ ! -d /data02 ]]; then
                        mkdir /data02
                else    
                        echo "/data02 is already exists"
                fi
                mount /data02
        else    
                echo "/data02 is already mounted"
        fi
}


timezone_set 	#Set timezone to Europe/Minsk
chronyd_on 	#Enable chronyd
add_message 	#Set banner and motd
lv_create 	# Create a logical volumes
mnt_lv		# Mount created logical volumes

echo "OK"
