#!/bin/bash

echo "file name  :" $0;
echo "argu count :" $#;
echo "arguments  :" $*;

help=0;
if [ $# -eq 0 ]; then
    help=1;
elif [ "$1" != '-c' ]; then
    help=1;
elif [ "$1" == '-c' ]; then
    if [ $# -ne 4 ] && [ $# -ne 6 ] && [ $# -ne 5 ] && [ $# -ne 7 ]; then
        help=1;
    elif [ "$3" != '-t' ]; then
        help=1;
    fi
fi

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
    echo "*     download docker image, setup running environment, and then launch the system        ";
    echo "*                                                                                         ";
    echo "* Usage: ./launch.sh [-opts] [args]                                                       ";
    echo "*                                                                                         ";
    echo "*     -h : print help                                                                     ";
    echo "*     -c : assign config root dir                                                         ";
    echo "*          [arg] config files root dir                                                    ";
    echo "*     -t : assign target dir                                                              ";
    echo "*          [arg] target dir to store the config fils and run-time data                    ";
    echo "*                target root dir MUST BE FULL-PATH, for example                           ";
    echo "*                $PWD                                                                     ";
    echo "*     -p : assign web service port                                                        ";
    echo "*          [arg] web service port, default to 80                                          ";
    echo "*                port reserved: 8080,9000                                                 ";
    echo "*                                                                                         ";
    echo "*     -u : force update docker image from docker hub                                      ";
    echo "*                                                                                         ";
    echo "* example                                                                                 ";
    echo "*     ./launch.sh -c ./cust1/ -t ~/tfs -p 8888 -u                                         ";
    echo "*-----------------------------------------------------------------------------------------";

    exit 0;
fi

echo -e "\033[1;33m Setup & Launch start ...\033[0m"


cfg_root_dir=$2
tar_root=$4
port=80
if [ $# -ge 5 ] && [ "$5" == '-p' ]; then
    port=$6
fi

dl_dockerimg=0
if [ $# -eq 5 ] && [ "$5" == '-u' ]; then
    dl_dockerimg=1
elif [ $# -eq 7 ] && [ "$7" == '-u' ]; then
    dl_dockerimg=1
fi

# echo "dl_dockerimg: "${dl_dockerimg}
if [ ${dl_dockerimg} -eq 1 ]; then
    update_docker="Download docker image from Docker Hub"
else
    update_docker="Use local image"
fi

echo -e "*------------------------------------------------------------------------------------------"
echo -e "* Input Arguments                                                                          "
echo -e "*     config root : \033[1;32m${cfg_root_dir}\033[0m                                       "
echo -e "*     target root : \033[1;32m${tar_root}\033[0m                                           "
echo -e "*     port        : \033[1;32m${port}\033[0m                                               "
echo -e "*     docker img  : \033[1;32m${update_docker}\033[0m                                      "
echo -e "*------------------------------------------------------------------------------------------"

# exit 0
step=1
#-----------------------------------------------------------------------------
#   Check config files
# 
cfg_files_ok=1
# echo "config root dir: ${cfg_root_dir}";
echo -e "\033[1;35m Step ${step}: Validating config root dir: ${cfg_root_dir} ...\033[0m"
((step += 1)) 
file=${cfg_root_dir}/data_service_api/conf/app.conf
# echo "${file}"
if [ ! -f "$file" ]; then
    echo -e "${file}    --> \033[31mNot found\033[0m";
    cfg_files_ok=0;
else
    echo -e "${file}    --> \033[32mOK\033[0m";
fi

file=${cfg_root_dir}/web_ui/www/apiCfg.php
if [ ! -f "$file" ]; then
    echo -e "${file}    --> \033[31mNot found\033[0m";
    cfg_files_ok=0;
else
    echo -e "${file}    --> \033[32mOK\033[0m";
fi

file=${cfg_root_dir}//web_ui/nginx/conf/nginx.conf
if [ ! -f "$file" ]; then
    echo -e "${file}    --> \033[31mNot found\033[0m";
    cfg_files_ok=0;
else
    echo -e "${file}    --> \033[32mOK\033[0m";
fi

file=${cfg_root_dir}//web_ui/nginx/conf.d/default.conf
if [ ! -f "$file" ]; then
    echo -e "${file}    --> \033[31mNot found\033[0m";
    cfg_files_ok=0;
else
    echo -e "${file}    --> \033[32mOK\033[0m";
fi

# Add here to check other config files

if [ $cfg_files_ok -ne 1 ]; then
    echo -e "\033[1;31mError: some config files missed !\033[0m -> exit(-1)";
    exit -1;
fi

#-----------------------------------------------------------------------------
#   Check target Root Dir
# 
echo -e "\033[1;35m Step ${step}: Check Target Root: ${tar_root} ...\033[0m";
((step += 1))
if [ -d "${tar_root}" ]; then
    echo "Delete ${tar_root}";
    rm -rf ${tar_root}
fi
dir1=${tar_root}/data_service_api/conf
echo "create ${dir1}";
mkdir -p ${dir1}
dir1=${tar_root}/web_ui/www
echo "create ${dir1}";
mkdir -p ${dir1}

echo "Copy config files to ${tar_root} ...";
# API service config file
file=app.conf
dir1=data_service_api/conf
echo "${dir1}/${file}";
cp ${cfg_root_dir}/${dir1}/${file} ${tar_root}/${dir1}/${file}
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mError: failed to copy ${dir1}/${file} \033[0m";
    exit -2;
fi

# web config file
file=apiCfg.php
dir1=web_ui/www
echo "${dir1}/${file}";
cp ${cfg_root_dir}/${dir1}/${file} ${tar_root}/${dir1}/${file}
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mError: failed to copy ${dir1}/${file} \033[0m";
    exit -2;
fi

# nginx config file
dir1=web_ui/nginx
echo "${dir1}";
cp -r ${cfg_root_dir}/${dir1} ${tar_root}/${dir1}
if [ $? -ne 0 ]; then
    echo -e "\033[1;31mError: failed to copy ${dir1} \033[0m";
    exit -2;
fi

# exit 0;
if [ ${dl_dockerimg} -eq 1 ]; then
    #-----------------------------------------------------------------------------
    #   Download all docker images
    # 
    echo -e "\033[1;35m Step ${step}: Download docker images ...\033[0m";
    ((step += 1))

    # DB server
    echo -e "\033[1;36mdocker pull mysql:5.7 ...\033[0m";
    docker pull mysql:5.7
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download mysql:5.7\033[0m";
        exit -3;
    fi

    # DB initializer
    echo -e "\033[1;36mdocker pull cidana/db_initializer ...\033[0m"
    docker pull cidana/db_initializer
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download db_initializer\033[0m";
        exit -3;
    fi

    # API service
    echo -e "\033[1;36mdocker pull cidana/data_service ...\033[0m"
    docker pull cidana/data_service
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download data_service\033[0m";
        exit -3;
    fi

    # PHP web service
    echo -e "\033[1;36mdocker pull cidana/php_web_service ...\033[0m"
    docker pull cidana/php_web_service
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download php_web_service\033[0m";
        exit -3;
    fi

    # Nginx web service
    echo -e "\033[1;36mdocker pull cidana/nginx_web_service ...\033[0m"
    docker pull cidana/nginx_web_service
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download nginx_web_service\033[0m";
        exit -3;
    fi

    # AWCY service
    echo -e "\033[1;36mdocker pull cidana/awcy ...\033[0m"
    docker pull cidana/awcy
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download awcy\033[0m";
        exit -3;
    fi
fi

# exit 0

#-----------------------------------------------------------------------------
#   deploy awcy media files
# 
awcy_media_dir=${tar_root}/awcy/media/
echo -e "\033[1;36mdeploy media files to ${awcy_media_dir} ...\033[0m"
if [ ! -d ${awcy_media_dir} ]; then
    echo "${awcy_media_dir} not exist, create ";
    mkdir -p ${awcy_media_dir}
fi

download_dir=${tar_root}/download
echo -e "\033[1;35m Step ${step}: Deploy awcy media files ...\033[0m";
((step += 1))

if [ ! -d ${download_dir} ]; then
    echo "${download_dir} not exist, create ";
    mkdir -p ${download_dir}
fi

media_path="ci_test_platform/awcy_media/"
echo -e "\033[1;36m Download media files to ${download_dir}/${media_path} ...\033[0m"
ftp_cmd="wget -nH -r -c ftp://ftp.cidanash.com:8021/${media_path} --ftp-user=ci_test_platform --ftp-password=cidana"
(cd ${download_dir} && eval ${ftp_cmd})
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[1;31mError: failed to download media file from ftp\033[0m";
    exit -3;
fi

echo -e "\033[1;36m Move media files ...\033[0m"
echo "${download_dir}/${media_path} ==> ${awcy_media_dir}"
mv ${download_dir}/${media_path}/* ${awcy_media_dir}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[1;31mError: failed to deploy media files\033[0m";
    exit -3;
fi

echo "Remove the temp download dir ${download_dir}"
rm -rf ${download_dir}

# exit 0;

#-----------------------------------------------------------------------------
#   Launch dock containers
# 
echo -e "\033[1;35m Step ${step}: Launch docker containers ...\033[0m";
((step += 1))

#   Database Server
echo -e "\033[1;36m Launch & Initialize Database server ...\033[0m"
cmd="docker run --rm --name dbserver -v ${tar_root}/db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=dbserver@cidana -d mysql:5.7 && docker run --rm --name dbinitializer --link dbserver:dbserver -e MYSQL_ROOT_PASSWORD=dbserver@cidana cidana/db_initializer"

echo "${cmd}";

docker stop dbserver
if [ $? -eq 0 ]; then
    sleep 2s
fi
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[31mError: failed to launch db server, err:${res}\033[0m"
    exit -4
fi

#   API Service
echo -e "\033[1;36m Launch API Service ...\033[0m"
cmd="docker run -t --name app_server --rm --link dbserver:dbserver -p 8080:8080 -v ${tar_root}/data_service_api/conf/app.conf:/bin/data_service/conf/app.conf -v ${tar_root}/data_service_api/logs:/bin/data_service/logs -d cidana/data_service"
echo "${cmd}";

docker stop app_server
if [ $? -eq 0 ]; then
    sleep 2s
fi
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[31mError: failed to launch API Service, err:${res}\033[0m"
    exit -4
fi

#   PHP Web Service
echo -e "\033[1;36m Launch PHP Web Service ...\033[0m"
cmd="docker run --rm --name php-web -p 9000:9000 --link app_server:app_server -v ${tar_root}/web_ui/www/apiCfg.php:/usr/share/nginx/html/apiCfg.php:ro -d cidana/php_web_service"
echo "${cmd}";

docker stop php-web
if [ $? -eq 0 ]; then
    sleep 2s
fi
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[31mError: failed to launch PHP web service, err:${res}\033[0m"
    exit -4
fi

#   Nginx Web Service
echo -e "\033[1;36m Launch Nginx Web Service ...\033[0m"
cmd="docker run --rm --name nginx-server -p ${port}:80 --link php-web:phpfpm -v ${tar_root}/web_ui/www/apiCfg.php:/usr/share/nginx/html/apiCfg.php:ro -v ${tar_root}/web_ui/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro -v ${tar_root}/web_ui/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro -v ${tar_root}/web_ui/nginx/logs:/var/log/nginx -d cidana/nginx_web_service"
echo "${cmd}";

docker stop nginx-server
if [ $? -eq 0 ]; then
    sleep 2s
fi
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[31mError: failed to launch Nginx web service, err:${res}\033[0m"
    exit -4
fi

# AWCY service
echo -e "\033[1;36m Launch AWCY Service ...\033[0m"
cmd="docker run --rm --name awcy_server -p 3000:3000 -v ${tar_root}/awcy/data:/data -v ${tar_root}/awcy/media:/media --env MEDIAS_SRC_DIR=/media --env AWCY_API_KEY=cidana --env LOCAL_WORKER_ENABLED=true --env LOCAL_WORKER_SLOTS=4 -d cidana/awcy"

echo "${cmd}";

docker stop awcy_server
if [ $? -eq 0 ]; then
    sleep 2s
fi
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[31mError: failed to launch awcy service, err:${res}\033[0m"
    exit -4
fi

# Jenkins service
echo -e "\033[1;36m Launch Jenkins Service ...\033[0m"
cmd="docker run --rm --name jenkins -p 8082:8080 -p 50000:50000 -d cidana/jenkins:deploy"
echo "${cmd}";

docker stop jenkins
if [ $? -eq 0 ]; then
    sleep 2s
fi
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[31mError: failed to launch Jenkins service, err:${res}\033[0m"
    exit -4
fi


echo -e "\n \033[42;30m --- Setup & Launch finish successfuly ! --- \033[0m"

cfgfile=${tar_root}/data_service_api/conf/app.conf
web_home=`cat ${cfgfile} | grep "web_site" | cut -d"\"" -f2`
# echo "web_home: ${web_home}"

if [ -n "${web_home}" ]; then
    echo -e "-----------------------------------------------------------------------------"
    echo -e "\n Now, you can access the CTP system via \033[1;35m ${web_home} \033[0m\n"
    echo -e "-----------------------------------------------------------------------------"
fi


exit 0
