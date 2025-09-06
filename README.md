Readme for DRP project.
Codname "Fast-restore"

При необходимости провести оперативное восстановление последовательность действий следующая:

1) Подготовить 4 VM с установленной Ubuntu 24.04.01 LTS (!полноценая установка без GUI, не !minimal!!)в качестве ОС
   
2) Задать IP статически (или назначить через DHCP путем привязки ip-mac) следующие адреса
   pr-nginx = 192.168.1.240
   pr-backend-1 = 192.168.1.241
   pr-backend-2 = 192.168.1.242
   pr-prometheus = 192.168.1.243

3) Перед началом восстановления конфигураций  на каждом сервере склонировать репозиторий GIT в домашнюю папку пользователя toor
   git clone https://github.com/Zlodim89/DRP_repo.git

4) Последовательность действий по воостановлению:
   1. На серверве Pr-Nginx выполнить скрипт install_nginx.sh - настройка web-server with load balancing
   2. На серверве Pr-Nginx  выполнить скрипт install_filebeat.sh - настройка экспорта логов
      
   3. На сервере Pr-backend-1 Выпольнить install_mysql_main.sh - для настройки основго сервера + мастера репликации
   4. На сервере Pr-backend-1 Выпольнить  install_wp.sh - установка cms
   5. На сервере Pr-backend-1  Выпольнить install_nodexp.sh - для эскпорта логов системы
   6. На сервере Pr-backend-1 Выпольнить setup_repl.sh - для настройки репликации
   7.  На сервере Pr-backend-1 Выпольнить mysqldump -uroot -p --all-databases --single-transaction --master-data=2 > dump.sql и скопировать в /home/toor на втором сервере полученный dump.sql 


   8. На сервере Pr-backend-2 Выпольнить install_mysql_slave.sh
   9. На сервере Pr-backend-2  Выпольнить apt-get instll apache2 - для настройкм веб сервера (default page)
   10. На сервере Pr-backend-2 Выпольнить mysql -uroot -p < /root/dump.sql для загруки дампа
   11. На сервере Pr-backend-2 Выпольнить setup_repl_slave.sh для настройки репликации
   12. На сервере Pr-backend-2  Выпольнить setup_cron_mysql - настройка расписания резервного копирования
   13. На сервере Pr-backend-2  Выпольнить  mysql_backup.sh - для ручного бэкапа баз данных потаблично
   
   14. На сервере Pr-prometeheus Выпольнить install_log_tools.sh - подготовка к получению данны с filebeat Pr-Nginx    
   15. На сервере Pr-prometeheus Выпольнить setup_log_tools.sh- подготовка к получению данных с filebeat на Pr-Nginx
   16. На сервере Pr-prometeheus Выпольнить install_mon_tools.sh- подготовка к получению данны с node expoeter на Pr-backend-1
   17. На сервере Pr-prometeheus Выпольнить setup_mon_tools.sh - подготовка к получению данны с node expoeter на Pr-backend-1
   18. Перейти на http://192.168.1.243:3000 - и выполнить настройку дашборда Grafana импортировав готоый тип 1860
   19. http://192.168.1.243:5601/ - и выполнить настроку визуализации логов в Kibana


