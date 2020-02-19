#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

mysqlrootpwd=`date +%s | sha256sum | base64 | head -c 32`

echo "Mysql Root Password :" >> /root/passwd.log
echo $mysqlrootpwd >> /root/passwd.log

MemTotal=`free -m | grep Mem | awk '{print  $2}'`
if [[ ${MemTotal} -gt 1024 && ${MemTotal} -lt 2048 ]]; then
		sed -i "s#^key_buffer_size.*#key_buffer_size = 32M#" /etc/mysql.cnf
		sed -i "s#^table_open_cache.*#table_open_cache = 128#" /etc/mysql.cnf
		sed -i "s#^sort_buffer_size.*#sort_buffer_size = 768K#" /etc/mysql.cnf
		sed -i "s#^read_buffer_size.*#read_buffer_size = 768K#" /etc/mysql.cnf
		sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 8M#" /etc/mysql.cnf
		sed -i "s#^thread_cache_size.*#thread_cache_size = 16#" /etc/mysql.cnf
		sed -i "s#^query_cache_size.*#query_cache_size = 16M#" /etc/mysql.cnf
		sed -i "s#^tmp_table_size.*#tmp_table_size = 32M#" /etc/mysql.cnf
		sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 128M#" /etc/mysql.cnf
		sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 32M#" /etc/mysql.cnf
elif [[ ${MemTotal} -ge 2048 && ${MemTotal} -lt 4096 ]]; then
		sed -i "s#^key_buffer_size.*#key_buffer_size = 64M#" /etc/mysql.cnf
		sed -i "s#^table_open_cache.*#table_open_cache = 256#" /etc/mysql.cnf
		sed -i "s#^sort_buffer_size.*#sort_buffer_size = 1M#" /etc/mysql.cnf
		sed -i "s#^read_buffer_size.*#read_buffer_size = 1M#" /etc/mysql.cnf
		sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 16M#" /etc/mysql.cnf
		sed -i "s#^thread_cache_size.*#thread_cache_size = 32#" /etc/mysql.cnf
		sed -i "s#^query_cache_size.*#query_cache_size = 32M#" /etc/mysql.cnf
		sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/mysql.cnf
		sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 256M#" /etc/mysql.cnf
		sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 64M#" /etc/mysql.cnf
elif [[ ${MemTotal} -ge 4096 && ${MemTotal} -lt 8192 ]]; then
		sed -i "s#^key_buffer_size.*#key_buffer_size = 128M#" /etc/mysql.cnf
		sed -i "s#^table_open_cache.*#table_open_cache = 512#" /etc/mysql.cnf
		sed -i "s#^sort_buffer_size.*#sort_buffer_size = 2M#" /etc/mysql.cnf
		sed -i "s#^read_buffer_size.*#read_buffer_size = 2M#" /etc/mysql.cnf
		sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 32M#" /etc/mysql.cnf
		sed -i "s#^thread_cache_size.*#thread_cache_size = 64#" /etc/mysql.cnf
		sed -i "s#^query_cache_size.*#query_cache_size = 64M#" /etc/mysql.cnf
		sed -i "s#^tmp_table_size.*#tmp_table_size = 64M#" /etc/mysql.cnf
		sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 512M#" /etc/mysql.cnf
		sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 128M#" /etc/mysql.cnf
elif [[ ${MemTotal} -ge 8192 && ${MemTotal} -lt 16384 ]]; then
		sed -i "s#^key_buffer_size.*#key_buffer_size = 256M#" /etc/mysql.cnf
		sed -i "s#^table_open_cache.*#table_open_cache = 1024#" /etc/mysql.cnf
		sed -i "s#^sort_buffer_size.*#sort_buffer_size = 4M#" /etc/mysql.cnf
		sed -i "s#^read_buffer_size.*#read_buffer_size = 4M#" /etc/mysql.cnf
		sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 64M#" /etc/mysql.cnf
		sed -i "s#^thread_cache_size.*#thread_cache_size = 128#" /etc/mysql.cnf
		sed -i "s#^query_cache_size.*#query_cache_size = 128M#" /etc/mysql.cnf
		sed -i "s#^tmp_table_size.*#tmp_table_size = 128M#" /etc/mysql.cnf
		sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 1024M#" /etc/mysql.cnf
		sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 256M#" /etc/mysql.cnf
elif [[ ${MemTotal} -ge 16384 && ${MemTotal} -lt 32768 ]]; then
		sed -i "s#^key_buffer_size.*#key_buffer_size = 512M#" /etc/mysql.cnf
		sed -i "s#^table_open_cache.*#table_open_cache = 2048#" /etc/mysql.cnf
		sed -i "s#^sort_buffer_size.*#sort_buffer_size = 8M#" /etc/mysql.cnf
		sed -i "s#^read_buffer_size.*#read_buffer_size = 8M#" /etc/mysql.cnf
		sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 128M#" /etc/mysql.cnf
		sed -i "s#^thread_cache_size.*#thread_cache_size = 256#" /etc/mysql.cnf
		sed -i "s#^query_cache_size.*#query_cache_size = 256M#" /etc/mysql.cnf
		sed -i "s#^tmp_table_size.*#tmp_table_size = 256M#" /etc/mysql.cnf
		sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 2048M#" /etc/mysql.cnf
		sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 512M#" /etc/mysql.cnf
elif [[ ${MemTotal} -ge 32768 ]]; then
		sed -i "s#^key_buffer_size.*#key_buffer_size = 1024M#" /etc/mysql.cnf
		sed -i "s#^table_open_cache.*#table_open_cache = 4096#" /etc/mysql.cnf
		sed -i "s#^sort_buffer_size.*#sort_buffer_size = 16M#" /etc/mysql.cnf
		sed -i "s#^read_buffer_size.*#read_buffer_size = 16M#" /etc/mysql.cnf
		sed -i "s#^myisam_sort_buffer_size.*#myisam_sort_buffer_size = 256M#" /etc/mysql.cnf
		sed -i "s#^thread_cache_size.*#thread_cache_size = 512#" /etc/mysql.cnf
		sed -i "s#^query_cache_size.*#query_cache_size = 512M#" /etc/mysql.cnf
		sed -i "s#^tmp_table_size.*#tmp_table_size = 512M#" /etc/mysql.cnf
		sed -i "s#^innodb_buffer_pool_size.*#innodb_buffer_pool_size = 4096M#" /etc/mysql.cnf
		sed -i "s#^innodb_log_file_size.*#innodb_log_file_size = 1024M#" /etc/mysql.cnf
fi

###################################Config Mysql Password###################################
/usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/mysql.cnf --basedir=/usr/local/mysql --datadir=/www/wwwdata/mysqldb --user=mysql
#chgrp -R mysql /usr/local/mysql/.

if [ -d "/proc/vz" ];then
ulimit -s unlimited
fi

/etc/init.d/mysql start
/usr/local/mysql/bin/mysqladmin --defaults-file=/etc/mysql.cnf -u root password $mysqlrootpwd

cat > /tmp/mysql_sec_script<<EOF
use mysql;
update user set password=password('$mysqlrootpwd') where user='root';
delete from user where not (user='root') ;
delete from user where user='root' and password='';
drop database test;
DROP USER ''@'%';
flush privileges;
EOF

/usr/local/mysql/bin/mysql --defaults-file=/etc/mysql.cnf -u root -p$mysqlrootpwd -h localhost < /tmp/mysql_sec_script
rm -f /tmp/mysql_sec_script

chown -R mysql:mysql /www/wwwdata/mysqldb

/etc/init.d/mysql restart

###################################Config Mysql StartON###################################

if command -v systemctl >/dev/null 2>&1; then
	systemctl enable mysql.service
else
	chkconfig mysql on
fi