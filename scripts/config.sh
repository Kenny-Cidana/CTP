#!/bin/bash

echo "file name  :" $0;
echo "argu count :" $#;
echo "arguments  :" $*;

help=0;
if [ $# -ne 2 ]; then
    help=1;
elif [ "$1" == '-h' ]; then
    help=1;
elif [ "$1" != '-c' ]; then
    help=1;
fi
# echo "help=${help}"

# Color Setting for echo export
#    Black        0;30     Dark Gray     1;30
#    Red          0;31     Light Red     1;31
#    Green        0;32     Light Green   1;32
#    Brown/Orange 0;33     Yellow        1;33
#    Blue         0;34     Light Blue    1;34
#    Purple       0;35     Light Purple  1;35
#    Cyan         0;36     Light Cyan    1;36
#    Light Gray   0;37     White         1;37

if [ $help -eq 1 ]; then
    echo "*-----------------------------------------------------------------------------------------";
    echo "* launch.sh                                                                               ";
    echo "*     config and generate the config files        ";
    echo "*                                                                                         ";
    echo "* Usage: ./config.sh [-opts] [args]                                                       ";
    echo "*                                                                                         ";
    echo "*     -h : print help                                                                     ";
    echo "*     -c : assign config files root                                                       ";
    echo "*           [arg] config files root dir                                                  ";
    echo "*                                                                                         ";
    echo "* example                                                                                 ";
    echo "*     ./config.sh                                            ";
    echo "*-----------------------------------------------------------------------------------------";

    exit 0;
fi

echo -e "\033[1;35m CTP configuration start ...\033[0m"

cfg_root_dir=../confs/$2
echo "*--------------------------------------------------------------------------------------------"
echo "* [Input Arguments] "
echo -e "*   config root    => \033[1;32m${cfg_root_dir}\033[0m"
echo "*--------------------------------------------------------------------------------------------"

if [ -d ${cfg_root_dir} ]; then
    echo -e "\033[1;33m config dir \033[4m${cfg_root_dir}\033[0m\033[1;33m already exist\033[0m"
    sel_opt=1
    while [ ${sel_opt} -eq 1 ]
    do
        sel_opt=0
        echo -e -n "   Are you sure to delete it before continue\033[0m [Y/n]"
        read del_cfg_dir
        if [ ! -n "${del_cfg_dir}" ]; then
            del_cfg_dir="Y"
        fi
        echo ${del_cfg_dir} | grep -E "[Y|y|N|n]" > /dev/null
        if [ $? -ne 0 ]; then
            # del_cfg_dir="n"
            sel_opt=1
            continue
        fi
        # echo "del_cfg_dir: ${del_cfg_dir}"
        if [ "${del_cfg_dir}" != "Y" ] && [ "${del_cfg_dir}" != "y" ]; then
            # stop and exit
            exit 1
        fi

        rm -rf ${cfg_root_dir}
        if [ $? -ne 0 ]; then
            echo -e "\033[1;31m Failed to delete config dir ${cfg_root_dir} \033[0m"
            exit -10
        fi
        echo -e "    ${cfg_root_dir}\033[0m     --> \033[1;32mDeleted\033[0m"
    done
fi

# grab the IP address of this machine
this_machine=`ip addr | grep inet | grep -v inet6 | grep -E "global (dynamic)+ ens" | awk '{print $2}' |awk -F "/" '{print $1}'`
# echo "this_machine: ${this_machine}"
if [ ! -n "${this_machine}" ]; then
    echo -e "\033[1;30m Failed to get current machind IP \033[0m"
fi

echo -e "\033[1;36m Collect settings ...\033[0m"

echo -e " Service IP or hostname example: "
if [ ! -n "${this_machine}" ]; then
    echo -e "    1) IP       : \033[4m1.2.3.4\033[0m"
    echo -e "    2) hostname : \033[4mwww.abc.com\033[0m"
    echo -e -n "\033[1;33m target machine: \033[0m (IP or hostname)"
else
    echo -e "    1) IP       : \033[4m${this_machine}\033[0m (this machine)"
    echo -e "    2) hostname : \033[4mwww.abc.com\033[0m"
    echo -e -n "\033[1;33m target machine: \033[0m (press Enter key to use this machine IP \033[0;36m\033[4m${this_machine}\033[0m)"
fi
read target_machine
if [ ! -n "${target_machine}" ]; then
    target_machine=${this_machine}
fi

# validate IP or domain
# echo ${target_machine}
ip=`echo ${target_machine} | grep -E "(^([1-9]|1[0-9]|1[1-9]{2}|2[0-4][0-9]|25[0-5])\.)(([0-9]{1,2}|1[1-9]{2}|2[0-4][0-9]|25[0-5])\.){2}([1-9]|[1-9][0-9]|1[1-9]{2}|2[0-5][0-9]|25[0-4])$"`
# echo "ip: ${ip}"
if [ ! -n "${ip}" ]; then
    # check if user input is hostname
    hname=`echo ${target_machine} | grep -E "^\w+(\.\w+)*\.\w+"`
    # echo "hname:${hname}"
    if [ ! -n "${hname}" ]; then
        echo -e "\033[1;31m Invalid service IP or hostname \033[0m"
        exit -1;
    fi
fi

echo -e " Service Port"
echo -e "    1) value should greater than \033[4m999\033[0m"
echo -e "    2) port \033[4m8082\033[0m, \033[4m8080\033[0m & \033[4m3000\033[0m are reserved for internal using"
echo -e -n "\033[1;33m port: \033[0m (press Enter key to use default port \033[0;36m\033[4m8083\033[0m)"
read target_port
if [ ! -n "${target_port}" ]; then
    # echo "no input"
    target_port=8083
# else 
#     echo ${target_port} | grep -E "[ ]+" #> /dev/null
#     # echo ${target_port}
#     if [ $? -eq 0 ]; then
#         echo "input one or more space"
#         target_port=8083
#     fi
fi

# validate port
# echo ${target_port}
echo ${target_port} | grep -E "[0-9]{4,}" > /dev/null
if [ $? -ne 0 ]; then
    echo -e "\033[1;31m Invalid service port, it should be number with value greater than 999 \033[0m"
    exit -1;
fi

echo "*--------------------------------------------------------------------------------------------"
echo "* [Config items collected] "
echo -e "   target machine : \033[1;32m${target_machine}\033[0m"
echo -e "   target port    : \033[1;32m${target_port}\033[0m"
echo "*--------------------------------------------------------------------------------------------"


echo -e "\033[1;36m Config files generating ...\033[0m"

# duplicate config files from example
src_dir=../confs/example/
cp -r ${src_dir} ${cfg_root_dir}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "    Clone \033[0;36m${src_dir}\033[0m to \033[0;36m${cfg_root_dir}\033[0m          --> \033[1;31mFailed\033[0m"
    exit -2;
fi
echo -e "    Clone \033[0;36m${src_dir}\033[0m to \033[0;36m${cfg_root_dir}\033[0m          --> \033[1;32mOK\033[0m"

# ----------- handle app.conf --------------------------------------
cfgfile=${cfg_root_dir}/data_service_api/conf/app.conf
if [ ! -f ${cfgfile} ]; then
    echo -e "    \033[0;36m${cfgfile}\033[0m      --> \033[1;31mNot Found\033[0m"
    exit -3;
fi
# echo -e "    \033[0;36m${cfgfile}\033[0m      --> \033[1;32mFound\033[0m"

# {jenkins_server} ==> target_machine
# cat ${cfgfile} | grep "{jenkins_server}"
# sed -n -i 's/{jenkins_server}/${target_machine}/g' ${cfgfile}
sed -i 's/{jenkins_server}/'$target_machine'/g' ${cfgfile}

# {awcy_server} ==> target_machine
sed -i 's/{awcy_server}/'$target_machine'/g' ${cfgfile}

# {web_server} ==> target_machine
sed -i 's/{web_server}/'$target_machine'/g' ${cfgfile}

# {port} ==> target_port
sed -i 's/{port}/'$target_port'/g' ${cfgfile}

echo -e "    ${cfgfile}\033[0m      --> \033[1;32mProcessed\033[0m"

# ----------- handle app.conf --------------------------------------
cfgfile=${cfg_root_dir}/web_ui/www/apiCfg.php
if [ ! -f ${cfgfile} ]; then
    echo -e "    \033[0;36m${cfgfile}\033[0m     --> \033[1;31mNot Found\033[0m"
    exit -3;
fi
# echo -e "    \033[0;36m${cfgfile}\033[0m     --> \033[1;32mFound\033[0m"

# {web_server} ==> target_machine
sed -i 's/{web_server}/'$target_machine'/g' ${cfgfile}

# {jenkins_server} ==> target_machine
sed -i 's/{jenkins_server}/'$target_machine'/g' ${cfgfile}

# {awcy_server} ==> target_machine
sed -i 's/{awcy_server}/'$target_machine'/g' ${cfgfile}

# {awcy_server} ==> target_machine
sed -i 's/{awcy_server}/'$target_machine'/g' ${cfgfile}

# {api_server} ==> target_machine
sed -i 's/{api_server}/'$target_machine'/g' ${cfgfile}

# {port} ==> target_port
sed -i 's/{port}/'$target_port'/g' ${cfgfile}

echo -e "    ${cfgfile}\033[0m     --> \033[1;32mProcessed\033[0m"

echo -e "\n \033[42;30m all config files generate successfully \033[0m"

echo -e "\n Now, you can deploy the CTP by following command"
echo -e "\033[0;32m     sudo ./launch.sh -c $PWD/${cfg_root_dir} -t ~/ctp -p ${target_port} \033[0m\n"

exit 0
