from flask import Flask, request, Response, jsonify
from flask_restx import Api, Resource, fields
import psycopg2
import psycopg2.extras

import os
import logging
import json

from datetime import date, datetime
from decimal import Decimal

from dotenv import load_dotenv

app = Flask(__name__)

api = Api(app, version='1.0', title='Dean Office API', description='API for dean office', doc='/swagger/')
namespace = api.namespace('api/v1', description='Dean office operations')

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


app.json_encoder = custom_json_serializer


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
        # return Response(json.dumps(results_list, default=custom_json_serializer, ensure_ascii=False),
        #                 mimetype='application/json', status=200)
        return results_list
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
        return [{'response': return_value}], 201
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


student_model = api.model('Student', {
    'student_fullname': fields.String(description='Full name of the student'),
    'student_card_number': fields.String(description='Card number of the student'),
    'student_phone': fields.String(description='Phone number of the student'),
    'student_email': fields.String(description='Email of the student'),
    'student_birthdate': fields.String(description='Birthdate of the student'),
    'student_gender': fields.String(description='Gender of the student'),
    'student_study_form': fields.String(description='Form of study'),
    'student_accumulated_rating': fields.String(description='Accumulated rating'),
    'study_group_number': fields.String(description='Study group number'),
    'direction_training_name': fields.String(description='Direction of training'),
    'hostel_name': fields.String(description='Name of the hostel'),
    'hostel_address': fields.String(description='Address of the hostel'),
})


@namespace.route('/students', methods=['GET'])
class StudentList(Resource):
    @namespace.doc(params={'user_id': 'User ID'})
    @namespace.marshal_list_with(student_model)
    def get(self):
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
        return get_from_database(request_template)


teacher_model = api.model('Teacher', {
    'teacher_full_name': fields.String(description='Full name of the teacher'),
    'teacher_phone': fields.String(description='Phone number of the teacher'),
    'teacher_qualification': fields.String(description='Qualification of the teacher'),
    'teacher_academic_degree': fields.String(description='Academic degree of the teacher'),
    'teacher_experience': fields.String(description='Experience of the teacher'),
})


@namespace.route('/teachers', methods=['GET'])
class TeacherList(Resource):
    @namespace.doc(params={'user_id': 'User ID'})
    @namespace.marshal_list_with(teacher_model)
    def get(self):
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


discipline_model = api.model('Discipline', {
    'discipline_id': fields.Integer(description='ID of the discipline'),
    'discipline_name': fields.String(description='Name of the discipline'),
    'teacher_full_name': fields.String(description='Full name of the teacher'),
})


@namespace.route('/disciplines', methods=['GET'])
class DisciplineList(Resource):
    @namespace.doc(params={'user_id': 'User ID'})
    @namespace.marshal_list_with(discipline_model)
    def get(self):
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


test_model = api.model('Test', {
    'test_id': fields.Integer(description='ID of the test'),
    'test_number': fields.Integer(description='Number of the test'),
    'test_name': fields.String(description='Name of the test'),
    'test_start': fields.String(description='Start time of the test'),
    'test_end': fields.String(description='End time of the test'),
})


@namespace.route('/tests', methods=['GET'])
class TestList(Resource):
    @namespace.doc(params={'discipline_id': 'Discipline ID'})
    @namespace.marshal_list_with(test_model)
    def get(self):
        discipline_id = request.args.get('discipline_id')
        request_template = f"""
            SELECT 
                test_id,
                test_number,
                test_name,
                test_start,
                test_end
                FROM test
        """
        if discipline_id:
            request_template += f"""
                WHERE discipline_id={discipline_id}
            """
        return get_from_database(request_template)


question_model = api.model('Question', {
    'question_id': fields.Integer(description='ID of the question'),
    'question_text': fields.String(description='Text of the question'),
    'answer_id': fields.Integer(description='ID of the answer'),
    'answer_text': fields.String(description='Text of the answer'),
    'is_correct': fields.Boolean(description='Is the answer correct'),
})


@namespace.route('/questions', methods=['GET'])
class QuestionList(Resource):
    @namespace.doc(params={'test_id': 'Test ID'})
    @namespace.marshal_list_with(question_model)
    def get(self):
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
        """
        if test_id:
            request_template += f"""
                WHERE test_id={test_id}
            """
        return get_from_database(request_template)


attempt_model = api.model('Attempt', {
    'attempt_number': fields.Integer(description='Number of the attempt'),
    'attempt_datetime': fields.String(description='Datetime of the attempt'),
    'attempt_result': fields.String(description='Result of the attempt'),
})


@namespace.route('/attempts', methods=['GET'])
class AttemptList(Resource):
    @namespace.doc(params={'test_id': 'Test ID'})
    @namespace.doc(params={'user_id': 'User ID'})
    @namespace.marshal_list_with(attempt_model)
    def get(self):
        user_id = request.args.get('user_id')
        test_id = request.args.get('test_id')
        request_template = f"""
            SELECT
                attempt_number,
                attempt_datetime,
                attempt_result
            FROM attempt
        """
        if user_id and test_id:
            request_template += f"""                
                JOIN users USING (student_id)
                WHERE test_id={test_id} AND user_id={user_id}
            """
        return get_from_database(request_template)


result_model = api.model('Result', {
    'result_per_question': fields.String(description='Result per question'),
    'answer_id': fields.Integer(description='ID of the answer'),
    'question_id': fields.Integer(description='ID of the question'),
})


@namespace.route('/results', methods=['GET'])
class ResultList(Resource):
    @namespace.doc(params={'attempt_id': 'Attempt ID'})
    @namespace.marshal_list_with(result_model)
    def get(self):
        attempt_id = request.args.get('attempt_id')
        request_template = f"""
            SELECT 
                result_per_question,
                answer_id,
                question_id
            FROM test_result
                JOIN answer USING (answer_id)
        """
        if attempt_id:
            request_template += f"""
                WHERE attempt_id={attempt_id}
            """
        return get_from_database(request_template)


post_results_request_model = api.model('PostResultsRequest', {
    'user_id': fields.Integer(description='User ID', default=11),
    'test_id': fields.Integer(description='Test ID', default=30),
    'attempt_number': fields.Integer(description='Number of the attempt', default=3),
    'attempt_datetime': fields.String(description='Datetime of the attempt', default='2023-03-24 12:26:05'),
    'attempt_result': fields.Integer(description='Result of the attempt', default=50),
    'result_per_answer': fields.Raw(description='Result per answer',
                                    default={"1": "10", "5": "10", "9": "10", "13": "10", "17": "10"})
})

post_results_response_model = api.model('PostResultsResponse', {
    'id': fields.Integer(description='ID of the created resource'),
    'message': fields.String(description='Message indicating the success of resource creation')
})


@namespace.route('/post_results')
class PostResults(Resource):
    @namespace.expect(post_results_request_model, validate=True)
    @namespace.marshal_with(post_results_response_model)
    def post(self):
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
        # data = json.loads(response.data)
        student_id = response[0]["student_id"]

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
            # data = json.loads(response.data)
            # attempt_id = data['response']
            attempt_id = response[0]['response']

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
            # data = json.loads(response.data)
            # test_result_id = data['response']
            test_result_id = response[0]['response']

        # return jsonify({'id': test_result_id, 'message': 'Resource created successfully'}), 201
        return [{'id': test_result_id, 'message': 'Resource created successfully'}], 201


schedule_model = api.model('Schedule', {
    'lesson_start_datetime': fields.String(description='Start datetime of the lesson'),
    'lesson_end_datetime': fields.String(description='End datetime of the lesson'),
    'discipline_name': fields.String(description='Name of the discipline'),
    'room_number': fields.String(description='Number of the room'),
    'campus_name': fields.String(description='Name of the campus'),
    'lesson_type': fields.String(description='Type of the lesson'),
    'teacher_full_name': fields.String(description='Full name of the teacher'),
})


@namespace.route('/teacher_schedule', methods=['GET'])
class TeacherScheduleList(Resource):
    @namespace.doc(params={'user_id': 'User ID'})
    @namespace.marshal_list_with(schedule_model)
    def get(self):
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
            """
        if user_id:
            request_template += f"""
                    JOIN users USING (teacher_id)
                WHERE user_id={user_id}
            """
        return get_from_database(request_template)


@namespace.route('/student_schedule', methods=['GET'])
class StudentScheduleList(Resource):
    @namespace.doc(params={'user_id': 'User ID'})
    @namespace.marshal_list_with(schedule_model)
    def get(self):
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
        """
        if user_id:
            request_template += f"""
                    JOIN users USING (student_id)
                WHERE user_id={user_id}
            """
        return get_from_database(request_template)


if __name__ == '__main__':
    app.run(**flask_params)
