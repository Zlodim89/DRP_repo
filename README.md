Readme for DRP project.
Codname "Fast-restore"

При необходимости провести оперативное восстановление последовательность действий следующая:

1) Подготовить 4 VM с установленной Ubunty 24.04.01 LTS (!полноценая установка без GUI, не !minimal!!)в качестве ОС
   
2) Задать IP статически (или назначить через DHCP путем привязки ip-mac) следующие адреса
   pr-nginx = 192.168.1.240
   pr-backend-1 = 192.168.1.241
   pr-backend-2 = 192.168.1.242
   pr-prometheus = 192.168.1.243

3) Перед началом восстановления конфигураций  на каждом сервере склонировать репозиторий GIT в домашнюю папку пользователя toor
   git clone https://github.com/Zlodim89/DRP_repo.git
   
4) Установить пакеты (если не был взят заранее подготовленный VHD с предустановленной системой и пакетами)
   На pr-nginx = apt install -y nginx prometheus-node-exporter
   На pr-backend-1 = apt install -y  nginx php-fpm php-mysql php-curl php-gd php-xml php-mbstring unzip wget prometheus-node-exporter + скрипт mysql/install_mysql.sh
   На pr-backend-2 = apt install -y  nginx php-fpm php-mysql php-curl php-gd php-xml php-mbstring unzip wget prometheus-node-exporter + скрипт mysql/install_mysql.sh 
   На pr-prometheus = 
   
5) Приступаем к восстановлению конфигурации
   1. На pr-nginx запустить configure_nginx.sh
   2. На pr-backend-1 запустить install_wp_master.sh (если wordpress не установлен) или restore_master_from_backup.sh (если установлен и у нас есть дамп который положили в /home/toor/)
   3. На pr-backend-2 запустить setup_slave_wp.sh
