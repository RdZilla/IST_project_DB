# Installation Instructions
1. Скачать и установить Docker
2. Скопировать в рабочую папку файл docker-compose.yml и папку postgresql
3. В терминале рабочей папки выполнить команду ```docker-compose up --build```
4. Подключение к БД:
- Веб-интерфейс pgAdmin:  
  Для открытия pgAdmin перейти в браузере по адресу: http://localhost:5050/  
  Параметры для подключения к базе данных из pgAdmin:
  - Name = *любое желаемое*
  - host name = postgres_dean_office
  - port = 5432
  - Maintenan database = postgres
  - Username = postgres
  - Password = s20g;_2-r505t8  
По желанию можно установить флаг ```Save password?```
- Подключение БД в коде:  
  Параметры для подключения к базе данных в коде программы:  
  - DB_HOST=localhost
  - DB_PORT=5433
  - DB_NAME=dean_office
  - DB_USER=postgres
  - DB_PASSWORD=s20g;_2-r505t8
6. Запуск контейнеров:
- Интерфейс программы Docker
- Командная строка:
  - ```docker-compose up``` - включить контейнеры  
  По желанию можно добавить флаг -d для запуска в фоновом режиме: ```docker-compose up -d```
  - ```docker-compose down``` - выключить контейнеры
  - ```docker-compose restart``` - перезапустить контейнеры
