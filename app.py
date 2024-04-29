# EXAMPLE FILE FOR CHECK CONNECTION
# EXAMPLE FILE FOR CHECK CONNECTION
# EXAMPLE FILE FOR CHECK CONNECTION

import psycopg2
from dotenv import load_dotenv
import os

# Загрузка переменных окружения из файла .env
load_dotenv()

# Получение параметров подключения к базе данных из переменных окружения
db_params = {
    "host": os.getenv("DB_HOST"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "port": os.getenv("DB_PORT")
}

try:
    # Подключение к базе данных
    connection = psycopg2.connect(**db_params)

    # Создание курсора для выполнения SQL-запросов
    cursor = connection.cursor()

    # Выполнение SQL-запроса для выборки данных из таблицы student
    cursor.execute("SELECT * FROM student")

    # Получение результатов запроса
    students = cursor.fetchall()

    # Вывод результатов
    print("Список студентов:")
    for student in students:
        print(student)

except (Exception, psycopg2.Error) as error:
    print("Ошибка при работе с PostgreSQL:", error)

finally:
    try:
        # Закрытие курсора и соединения
        if connection:
            cursor.close()
            connection.close()
            print("Соединение с PostgreSQL закрыто")
    except Exception as ex:
        print("Error:", ex)
