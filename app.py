from flask import Flask, request, Response
import psycopg2
import psycopg2.extras

import os
import logging
import json

from datetime import date, datetime
from decimal import Decimal

from dotenv import load_dotenv

app = Flask(__name__)

logging.basicConfig(
    filename='logs/app.log',
    filemode='a',
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.ERROR
)

load_dotenv()

db_params = {
    "host": os.getenv("DB_HOST"),
    "database": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD"),
    "port": os.getenv("DB_PORT")
}

flask_params = {
    "host": os.getenv("FLASK_HOST"),
    "port": os.getenv("FLASK_PORT"),
    "debug": os.getenv("FLASK_DEBUG"),
}


def custom_json_serializer(obj):
    """Custom JSON serializer for objects not serializable by default JSON code"""
    if isinstance(obj, (datetime, date)):
        return obj.isoformat()
    elif isinstance(obj, Decimal):
        return float(obj)
    raise TypeError(f"Type {type(obj)} not serializable")


def connection_to_database(request_template: str) -> Response():
    connection = psycopg2.connect(**db_params)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    try:
        cursor.execute(request_template)
        results = cursor.fetchall()
        results_list = [dict(result) for result in results]
        if results_list is None:
            return Response(json.dumps({"error": "Результат отсутствует"}, ensure_ascii=False),
                            mimetype='application/json', status=404)
        return Response(json.dumps(results_list, default=custom_json_serializer, ensure_ascii=False),
                        mimetype='application/json', status=200)
    except Exception as error:
        logging.error(f"Ошибка: {error}")
        return Response(json.dumps({"error": "Произошла ошибка при получении данных"}, ensure_ascii=False),
                        mimetype='application/json', status=500)
    finally:
        try:
            if connection:
                cursor.close()
                connection.close()
        except Exception as ex:
            logging.error("Ошибка при работе с PostgreSQL: %s", ex)


@app.route('/api/v1/students', methods=['GET'])
def get_students():
    user_id = request.args.get('user_id')
    request_template = f"""
    SELECT 
        student_fullname, 
        student_card_number, 
        student_phone, 
        student_email, 
        student_birthdate, 
        student_gender,
        student_study_form,
        student_accumulated_rating,
        study_group_number,
        direction_training_name,
        hostel_name,
        hostel_address
    FROM student 
        JOIN study_group USING (study_group_id)
        JOIN direction_training USING (direction_training_id)
        JOIN hostel USING (hostel_id)
    """
    if user_id:
        request_template += f"""
            JOIN users USING (student_id)
        WHERE user_id={user_id}
        """
        # request_template += f"WHERE user_id = {user_id}"
    return connection_to_database(request_template)


@app.route('/api/v1/teachers', methods=['GET'])
def get_teachers():
    user_id = request.args.get('user_id')
    request_template = f"""
    SELECT 
        teacher_full_name,
        teacher_phone,
        teacher_qualification,
        teacher_academic_degree,
        teacher_experience	
    FROM
        teacher
    """
    if user_id:
        request_template += f"""	
            JOIN users USING (teacher_id)
        WHERE user_id={user_id}
        """
    return connection_to_database(request_template)


@app.route('/api/v1/disciplines', methods=['GET'])
def get_disciplines():
    user_id = request.args.get('user_id')
    request_template = f"""
    SELECT 
        discipline_name,
        teacher_full_name
    FROM discipline
        JOIN teacher_discipline USING (discipline_id)
        JOIN teacher USING (teacher_id)
        JOIN users USING (teacher_id)
    WHERE discipline_name IN (SELECT 
        discipline_name
    FROM discipline
        JOIN teacher_discipline USING (discipline_id)
        JOIN teacher USING (teacher_id)
        JOIN users USING (teacher_id)
    WHERE user_id={user_id})
    """

    return connection_to_database(request_template)


if __name__ == '__main__':
    app.run(**flask_params)
