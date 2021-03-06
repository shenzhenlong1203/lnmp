#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; } 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
#                           Uninstall LNMP                            #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
. ./options.conf

Uninstall()
{
[ -e "$db_install_dir" ] && service mysqld stop && rm -rf /etc/init.d/mysqld /etc/my.cnf
[ -e "$apache_install_dir" ] && service httpd stop && rm -rf /etc/init.d/httpd
[ -e "$php_install_dir" ] && service php-fpm stop && rm -rf /etc/init.d/php-fpm
[ -e "$web_install_dir" ] && service nginx stop && rm -rf /etc/init.d/nginx /etc/logrotate.d/nginx
[ -e "$pureftpd_install_dir" ] && service pureftpd stop && rm -rf /etc/init.d/pureftpd
[ -e "$redis_install_dir" ] && service redis-server stop && rm -rf /etc/init.d/redis-server
[ -e "$memcached_install_dir" ] && service memcached stop && rm -rf /etc/init.d/memcached
[ -e "/usr/local/imagemagick" ] && rm -rf /usr/local/imagemagick 
[ -e "/usr/local/graphicsmagick" ] && rm -rf /usr/local/graphicsmagick 
[ -e "/etc/init.d/supervisord" ] && service supervisord stop && { rm -rf /etc/supervisord.conf; /etc/init.d/supervisord; } 
[ -e "/etc/systemd/system/hhvm.service" ] && service hhvm stop && { rpm -e hhvm ;rm -rf /etc/systemd/system/hhvm.service /etc/hhvm /var/log/hhvm; } 
[ -e "/etc/init.d/hhvm" ] && service hhvm stop && { rpm -e hhvm ;rm -rf /etc/init.d/hhvm /etc/hhvm /var/log/hhvm; } 
id -u $run_user >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel $run_user
id -u mysql >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel mysql 

/bin/mv ${wwwroot_dir}{,_$(date +%F)}
/bin/mv ${db_data_dir}{,_$(date +%F)}
for D in `cat ./options.conf | grep dir= | grep -v lnmp | awk -F'=' '{print $2}' | sort | uniq`
do
        [ -e "$D" ] && rm -rf $D
done

sed -i 's@^lnmp_dir=.*@lnmp_dir=@' ./options.conf
sed -i 's@^web_install_dir=.*@web_install_dir=@' ./options.conf
sed -i 's@^db_install_dir=.*@db_install_dir=@' ./options.conf
sed -i 's@^db_data_dir=.*@db_data_dir=@' ./options.conf
sed -i 's@^dbrootpwd=.*@dbrootpwd=@' ./options.conf
sed -i 's@^ftpmanagerpwd=.*@ftpmanagerpwd=@' ./options.conf
sed -i 's@^conn_ftpusers_dbpwd=.*@conn_ftpusers_dbpwd=@' ./options.conf
sed -i "s@^export.*$db_install_dir.*@@g" /etc/profile && . /etc/profile
echo -e "\033[32mUninstall completed.\033[0m"
}

get_char() 
{ 
SAVEDSTTY=`stty -g` 
stty -echo 
stty cbreak 
dd if=/dev/tty bs=1 count=1 2> /dev/null 
stty -raw 
stty echo 
stty $SAVEDSTTY 
} 
 
echo 
echo -e "\033[31mYou will uninstall LNMP, Please backup your configure files and DB data! \033[0m"
echo 
echo -e "\033[33mThe following directory or files will be remove: \033[0m"
for D in `cat ./options.conf | grep dir= | grep -v lnmp | awk -F'=' '{print $2}' | sort | uniq` 
do
	[ -e "$D" ] && echo $D
done
[ -e "$web_install_dir" ] && echo -e "/etc/init.d/nginx\n/etc/logrotate.d/nginx"
[ -e "$apache_install_dir" ] && echo '/etc/init.d/httpd'
[ -e "$db_install_dir" ] && echo -e "/etc/init.d/mysqld\n/etc/my.cnf"
[ -e "$php_install_dir" ] && echo '/etc/init.d/php-fpm'
[ -e "$pureftpd_install_dir" ] && echo '/etc/init.d/pureftpd'
[ -e "$memcached_install_dir" ] && echo '/etc/init.d/memcached' 
[ -e "$redis_install_dir" ] && echo '/etc/init.d/redis-server' 
[ -e "/usr/local/imagemagick" ] && echo '/usr/local/imagemagick' 
[ -e "/usr/local/graphicsmagick" ] && echo '/usr/local/graphicsmagick' 
echo 
echo "Press Ctrl+c to cancel or Press any key to continue..."
char=`get_char`

while :
do
        echo
        read -p "Do you want to uninstall LNMP? [y/n]: " uninstall_yn
        if [ "$uninstall_yn" != 'y' -a "$uninstall_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done

[ "$uninstall_yn" == 'y' ] && Uninstall
