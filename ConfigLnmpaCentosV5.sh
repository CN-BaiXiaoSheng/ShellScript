#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install Pptpd"
    exit 1
fi

clear
echo "============================================================================="
echo "======================Lnmpa for CentOS/RadHat Linux VPS======================"
echo "============================================================================="

DLL=http://xxxxxx.xxxxxx

groupadd www
useradd -s /sbin/nologin -g www www -d /www
chown www:www /www
chmod 775 /www
mkdir -p /www/wwwroot
mkdir -p /www/wwwlogs
mkdir -p /www/wwwssls
mkdir -p /tmp/tcmalloc
mkdir -p /www/wwwroot/localhost
chown -R www:www /www/wwwroot
chown -R www:www /www/wwwlogs
chown -R www:www /tmp/tcmalloc
chmod 777 /www/wwwlogs

if grep -Eqi '^127.0.0.1[[:space:]]*localhost' /etc/hosts; then
    echo "Hosts: ok."
else
    echo "127.0.0.1 localhost.localdomain localhost" >> /etc/hosts
fi
pingresult=`ping -c1 dlcache.oss.hangzhou.dagaiba.com 2>&1`
echo "${pingresult}"
if echo "${pingresult}" | grep -q "unknown host"; then
echo "DNS...fail"
echo "Writing nameserver to /etc/resolv.conf ..."
echo -e "nameserver 208.67.220.220\nnameserver 114.114.114.114" > /etc/resolv.conf
    else
echo "DNS...ok"
fi

sleep 3
function Lnmpa_InstallSoft()
{
cat /etc/issue
uname -a
MemTotal=`free -m | grep Mem | awk '{print $2}'`
echo -e "\n Memory is: ${MemTotal} MB "

#Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#Set Ntp
yum install -y ntp
ntpdate -u pool.ntp.org
date

#Clean RPM
rpm -qa|grep httpd
rpm -e httpd httpd-tools --nodeps
rpm -qa|grep mysql
rpm -e mysql mysql-libs --nodeps
rpm -qa|grep php
rpm -e php-mysql php-cli php-gd php-common php --nodeps
yum -y remove httpd*
yum -y remove mysql-server mysql mysql-libs
yum -y remove php*
yum -y remove php-mysql
yum clean all
yum -y install yum-fastestmirror redhat-lsb
yum -y update

#Clean Yum
cp /etc/yum.conf /etc/yum.conf.bak
sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf

#Yum packages
for packages in make cmake gcc gcc-c++ gcc-g77 flex bison file libtool libtool-libs autoconf kernel-devel patch wget crontabs libjpeg libjpeg-devel libpng libpng-devel giflib-devel giflib libpng10 libpng10-devel gd gd-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel unzip tar bzip2 bzip2-devel libzip-devel libevent libevent-devel ncurses ncurses-devel curl curl-devel libcurl libcurl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel vim-minimal gettext gettext-devel ncurses-devel gmp-devel pspell-devel unzip libcap diffutils ca-certificates net-tools libc-client-devel psmisc libXpm-devel git-core c-ares-devel libicu-devel libxslt libxslt-devel xz expat-devel libaio-devel rpcgen libtirpc-devel perl perl-ExtUtils-Embed re2c nghttp2 bison lua-devel;
do yum -y install $packages; done
yum -y update nss

#Install_Libiconv
cd /tmp
if [ -s libiconv-1.15.tar.gz ]; then
	echo "libiconv-1.15.tar.gz [found]"
else
	echo "Error: libiconv-1.15.tar.gz not found!!!download now......"
	wget -c $DLL/libiconv/libiconv-1.15.tar.gz
fi
tar -zxf libiconv-1.15.tar.gz
cd libiconv-1.15/
./configure --enable-static
make && make install

#Install_Libmcrypt
cd /tmp
if [ -s libmcrypt-2.5.8.tar.gz ]; then
	echo "libmcrypt-2.5.8.tar.gz [found]"
else
	echo "Error: libmcrypt-2.5.8.tar.gz not found!!!download now......"
	wget -c $DLL/libmcrypt/libmcrypt-2.5.8.tar.gz
fi
tar -zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8/
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
ln -sf /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -sf /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -sf /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -sf /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ldconfig

#Install_Mhash
cd /tmp
if [ -s mhash-0.9.9.9.tar.gz ]; then
	echo "mhash-0.9.9.9.tar.gz [found]"
else
	echo "Error: mhash-0.9.9.9.tar.gz not found!!!download now......"
	wget -c $DLL/mhash/mhash-0.9.9.9.tar.gz
fi
tar -zxf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make && make install
ln -sf /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -sf /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -sf /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -sf /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -sf /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
ldconfig

#Install_Mcrypt
cd /tmp
if [ -s mcrypt-2.6.8.tar.gz ]; then
	echo "mcrypt-2.6.8.tar.gz [found]"
else
	echo "Error: mcrypt-2.6.8.tar.gz not found!!!download now......"
	wget -c $DLL/mcrypt/mcrypt-2.6.8.tar.gz
fi
tar -zxf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
./configure
make && make install

#Install_Freetype
cd /tmp
if [ -s freetype-2.7.tar.bz2 ]; then
	echo "freetype-2.7.tar.bz2 [found]"
else
	echo "Error: freetype-2.7.tar.bz2 not found!!!download now......"
	wget -c $DLL/freetype/freetype-2.7.tar.bz2
fi
tar -jxf freetype-2.7.tar.bz2
cd freetype-2.7/
./configure --prefix=/usr/local/freetype
make && make install
[[ -d /usr/lib/pkgconfig ]] && \cp /usr/local/freetype/lib/pkgconfig/freetype2.pc /usr/lib/pkgconfig/
cat > /etc/ld.so.conf.d/freetype.conf<<EOF
/usr/local/freetype/lib
EOF
ldconfig
ln -sf /usr/local/freetype/include/freetype2/* /usr/include/

#Install_Pcre
cd /tmp
if ! command -v pcre-config >/dev/null 2>&1 || pcre-config --version | grep -vEqi '^8.'; then
	 if [ -s pcre-8.42.tar.bz2 ]; then
		echo "pcre-8.42.tar.bz2 [found]"
	else	
		echo "Error: pcre-8.42.tar.bz2 not found!!!download now......"
		wget -c $DLL/pcre/pcre-8.42.tar.bz2
	fi
	tar -jxf pcre-8.42.tar.bz2
	cd pcre-8.42
	./configure
	make && make install
fi

#Install_Icu4c
cd /tmp
if command -v icu-config >/dev/null 2>&1 && icu-config --version | grep -Eq "^3."; then
	if [ -s icu4c-63_1-src.tgz ]; then
		echo "icu4c-63_1-src.tgz [found]"
	else
		echo "Error: icu4c-63_1-src.tgz not found!!!download now......"
		wget -c $DLL/icu4c/icu4c-63_1-src.tgz
	fi
	tar -zxf icu4c-63_1-src.tgz
	cd icu/source
	./configure --prefix=/usr
	if [ ! -s /usr/include/xlocale.h ]; then
		ln -s /usr/include/locale.h /usr/include/xlocale.h
	fi
	make && make install
fi

#Install_Libunwind
cd /tmp
if [ -s libunwind-1.2.1.tar.gz ]; then
	echo "libunwind-1.2.1.tar.gz [found]"
else
	echo "Error: libunwind-1.2.1.tar.gz not found!!!download now......"
	wget -c $DLL/libunwind/libunwind-1.2.1.tar.gz
fi
tar -zxf libunwind-1.2.1.tar.gz
cd libunwind-1.2.1/
CFLAGS=-fPIC ./configure
make CFLAGS=-fPIC
make CFLAGS=-fPIC install

#Install_Gperftools
cd /tmp
if [ -s gperftools-2.7.tar.gz ]; then
	echo "gperftools-2.7.tar.gz [found]"
else
	echo "Error: gperftools-2.7.tar.gz not found!!!download now......"
	wget -c $DLL/gperftools/gperftools-2.7.tar.gz
fi
tar -zxf gperftools-2.7.tar.gz
cd gperftools-2.7
./configure
make && make install
ldconfig
ln -sf /usr/local/lib/libtcmalloc* /usr/lib/

#Install_AutoConf
cd /tmp
if [ -s autoconf-2.69.tar.gz ]; then
	echo "autoconf-2.69.tar.gz [found]"
else
	echo "Error: autoconf-2.69.tar.gz not found!!!download now......"
	wget -c $DLL/autoconf/autoconf-2.69.tar.gz
fi
tar -zxf autoconf-2.69.tar.gz
cd autoconf-2.69/
./configure --prefix=/usr/local/autoconf
make && make install
export PHP_AUTOCONF=/usr/local/autoconf/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf/bin/autoheader

#Install_ReadLine
cd /tmp
if [ -s readline-6.3.tar.gz ]; then
	echo "readline-6.3.tar.gz [found]"
else
	echo "Error: readline-6.3.tar.gz not found!!!download now......"
	wget -c $DLL/readline/readline-6.3.tar.gz
fi
tar -zxf readline-6.3.tar.gz
cd readline-6.3
./configure --prefix=/usr/local/readline
make && make install
ln -s /usr/local/readline/lib/libhistory.so /usr/lib/libreadline.so
ln -s /usr/lib/libreadline.so libreadline.so.6

#Install_Lua
cd /tmp
if [ -s lua-5.3.5.tar.gz ]; then
	echo "lua-5.3.5.tar.gz [found]"
else
	echo "Error: lua-5.3.5.tar.gz not found!!!download now......"
	wget -c $DLL/lua/lua-5.3.5.tar.gz
fi
tar -zxf lua-5.3.5.tar.gz
cd lua-5.3.5
sed -i 's/MYCFLAGS\=/MYCFLAGS\=\-I\/usr\/local\/readline\/include/' src/Makefile
sed -i 's/MYLDFLAGS\=/MYLDFLAGS\=\-L\/usr\/local\/readline\/lib/' src/Makefile
sed -i 's/SYSLIBS\=\"-Wl,-E -ldl -lreadline\"/SYSLIBS\=\"-Wl,-E -ldl -lreadline -lncurses\"/' src/Makefile
make linux
make install

#Install_Luajit
cd /tmp
if [[ ! -s /usr/local/luajit/bin/luajit || ! -s /usr/local/luajit/include/luajit-2.1/luajit.h || ! -s /usr/local/luajit/lib/libluajit-5.1.so ]]; then
	if [ -s luajit2-2.1-20190329.tar.gz ]; then
		echo "luajit2-2.1-20190329.tar.gz [found]"
	else
		echo "Error: luajit2-2.1-20190329.tar.gz not found!!!download now......"
		wget -c $DLL/luajit/luajit2-2.1-20190329.tar.gz
	fi
	tar -zxf luajit2-2.1-20190329.tar.gz
	cd luajit2-2.1-20190329
	sed -i 's/luajit-\$(MAJVER).\$(MINVER)/luajit/' Makefile
	sed -i 's/luajit-\$(VERSION)/luajit/' Makefile
	make
	make install PREFIX=/usr/local/luajit
fi
cat > /etc/ld.so.conf.d/luajit.conf<<EOF
/usr/local/luajit/lib
EOF
ln -sf /usr/local/luajit/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
cat >/etc/profile.d/luajit.sh<<EOF
export LUAJIT_LIB=/usr/local/luajit/lib
export LUAJIT_INC=/usr/local/luajit/include/luajit
EOF
source /etc/profile.d/luajit.sh

#Install_GeoIP
cd /tmp
wget -c $DLL/geoip/GeoIP-1.4.8.tar.gz
tar -zxf GeoIP-1.4.8.tar.gz
cd GeoIP-1.4.8
./configure
make; make install
echo '/usr/local/lib' > /etc/ld.so.conf.d/geoip.conf
ldconfig

cd /usr/local/share/GeoIP/
rm -rf GeoIP.dat
wget -c $DLL/geoip/GeoIPv6.dat.gz && gunzip GeoIPv6.dat.gz
wget -c $DLL/geoip/GeoIP.dat.gz && gunzip GeoIP.dat.gz
wget -c $DLL/geoip/GeoLiteCity.dat.gz && gunzip GeoLiteCity.dat.gz
wget -c $DLL/geoip/GeoLiteCityv6.dat.gz && gunzip GeoLiteCityv6.dat.gz
wget -c $DLL/geoip/GeoIPASNum.dat.gz && gunzip GeoIPASNum.dat.gz
wget -c $DLL/geoip/GeoIPASNumv6.dat.gz && gunzip GeoIPASNumv6.dat.gz

#Install_JDK
cd /tmp
wget -c $DLL/java/jdk-8u231-linux-x64.tar.gz
mkdir -p /usr/local/java
tar zxvf jdk-8u231-linux-x64.tar.gz -C /usr/local/java
mv /usr/local/java/jdk1.8.0_231 /usr/local/java/jdk

cat >>/etc/profile<<eof
#JDK_Config
export JAVA_HOME=/usr/local/java/jdk
export CLASSPATH=.:\$JAVA_HOME/jre/lib/rt.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar
export PATH=\$PATH:\$JAVA_HOME/bin
eof
source /etc/profile

#Config_lib
cd /tmp
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/lib64/libpng.* /usr/lib/
	ln -s /usr/lib64/libjpeg.* /usr/lib/
fi
ulimit -v unlimited
if [ ! `grep -l "/lib" '/etc/ld.so.conf'` ]; then
	echo "/lib" >> /etc/ld.so.conf
fi
if [ ! `grep -l '/usr/lib' '/etc/ld.so.conf'` ]; then
	echo "/usr/lib" >> /etc/ld.so.conf
fi
if [ -d "/usr/lib64" ] && [ ! `grep -l '/usr/lib64' '/etc/ld.so.conf'` ]; then
	echo "/usr/lib64" >> /etc/ld.so.conf
fi
if [ ! `grep -l '/usr/local/lib' '/etc/ld.so.conf'` ]; then
	echo "/usr/local/lib" >> /etc/ld.so.conf
fi
ldconfig
}

function Lnmpa_InstallMySQL()
{
echo "============================Install MySQL 5.6.43=================================="
#Install_MySQL
cd /tmp
rm -f /etc/my.cnf
if [ -s mysql-5.6.44.tar.gz ]; then
	echo " mysql-5.6.44.tar.gz [found]"
else
	echo "Error: mysql-5.6.44.tar.gz not found!!!download now......"
	wget -c $DLL/mysql/mysql-5.6.44.tar.gz
fi

rm -rf mysql-5.6.44
tar -zxf mysql-5.6.44.tar.gz
cd mysql-5.6.44/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mysql -DSYSCONFDIR=/etc -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_ZLIB=system -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_EXTRA_CHARSETS=all -DWITH_SSL=system -DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'
make
make install

groupadd mysql
useradd -s /sbin/nologin -M -g mysql mysql

cat > /etc/mysql.cnf<<EOF
# Example MySQL config file for medium systems.
#
# This is for a large system with memory of 1G-2G where the system runs mainly
# MySQL.
#
# This is a MySQL example config file for systems with 4GB of memory
# running mostly MySQL using InnoDB only tables and performing complex
# queries with few connections.
#
# MySQL programs look for option files in a set of
# locations which depend on the deployment platform.
# You can copy this option file to one of those
# locations. For information about these locations, see:
# http://dev.mysql.com/doc/mysql/en/option-files.html
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.
#
# More detailed information about the individual options can also be
# found in the manual.
#
#
# The following options will be read by MySQL client applications.
# Note that only client applications shipped by MySQL are guaranteed
# to read this section. If you want your own MySQL client program to
# honor these values, you need to specify it as an option during the
# MySQL client library initialization.
#
[client]
#password		= [your_password]
port			= 3306
socket			= /tmp/mysql.sock

# *** Application-specific options follow here ***
#
# The MySQL server
#
[mysqld]

# generic configuration options
port			= 3306
socket			= /tmp/mysql.sock
user			= mysql

# explicit_defaults_for_timestamp is itself deprecated because its 
# only purpose is to permit control over now-deprecated TIMESTAMP 
# behaviors that will be removed in a future MySQL release. When that 
# removal occurs,#explicit_defaults_for_timestamp will have no purpose 
# and will be removed as well. 
explicit_defaults_for_timestamp = true

# back_log is the number of connections the operating system can keep in
# the listen queue, before the MySQL connection manager thread has
# processed them. If you have a very high connection rate and experience
# "connection refused" errors, you might need to increase this value.
# Check your OS documentation for the maximum value of this parameter.
# Attempting to set back_log higher than your operating system limit
# will have no effect.
back_log = 64

# Don't listen on a TCP/IP port at all. This can be a security
# enhancement, if all processes that need to connect to mysqld run
# on the same host.  All interaction with mysqld must be made via Unix
# sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
#skip-networking

#Client / initial size of the buffer for communication between servers. When
#creating multi-row insert statements (as with option --extended-insert or
#--opt), mysqldump to create a length of net_buffer_length line. If you increase
#this variable, it should also ensure that the MySQL server variable
#net_buffer_length at least so big.
net_buffer_length = 16K

# The maximum amount of concurrent sessions the MySQL server will
# allow. One of these connections will be reserved for a user with
# SUPER privileges to allow the administrator to login even if the
# connection limit has been reached.
max_connections = 128

# Maximum amount of errors allowed per host. If this limit is reached,
# the host will be blocked from connecting to the MySQL server until
# "FLUSH HOSTS" has been run or the server was restarted. Invalid
# passwords and other errors during the connect phase result in
# increasing this value. See the "Aborted_connects" status variable for
# global counter.
max_connect_errors = 1024

# The number of open tables for all threads. Increasing this value
# increases the number of file descriptors that mysqld requires.
# Therefore you have to make sure to set the amount of open files
# allowed to at least 4096 in the variable "open-files-limit" in
# section [mysqld_safe]
table_open_cache = 128

# The number of cached table definition (. frm) files. If there are 
# more tables, you can increase the value to speed up the opening of 
# the table. Unlike general table caching, table definition caching 
# does not occupy file descriptors and takes up less space. Minimum 400, 
# online 2000, default: 400 + (table_open_cache / 2)。
table_definition_cache = 400

# Enable external file level locking. Enabled file locking will have a
# negative impact on performance, so only use it in case you have
# multiple database instances running on the same files (note some
# restrictions still apply!) or if you use other software relying on
# locking MyISAM tables on file level.
skip-external-locking

# The maximum size of a query packet the server can handle as well as
# maximum query size server can process (Important when working with
# large BLOBs).  enlarged dynamically, for each connection.
max_allowed_packet = 4M

# The size of the cache to hold the SQL statements for the binary log
# during a transaction. If you often use big, multi-statement
# transactions you can increase this value to get more performance. All
# statements from transactions are buffered in the binary log cache and
# are being written to the binary log at once after the COMMIT.  If the
# transaction is larger than this value, temporary file on disk is used
# instead.  This buffer is allocated per connection on first update
# statement in transaction
binlog_cache_size = 1M

# Maximum allowed size for a single HEAP (in memory) table. This option
# is a protection against the accidential creation of a very large HEAP
# table which could otherwise use up all memory resources.
max_heap_table_size = 32M

# Sort buffer is used to perform sorts for some ORDER BY and GROUP BY
# queries. If sorted data does not fit into the sort buffer, a disk
# based merge sort is used instead - See the "Sort_merge_passes"
# status variable. Allocated per thread if sort is needed.
sort_buffer_size = 512K

# This buffer is used for the optimization of full JOINs (JOINs without
# indexes). Such JOINs are very bad for performance in most cases
# anyway, but setting this variable to a large value reduces the
# performance impact. See the "Select_full_join" status variable for a
# count of full JOINs. Allocated per thread if full join is found
join_buffer_size = 256K

# How many threads we should keep in a cache for reuse. When a client
# disconnects, the client's threads are put in the cache if there aren't
# more than thread_cache_size threads from before.  This greatly reduces
# the amount of thread creations needed if you have a lot of new
# connections. (Normally this doesn't give a notable performance
# improvement if you have a good thread implementation.)
thread_cache_size = 8

# Query cache is used to cache SELECT results and later return them
# without actual executing the same query once again. Having the query
# cache enabled may result in significant speed improvements, if your
# have a lot of identical queries and rarely changing tables. See the
# "Qcache_lowmem_prunes" status variable to check if the current value
# is high enough for your load.
# Note: In case your tables change very often or if your queries are
# textually different every time, the query cache may result in a
# slowdown instead of a performance improvement.
query_cache_type = ON
query_cache_size = 8M

# Only cache result sets that are smaller than this limit. This is to
# protect the query cache of a very large result set overwriting all
# other query results.
query_cache_limit = 2M

# Minimum word length to be indexed by the full text search index.
# You might wish to decrease it if you need to search for shorter words.
# Note that you need to rebuild your FULLTEXT index, after you have
# modified this value.
ft_min_word_len = 4

# If your system supports the memlock() function call, you might want to
# enable this option while running MySQL to keep it locked in memory and
# to avoid potential swapping out in case of high memory pressure. Good
# for performance.
#memlock

# When you create a new table as a table type used by default,
# If you create a table that there is no particular type of execution, 
# this value will be used
#default_table_type = InnoDB

# Table type which is used by default when creating new tables, if not
# specified differently during the CREATE TABLE statement.
#default-storage-engine = MYISAM
default-storage-engine = InnoDB

# Thread stack size to use. This amount of memory is always reserved at
# connection time. MySQL itself usually needs no more than 64K of
# memory, while if you use your own stack hungry UDF functions or your
# OS requires more stack for some operations, you might need to set this
# to a higher value.
thread_stack = 256K

# Set the default transaction isolation level. Levels available are:
# READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE
transaction_isolation = READ-COMMITTED

# Maximum size for internal (in-memory) temporary tables. If a table
# grows larger than this value, it is automatically converted to disk
# based table This limitation is for a single table. There can be many
# of them.
tmp_table_size = 32M

# Enable binary logging. This is required for acting as a MASTER in a
# replication configuration. You also need the binary log if you need
# the ability to do point in time recovery from your latest backup.
log-bin = mysql-bin

# binary logging format - mixed recommended
binlog_format = mixed

# If you're using replication with chained slaves (A->B->C), you need to
# enable this option on server B. It enables logging of updates done by
# the slave thread into the slave's binary log.
#log_slave_updates

# Enable the full query log. Every query (even ones with incorrect
# syntax) that the server receives will be logged. This is useful for
# debugging, it is usually disabled in production use.
#general_log = ON
#general_log_file = /www/wwwdata/mysqldb/mysql_query.log

# Print warnings to the error log file.  If you have any problem with
# MySQL you should enable logging of warnings and examine the error log
# for possible explanations.
log_warnings = 2

# Record slow queries. Slow query refers to the consumption of the query 
# than "long_query_time" defined more time. If log_long_format is opened, 
# those queries that do not use the index will also be recorded. If you 
# regularly add new queries to an existing system, then generally speaking 
# it is a good idea,
slow_query_log = ON

# Specify a slow log file storage location, which can be empty, and the system
# will give a default file hostname-slow.log
#slow_query_log_file

# All use than this time (in seconds) for more inquiries will be considered 
# slow queries. Do As used herein "1", otherwise it will cause all of the query, 
# even very fast query page is recorded (the present time due to the accuracy of 
# MySQL can only reach the second level).
long_query_time = 2

# The parameter log_output specifies the format of slow query output, which defaults 
# to FILE. You can set it to TABLE and then query the slow_log table under MySQL 
# architecture.
log_output = table

# If the running SQL statement does not use an index, the MySQL database will also 
# record the SQL statement in the slow query log file.
log_queries_not_using_indexes = ON

# Represents the number of SQL statements per minute that are allowed to log to slow_log
# without using an index (0 is unrestricted, and SQL may not be recorded if it is a fixed
# value).
log_throttle_queries_not_using_indexes = 0

# This directory is used to store temporary files MySQL. For example,
# It is used to handle large disk-based sorting, and internal ordering the same.
# And simple temporary tables.
# If you do not create very large temporary file, place it on swapfs / tmpfs file system 
# may be better Another option is that you can also be placed on a separate disk.
# You can use ";" to place multiple paths
# They will be used in accordance with roud-robin polling methods.
tmpdir = /www/wwwdata/mysqldb/tmp

# ***  Replication related settings

# Unique server identification number between 1 and 2^32-1. This value
# is required for both master and slave hosts. It defaults to 1 if
# "master-host" is not set, but will MySQL will not function as a master
# if it is omitted.

# required unique id between 1 and 2^32 - 1
# defaults to 1 if master-host is not set
# but will not function as a master if omitted
server-id       = 1

# Replication Slave (comment out master section to use this)
#
# To configure this host as a replication slave, you can choose between
# two methods :
#
# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
#
# OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    changes in this file to the variable values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
#
# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
#server-id = 2
#
# The replication master for this slave - required
#master-host =
#
# The username the slave will use for authentication when connecting
# to the master - required
#master-user =
#
# The password the slave will authenticate with when connecting to
# the master - required
#master-password =
#
# The port the master is listening on.
# optional - defaults to 3306
#master-port =

# If the connection with the master server is unsuccessful, wait n seconds (s) 
# before managing (default is 60s). If a mater. info file exists on the slave 
# server, it will ignore this option.
#master-connect-retry = 

# The database is not mirrored.
#replicate-ignore-db =

# Mirror only this database.
#replicate-do-db =

# Make the slave read-only. Only users with the SUPER privilege and the
# replication slave thread will be able to modify data on it. You can
# use this to ensure that no applications will accidently modify data on
# the slave instead of the master
#read_only = 0/1

# 1: Delete the processed SQL command from the relay log file immediately 
# (default settings); 0: Delete the processed SQL command from the relay log 
# file immediately.
#read-log-purge = 0/1


#*** MyISAM Specific options

# Size of the Key Buffer, used to cache index blocks for MyISAM tables.
# Do not set it larger than 30% of your available memory, as some memory
# is also required by the OS to cache rows. Even if you're not using
# MyISAM tables, you should still set it to 8-64M as it will also be
# used for internal temporary disk tables.
key_buffer_size = 32M

# Size of the buffer used for doing full table scans.
# Allocated per thread, if a full scan is needed.
read_buffer_size = 256K

# When after sorting, from an already sorted sequence reads The row data read 
# from the buffer to prevent the disk seeks.
# If you increase this value, you can improve the performance of many ORDER BY.
# When assigned by each thread when needed
read_rnd_buffer_size = 512K

# MyISAM uses special tree-like cache to make bulk inserts (that is,
# INSERT ... SELECT, INSERT ... VALUES (...), (...), ..., and LOAD DATA
# INFILE) faster. This variable limits the size of the cache tree in
# bytes per thread. Setting it to 0 will disable this optimisation.  Do
# not set it larger than "key_buffer_size" for optimal performance.
# This buffer is allocated when a bulk insert is detected.
bulk_insert_buffer_size = 8M

# This buffer is allocated when MySQL needs to rebuild the index in
# REPAIR, OPTIMIZE, ALTER table statements as well as in LOAD DATA INFILE
# into an empty table. It is allocated per thread so be careful with
# large settings.
myisam_sort_buffer_size = 8M

# The maximum size of the temporary file MySQL is allowed to use while
# recreating the index (during REPAIR, ALTER TABLE or LOAD DATA INFILE.
# If the file-size would be bigger than this, the index will be created
# through the key cache (which is slower).
myisam_max_sort_file_size = 256M

# If a table has more than one index, MyISAM can use more than one
# thread to repair them by sorting in parallel. This makes sense if you
# have multiple CPUs and plenty of memory.
myisam_repair_threads = 1

# Set the MyISAM storage engine recovery mode. The option value is any 
# combination of the values of OFF, DEFAULT, BACKUP, FORCE, or QUICK. 
#myisam_recover_options = 

# Off by default Federated
#skip-federated
federated = ON

# *** BDB related options ***

# If you are running MySQL services have BDB support but when you're not 
# going to use this option. This will save memory and may accelerate something.
#skip-bdb

# *** INNODB Specific options ***

# Use this option if you have a MySQL server with InnoDB support enabled
# but you do not plan to use it. This will save memory and disk space
# and speed up some things.
#skip-innodb

# Additional memory pool that is used by InnoDB to store metadata
# information.  If InnoDB requires more memory for this purpose it will
# start to allocate it from the OS.  As this is fast enough on most
# recent operating systems, you normally do not need to change this
# value. SHOW INNODB STATUS will display the current amount used.
#innodb_additional_mem_pool_size = 0M

# Enable the operating system memory allocator. If disabled, InnoDB 
# uses its own allocator. The default value is ON.
#innodb_use_sys_malloc = ON

# InnoDB, unlike MyISAM, uses a buffer pool to cache both indexes and
# row data. The bigger you set this the less disk I/O is needed to
# access data in tables. On a dedicated database server you may set this
# parameter up to 80% of the machine physical memory size. Do not set it
# too large, though, because competition of the physical memory may
# cause paging in the operating system.  Note that on 32bit systems you
# might be limited to 2-3.5G of user level memory per process, so do not
# set it too high.
innodb_buffer_pool_size = 32M

# InnoDB stores data in one or more data files forming the tablespace.
# If you have a single logical drive for your data, a single
# autoextending file would be good enough. In other cases, a single file
# per device is often a good choice. You can configure InnoDB to use raw
# disk partitions as well - please refer to the manual for more info
# about this.
innodb_data_file_path = ibdata1:10M:autoextend

# Set this option if you would like the InnoDB tablespace files to be
# stored in another location. By default this is the MySQL datadir.
innodb_data_home_dir = /www/wwwdata/mysqldb

# Number of IO threads to use for async IO operations. This value is
# hardcoded to 4 on Unix, but on Windows disk I/O may benefit from a
# larger number.
#innodb_file_io_threads = 4

# If you run into InnoDB tablespace corruption, setting this to a nonzero
# value will likely help you to dump your tables. Start from value 1 and
# increase it until you're able to dump the table successfully.
#innodb_force_recovery = 0

# Number of threads allowed inside the InnoDB kernel. The optimal value
# depends highly on the application, hardware as well as the OS
# scheduler properties. A too high value may lead to thread thrashing.
#innodb_thread_concurrency = 8

# If set to 1, InnoDB will flush (fsync) the transaction logs to the
# disk at each commit, which offers full ACID behavior. If you are
# willing to compromise this safety, and you are running small
# transactions, you may set this to 0 or 2 to reduce disk I/O to the
# logs. Value 0 means that the log is only written to the log file and
# the log file flushed to disk approximately once per second. Value 2
# means the log is written to the log file at each commit, but the log
# file is only flushed to disk approximately once per second.
innodb_flush_log_at_trx_commit = 1

# Speed up InnoDB shutdown. This will disable InnoDB to do a full purge
# and insert buffer merge on shutdown. It may increase shutdown time a
# lot, but InnoDB will have to do it on the next startup instead.
#innodb_fast_shutdown = 1

# The size of the buffer InnoDB uses for buffering log data. As soon as
# it is full, InnoDB will have to flush it to disk. As it is flushed
# once per second anyway, it does not make sense to have it very large
# (even with long transactions).
innodb_log_buffer_size = 8M

# Size of each log file in a log group. You should set the combined size
# of log files to about 25%-100% of your buffer pool size to avoid
# unneeded buffer pool flush activity on log file overwrite. However,
# note that a larger logfile size will increase the time needed for the
# recovery process.
innodb_log_file_size = 8M

# Total number of files in the log group. A value of 2-3 is usually good
# enough.
innodb_log_files_in_group = 3

# Location of the InnoDB log files. Default is the MySQL datadir. You
# may wish to point it to a dedicated hard drive or a RAID1 volume for
# improved performance
innodb_log_group_home_dir = /www/wwwdata/mysqldb

# Maximum allowed percentage of dirty pages in the InnoDB buffer pool.
# If it is reached, InnoDB will start flushing them out agressively to
# not run out of clean pages at all. This is a soft limit, not
# guaranteed to be held.
#innodb_max_dirty_pages_pct = 90

# The flush method InnoDB will use for Log. The tablespace always uses
# doublewrite flush logic. The default value is "fdatasync", another
# option is "O_DSYNC".
#innodb_flush_method = O_DSYNC

# How long an InnoDB transaction should wait for a lock to be granted
# before being rolled back. InnoDB automatically detects transaction
# deadlocks in its own lock table and rolls back the transaction. If you
# use the LOCK TABLES command, or other transaction-safe storage engines
# than InnoDB in the same transaction, then a deadlock may arise which
# InnoDB cannot notice. In cases like this the timeout is useful to
# resolve the situation.
innodb_lock_wait_timeout = 60

# This setting needs to be informed whether InnoDB data and index all the 
# tables stored in the shared table space (innodb_file_per_table = OFF) or 
# as a separate data for each table in a .ibd file (innodb_file_per_table = ON)
# Reclaim disk space each table in a file that allows you to drop, truncate or 
# rebuild table This is also necessary advanced features, such as data compression, 
# but it does not bring any performance gains.
innodb_file_per_table = ON

# MySQL open file descriptor limit, the default minimum 1024; when
# open_files_limit is not configured to compare max_connections * 5 and the value
# of ulimit -n, which Dayong which,
open_files_limit = 65535

# The maximum number of instrumented table objects. 
performance_schema_max_table_instances = 400

[mysqldump]
# Do not buffer the whole result set in memory before writing it to
# file. Required for dumping very large tables
quick

max_allowed_packet = 16M

[mysql]
no-auto-rehash

# Only allow UPDATEs and DELETEs that use keys.
#safe-updates

[myisamchk]
key_buffer_size = 32M
sort_buffer_size = 512K
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
# Increase the amount of open files allowed per process. Warning: Make
# sure you have set the global system limit high enough! The high value
# is required for a large number of opened tables
open-files-limit = 65535
#malloc-lib=/usr/lib/libtcmalloc.so

EOF

mkdir -p /www/wwwdata/mysqldb
mkdir -p /www/wwwdata/mysqldb/tmp
chmod 700 /www/wwwdata/mysqldb
chown -R root:root /usr/local/mysql
chown -R mysql:mysql /www/wwwdata/mysqldb
chown root:mysql /etc/mysql.cnf
chmod 644 /etc/mysql.cnf

wget -c $DLL/init.d/init.d.mysql && mv init.d.mysql /etc/init.d/mysql
chmod 755 /etc/init.d/mysql

cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
ldconfig

ln -s /usr/local/mysql/lib/mysql /usr/lib/mysql
ln -s /usr/local/mysql/include/mysql /usr/include/mysql
ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
ln -s /usr/local/mysql/bin/mysqld /usr/bin/mysqld
ln -s /usr/local/mysql/bin/mysqldump /usr/bin/mysqldump
ln -s /usr/local/mysql/bin/myisamchk /usr/bin/myisamchk
ln -s /usr/local/mysql/bin/mysqld_safe /usr/bin/mysqld_safe

if command -v systemctl >/dev/null 2>&1; then
	systemctl disable mysql.service
else
	chkconfig --add mysql
	chkconfig mysql off
fi

cd
wget -c $DLL/tools/config_mysql.sh

if [ -s /usr/local/mysql/bin/mysql ] && [ -s /usr/local/mysql/bin/mysqld_safe ] && [ -s /etc/mysql.cnf ]; then
	echo "MySQL: OK"
	ismysql="ok"
else
	echo "Error: /usr/local/mysql not found!!!MySQL install failed."
fi

echo "============================MySQL 5.6.44 install completed========================="
}

function Lnmpa_InstallMariaDB()
{
echo "============================Install MariaDB 10.1.40=================================="
#Install_Mariadb
cd /tmp
if [ -s mariadb-10.1.40.tar.gz ]; then
	echo "mariadb-10.1.40.tar.gz [found]"
else
	echo "Error: mariadb-10.1.40.tar.gz not found!!!download now......"
	wget -c $DLL/mariadb/mariadb-10.1.40.tar.gz
fi

rm -f /etc/my.cnf
tar -zxf mariadb-10.1.40.tar.gz
cd mariadb-10.1.40/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local/mariadb -DSYSCONFDIR=/etc -DWITH_ARIA_STORAGE_ENGINE=1 -DWITH_XTRADB_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_FEDERATED_STORAGE_ENGINE=1 -DWITH_ARCHIVE_STORAGE_ENGINE=1 -DWITH_BLACKHOLE_STORAGE_ENGINE=1 -DWITH_SPHINX_STORAGE_ENGINE=1 -DWITH_TOKUDB_STORAGE_ENGINE=1 -DWITH_PERFSCHEMA_STORAGE_ENGINE=1 -DWITH_CASSANDRA_STORAGE_ENGINE=1 -DWITH_MERGE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DWITH_SPHINXSE_STORAGE_ENGINE=1 -DWITH_FEDERATEDX_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DDEFAULT_COLLATION=utf8mb4_general_ci -DWITH_READLINE=1 -DWITH_EMBEDDED_SERVER=1 -DENABLED_LOCAL_INFILE=1 -DWITH_SSL=system -DWITH_ZLIB=system -DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'
make
make install

groupadd mariadb
useradd -s /sbin/nologin -M -g mariadb mariadb

cat > /etc/mariadb.cnf<<EOF
# Example MariaDB config file for medium systems.
#
# This is a MariaDB example config file for systems with 4GB of memory
# running mostly MariaDB using InnoDB only tables and performing complex
# queries with few connections.
#
# MariaDB programs look for option files in a set of
# locations which depend on the deployment platform.
# You can copy this option file to one of those
# locations. For information about these locations, do:
# 'my_print_defaults --help' and see what is printed under
# Default options are read from the following files in the given order:
# More information at: http://dev.mysql.com/doc/mysql/en/option-files.html
#
# In this file, you can use all long options that a program supports.
# If you want to know which options a program supports, run the program
# with the "--help" option.
#
# More detailed information about the individual options can also be
# found in the manual.
#

#
# The following options will be read by MariaDB client applications.
# Note that only client applications shipped by MariaDB are guaranteed
# to read this section. If you want your own MariaDB client program to
# honor these values, you need to specify it as an option during the
# MariaDB client library initialization.
#
[client]
#password	= [your_password]
port		= 3308
socket		= /tmp/mariadb.sock

# *** Application-specific options follow here ***

#
# The MariaDB server
#
[mysqld]

# generic configuration options
port		= 3308
socket		= /tmp/mariadb.sock
user		= mariadb

# explicit_defaults_for_timestamp is itself deprecated because its 
# only purpose is to permit control over now-deprecated TIMESTAMP 
# behaviors that will be removed in a future MySQL release. When that 
# removal occurs,#explicit_defaults_for_timestamp will have no purpose 
# and will be removed as well. 
#explicit_defaults_for_timestamp = true

# back_log is the number of connections the operating system can keep in
# the listen queue, before the MariaDB connection manager thread has
# processed them. If you have a very high connection rate and experience
# "connection refused" errors, you might need to increase this value.
# Check your OS documentation for the maximum value of this parameter.
# Attempting to set back_log higher than your operating system limit
# will have no effect.
back_log = 64

# Don't listen on a TCP/IP port at all. This can be a security
# enhancement, if all processes that need to connect to mysqld run
# on the same host.  All interaction with mysqld must be made via Unix
# sockets or named pipes.
# Note that using this option without enabling named pipes on Windows
# (via the "enable-named-pipe" option) will render mysqld useless!
#skip-networking

#Client / initial size of the buffer for communication between servers. When
#creating multi-row insert statements (as with option --extended-insert or
#--opt), mysqldump to create a length of net_buffer_length line. If you increase
#this variable, it should also ensure that the MySQL server variable
#net_buffer_length at least so big.
net_buffer_length = 16K

# The maximum amount of concurrent sessions the MariaDB server will
# allow. One of these connections will be reserved for a user with
# SUPER privileges to allow the administrator to login even if the
# connection limit has been reached.
max_connections = 88

# Maximum amount of errors allowed per host. If this limit is reached,
# the host will be blocked from connecting to the MariaDB server until
# "FLUSH HOSTS" has been run or the server was restarted. Invalid
# passwords and other errors during the connect phase result in
# increasing this value. See the "Aborted_connects" status variable for
# global counter.
max_connect_errors = 1024

# The number of open tables for all threads. Increasing this value
# increases the number of file descriptors that mysqld requires.
# Therefore you have to make sure to set the amount of open files
# allowed to at least 4096 in the variable "open-files-limit" in
# section [mysqld_safe]
table_open_cache = 128

# The number of cached table definition (. frm) files. If there are 
# more tables, you can increase the value to speed up the opening of 
# the table. Unlike general table caching, table definition caching 
# does not occupy file descriptors and takes up less space. Minimum 400, 
# online 2000, default: 400 + (table_open_cache / 2)。
table_definition_cache = 400

# Enable external file level locking. Enabled file locking will have a
# negative impact on performance, so only use it in case you have
# multiple database instances running on the same files (note some
# restrictions still apply!) or if you use other software relying on
# locking MyISAM tables on file level.
#external-locking
skip-external-locking

# The maximum size of a query packet the server can handle as well as
# maximum query size server can process (Important when working with
# large BLOBs).  enlarged dynamically, for each connection.
max_allowed_packet = 4M

# The size of the cache to hold the SQL statements for the binary log
# during a transaction. If you often use big, multi-statement
# transactions you can increase this value to get more performance. All
# statements from transactions are buffered in the binary log cache and
# are being written to the binary log at once after the COMMIT.  If the
# transaction is larger than this value, temporary file on disk is used
# instead.  This buffer is allocated per connection on first update
# statement in transaction
binlog_cache_size = 1M

# Maximum allowed size for a single HEAP (in memory) table. This option
# is a protection against the accidential creation of a very large HEAP
# table which could otherwise use up all memory resources.
max_heap_table_size = 32M

# Sort buffer is used to perform sorts for some ORDER BY and GROUP BY
# queries. If sorted data does not fit into the sort buffer, a disk
# based merge sort is used instead - See the "Sort_merge_passes"
# status variable. Allocated per thread if sort is needed.
sort_buffer_size = 256K

# This buffer is used for the optimization of full JOINs (JOINs without
# indexes). Such JOINs are very bad for performance in most cases
# anyway, but setting this variable to a large value reduces the
# performance impact. See the "Select_full_join" status variable for a
# count of full JOINs. Allocated per thread if full join is found
join_buffer_size = 256K

# How many threads we should keep in a cache for reuse. When a client
# disconnects, the client's threads are put in the cache if there aren't
# more than thread_cache_size threads from before.  This greatly reduces
# the amount of thread creations needed if you have a lot of new
# connections. (Normally this doesn't give a notable performance
# improvement if you have a good thread implementation.)
thread_cache_size = 8

# This permits the application to give the threads system a hint for the
# desired number of threads that should be run at the same time.  This
# value only makes sense on systems that support the thread_concurrency()
# function call (Sun Solaris, for example).
# You should try [number of CPUs]*(2..4) for thread_concurrency
#thread_concurrency = 1

# Query cache is used to cache SELECT results and later return them
# without actual executing the same query once again. Having the query
# cache enabled may result in significant speed improvements, if your
# have a lot of identical queries and rarely changing tables. See the
# "Qcache_lowmem_prunes" status variable to check if the current value
# is high enough for your load.
# Note: In case your tables change very often or if your queries are
# textually different every time, the query cache may result in a
# slowdown instead of a performance improvement.
query_cache_type = ON
query_cache_size = 4M

# Only cache result sets that are smaller than this limit. This is to
# protect the query cache of a very large result set overwriting all
# other query results.
query_cache_limit = 2M

# Minimum word length to be indexed by the full text search index.
# You might wish to decrease it if you need to search for shorter words.
# Note that you need to rebuild your FULLTEXT index, after you have
# modified this value.
ft_min_word_len = 4

# If your system supports the memlock() function call, you might want to
# enable this option while running MariaDB to keep it locked in memory and
# to avoid potential swapping out in case of high memory pressure. Good
# for performance.
#memlock

# Table type which is used by default when creating new tables, if not
# specified differently during the CREATE TABLE statement.
default-storage-engine = InnoDB

# Thread stack size to use. This amount of memory is always reserved at
# connection time. MariaDB itself usually needs no more than 64K of
# memory, while if you use your own stack hungry UDF functions or your
# OS requires more stack for some operations, you might need to set this
# to a higher value.
thread_stack = 256K

# Set the default transaction isolation level. Levels available are:
# READ-UNCOMMITTED, READ-COMMITTED, REPEATABLE-READ, SERIALIZABLE
transaction_isolation = READ-COMMITTED

# Maximum size for internal (in-memory) temporary tables. If a table
# grows larger than this value, it is automatically converted to disk
# based table This limitation is for a single table. There can be many
# of them.
tmp_table_size = 16M

# Enable binary logging. This is required for acting as a MASTER in a
# replication configuration. You also need the binary log if you need
# the ability to do point in time recovery from your latest backup.
log-bin=mysql-bin

# binary logging format - mixed recommended
binlog_format = mixed

# If you're using replication with chained slaves (A->B->C), you need to
# enable this option on server B. It enables logging of updates done by
# the slave thread into the slave's binary log.
#log_slave_updates

# Enable the full query log. Every query (even ones with incorrect
# syntax) that the server receives will be logged. This is useful for
# debugging, it is usually disabled in production use.
#general_log = ON
#general_log_file = /www/wwwdata/mariadb/mariadb_query.log

# Print warnings to the error log file.  If you have any problem with
# MariaDB you should enable logging of warnings and examine the error log
# for possible explanations.
log_warnings = 2

# Log slow queries. Slow queries are queries which take more than the
# amount of time defined in "long_query_time" or which do not use
# indexes well, if log_short_format is not enabled. It is normally good idea
# to have this turned on if you frequently add new queries to the
# system.
slow_query_log = ON

# Specify a slow log file storage location, which can be empty, and the system
# will give a default file hostname-slow.log
#slow_query_log_file

# All queries taking more than this amount of time (in seconds) will be
# trated as slow. Do not use "1" as a value here, as this will result in
# even very fast queries being logged from time to time (as MariaDB
# currently measures time with second accuracy only).
long_query_time = 2

# The parameter log_output specifies the format of slow query output, which defaults 
# to FILE. You can set it to TABLE and then query the slow_log table under MySQL 
# architecture.
log_output = table

# If the running SQL statement does not use an index, the MySQL database will also 
# record the SQL statement in the slow query log file.
log_queries_not_using_indexes = ON

# Represents the number of SQL statements per minute that are allowed to log to slow_log
# without using an index (0 is unrestricted, and SQL may not be recorded if it is a fixed
# value).
#log_throttle_queries_not_using_indexes = 0

# The directory used by MySQL for storing temporary files. For example,
# it is used to perform disk based large sorts, as well as for internal
# and explicit temporary tables. It might be good to put it on a
# swapfs/tmpfs filesystem, if you do not create very large temporary
# files. Alternatively you can put it on dedicated disk. You can
# specify multiple paths here by separating them by ";" - they will then
# be used in a round-robin fashion.
tmpdir = /www/wwwdata/mariadb/tmp

# ***  Replication related settings

# Unique server identification number between 1 and 2^32-1. This value
# is required for both master and slave hosts. It defaults to 1 if
# "master-host" is not set, but will MariaDB will not function as a master
# if it is omitted.
server-id = 1

# Replication Slave (comment out master section to use this)
#
# To configure this host as a replication slave, you can choose between
# two methods :
#
# 1) Use the CHANGE MASTER TO command (fully described in our manual) -
#    the syntax is:
#
#    CHANGE MASTER TO MASTER_HOST=<host>, MASTER_PORT=<port>,
#    MASTER_USER=<user>, MASTER_PASSWORD=<password> ;
#
#    where you replace <host>, <user>, <password> by quoted strings and
#    <port> by the master's port number (3306 by default).
#
#    Example:
#
#    CHANGE MASTER TO MASTER_HOST='125.564.12.1', MASTER_PORT=3306,
#    MASTER_USER='joe', MASTER_PASSWORD='secret';
#
# OR
#
# 2) Set the variables below. However, in case you choose this method, then
#    start replication for the first time (even unsuccessfully, for example
#    if you mistyped the password in master-password and the slave fails to
#    connect), the slave will create a master.info file, and any later
#    changes in this file to the variable values below will be ignored and
#    overridden by the content of the master.info file, unless you shutdown
#    the slave server, delete master.info and restart the slaver server.
#    For that reason, you may want to leave the lines below untouched
#    (commented) and instead use CHANGE MASTER TO (see above)
#
# required unique id between 2 and 2^32 - 1
# (and different from the master)
# defaults to 2 if master-host is set
# but will not function as a slave if omitted
#server-id = 2
#
# The replication master for this slave - required
#master-host = <hostname>
#
# The username the slave will use for authentication when connecting
# to the master - required
#master-user = <username>
#
# The password the slave will authenticate with when connecting to
# the master - required
#master-password = <password>
#
# The port the master is listening on.
# optional - defaults to 3306
#master-port = <port>

# Make the slave read-only. Only users with the SUPER privilege and the
# replication slave thread will be able to modify data on it. You can
# use this to ensure that no applications will accidently modify data on
# the slave instead of the master
#read_only

#*** MyISAM Specific options

# Size of the Key Buffer, used to cache index blocks for MyISAM tables.
# Do not set it larger than 30% of your available memory, as some memory
# is also required by the OS to cache rows. Even if you're not using
# MyISAM tables, you should still set it to 8-64M as it will also be
# used for internal temporary disk tables.
key_buffer_size = 16M

# Size of the buffer used for doing full table scans.
# Allocated per thread, if a full scan is needed.
read_buffer_size = 256K

# When reading rows in sorted order after a sort, the rows are read
# through this buffer to avoid disk seeks. You can improve ORDER BY
# performance a lot, if set this to a high value.
# Allocated per thread, when needed.
read_rnd_buffer_size = 256K

# MyISAM uses special tree-like cache to make bulk inserts (that is,
# INSERT ... SELECT, INSERT ... VALUES (...), (...), ..., and LOAD DATA
# INFILE) faster. This variable limits the size of the cache tree in
# bytes per thread. Setting it to 0 will disable this optimisation.  Do
# not set it larger than "key_buffer_size" for optimal performance.
# This buffer is allocated when a bulk insert is detected.
bulk_insert_buffer_size = 8M

# This buffer is allocated when MariaDB needs to rebuild the index in
# REPAIR, OPTIMIZE, ALTER table statements as well as in LOAD DATA INFILE
# into an empty table. It is allocated per thread so be careful with
# large settings.
myisam_sort_buffer_size = 8M

# The maximum size of the temporary file MariaDB is allowed to use while
# recreating the index (during REPAIR, ALTER TABLE or LOAD DATA INFILE.
# If the file-size would be bigger than this, the index will be created
# through the key cache (which is slower).
myisam_max_sort_file_size = 256M

# If a table has more than one index, MyISAM can use more than one
# thread to repair them by sorting in parallel. This makes sense if you
# have multiple CPUs and plenty of memory.
myisam_repair_threads = 1

# Set the MyISAM storage engine recovery mode. The option value is any 
# combination of the values of OFF, DEFAULT, BACKUP, FORCE, or QUICK. 
#myisam_recover_options = 

# Off by default Federated
#skip-federated
federated = ON

# *** BDB related options ***

# If you are running MySQL services have BDB support but when you're not 
# going to use this option. This will save memory and may accelerate something.
#skip-bdb

# *** INNODB Specific options ***

# Use this option if you have a MariaDB server with InnoDB support enabled
# but you do not plan to use it. This will save memory and disk space
# and speed up some things.
#skip-innodb

# Additional memory pool that is used by InnoDB to store metadata
# information.  If InnoDB requires more memory for this purpose it will
# start to allocate it from the OS.  As this is fast enough on most
# recent operating systems, you normally do not need to change this
# value. SHOW INNODB STATUS will display the current amount used.
#innodb_additional_mem_pool_size = 0M

# Enable the operating system memory allocator. If disabled, InnoDB 
# uses its own allocator. The default value is ON.
#innodb_use_sys_malloc = ON

# InnoDB, unlike MyISAM, uses a buffer pool to cache both indexes and
# row data. The bigger you set this the less disk I/O is needed to
# access data in tables. On a dedicated database server you may set this
# parameter up to 80% of the machine physical memory size. Do not set it
# too large, though, because competition of the physical memory may
# cause paging in the operating system.  Note that on 32bit systems you
# might be limited to 2-3.5G of user level memory per process, so do not
# set it too high.
innodb_buffer_pool_size = 16M

# InnoDB stores data in one or more data files forming the tablespace.
# If you have a single logical drive for your data, a single
# autoextending file would be good enough. In other cases, a single file
# per device is often a good choice. You can configure InnoDB to use raw
# disk partitions as well - please refer to the manual for more info
# about this.
innodb_data_file_path = ibdata1:10M:autoextend

# Set this option if you would like the InnoDB tablespace files to be
# stored in another location. By default this is the MariaDB datadir.
innodb_data_home_dir = /www/wwwdata/mariadb

# Number of IO threads to use for async IO operations. This value is
# hardcoded to 8 on Unix, but on Windows disk I/O may benefit from a
# larger number.
#innodb_file_io_threads = 4
#innodb_write_io_threads = 8
#innodb_read_io_threads = 8

# If you run into InnoDB tablespace corruption, setting this to a nonzero
# value will likely help you to dump your tables. Start from value 1 and
# increase it until you're able to dump the table successfully.
#innodb_force_recovery = 1

# Number of threads allowed inside the InnoDB kernel. The optimal value
# depends highly on the application, hardware as well as the OS
# scheduler properties. A too high value may lead to thread thrashing.
#innodb_thread_concurrency = 4

# If set to 1, InnoDB will flush (fsync) the transaction logs to the
# disk at each commit, which offers full ACID behavior. If you are
# willing to compromise this safety, and you are running small
# transactions, you may set this to 0 or 2 to reduce disk I/O to the
# logs. Value 0 means that the log is only written to the log file and
# the log file flushed to disk approximately once per second. Value 2
# means the log is written to the log file at each commit, but the log
# file is only flushed to disk approximately once per second.
innodb_flush_log_at_trx_commit = 1

# Speed up InnoDB shutdown. This will disable InnoDB to do a full purge
# and insert buffer merge on shutdown. It may increase shutdown time a
# lot, but InnoDB will have to do it on the next startup instead.
#innodb_fast_shutdown

# The size of the buffer InnoDB uses for buffering log data. As soon as
# it is full, InnoDB will have to flush it to disk. As it is flushed
# once per second anyway, it does not make sense to have it very large
# (even with long transactions).
innodb_log_buffer_size = 4M

# Size of each log file in a log group. You should set the combined size
# of log files to about 25%-100% of your buffer pool size to avoid
# unneeded buffer pool flush activity on log file overwrite. However,
# note that a larger logfile size will increase the time needed for the
# recovery process.
innodb_log_file_size = 8M

# Total number of files in the log group. A value of 2-3 is usually good
# enough.
innodb_log_files_in_group = 3

# Location of the InnoDB log files. Default is the MariaDB datadir. You
# may wish to point it to a dedicated hard drive or a RAID1 volume for
# improved performance
innodb_log_group_home_dir = /www/wwwdata/mariadb

# Maximum allowed percentage of dirty pages in the InnoDB buffer pool.
# If it is reached, InnoDB will start flushing them out agressively to
# not run out of clean pages at all. This is a soft limit, not
# guaranteed to be held.
#innodb_max_dirty_pages_pct = 4

# The flush method InnoDB will use for Log. The tablespace always uses
# doublewrite flush logic. The default value is "fdatasync", another
# option is "O_DSYNC".
#innodb_flush_method = O_DSYNC

# How long an InnoDB transaction should wait for a lock to be granted
# before being rolled back. InnoDB automatically detects transaction
# deadlocks in its own lock table and rolls back the transaction. If you
# use the LOCK TABLES command, or other transaction-safe storage engines
# than InnoDB in the same transaction, then a deadlock may arise which
# InnoDB cannot notice. In cases like this the timeout is useful to
# resolve the situation.
innodb_lock_wait_timeout = 50

# This setting needs to be informed whether InnoDB data and index all the
# tables stored in the shared table space (innodb_file_per_table = OFF) or 
# as a separate data for each table in a .ibd file (innodb_file_per_table = ON)
# Reclaim disk space each table in a file that allows you to drop, truncate or
# rebuild table This is also necessary advanced features, such as data compression, 
# but it does not bring any performance gains
innodb_file_per_table = ON

#MySQL open file descriptor limit, the default minimum 1024; when
#open_files_limit is not configured to compare max_connections * 5 and the value
#of ulimit -n, which Dayong which,
open_files_limit = 65535

[mysqldump]
# Do not buffer the whole result set in memory before writing it to
# file. Required for dumping very large tables
quick

max_allowed_packet = 16M

[mysql]
no-auto-rehash

# Only allow UPDATEs and DELETEs that use keys.
#safe-updates

[myisamchk]
key_buffer_size = 16M
sort_buffer_size = 256K
read_buffer = 4M
write_buffer = 4M

[mysqlhotcopy]
interactive-timeout

[mysqld_safe]
# Increase the amount of open files allowed per process. Warning: Make
# sure you have set the global system limit high enough! The high value
# is required for a large number of opened tables
open-files-limit = 65535
#malloc-lib=/usr/lib/libtcmalloc.so

EOF

mkdir -p /www/wwwdata/mariadb
mkdir -p /www/wwwdata/mariadb/tmp
chmod 700 /www/wwwdata/mariadb
chown -R root:root /usr/local/mariadb
chown -R mariadb:mariadb /www/wwwdata/mariadb
chown root:mariadb /etc/mariadb.cnf
chmod 644 /etc/mariadb.cnf

wget -c $DLL/init.d/init.d.mariadb && mv init.d.mariadb /etc/init.d/mariadb
chmod 755 /etc/init.d/mariadb

cat > /etc/ld.so.conf.d/mariadb.conf<<EOF
/usr/local/mariadb/lib
/usr/local/lib
EOF
ldconfig

ln -sf /usr/local/mariadb/bin/mysql /usr/bin/mariadb
ln -sf /usr/local/mariadb/bin/mysqldump /usr/bin/mariadbdump
ln -s /usr/local/mariadb/bin/mysqld /usr/bin/mariadbd
ln -sf /usr/local/mariadb/bin/myisamchk /usr/bin/maisamchk
ln -sf /usr/local/mariadb/bin/mysqld_safe /usr/bin/mariadb_safe
ln -sf /usr/local/mariadb/bin/mysqlcheck /usr/bin/mariadbcheck

if command -v systemctl >/dev/null 2>&1; then
	systemctl disable mariadb.service
else
	chkconfig --add mariadb
	chkconfig mariadb off
fi

cd
wget -c $DLL/tools/config_mariadb.sh

if [ -s /usr/local/mariadb/bin/mysql ] && [ -s /usr/local/mariadb/bin/mysqld_safe ] && [ -s /etc/mariadb.cnf ]; then
	echo "MariaDB: OK"
	isMariaDB="ok"
	else
	echo "Error: /usr/local/mariadb not found!!!MySQL install failed."
fi
echo "============================MariaDB 10.1.40 install completed========================="
}

function Lnmpa_InstallApache()
{
echo "============================Install Apache 2.4.7=================================="
#Install_Apache
cd /tmp
if [ -s httpd-2.4.41.tar.bz2 ]; then
	echo "httpd-2.4.41.tar.bz2 [found]"
else
	echo "Error: httpd-2.4.41.tar.bz2 not found!!!download now......"
	wget -c $DLL/apache/httpd-2.4.41.tar.bz2
fi

if [ -s apr-1.7.0.tar.bz2 ]; then
	echo "apr-1.7.0.tar.bz2 [found]"
else
	echo "Error: apr-1.7.0.tar.bz2 not found!!!download now......"
	wget -c $DLL/apr/apr-1.7.0.tar.bz2
fi

if [ -s apr-util-1.6.1.tar.bz2 ]; then
	echo "apr-util-1.6.1.tar.bz2 [found]"
else
	echo "Error: apr-util-1.6.1.tar.bz2 not found!!!download now......"
	wget -c $DLL/apr/apr-util-1.6.1.tar.bz2
fi

rm -rf httpd-2.4.41 apr-1.7.0 apr-util-1.6.1
tar -jxf httpd-2.4.41.tar.bz2
tar -jxf apr-1.7.0.tar.bz2
tar -jxf apr-util-1.6.1.tar.bz2
cp -rf ./apr-1.7.0 ./httpd-2.4.41/srclib/apr
cp -rf ./apr-util-1.6.1 ./httpd-2.4.41/srclib/apr-util
cd httpd-2.4.41/
sed -i 's/#define AP_SERVER_BASEPRODUCT "Apache"/#define AP_SERVER_BASEPRODUCT "SuperServer"/' include/ap_release.h
sed -i 's/#define PLATFORM "Unix"/#define PLATFORM "SuperOS"/' os/unix/os.h
./configure --prefix=/usr/local/apache --enable-mods-shared=all --enable-mpms-shared=all --with-suexec-caller=www --with-suexec-bin=/usr/local/apache/bin/suexec --enable-so --with-pcre --with-ssl --enable-ssl --with-included-apr --with-apr-util --enable-static-ab --enable-suexec --enable-cgi --enable-cgid --with-crypto
make
make install

mv /usr/local/apache/conf/httpd.conf /usr/local/apache/conf/httpd.conf.bak
mv /usr/local/apache/conf/extra/httpd-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf.bak
mv /usr/local/apache/conf/extra/httpd-default.conf /usr/local/apache/conf/extra/httpd-default.conf.bak
mv /usr/local/apache/conf/extra/httpd-ssl.conf /usr/local/apache/conf/extra/httpd-ssl.conf.bak

cd /tmp
mkdir -p /usr/local/apache/conf/vhosts
wget -c $DLL/conf/httpd-lnmpa.conf && mv httpd-lnmpa.conf /usr/local/apache/conf/httpd.conf
wget -c $DLL/conf/httpd-lnmpa-vhosts.conf && mv httpd-lnmpa-vhosts.conf /usr/local/apache/conf/extra/httpd-vhosts.conf
wget -c $DLL/conf/httpd-lnmpa-default.conf && mv httpd-lnmpa-default.conf /usr/local/apache/conf/extra/httpd-default.conf
wget -c $DLL/conf/httpd-lnmpa-ssl.conf && mv httpd-lnmpa-ssl.conf /usr/local/apache/conf/extra/httpd-ssl.conf
wget -c $DLL/conf/httpd-lnmpa-remoteip.conf && mv httpd-lnmpa-remoteip.conf /usr/local/apache/conf/extra/httpd-remoteip.conf
wget -c $DLL/conf/httpd-lnmpa-localhost.conf && mv httpd-lnmpa-localhost.conf /usr/local/apache/conf/vhosts/localhost.conf
wget -c $DLL/conf/localhost.key && mv localhost.key /www/wwwssls/localhost.key
wget -c $DLL/conf/localhost.crt && mv localhost.crt /www/wwwssls/localhost.crt

wget -c $DLL/init.d/init.d.httpd  && mv init.d.httpd /etc/init.d/httpd
chmod +x /etc/init.d/httpd

if command -v systemctl >/dev/null 2>&1; then
	systemctl disable httpd.service
else
	chkconfig --add httpd
	chkconfig httpd off
fi

#Install_apache_geoip_model
cd /tmp
if [ -s geoip-api-mod_geoip2-1.2.10 ]; then
	rm -rf geoip-api-mod_geoip2-1.2.10
fi
wget  -c $DLL/geoip/geoip-api-mod_geoip2-1.2.10.tar.gz
tar -zxf geoip-api-mod_geoip2-1.2.10.tar.gz
cd geoip-api-mod_geoip2-1.2.10
/usr/local/apache/bin/apxs -cia -I/usr/local/include -L/usr/local/lib -lGeoIP mod_geoip.c

#Install_Php
cd /tmp
rm -rf /usr/local/php/
if [ -s php-7.1.32 ]; then
	rm -rf php-7.1.32
fi
wget -c $DLL/php/php-7.1.32.tar.bz2
tar -jxf php-7.1.32.tar.bz2
cd php-7.1.32/
./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --with-apxs2=/usr/local/apache/bin/apxs --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-freetype-dir=/usr/local/freetype --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring --with-mcrypt --enable-ftp --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext --enable-fileinfo --enable-opcache  --with-xsl --enable-exif --with-bz2 --enable-intl
make ZEND_EXTRA_LIBS='-liconv' -j `grep 'processor' /proc/cpuinfo | wc -l`
if [ $? -ne 0 ]; then
	make ZEND_EXTRA_LIBS='-liconv'
fi
make install

ln -sf /usr/local/php/bin/php /usr/bin/php
ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
ln -sf /usr/local/php/bin/pear /usr/bin/pear
ln -sf /usr/local/php/bin/pecl /usr/bin/pecl
rm -f /usr/local/php/conf.d/*

#cd /tmp
#wget  http://pear.php.net/go-pear.phar 
#/usr/local/php/bin/php go-pear.phar

mkdir -p /usr/local/php/{etc,conf.d}
\cp php.ini-production /usr/local/php/etc/php.ini

export PHP_AUTOCONF=/usr/local/autoconf/bin/autoconf
export PHP_AUTOHEADER=/usr/local/autoconf/bin/autoheader

cd /tmp
sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini

/usr/local/php/bin/pear config-set php_ini /usr/local/php/etc/php.ini
/usr/local/php/bin/pecl config-set php_ini /usr/local/php/etc/php.ini

curl -sS --connect-timeout 30 -m 60 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
if [ $? -eq 0 ]; then
    echo "Composer install successfully."
else
    if [ -s /usr/local/php/bin/php ]; then
        wget --prefer-family=IPv4 --no-check-certificate -T 120 -t3 $DLL/php/composer.phar -O /usr/local/bin/composer
        if [ $? -eq 0 ]; then
            echo "Composer install successfully."
        else
            echo "Composer install failed!"
        fi
        chmod +x /usr/local/bin/composer
    fi
fi

php_ext_dir="`/usr/local/php/bin/php-config --extension-dir`/"
memcached_so="${php_ext_dir}memcached.so"
if [ -s "${memcached_so}" ]; then
	rm -f "${memcached_so}"
fi
memcache_so="${php_ext_dir}memcache.so"
if [ -s "${memcache_so}" ]; then
	rm -f "${memcache_so}"
fi
imagick_so="${php_ext_dir}imagick.so"
if [ -s "${imagick_so}" ]; then
	rm -f "${imagick_so}"
fi
gmagick_so="${php_ext_dir}gmagick.so"
if [ -s "${gmagick_so}" ]; then
	rm -f "${gmagick_so}"
fi
redis_so="${php_ext_dir}redis.so"
if [ -s "${redis_so}" ]; then
	rm -f "${redis_so}"
fi
mongodb_so="${php_ext_dir}mongodb.so"
if [ -s "${mongodb_so}" ]; then
	rm -f "${mongodb_so}"
fi

#Install_IonCube
cd /tmp
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
cd /usr/local/
	wget -c $DLL/ioncube/ioncube_loaders_lin_x86-64.tar.gz
	tar -zxf ioncube_loaders_lin_x86-64.tar.gz
	rm -rf ioncube_loaders_lin_x86-64.tar.gz
else
cd /usr/local/
	wget -c $DLL/ioncube/ioncube_loaders_lin_x86.tar.gz
	tar -zxf ioncube_loaders_lin_x86.tar.gz
	rm -rf ioncube_loaders_lin_x86.tar.gz
fi

echo "Writing ionCube Loader to configure files..."
cat >/usr/local/php/conf.d/000-ioncube.ini<<EOF
[ionCube Loader]
zend_extension="/usr/local/ioncube/ioncube_loader_lin_7.1_ts.so"
EOF

#Install_memcached_Service
cd /tmp
if [ -s memcached-1.5.14 ]; then
	rm -rf memcached-1.5.14/
fi
wget -c $DLL/memcache/memcached-1.5.14.tar.gz
tar -zxf memcached-1.5.14.tar.gz
cd memcached-1.5.14/
./configure --prefix=/usr/local/memcached
make && make install
ln /usr/local/memcached/bin/memcached /usr/bin/memcached

wget -c $DLL/init.d/init.d.memcached && mv init.d.memcached /etc/init.d/memcached
chmod +x /etc/init.d/memcached
useradd -s /sbin/nologin nobody

if command -v systemctl >/dev/null 2>&1; then
	systemctl disable memcached.service
else
	chkconfig --add memcached
	chkconfig memcached off
fi

if [ ! -d /var/lock/subsys ]; then
	mkdir -p /var/lock/subsys
fi

#Install_PHPMemcache
cd /tmp
rm -rf pecl-memcache
git clone https://github.com/websupport-sk/pecl-memcache.git
cd pecl-memcache
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-zlib-dir --enable-memcache
make && make install

#Install_PHPMemcached
cd /tmp
yum install cyrus-sasl-devel -y
if [ -s libmemcached-1.0.18 ]; then
	rm -rf libmemcached-1.0.18/
fi
wget -c $DLL/memcache/libmemcached-1.0.18.tar.gz
tar -zxf libmemcached-1.0.18.tar.gz
cd libmemcached-1.0.18
if gcc -dumpversion|grep -q "^[78]"; then
	wget -c $DLL/memcache/libmemcached-1.0.18-gcc7.patch
	patch -p1 < ${cur_dir}/src/patch/libmemcached-1.0.18-gcc7.patch
fi
./configure --prefix=/usr/local/libmemcached --with-memcached
make && make install && make clean

cd /tmp
if [ -s memcached-3.1.3 ]; then
	rm -rf memcached-3.1.3/
fi
wget -c $DLL/memcache/memcached-3.1.3.tgz
tar -zxf memcached-3.1.3.tgz
cd memcached-3.1.3/
/usr/local/php/bin/phpize
./configure --with-libmemcached-dir=/usr/local/libmemcached --enable-memcached --enable-memcached-sasl --with-php-config=/usr/local/php/bin/php-config --with-zlib-dir
make && make install

cat >/usr/local/php/conf.d/001-memcached.ini<<EOF
extension = memcached.so
EOF

cat >/usr/local/php/conf.d/001-memcache.ini<<EOF
extension = memcache.so
EOF

#Install_Redis
cd /tmp
wget -c $DLL/redis/redis-4.3.0.tgz
tar -zxf redis-4.3.0.tgz
cd redis-4.3.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install

cat >/usr/local/php/conf.d/001-redis.ini<<EOF
extension = "redis.so"
EOF

#Install_Mongodb
cd /tmp
wget -c $DLL/mongodb/mongodb-1.6.0.tgz
tar -zxf mongodb-1.6.0.tgz
cd mongodb-1.6.0
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install

cat >/usr/local/php/conf.d/000-mongodb.ini<<EOF
extension = "mongodb.so"
EOF

#Install_Imagick
cd /tmp
yum install -y epel-release libwebp-devel libtool-ltdl-devel
ldconfig

if [ -s ImageMagick-7.0.8-45 ]; then
	rm -rf ImageMagick-7.0.8-45/
fi
wget -c $DLL/imagemagick/ImageMagick-7.0.8-45.tar.gz
tar xvzf ImageMagick-7.0.8-45.tar.gz
cd ImageMagick-7.0.8-45/
./configure --prefix=/usr/local/imagemagick --with-modules --enable-shared --with-perl
make && make install

cd /tmp
if [ -s imagick-3.4.4 ]; then
	rm -rf imagick-3.4.4/
fi
wget -c $DLL/imagick/imagick-3.4.4.tgz
tar -zxf imagick-3.4.4.tgz
cd imagick-3.4.4
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-imagick=/usr/local/imagemagick
make && make install

cat >/usr/local/php/conf.d/002-imagick.ini<<EOF
[Imagick]
extension = imagick.so
EOF

#Install_Gmagick
cd /tmp
if [ -s GraphicsMagick-1.3.33 ]; then
	rm -rf GraphicsMagick-1.3.33/
fi
wget -c $DLL/graphicsmagick/GraphicsMagick-1.3.33.tar.gz
tar -zxf GraphicsMagick-1.3.33.tar.gz
cd GraphicsMagick-1.3.33
./configure --prefix=/usr/local/graphicsmagick --enable-shared --enable-static --enable-symbol-prefix
make && make install

cat >/etc/profile.d/gmagick.sh<<EOF
export GMAGICK_HOME="/usr/local/graphicsmagick"
export PATH="$GMAGICK_HOME/bin:$PATH"
LD_LIBRARY_PATH=$GMAGICK_HOME/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH
EOF
source /etc/profile.d/gmagick.sh

cd /tmp
if [ -s gmagick-2.0.5RC1 ]; then
	rm -rf gmagick-2.0.5RC1/
fi
wget -c $DLL/gmagick/gmagick-2.0.5RC1.tgz
tar -zxf gmagick-2.0.5RC1.tgz
cd gmagick-2.0.5RC1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-gmagick=/usr/local/graphicsmagick
make && make install

cat >/usr/local/php/conf.d/002-gmagick.ini.bak<<EOF
[Gmagick]
extension = gmagick.so
EOF

#Install_Opcache
cd /tmp
cat >/usr/local/php/conf.d/003-opcache.ini<<EOF
[Zend Opcache]
zend_extension = "opcache.so"
opcache.memory_consumption = 128
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = 4000
opcache.revalidate_freq = 60
opcache.fast_shutdown = 1
opcache.enable_cli = 1
EOF

wget -c $DLL/conf/ocp.php
\cp ./ocp.php /www/wwwroot/localhost/ocp.php

wget -c $DLL/tools/cut_apache_log && mv cut_apache_log /usr/local/apache/bin/cut_apache_log
chmod +x /usr/local/apache/bin/cut_apache_log
echo "0 0 * * * /usr/local/apache/bin/cut_apache_log" >>/var/spool/cron/root

/etc/init.d/httpd restart
echo "============================Apache 2.2.27 install completed========================="
}

function Lnmpa_InstallNginx()
{
echo "============================Install Nginx=================================="
#Install_Nginx
cd /tmp
if [ -s lua-nginx-module-0.10.14.tar.gz ]; then
	echo "lua-nginx-module-0.10.14.tar.gz [found]"
else
	echo "Error: lua-nginx-module-0.10.14.tar.gz not found!!!download now......"
	wget -c $DLL/lua-nginx/lua-nginx-module-0.10.14.tar.gz
fi
rm -rf lua-nginx-module-0.10.14
tar -zxf lua-nginx-module-0.10.14.tar.gz

cd /tmp
if [ -s ngx_devel_kit-0.3.1rc1.tar.gz ]; then
	echo "ngx_devel_kit-0.3.1rc1.tar.gz [found]"
else
echo "Error: ngx_devel_kit-0.3.1rc1.tar.gz not found!!!download now......"
	wget -c $DLL/nginx-module/ngx_devel_kit-0.3.1rc1.tar.gz
fi
rm -rf ngx_devel_kit-0.3.1rc1
tar -zxf ngx_devel_kit-0.3.1rc1.tar.gz

cd /tmp
if [ -s nginx-http-concat-1.2.2.tar.gz ]; then
	echo "nginx-http-concat-1.2.2.tar.gz [found]"
else
echo "Error: nginx-http-concat-1.2.2.tar.gz not found!!!download now......"
	wget -c $DLL/nginx-module/nginx-http-concat-1.2.2.tar.gz
fi
rm -rf nginx-http-concat-1.2.2
tar -zxf nginx-http-concat-1.2.2.tar.gz

cd /tmp
if [ -s nginx-http-footer-filter-1.2.2.tar.gz ]; then
	echo "nginx-http-footer-filter-1.2.2.tar.gz [found]"
else
	echo "Error: nginx-http-footer-filter-1.2.2.tar.gz not found!!!download now......"
	wget -c $DLL/nginx-module/nginx-http-footer-filter-1.2.2.tar.gz
fi
rm -rf nginx-http-footer-filter-1.2.2
tar -zxf nginx-http-footer-filter-1.2.2.tar.gz

cd /tmp
if [ -s ngx_req_status-master.zip ]; then
	echo "ngx_req_status-master.zip [found]"
else
	echo "Error: ngx_req_status-master.zip not found!!!download now......"
	wget -c $DLL/nginx-module/ngx_req_status-master.zip
fi
rm -rf ngx_req_status-master
unzip ngx_req_status-master.zip

cd /tmp
if [ -s nginx-http-sysguard-master.zip ]; then
	echo "nginx-http-sysguard-master.zip [found]"
else
	echo "Error: nginx-http-sysguard-master.zip not found!!!download now......"
	wget -c $DLL/nginx-module/nginx-http-sysguard-master.zip
fi
rm -rf nginx-http-sysguard-master
unzip nginx-http-sysguard-master.zip

cd /tmp
if [ -s nginx_upstream_check_module-master.zip ]; then
	echo "nginx_upstream_check_module-master.zip [found]"
else
	echo "Error: nginx_upstream_check_module-master.zip not found!!!download now......"
	wget -c $DLL/nginx-module/nginx_upstream_check_module-master.zip
fi
rm -rf nginx_upstream_check_module-master
unzip nginx_upstream_check_module-master.zip

cd /tmp
if [ -s openssl-1.1.1c.tar.gz ]; then
	echo "openssl-1.1.1c.tar.gz [found]"
else
	echo "Error: openssl-1.1.1c.tar.gz not found!!!download now......"
	wget -c $DLL/openssl/openssl-1.1.1c.tar.gz
fi
rm -rf openssl-1.1.1c
tar -zxf openssl-1.1.1c.tar.gz

cd /tmp
if [ -s nginx-1.16.1.tar.gz ]; then
	echo "nginx-1.16.1.tar.gz [found]"
else
	echo "Error: nginx-1.16.1.tar.gz not found!!!download now......"
	wget -c $DLL/nginx/nginx-1.16.1.tar.gz
fi
rm -rf nginx-1.16.1
tar -zxf nginx-1.16.1.tar.gz
mv lua-nginx-module-0.10.14  nginx-1.16.1/nginx-lua
mv ngx_devel_kit-0.3.1rc1 nginx-1.16.1/nginx-devel-kit
mv nginx-http-concat-1.2.2 nginx-1.16.1/nginx-http-concat
mv nginx-http-footer-filter-1.2.2 nginx-1.16.1/nginx-http-footer-filter
mv ngx_req_status-master nginx-1.16.1/nginx-req-status
mv nginx-http-sysguard-master nginx-1.16.1/nginx-http-sysguard
mv nginx_upstream_check_module-master nginx-1.16.1/nginx-upstream-check
mv openssl-1.1.1c nginx-1.16.1/openssl

cd nginx-1.16.1
sed -i 's/#define NGINX_VER          "nginx\/" NGINX_VERSION/#define NGINX_VER          "SuperServer\/" NGINX_VERSION/' src/core/nginx.h
sed -i 's/#define NGINX_VERSION      "1.14.2"/#define NGINX_VERSION      "FinallMX"/' src/core/nginx.h
sed -i 's/#define NGINX_VAR          "NGINX"/#define NGINX_VAR          "SuperServer"/' src/core/nginx.h

wget -c $DLL/nginx/write_filter-1.7.11.patch
wget -c $DLL/nginx/nginx_sysguard_1.3.9.patch
patch -p1 < ./write_filter-1.7.11.patch
patch -p1 < ./nginx_sysguard_1.3.9.patch

export LUAJIT_LIB=/usr/local/luajit/lib
export LUAJIT_INC=/usr/local/luajit/include/luajit

./configure --user=www --group=www --prefix=/usr/local/nginx \
--add-module=./nginx-lua \
--add-module=./nginx-req-status \
--add-module=./nginx-devel-kit \
--add-module=./nginx-upstream-check \
--add-module=./nginx-http-concat \
--add-module=./nginx-http-sysguard \
--add-module=./nginx-http-footer-filter \
--with-openssl=./openssl \
--with-openssl-opt='enable-weak-ssl-ciphers' \
--with-ld-opt=-Wl,-rpath,/usr/local/luajit/lib \
--with-http_random_index_module \
--with-google_perftools_module \
--with-http_gzip_static_module \
--with-http_secure_link_module \
--with-http_stub_status_module \
--with-http_addition_module \
--with-http_realip_module \
--with-stream_ssl_module \
--with-http_geoip_module \
--with-http_perl_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_ssl_module \
--with-http_flv_module \
--with-http_v2_module \
--with-mail_ssl_module \
--with-stream \
--with-mail \
--with-pcre
make ; make install
cd ../

ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
mkdir -p /usr/local/nginx/conf/vhosts

cd /tmp
if [ -s ngx_lua_waf-1.0.3.tar.gz ]; then
	echo "ngx_lua_waf-1.0.3.tar.gz [found]"
else
	echo "Error: ngx_lua_waf-1.0.3.tar.gz not found!!!download now......"
	wget -c $DLL/nginx-module/ngx_lua_waf-1.0.3.tar.gz
	tar -zxf ngx_lua_waf-1.0.3.tar.gz
	mv ngx_lua_waf-1.0.3 /usr/local/nginx/conf/waf
	mv /usr/local/nginx/conf/waf/install.sh /usr/local/nginx/conf/waf/install.sh.bak
	mv /usr/local/nginx/conf/waf/config.lua /usr/local/nginx/conf/waf/config.lua.bak
	wget -c $DLL/conf/config.lua && mv config.lua /usr/local/nginx/conf/waf/config.lua
	sed -i 's/\/usr\/local\/nginx\/logs\//\/www\/wwwlogs\/hacklogs\//' /usr/local/nginx/conf/waf/config.lua
	mkdir -p /www/wwwlogs/hacklogs/
fi

wget -c $DLL/conf/nginx-lnmpa.conf && mv nginx-lnmpa.conf /usr/local/nginx/conf/nginx.conf
wget -c $DLL/conf/nginx-lnmpa-proxy.conf && mv nginx-lnmpa-proxy.conf /usr/local/nginx/conf/proxy.conf
wget -c $DLL/conf/nginx-lnmpa-localhost.conf && mv nginx-lnmpa-localhost.conf /usr/local/nginx/conf/vhosts/localhost.conf
wget -c $DLL/conf/nginx-badboy.conf && mv nginx-badboy.conf /usr/local/nginx/conf/vhosts/badboy.conf

mkdir -p /usr/local/nginx/conf/rewrite
wget -c $DLL/conf/rewrite/yii2.conf && mv yii2.conf /usr/local/nginx/conf/rewrite/yii2.conf
wget -c $DLL/conf/rewrite/wp2.conf && mv wp2.conf /usr/local/nginx/conf/rewrite/wp2.conf
wget -c $DLL/conf/rewrite/wordpress.conf && mv wordpress.conf /usr/local/nginx/conf/rewrite/wordpress.conf
wget -c $DLL/conf/rewrite/typecho2.conf && mv typecho2.conf /usr/local/nginx/conf/rewrite/typecho2.conf
wget -c $DLL/conf/rewrite/typecho.conf && mv typecho.conf /usr/local/nginx/conf/rewrite/typecho.conf
wget -c $DLL/conf/rewrite/thinkphp.conf && mv thinkphp.conf /usr/local/nginx/conf/rewrite/thinkphp.conf
wget -c $DLL/conf/rewrite/shopex.conf && mv shopex.conf /usr/local/nginx/conf/rewrite/shopex.conf
wget -c $DLL/conf/rewrite/sablog.conf && mv sablog.conf /usr/local/nginx/conf/rewrite/sablog.conf
wget -c $DLL/conf/rewrite/phpwind.conf && mv phpwind.conf /usr/local/nginx/conf/rewrite/phpwind.conf
wget -c $DLL/conf/rewrite/other.conf && mv other.conf /usr/local/nginx/conf/rewrite/other.conf
wget -c $DLL/conf/rewrite/none.conf && mv none.conf /usr/local/nginx/conf/rewrite/none.conf
wget -c $DLL/conf/rewrite/laravel.conf && mv laravel.conf /usr/local/nginx/conf/rewrite/laravel.conf
wget -c $DLL/conf/rewrite/joomla.conf && mv joomla.conf /usr/local/nginx/conf/rewrite/joomla.conf
wget -c $DLL/conf/rewrite/ecshop.conf && mv ecshop.conf /usr/local/nginx/conf/rewrite/ecshop.conf
wget -c $DLL/conf/rewrite/drupal.conf && mv drupal.conf /usr/local/nginx/conf/rewrite/drupal.conf
wget -c $DLL/conf/rewrite/discuzx2.conf && mv discuzx2.conf /usr/local/nginx/conf/rewrite/discuzx2.conf
wget -c $DLL/conf/rewrite/discuzx.conf && mv discuzx.conf /usr/local/nginx/conf/rewrite/discuzx.conf
wget -c $DLL/conf/rewrite/discuz.conf && mv discuz.conf /usr/local/nginx/conf/rewrite/discuz.conf
wget -c $DLL/conf/rewrite/dedecms.conf && mv dedecms.conf /usr/local/nginx/conf/rewrite/dedecms.conf
wget -c $DLL/conf/rewrite/dabr.conf && mv dabr.conf /usr/local/nginx/conf/rewrite/dabr.conf
wget -c $DLL/conf/rewrite/codeigniter.conf && mv codeigniter.conf /usr/local/nginx/conf/rewrite/codeigniter.conf

wget -c $DLL/init.d/init.d.nginx && mv init.d.nginx /etc/init.d/nginx
chmod +x /etc/init.d/nginx

if command -v systemctl >/dev/null 2>&1; then
	systemctl disable nginx.service
else
	chkconfig --add nginx
	chkconfig nginx off
fi

wget -c $DLL/tools/cut_nginx_log && mv cut_nginx_log /usr/local/nginx/sbin/cut_nginx_log
chmod +x /usr/local/nginx/sbin/cut_nginx_log
echo "0 0 * * * /usr/local/nginx/sbin/cut_nginx_log" >>/var/spool/cron/root

/etc/init.d/nginx restart
/etc/init.d/nginx stop
echo "============================== Check install =============================="
echo "Checking ..."
if [[ -s /usr/local/nginx/conf/nginx.conf && -s /usr/local/nginx/sbin/nginx ]]; then
	echo "Nginx: OK"
else
	echo "Error: Nginx install failed."
fi
echo "============================Nginx install completed========================="
}

function Lnmpa_InstallWeb()
{
echo "============================Install Web=================================="
cd /www/wwwroot/localhost
wget -c $DLL/phpmyadmin/phpMyAdmin-4.7.3-all-languages.zip
unzip phpMyAdmin-4.7.3-all-languages.zip
rm -rf phpMyAdmin-4.7.3-all-languages.zip
mv phpMyAdmin-4.7.3-all-languages phpMyAdmin
cd phpMyAdmin
cp config.sample.inc.php config.inc.php
echo "" >> config.inc.php
echo "/**" >> config.inc.php
echo " * allow login to any user entered server in cookie based authentication" >> config.inc.php
echo " *" >> config.inc.php
echo " * @global boolean \$cfg['AllowArbitraryServer']" >> config.inc.php
echo " */" >> config.inc.php
echo "\$cfg['AllowArbitraryServer'] = true; //默认是false,改成true" >> config.inc.php
echo "" >> config.inc.php
echo "/**" >> config.inc.php
echo " * Whether or not to query the user before sending the error report to" >> config.inc.php
echo " * the phpMyAdmin team when a JavaScript error occurs" >> config.inc.php
echo " *" >> config.inc.php
echo " * Available options" >> config.inc.php
echo " * ('ask' | 'always' | 'never')" >> config.inc.php
echo " * default = 'ask'" >> config.inc.php
echo " */" >> config.inc.php
echo "\$cfg['SendErrorReports'] = 'never'; // 发送错误报告" >> config.inc.php
chown -R www:www /www/wwwroot/localhost/phpMyAdmin
echo "============================Web install completed========================="
}

if [ -s /tmp/.ConfigLnmpa.lock ]; then
echo "This shell script has run! Bye!!"
else
Lnmpa_InstallSoft 2>&1 | tee ConfigLnmpa.log
Lnmpa_InstallMySQL 2>&1 | tee -a ConfigLnmpa.log
Lnmpa_InstallMariaDB 2>&1 | tee -a ConfigLnmpa.log
Lnmpa_InstallApache 2>&1 | tee -a ConfigLnmpa.log
Lnmpa_InstallNginx 2>&1 | tee -a ConfigLnmpa.log
Lnmpa_InstallWeb 2>&1 | tee -a ConfigLnmpa.log
echo > /tmp/.ConfigLnmpa.lock
fi
