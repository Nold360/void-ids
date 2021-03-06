#!/bin/bash
# void - Intrusion Detection Script
#
# By Gerrit 'Nold' Pannek - 2014
# Copyright: GPLv3 or higher
#

CONFIG_FILE="/etc/void/void.conf"
MODULE_PATH="/usr/share/void/modules/"	

function detect_pms {
	for module in $(ls -1 ${MODULE_PATH}/pms/*); do
		if which $(basename $module) &>/dev/null; then
			basename $module
			return 0
		fi
	done
	echo unknown
	return 1
}


# Configuration for filter and output modules
# Params:
#	CONFIG_FILE
#	MODULE_PATH
#	MODULE_TYPE (= OUTPUT|FILTER)
function get_module_config {
	MODULE_TYPE=$1

	. $CONFIG_FILE

	# Default value if not set
	if [ -z "$(eval echo "$"${MODULE_TYPE})" ] ; then
		if [ "$(eval echo "$"${MODULE_TYPE})" == "OUTPUT" ] ; then
			echo "raw"
			return 0
		else
			# default filter-module = none
			echo "none"
			return 0
		fi
        fi

	#Check if we have multiple modules
        if [[ "$(eval echo "$"${MODULE_TYPE})" =~ .*,.* ]] ; then
		[ "$MODULE_TYPE" == "OUTPUT" ] && module_string="tee "

                for module in $(eval echo "$"${MODULE_TYPE} | tr "," " "); do
                        if [ ! -e "${MODULE_PATH}/$(echo $MODULE_TYPE | tr [A-Z] [a-z])/${module}" ] ; then
                                echo "ERROR: Couldn't open module: ${MODULE_PATH}/$(echo $MODULE_TYPE | tr [A-Z] [a-z])/${module}"
                                exit 1
                        fi

                        if [ "$MODULE_TYPE" == "OUTPUT" ] ; then
				module_string="${module_string} >(${MODULE_PATH}/$(echo $MODULE_TYPE | tr [A-Z] [a-z])/${module})" 
			else
				[ ! -z "$module_string" ] && module_string="${module_string} | "
				module_string="${module_string} ${MODULE_PATH}/$(echo $MODULE_TYPE | tr [A-Z] [a-z])/${module}" 
			fi
                done
                [ "$MODULE_TYPE" == "OUTPUT" ] && module_string="${module_string} &>/dev/null"
        else
                if [ ! -e "${MODULE_PATH}/$(echo $MODULE_TYPE | tr [A-Z] [a-z])/$(eval echo "$"${MODULE_TYPE})" ] ; then
                        echo "ERROR: Couldn't open module: ${MODULE_PATH}/$(echo $MODULE_TYPE | tr [A-Z] [a-z])/$(eval echo "$"${MODULE_TYPE})"
                        exit 1
                fi
        fi

	echo $module_string
	return 0
}

function get_config {
	if [ ! -e $CONFIG_FILE ] ; then
		echo "ERROR: Couldn't open $CONFIG_FILE"
		exit 1
	fi	
	. $CONFIG_FILE
	
	[ -z "$DEBUG" ] && DEBUG=false

	if [ -z "$PMS" -o "$PMS" == "auto" ] ; then
		PMS=$(detect_pms)
		if [ "$PMS" == "unknown" ] ; then
			echo "ERROR: No matching PMS-Module found!"
			exit 1
		fi
	fi

	output_module=$(get_module_config OUTPUT)
	filter_module=$(get_module_config FILTER)

	$DEBUG && echo $output_module
	$DEBUG && echo $filter_module	

	if [ ! -e "${MODULE_PATH}/pms/${PMS}" ] ; then
		echo "ERROR: Couldn't load PMS-Module: ${MODULE_PATH}/pms/${PMS}"
		exit 1
	fi
	pms_module=${MODULE_PATH}/pms/${PMS}
}

function main {
	get_config

	eval $pms_module |\
	eval $filter_module |\
	eval $output_module |\
	grep .

	return 0
}

main
