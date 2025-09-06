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

4) Последовательность действий по воостановлению:
   1. На серверве Pr-Nginx выполнить скрипт install_nginx.sh - настройка web-server with load balancing
   2. На серверве Pr-Nginx  выполнить скрипт install_filebeat.sh - настройка эскорта логов
   3. На сервере Pr-backend-2 Выпольнить install_mysql_slave.sh
   4. На сервере Pr-backend-2  Выпольнить apt-get instll apache2 - для настройкм веб сервера (default page)
   5. На сервере Pr-backend-1 Выпольнить install_mysql_main.sh - для настройки основго сервера + мастера репликации
   9. На сервере Pr-backend-1 Выпольнить  install_wp.sh - установка cms
   10. На сервере Pr-backend-1  Выпольнить install_nodexp.sh - для эскпорта логов системы
   11. На сервере Pr-prometeheus Выпольнить setup_log_tools.sh - подготовка к получению данны с node expoeter на Pr-backend-1 и 2
   12. На сервере Pr-prometeheus Выпольнить install_mon_tools.sh- подготовка к получению данны с filebeat на Pr-Nginx
   13. На сервере Pr-prometeheus Выпольнить setup_log_tools.sh- подготовка к получению данны с filebeat на Pr-Nginx
   14. На сервере Pr-backend-2  Выпольнить setup_cron_mysql - настройка расписания резервного копирования
       
