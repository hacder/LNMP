#!/bin/bash

####---- global variables ----begin####
export nginx_version=1.8.1
export mysql_version=5.6.21
export php_version=5.6.14

export phpmyadmin_version=4.1.8
export vsftpd_version=2.3.2
export sphinx_version=0.9.9
export install_ftp_version=0.0.0
####---- global variables ----end####


web=nginx
install_log=/webroot/website-info.log

#新增PHP-7.2.0
tmp=1
read -p "Please select the php version of 5.6.21/7.2.0, input 1 or 2 : " tmp
if [ "$tmp" == "1" ];then
  php_version=5.6.21
elif [ "$tmp" == "2" ];then
  php_version=7.2.0
fi

echo "**********************************"
echo "You will install the version :"
echo "web    : $web"
if echo $web |grep "nginx" > /dev/null;then
  echo "nginx : $nginx_version"
else
  echo "apache : $httpd_version"
fi
echo "php    : $php_version"
echo "mysql  : $mysql_version"
echo "*********************************"

read -p "Enter the y or Y to continue:" isY
if [ "${isY}" != "y" ] && [ "${isY}" != "Y" ];then
   exit 1
fi
####---- version selection ----end####


####---- Clean up the environment ----begin####
echo "will be installed, wait ..."
./uninstall.sh in &> /dev/null
####---- Clean up the environment ----end####


if echo $web|grep "nginx" > /dev/null;then
web_dir=nginx-${nginx_version}
else
web_dir=httpd-${httpd_version}
fi

php_dir=php-${php_version}

if [ `uname -m` == "x86_64" ];then
machine=x86_64
else
machine=i686
fi


####---- global variables ----begin####
export web
export web_dir
export php_dir
export mysql_dir=mysql-${mysql_version}
export vsftpd_dir=vsftpd-${vsftpd_version}
export sphinx_dir=sphinx-${sphinx_version}
####---- global variables ----end####


ifredhat=$(cat /proc/version | grep redhat)
ifcentos=$(cat /proc/version | grep centos)
ifubuntu=$(cat /proc/version | grep ubuntu)
ifdebian=$(cat /proc/version | grep -i debian)


####---- install dependencies ----begin####
if [ "$ifcentos" != "" ] || [ "$machine" == "i686" ];then
rpm -e httpd-2.2.3-31.el5.centos gnome-user-share &> /dev/null
fi

\cp /etc/rc.local /etc/rc.local.bak
if [ "$ifredhat" != "" ];then
rpm -e --allmatches mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
fi

if [ "$ifredhat" != "" ];then
  \mv /etc/yum.repos.d/rhel-debuginfo.repo /etc/yum.repos.d/rhel-debuginfo.repo.bak &> /dev/null
  \cp ./res/rhel-debuginfo.repo /etc/yum.repos.d/
  yum makecache
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
  yum -y install gcc gcc-c++ gcc-g77 make libtool autoconf patch unzip automake fiex* libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake libaio*
  iptables -F
elif [ "$ifcentos" != "" ];then
	if grep 5.10 /etc/issus  ;then
	  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
	fi
  sed -i 's/^exclude/#exclude/' /etc/yum.conf
  yum makecache
  yum -y remove mysql MySQL-python perl-DBD-MySQL dovecot exim qt-MySQL perl-DBD-MySQL dovecot qt-MySQL mysql-server mysql-connector-odbc php-mysql mysql-bench libdbi-dbd-mysql mysql-devel-5.0.77-3.el5 httpd php mod_auth_mysql mailman squirrelmail php-pdo php-common php-mbstring php-cli &> /dev/null
  yum -y install gcc gcc-c++ gcc-g77 make libtool autoconf patch unzip automake libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl libmcrypt libmcrypt-devel libpng libpng-devel libjpeg-devel openssl openssl-devel curl curl-devel libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl autoconf automake libaio*
  iptables -F
elif [ "$ifubuntu" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak &> /dev/null
  \mv /etc/nginx /etc/nginx.bak &> /dev/null
  \mv /etc/php5 /etc/php5.bak &> /dev/null
  \mv /etc/mysql /etc/mysql.bak &> /dev/null
  apt-get -y autoremove apache2 nginx php5 mysql-server &> /dev/null
  apt-get -y install unzip build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf libperl-dev libtool libaio*
  iptables -F
elif [ "$ifdebian" != "" ];then
  apt-get -y update
  \mv /etc/apache2 /etc/apache2.bak &> /dev/null
  \mv /etc/nginx /etc/nginx.bak &> /dev/null
  \mv /etc/php5 /etc/php5.bak &> /dev/null
  \mv /etc/mysql /etc/mysql.bak &> /dev/null
  apt-get -y autoremove apache2 nginx php5 mysql-server &> /dev/null
  apt-get -y install unzip psmisc build-essential libncurses5-dev libfreetype6-dev libxml2-dev libssl-dev libcurl4-openssl-dev libjpeg62-dev libpng12-dev libfreetype6-dev libsasl2-dev libpcre3-dev autoconf libperl-dev libtool libaio*
  iptables -F
fi
####---- install dependencies ----end####


####---- install software ----begin####
rm -f tmp.log
echo tmp.log

./env/install_set_sysctl.sh
./env/install_set_ulimit.sh

if [ -e /dev/xvdb ];then
	./env/install_disk.sh
fi

./env/install_dir.sh
echo "---------- make dir ok ----------" >> tmp.log

./env/install_env.sh
echo "---------- env ok ----------" >> tmp.log

./mysql/install_${mysql_dir}.sh
echo "---------- ${mysql_dir} ok ----------" >> tmp.log

if echo $web |grep "nginx" > /dev/null;then
	./nginx/install_nginx-${nginx_version}.sh
	echo "---------- ${web_dir} ok ----------" >> tmp.log
  chmod +x ./php/install_nginx_php-${php_version}.sh
	./php/install_nginx_php-${php_version}.sh
	echo "---------- ${php_dir} ok ----------" >> tmp.log
else
	./apache/install_httpd-${httpd_version}.sh
	echo "---------- ${web_dir} ok ----------" >> tmp.log
	./php/install_httpd_php-${php_version}.sh
	echo "---------- ${php_dir} ok ----------" >> tmp.log
fi

if [ "$php_version" != "5.6.14" ];then
  ./php/install_php_extension.sh
  echo "---------- php extension ok ----------" >> tmp.log
fi
./ftp/install_${vsftpd_dir}.sh
install_ftp_version=$(vsftpd -v 0> vsftpd_version && cat vsftpd_version |awk -F: '{print $2}'|awk '{print $2}' && rm -f vsftpd_version)
echo "---------- vsftpd-$install_ftp_version  ok ----------" >> tmp.log

./res/install_soft.sh
echo "---------- default web ok ----------" >> tmp.log
echo "---------- phpmyadmin-$phpmyadmin_version ok ----------" >> tmp.log
echo "---------- web init ok ----------" >> tmp.log
####---- install software ----end####


####---- Start command is written to the rc.local ----begin####
if ! cat /etc/rc.local | grep "/etc/init.d/mysqld" > /dev/null;then 
    echo "/etc/init.d/mysqld start" >> /etc/rc.local
fi
if echo $web|grep "nginx" > /dev/null;then
  if ! cat /etc/rc.local | grep "/etc/init.d/nginx" > /dev/null;then 
     echo "/etc/init.d/nginx start" >> /etc/rc.local
	 echo "/etc/init.d/php-fpm start" >> /etc/rc.local
  fi
else
  if ! cat /etc/rc.local | grep "/etc/init.d/httpd" > /dev/null;then 
     echo "/etc/init.d/httpd start" >> /etc/rc.local
  fi
fi
if ! cat /etc/rc.local | grep "/etc/init.d/vsftpd" > /dev/null;then 
    echo "/etc/init.d/vsftpd start" >> /etc/rc.local
fi
####---- Start command is written to the rc.local ----end####


####---- centos yum configuration----begin####
if [ "$ifcentos" != "" ] && [ "$machine" == "x86_64" ];then
sed -i 's/^#exclude/exclude/' /etc/yum.conf
fi
if [ "$ifubuntu" != "" ] || [ "$ifdebian" != "" ];then
	mkdir -p /var/lock
	sed -i 's#exit 0#touch /var/lock/local#' /etc/rc.local
else
	mkdir -p /var/lock/subsys/
fi
####---- centos yum configuration ----end####

####---- mysql password initialization ----begin####
echo "---------- rc init ok ----------" >> tmp.log

if [ "$php_version" != "7.2.0" ];then
  /webroot/server/php/bin/php -f ./res/init_mysql.php
else
  /webroot/server/php/bin/php -f ./res/init_mysql_php7.php
fi
echo "---------- mysql init ok ----------" >> tmp.log
####---- mysql password initialization ----end####


####---- Environment variable settings ----begin####
\cp /etc/profile /etc/profile.bak
if echo $web|grep "nginx" > /dev/null;then
  echo 'export PATH=$PATH:/webroot/server/mysql/bin:/webroot/server/nginx/sbin:/webroot/server/php/sbin:/webroot/server/php/bin' >> /etc/profile
  export PATH=$PATH:/webroot/server/mysql/bin:/webroot/server/nginx/sbin:/webroot/server/php/sbin:/webroot/server/php/bin
else
  echo 'export PATH=$PATH:/webroot/server/mysql/bin:/webroot/server/httpd/bin:/webroot/server/php/sbin:/webroot/server/php/bin' >> /etc/profile
  export PATH=$PATH:/webroot/server/mysql/bin:/webroot/server/httpd/bin:/webroot/server/php/sbin:/webroot/server/php/bin
fi
####---- Environment variable settings ----end####


####---- restart ----begin####
if echo $web|grep "nginx" > /dev/null;then
/etc/init.d/php-fpm restart > /dev/null
/etc/init.d/nginx restart > /dev/null
else
/etc/init.d/httpd restart > /dev/null
/etc/init.d/httpd start &> /dev/null
fi
/etc/init.d/vsftpd restart
####---- restart ----end####

####---- log ----begin####
\cp tmp.log $install_log
cat $install_log
####---- log ----end####