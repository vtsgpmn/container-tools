#!/bin/sh

set_env_func() {
    echo
    echo -e "\033[1;34m============ ENV ============\033[0m"
    # Lowercase 
    export http_proxy="http://${credential}${proxy_host}:${proxy_port}"
    export https_proxy="http://$credential${proxy_host}:${proxy_port}"
    export no_proxy="localhost, 127.0.0.0/8"

    # Uppercase
    export HTTP_PROXY="http://${credential}${proxy_host}:${proxy_port}"
    export HTTPS_PROXY="http://$credential${proxy_host}:${proxy_port}"
    export NO_PROXY="localhost, 127.0.0.0/8"


    env | grep -i proxy
    echo -e "\033[1;33mWARNING: This script should be sourced for [env] option to take effect\033[0m"
}

set_etc_environment() {
    echo
    echo -e "\033[1;34m============ /etc/environment ============\033[0m"

    # append proxy settings if not exist in /etc/environment file TODO
    grep -q -i -E '^http_proxy=.+$' /etc/environment
    if [ $? -ne 0 ]; then
        echo 'http_proxy=http://'"${credential}${proxy_host}:${proxy_port}" >> /etc/environment
        echo "Installed http_proxy."
    else
        echo "http_proxy already exist. Skipping..."
    fi


    grep -q -i -E '^https_proxy=.+$' /etc/environment
    if [ $? -ne 0 ]; then
        echo 'https_proxy=http://'"${credential}${proxy_host}:${proxy_port}" >> /etc/environment
        echo "Installed https_proxy."
    else
        echo "https_proxy already exist. Skipping..."
    fi

}


set_maven_opts_func() {
    echo
    echo -e "\033[1;34m============ MAVEN_OPTS ============\033[0m"

    # Set MAVEN_OPTS environment variables
    export MAVEN_OPTS="-Dhttp.proxyHost=${proxy_host} -Dhttp.proxyPort=${proxy_port} -Dhttps.proxyHost=${proxy_host} -Dhttps.proxyPort=${proxy_port}"

    env | grep MAVEN_OPTS
    echo -e "\033[1;33mWARNING: This script should be sourced for [maven_opts] option to take effect\033[0m"
}


set_maven_xml_func() {
    echo
    echo -e "\033[1;34m============ MAVEN ============\033[0m"
    # If there's no Maven settings.xml
    if [  -f $HOME/.m2/settings.xml ]
    then
        echo No \$HOME/.m2/settings.xml found. Creating...
        mkdir -p $HOME/.m2/
        echo >aaa.echo <<end-of-file '<?xml version="1.0" encoding="UTF-8"?>
<settings
xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <proxies>
        <!-- Proxy for HTTP -->
        <proxy>
            <active>true</active>
            <protocol>http</protocol>
            <host>'"${proxy_host}"'</host>
            <port>'"${proxy_port}"'</port>
            <nonProxyHosts>127.0.0.1|localhost|*.local</nonProxyHosts>
        </proxy>


        <!-- Proxy for HTTPS -->
        <proxy>
            <active>true</active>
            <protocol>https</protocol>
            <host>'"${proxy_host}"'</host>
            <port>'"${proxy_port}"'</port>
            <nonProxyHosts>127.0.0.1|localhost|*.local</nonProxyHosts>
        </proxy-->
    </proxies>

</settings>'
end-of-file

    else 
        echo \$HOME/.m2/settings.xml already exists. Attempting to add proxy settings...
        echo Edit settings.xml: feature not implemented yet

    fi

}

# =========================== MAIN SCRIPT ===========================

# Default values
unset proxy_host proxy_port proxy_username proxy_password


# leading colon (:) means "silent errors reporting mode"
# colon following any character means it expects an argument
# h: proxy host
# p: proxy port
# u: proxy username
# s: proxy password
while getopts ":h:p:u:s:" OPT
do
    case $OPT in
        h)
            proxy_host=$OPTARG
            ;;
        p) 
            proxy_port=$OPTARG
            ;;
        u) 
            proxy_username=$OPTARG 
            ;;
        s) 
            proxy_password=$OPTARG
            ;;
        :)
            echo "Invalid option: -${OPTARG} requires an argument" 1>&2
            ;;
        \?) 
            echo "Invalid option: -${OPTARG}" 1>&2
            echo "Usage: WIP" 1>&2
            ;;
    esac
done


# CHECK MANDATORY options
# Exit if $proxy_host is not set
if [ -z $proxy_host ] 
then
    echo "Error: Proxy host is not set" 
    exit 1
fi

# Exit if $proxy_port is not set
if [ -z $proxy_port ]
then
    echo "Error: Proxy port is not set"
    exit 2
fi

# OPTIND means current option's index
# Shift index to the start of the remaining options
shift "$(($OPTIND - 1))"

# Build the credential part of proxy's URI
if [ -n "${proxy_username}" ]
then
    credential="$proxy_username:$proxy_password@"
fi

# Proxy installation options
while item=$1; shift;
do  
    case $item in
        env)
            set_env_func
            ;;
        etc-environment)

            ;;
        maven-opts)
            set_maven_opts_func
            ;;
        maven-xml)
            set_maven_xml_func
            ;;
        apt)
            echo feature not implemented yet
            ;;
        yum)
            echo feature not implemented yet
            ;;
        docker)
            echo feature not implemented yet
            ;;
        

    esac
done


