from flask import Flask, request, Response, jsonify
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


def get_from_database(request_template: str) -> Response():
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


def post_to_database(request_template: str):
    connection = psycopg2.connect(**db_params)
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
    try:
        cursor.execute(request_template)
        return_value = cursor.fetchone()[0]
        connection.commit()
        return jsonify({'response': return_value}), 201
    except Exception as error:
        connection.rollback()
        logging.error(f"Ошибка: {error}")
        return jsonify({'error': 'Internal server error', 'details': str(error)}), 500
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
    return get_from_database(request_template)


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
    return get_from_database(request_template)


@app.route('/api/v1/disciplines', methods=['GET'])
def get_disciplines():
    user_id = request.args.get('user_id')
    if user_id is None:
        request_template = f"""
            SELECT 
                discipline_id,
                discipline_name,
                teacher_full_name
            FROM discipline
                JOIN teacher_discipline USING (discipline_id)
                JOIN teacher USING (teacher_id)
        """
        return get_from_database(request_template)
    else:
        request_template = f"""
            SELECT 
                discipline_id,
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
        return get_from_database(request_template)


@app.route('/api/v1/student_disciplines', methods=['GET'])
def get_student_disciplines():
    user_id = request.args.get('user_id')
    request_template = f"""
        SELECT 
            discipline_id,
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
    return get_from_database(request_template)


@app.route('/api/v1/tests', methods=['GET'])
def get_tests():
    discipline_id = request.args.get('discipline_id')
    request_template = f"""
        SELECT 
            test_id,
            test_number,
            test_name,
            test_start,
            test_end
            FROM test
        WHERE discipline_id={discipline_id}
    """
    return get_from_database(request_template)


@app.route('/api/v1/questions', methods=['GET'])
def get_questions():
    test_id = request.args.get('test_id')
    request_template = f"""
        SELECT
            question_id,
            question_text,
            answer_id,
            answer_text,
            is_correct
        FROM question 
            JOIN answer USING (question_id)
        WHERE test_id={test_id}
    """
    return get_from_database(request_template)


@app.route('/api/v1/attempts', methods=['GET'])
def get_attempts():
    test_id = request.args.get('test_id')
    user_id = request.args.get('user_id')
    request_template = f"""
        SELECT
            attempt_number,
            attempt_datetime,
            attempt_result
        FROM attempt
            JOIN users USING (student_id)
        WHERE test_id={test_id} AND user_id={user_id}
    """
    return get_from_database(request_template)


@app.route('/api/v1/results', methods=['GET'])
def get_results():
    attempt_id = request.args.get('attempt_id')
    request_template = f"""
        SELECT 
            result_per_question,
            answer_id,
            question_id
        FROM test_result
            JOIN answer USING (answer_id)
        WHERE attempt_id={attempt_id}
    """
    return get_from_database(request_template)


@app.route('/api/v1/post_results', methods=['POST'])
def post_results():
    data = request.json
    user_id = data.get('user_id')
    test_id = data.get('test_id')
    attempt_number = data.get('attempt_number')
    attempt_datetime = data.get('attempt_datetime')
    attempt_result = data.get('attempt_result')
    result_per_answer = data.get('result_per_answer')

    request_template = f"""
        SELECT student_id 
        FROM users
            JOIN student USING(student_id)
        WHERE user_id={user_id}
    """
    response = get_from_database(request_template)
    data = json.loads(response.data)
    student_id = data[0]["student_id"]

    # INSERT INTO attempt(attempt_number, attempt_datetime, attempt_result, test_id, student_id)
    # VALUES(1, '2023-01-13 13:47:00', 50, 1, 1),
    request_template = f"""
            INSERT INTO attempt (attempt_number, attempt_datetime, attempt_result, test_id, student_id)
            VALUES ({attempt_number}, '{attempt_datetime}', {attempt_result}, {test_id}, {student_id}) 
            RETURNING attempt_id
        """
    response, status = post_to_database(request_template)
    if status == 500:
        return response, 500
    else:
        data = json.loads(response.data)
        attempt_id = data['response']

    # INSERT INTO test_result(result_per_question, answer_id, attempt_id)
    # VALUES(10, 1, 1),
    request_template = ("INSERT INTO test_result (result_per_question, answer_id, attempt_id)"
                        "VALUES ")
    for answer_id, result_per_question in result_per_answer.items():
        request_template += f"""
        ({result_per_question}, {answer_id}, {attempt_id}),"""

    parts = request_template.rsplit(',', maxsplit=1)
    request_template = parts[0] + parts[1] if len(parts) > 1 else request_template

    request_template += " RETURNING test_result_id"

    response, status = post_to_database(request_template)
    if status == 500:
        return response, 500
    else:
        data = json.loads(response.data)
        test_result_id = data['response']

    return jsonify({'id': test_result_id, 'message': 'Resource created successfully'}), 201


@app.route('/api/v1/teacher_schedule', methods=['GET'])
def get_teacher_schedule():
    user_id = request.args.get('user_id')
    request_template = f"""
        SELECT
            lesson_start_datetime,
            lesson_end_datetime,
            discipline_name,
            room_number,
            campus_name,
            lesson_type,
            teacher_full_name  
        FROM schedule
            JOIN teacher USING (teacher_id)
            JOIN discipline USING (discipline_id)
            JOIN study_group USING (study_group_id)
            JOIN room USING (room_id)
            JOIN campus USING (campus_id)
            JOIN users USING (teacher_id)
        WHERE user_id={user_id}
    """
    return get_from_database(request_template)


@app.route('/api/v1/student_schedule', methods=['GET'])
def get_student_schedule():
    user_id = request.args.get('user_id')
    request_template = f"""
        SELECT
            lesson_start_datetime,
            lesson_end_datetime,
            discipline_name,
            room_number,
            campus_name,
            lesson_type,
            teacher_full_name          
        FROM schedule
            JOIN teacher USING (teacher_id)
            JOIN discipline USING (discipline_id)
            JOIN study_group USING (study_group_id)
            JOIN room USING (room_id)
            JOIN campus USING (campus_id)
            JOIN student USING (study_group_id)
            JOIN users USING (student_id)
        WHERE user_id={user_id}
    """
    return get_from_database(request_template)


if __name__ == '__main__':
    app.run(**flask_params)
