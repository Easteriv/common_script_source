#!/bin/bash

function checkPython() {
  python_version=$(python3 -V)
  python_result=$(echo "${python_version}" | grep '不是内部或外部命令')
  if [ "${python_result}" != "" ]; then
    echo "本脚本需要Python环境支持,请先安装Python"
    exit
  fi
  echo "Python脚本需要pycryptodome模块提供支持,如您已安装,请忽略"
  echo "是否自动安装pycryptodome模块?(Y/N)"
  read -r selector
  if [ "${selector}" == "Y" ]; then
    pip install pycryptodome
  fi
}

function os_support() {
  if [[ $(uname) != 'Darwin' ]]; then
    echo "本脚本暂时只支持macOS系统"
    exit
  fi
}

function getPythonSource() {
  echo "是否自动安装Python解密脚本:https://github.com/Easteriv/python_script_source/blob/main/SecureCRTCipher.py ,如已下载,请忽略(Y/N)"
  read -r source_downLoad_selector
  if [ "${source_downLoad_selector}" == "Y" ]; then
    curl --request GET -sL \
      --url 'https://raw.githubusercontent.com/Easteriv/python_script_source/main/SecureCRTCipher.py' \
      --output 'SecureCRTCipher.py'
    echo "下载完毕,脚本SecureCRTClipher.py已存放在当前目录"
  fi
}

os_support
checkPython
getPythonSource
CURRENT_DIR=$(pwd)
path=${HOME}/Library/Application\ Support/VanDyke/SecureCRT/Config/Sessions
cd "${path}" || exit
ls
echo  "请输入你要解析的服务器IP地址"
read -r name
password_line=$(cat < "${name}.ini" | grep 'S:"Password\ V2') || { echo "command failed"; exit 1; }
token=${password_line#*=02:}
cd "${CURRENT_DIR}" || exit
real_password=$(python3 SecureCRTCipher.py dec -v2 "${token}")
result=$(echo "$real_password" | grep "Error")
if [ "${result}" != "" ]
then
  echo "密码解析异常,脚本即将退出"
  exit
else
  echo "您服务器:[${name}]的密码为:[${real_password}],请注意保存!"
fi
