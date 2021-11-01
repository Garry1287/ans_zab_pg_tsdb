#Zabbix plan 2

Сертификаты обновить для нормальной работы
```
apt install sudo vim ca-certificates gnupg gnupg2
```

Без этого не установиться zabbix-sql-scripts
```
vi /etc/dpkg/dpkg.cfg.d/excludes

and comment next:
Code:

# Drop all documentation ...
path-exclude=/usr/share/doc/*
```

Не работал в anisble update_cache: yes без установки
```
apt-get install apt-transport-https
```
[Failed to update apt cache (update_cache) · Issue #30754 · ansible/ansible · GitHub](https://github.com/ansible/ansible/issues/30754)


Установка zabbix repo и пакетов для zabbix.

```
   wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu18.04_all.deb
   
   dpkg -i zabbix-release_5.4-1+ubuntu18.04_all.deb
   apt update 
    apt install zabbix-server-pgsql zabbix-frontend-php php7.2-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent 
```


Установка базы данных
```
echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" | sudo tee  /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
 apt install postgresql-13 postgresql-client-13
```

Установка timescaledb и тюнинг базы данных
 ```
  echo 'deb https://packagecloud.io/timescale/timescaledb/ubuntu/ bionic main'  > /etc/apt/sources.list.d/timescaledb.list

 wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey |  apt-key add -

   apt update
   apt install timescaledb-2-postgresql-13
   timescaledb-tune --quiet --yes
```


Старт базы данных
```
   service postgresql start (systemctl status postgresql@13-main.service)
```



Создание пользователя и базы данных
```
# sudo -u postgres createuser --pwprompt zabbix
# sudo -u postgres createdb -O zabbix zabbix 
```

Импорт схемы и патчинг базы под timescaledb
```
   zcat /usr/share/doc/zabbix-sql-scripts/postgresql/create.sql.gz | sudo -u zabbix psql zabbix
   echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" | sudo -u postgres psql zabbix
   cat /usr/share/doc/zabbix-sql-scripts/postgresql/timescaledb.sql | sudo -u zabbix psql zabbix
```

Пароль от бд для старта базы данных
Отредактируйте файл /etc/zabbix/zabbix_server.conf
DBPassword=password 

Не забыть запустить zabbix-server zabbix-agent
```
# systemctl restart zabbix-server zabbix-agent apache2
# systemctl enable zabbix-server zabbix-agent apache2
```
Настройте веб-интерфейс Zabbix

Откройте установленный веб-интерфейс Zabbix: http://server_ip_or_name/zabbix
Выполните действия по этой инструкции: Установка веб-интерфейса Zabbix



Понимание использования
```
raw отличается от command и shell тем, что не выполняет дополнительную обработку выполнения команды. Эти дополнительные обработки присутствуют в почти любом модуле Ansible. Модуль raw передает команду, как есть в "сыром" виде без проверок.
Модули command и shell отличаются тем, что в модуле command команда выполняется без прохождения через оболочку /bin/sh. Поэтому переменные определенные в оболочке и перенаправления-конвееры работать не будут. Модуль shell выполняет команды через оболочку по умолчанию /bin/sh. Поэтому там будут доступны переменные оболочки и перенаправления. 
```








```
rm -fr /tmp/tosping
/var/lib/zabbix/scripts/tosping_hosts-nlmk.sh &
/var/lib/zabbix/scripts/tosping_hosts-localhost.sh &
```




  Скрипты запуска располагаются в автозагрузке /etc/rc.local, в /etc/hosts прописывает имена хостов 
```
rm -fr /tmp/tosping
/var/lib/zabbix/scripts/tosping_hosts-nlmk.sh &
/var/lib/zabbix/scripts/tosping_hosts-localhost.sh &
```

Скрипт /var/lib/zabbix/scripts/tosping_hosts-nlmk.sh запускает в цикле suptosping.sh с параметрами, разными tos

В /var/lib/zabbix/scripts/_hosts-nlmk - используем имена такие же, как в /etc/hosts
```
_C=300
_TOSs="0 104 184"
_HOSTS=/var/lib/zabbix/scripts/_hosts-nlmk
_TS=$(date +%s)

(suptosping.sh $_HOSTS $_C ${_TOS} $_TS ${outfile} &)
```

Запущенные процессы
```
root      4629  0.0  0.0   6728  3212 ?        S    15:40   0:00 /bin/bash /var/lib/zabbix/scripts/suptosping.sh /var/lib/zabbix/scripts/_hosts-nlmk 300 0 1625490055 outfile_host
root      4631  0.0  0.0   6728  3216 ?        S    15:40   0:00 /bin/bash /var/lib/zabbix/scripts/suptosping.sh /var/lib/zabbix/scripts/_hosts-nlmk 300 104 1625490055 outfile_ho
root      4633  0.0  0.0   6728  3196 ?        S    15:40   0:00 /bin/bash /var/lib/zabbix/scripts/suptosping.sh /var/lib/zabbix/scripts/_hosts-nlmk 300 184 1625490055 outfile_ho
root      4635  0.3  0.0   3928  1464 ?        S    15:40   0:00 fping -qc300 -O0 -f /var/lib/zabbix/scripts/_hosts-nlmk
root      4637  0.3  0.0   3928  1660 ?        S    15:40   0:00 fping -qc300 -O104 -f /var/lib/zabbix/scripts/_hosts-nlmk
root      4638  0.3  0.0   3928  1468 ?        S    15:40   0:00 fping -qc300 -O184 -f /var/lib/zabbix/scripts/_hosts-nlmk
```


Файл suptosping.sh - запускает fping, в файл 
```
_HOSTS=$1
_C=$2
_TOS=$3
_TS=$4
outfile=$5
```
```
fping -qc$_C -O$_TOS -f $_HOSTS >result$(basename ${_HOSTS})_${_TOS} 2>&1

awk '{print $1"/"$5}' result$(basename ${_HOSTS})_${_TOS} | awk -F/ '{print $1,"loss"t,$4}' ts=$_TS t=$_TOS | sed 's/%,*//g' >> $outfile

 -q   Quiet. Don't show per-probe results, but only the final summary. Also don't show ICMP error messages.
 -c n Number of request packets to send to each target.  In this mode, a line is displayed for each received response (this can suppressed with -q
            or -Q).  Also, statistics about responses for each target are displayed when all requests have been sent (or when interrupted).
```

```
-rw-r--r--  1 root root  4105 May 12 12:49 outfile_hosts-nlmk
```




```
/bin/bash /var/lib/zabbix/scripts/suptosping.sh /var/lib/zabbix/scripts/_hosts-nlmk 300 0 157
/bin/bash /var/lib/zabbix/scripts/suptosping.sh /var/lib/zabbix/scripts/_hosts-nlmk 300 104 1
/bin/bash /var/lib/zabbix/scripts/suptosping.sh /var/lib/zabbix/scripts/_hosts-nlmk 300 184 1
```

```
root     22762  1.7  0.0   7976   780 ?        S    11:50   0:05 fping -qc300 -O0 -f /var/lib/zabbix/scripts/_hosts-nlmk
root     22765  1.8  0.0   7976   768 ?        S    11:50   0:05 fping -qc300 -O104 -f /var/lib/zabbix/scripts/_hosts-nlmk
root     22768  1.8  0.0   7976   768 ?        S    11:50   0:05 fping -qc300 -O184 -f /var/lib/zabbix/scripts/_hosts-nlmk
```


```
fping -qc300 -O0 -f /var/lib/zabbix/scripts/_hosts-nlmk

[root@zabbix1 tosping]# fping -qc300 -O104 vchm-kazan
vchm-kazan : xmt/rcv/%loss = 300/0/100%
```


Получаем на сервере через темплейт - IPP_ping
по key определяем к чему значения относятся, названия хостов должны совпадать, как я понимаю, чтобы сработала привязка к правильному хосту.
Рисуются графики.


4 темплейта для мониторинга