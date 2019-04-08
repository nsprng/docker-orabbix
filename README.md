# docker-orabbix

## Description
Dockerized version of [Orabbix](http://www.smartmarmot.com/product/orabbix/)

## Getting started
### Build docker image:
```bash
docker build -t user/orabbix:latest
```
### Copy conf/ folder on host system and modify config.props:
```
ZabbixServerList=ZabbixServer1

ZabbixServer1.Address=myzabbix.com
ZabbixServer1.Port=10051

OrabbixDaemon.PidFile=./logs/orabbix.pid
OrabbixDaemon.Sleep=300
OrabbixDaemon.MaxThreadNumber=100

DatabaseList=mydatabase
DatabaseList.MaxActive=10
DatabaseList.MaxWait=100
DatabaseList.MaxIdle=1

mydatabase.Url=jdbc:oracle:thin:@mydatabase.com:1521:MY_DB_SID
mydatabase.User=zabbix
mydatabase.Password=NotSecurePassword
mydatabase.QueryListFile=./conf/mydatabase.props
```
### Create file conf/mydatabase.props with necessary SQL statements:
```sql
DefaultQueryPeriod=1

QueryList=all_proc, free_shared_pool, session_active, session_inactive, session_system, \
	summ_pga, redo_active, redo_current, free_fast_recovery_area, buffer_cache_hit, free_proc

all_proc.Query=select count(*) from v$process

free_proc.Query=select (select value from v$parameter where name ='processes') - (select count(*) from v$process) from dual

free_shared_pool.Query=select bytes  from v$sgastat where name = 'free memory' and pool='shared pool'

session_active.Query=select count(*) from v$session where status='ACTIVE'

session_inactive.Query=select count(*) from v$session where status='INACTIVE'

session_system.Query=select SUM(Decode(Type, 'BACKGROUND', 1, 0)) system_sessions FROM V$SESSION

summ_pga.Query=SELECT ROUND(SUM(pga_alloc_mem)) FROM v$process

redo_active.Query=select count(*) from v$log where status='ACTIVE'

redo_current.Query=select "GROUP#" from v$log where status='CURRENT'

free_fast_recovery_area.Query=select SPACE_LIMIT-SPACE_USED from V$recovery_File_Dest

buffer_cache_hit.Query=select 1-physical_reads/(db_block_gets+consistent_gets) from v$buffer_pool_statistics
```
### Create database user:
```sql
CREATE USER ZABBIX
IDENTIFIED BY NotSecurePassword
DEFAULT TABLESPACE SYSTEM
TEMPORARY TABLESPACE TEMP
PROFILE DEFAULT
ACCOUNT UNLOCK;
GRANT CONNECT TO ZABBIX;
GRANT RESOURCE TO ZABBIX;
ALTER USER ZABBIX DEFAULT ROLE ALL;
GRANT SELECT ANY TABLE TO ZABBIX;
GRANT CREATE SESSION TO ZABBIX;
GRANT SELECT ANY DICTIONARY TO ZABBIX;
GRANT UNLIMITED TABLESPACE TO ZABBIX;
GRANT SELECT ANY DICTIONARY TO ZABBIX;
```
### Start container:
```bash
docker run -dit --name orabbix -v /home/user/conf:/opt/orabbix/conf user/orabbix:latest
```
