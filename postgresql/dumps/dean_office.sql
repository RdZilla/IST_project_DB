CREATE DATABASE dean_office;

-- Переключение на базу данных dean_office
\c dean_office;

DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS hostel CASCADE;
DROP TABLE IF EXISTS study_group CASCADE;
DROP TABLE IF EXISTS direction_training CASCADE;
DROP TABLE IF EXISTS institute CASCADE;
DROP TABLE IF EXISTS study_plan CASCADE;
DROP TABLE IF EXISTS discipline CASCADE;
DROP TABLE IF EXISTS study_plan_discipline CASCADE;
DROP TABLE IF EXISTS schedule CASCADE;
DROP TABLE IF EXISTS room CASCADE;
DROP TABLE IF EXISTS campus CASCADE;
DROP TABLE IF EXISTS teacher CASCADE;
DROP TABLE IF EXISTS teacher_discipline CASCADE;
DROP TABLE IF EXISTS exam_sheet CASCADE;
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS rfid_tag CASCADE;

DROP TABLE IF EXISTS test CASCADE;
DROP TABLE IF EXISTS question CASCADE;
DROP TABLE IF EXISTS answer CASCADE;
DROP TABLE IF EXISTS attempt CASCADE;
DROP TABLE IF EXISTS test_result CASCADE;

CREATE TABLE student
(
    student_id                 BIGSERIAL PRIMARY KEY,

    student_fullname           VARCHAR(200),
    student_birthdate          DATE,
    student_gender             varchar(7),
    student_email              TEXT,
    student_phone              VARCHAR(11),
    student_address            TEXT,
    student_passport           varchar(11),
    student_snils              varchar(14),
    student_card_number        INT,
    student_study_form         VARCHAR(12),
    student_accumulated_rating DECIMAL(4, 2),

    hostel_id                  SMALLSERIAL,
    study_group_id             SMALLSERIAL
);

CREATE TABLE hostel
(
    hostel_id                  SMALLSERIAL PRIMARY KEY,

    hostel_name                varchar(50),
    hostel_address             text,
    hostel_number_place        int,
    hostel_phone               varchar(11),
    hostel_email               text,
    hostel_commandant_fullname varchar(200)
);

CREATE TABLE study_group
(
    study_group_id        SMALLSERIAL PRIMARY KEY,

    study_group_number    VARCHAR(9),
    study_group_course    SMALLINT,

    direction_training_id SMALLSERIAL
);

CREATE TABLE direction_training
(
    direction_training_id              SMALLSERIAL PRIMARY KEY,

    direction_training_code            VARCHAR(8),
    direction_training_name            VARCHAR(100),
    direction_training_education_level VARCHAR(12),
    direction_training_description     TEXT,

    institute_id                       SMALLSERIAL,
    study_plan_id                      BIGSERIAL
);

CREATE TABLE institute
(
    institute_id       SMALLSERIAL PRIMARY KEY,

    institute_name     VARCHAR(60),
    institute_address  TEXT,
    director_full_name VARCHAR(200),
    director_phone     VARCHAR(11),
    director_email     TEXT
);

CREATE TABLE study_plan
(
    study_plan_id     SERIAL PRIMARY KEY,

    study_plan_number VARCHAR(20),
    study_plan_year   SMALLINT
);

CREATE TABLE discipline
(
    discipline_id          SMALLSERIAL PRIMARY KEY,

    discipline_name        VARCHAR(80),
    discipline_description TEXT,
    discipline_hours       SMALLINT
);

CREATE TABLE study_plan_discipline
(
    study_plan_discipline_id BIGSERIAL PRIMARY KEY,

    study_plan_id            SMALLSERIAL,
    discipline_id            SMALLSERIAL
);

CREATE TABLE schedule
(
    schedule_id           BIGSERIAL,
    lesson_start_datetime TIMESTAMP,
    PRIMARY KEY (schedule_id, lesson_start_datetime),

    lesson_type           VARCHAR(30),
    lesson_end_datetime   TIMESTAMP,

    teacher_id            SERIAL,
    room_id               SMALLSERIAL,
    discipline_id         SMALLSERIAL,
    study_group_id        SMALLSERIAL
);

CREATE TABLE room
(
    room_id     SMALLSERIAL PRIMARY KEY,

    room_number SMALLINT,
    room_type   VARCHAR(20),

    campus_id   SMALLSERIAL
);

CREATE TABLE campus
(
    campus_id      SMALLSERIAL PRIMARY KEY,

    campus_name    VARCHAR(50),
    campus_number  SMALLINT,
    campus_address TEXT
);

CREATE TABLE teacher
(
    teacher_id              SERIAL PRIMARY KEY,

    teacher_full_name       VARCHAR(200),
    teacher_phone           VARCHAR(11),
    teacher_qualification   VARCHAR(50),
    teacher_academic_degree VARCHAR(50),
    teacher_experience      INT
);

CREATE TABLE teacher_discipline
(
    teacher_discipline_id SERIAL PRIMARY KEY,

    teacher_id            SERIAL,
    discipline_id         SMALLSERIAL
);

CREATE TABLE exam_sheet
(
    exam_sheet_id     SMALLSERIAL PRIMARY KEY,

    exam_sheet_number VARCHAR(10),
    mark              SMALLINT,
    date_exam         date,
    semester          SMALLINT,

    student_id        BIGSERIAL,
    teacher_id        SERIAL,
    discipline_id     SMALLSERIAL
);

CREATE TABLE attendance
(
    attendance_id       BIGSERIAL PRIMARY KEY,

    attendance_bool     BOOLEAN,
    attendance_datetime timestamptz,

    student_id          BIGSERIAL,
    discipline_id       smallserial
);

create table users
(
    user_id       BIGSERIAL PRIMARY KEY,

    user_login    varchar(50),
    user_password text,
    user_status   int,

    teacher_id    SERIAL,
    student_id    BIGSERIAL
);

CREATE TABLE rfid_tag
(
    rfid_id    BIGSERIAL PRIMARY KEY,

    teacher_id SERIAL,
    student_id BIGSERIAL
);



CREATE TABLE test
(
    test_id       SERIAL PRIMARY KEY,

    test_number   SMALLINT,
    test_name     VARCHAR(200),

    discipline_id SMALLSERIAL
);

CREATE TABLE question
(
    question_id   BIGSERIAL PRIMARY KEY,

    question_text TEXT,

    test_id       SERIAL
);

CREATE TABLE answer
(
    answer_id   BIGSERIAL PRIMARY KEY,

    answer_text TEXT,
    is_correct  BOOLEAN,

    question_id BIGSERIAL

);

CREATE TABLE attempt
(
    attempt_id       BIGSERIAL PRIMARY KEY,

    attempt_number   BIGINT,
    attempt_datetime timestamp,
    attempt_result   SMALLINT,

    test_id          SERIAL,
    student_id       BIGSERIAL
);

CREATE TABLE test_result
(
    test_result_id      BIGSERIAL PRIMARY KEY,

    result_per_question SMALLINT,

    answer_id           BIGSERIAL,
    attempt_id          BIGSERIAL
);



ALTER TABLE student
    ADD CONSTRAINT fk_study_group_id
        FOREIGN KEY (study_group_id)
            REFERENCES study_group (study_group_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_hostel_id
        FOREIGN KEY (hostel_id)
            REFERENCES hostel (hostel_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE study_group
    ADD CONSTRAINT fk_direction_training_id
        FOREIGN KEY (direction_training_id)
            REFERENCES direction_training (direction_training_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE direction_training
    ADD CONSTRAINT fk_institute_id
        FOREIGN KEY (institute_id)
            REFERENCES institute (institute_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_study_plan_id
        FOREIGN KEY (study_plan_id)
            REFERENCES study_plan (study_plan_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE study_plan_discipline
    ADD CONSTRAINT fk_study_plan_id
        FOREIGN KEY (study_plan_id)
            REFERENCES study_plan (study_plan_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_discipline_id
        FOREIGN KEY (discipline_id)
            REFERENCES discipline (discipline_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE schedule
    ADD CONSTRAINT fk_teacher_id
        FOREIGN KEY (teacher_id)
            REFERENCES teacher (teacher_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_room_id
        FOREIGN KEY (room_id)
            REFERENCES room (room_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_discipline_id
        FOREIGN KEY (discipline_id)
            REFERENCES discipline (discipline_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_study_group_id
        FOREIGN KEY (study_group_id)
            REFERENCES study_group (study_group_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE room
    ADD CONSTRAINT fk_campus_id
        FOREIGN KEY (campus_id)
            REFERENCES campus (campus_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE teacher_discipline
    ADD CONSTRAINT fk_teacher_id
        FOREIGN KEY (teacher_id)
            REFERENCES teacher (teacher_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_discipline_id
        FOREIGN KEY (discipline_id)
            REFERENCES discipline (discipline_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE exam_sheet
    ADD CONSTRAINT fk_student_id
        FOREIGN KEY (student_id)
            REFERENCES student (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_teacher_id
        FOREIGN KEY (teacher_id)
            REFERENCES teacher (teacher_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_discipline_id
        FOREIGN KEY (discipline_id)
            REFERENCES discipline (discipline_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE attendance
    ADD CONSTRAINT fk_student_id
        FOREIGN KEY (student_id)
            REFERENCES student (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_discipline_id
        FOREIGN KEY (discipline_id)
            REFERENCES discipline (discipline_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE users
    ADD CONSTRAINT fk_teacher_id
        FOREIGN KEY (teacher_id)
            REFERENCES teacher (teacher_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_student_id
        FOREIGN KEY (student_id)
            REFERENCES student (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE rfid_tag
    ADD CONSTRAINT fk_teacher_id
        FOREIGN KEY (teacher_id)
            REFERENCES teacher (teacher_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_student_id
        FOREIGN KEY (student_id)
            REFERENCES student (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE teacher_discipline
    ALTER COLUMN teacher_id DROP NOT NULL,
    ALTER COLUMN discipline_id DROP NOT NULL;

ALTER TABLE users
    ALTER COLUMN teacher_id DROP NOT NULL,
    ALTER COLUMN student_id DROP NOT NULL;



ALTER TABLE test
    ADD CONSTRAINT fk_discipline_id
        FOREIGN KEY (discipline_id)
            REFERENCES discipline (discipline_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE question
    ADD CONSTRAINT fk_test_id
        FOREIGN KEY (test_id)
            REFERENCES test (test_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE answer
    ADD CONSTRAINT fk_question_id
        FOREIGN KEY (question_id)
            REFERENCES question (question_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE test_result
    ADD CONSTRAINT fk_answer_id
        FOREIGN KEY (answer_id)
            REFERENCES answer (answer_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_attempt_id
        FOREIGN KEY (attempt_id)
            REFERENCES attempt (attempt_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;

ALTER TABLE attempt
    ADD CONSTRAINT fk_student_id
        FOREIGN KEY (student_id)
            REFERENCES student (student_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
    ADD CONSTRAINT fk_test_id
        FOREIGN KEY (test_id)
            REFERENCES test (test_id)
            ON DELETE CASCADE
            ON UPDATE CASCADE;



INSERT INTO institute (institute_name, institute_address, director_full_name, director_phone, director_email)
VALUES ('Institute of Mathematics', '123 Main Street, Cityville', 'John Doe', '1234567890', 'john.doe@example.com'),
       ('Institute of Physics', '456 Oak Avenue, Townsville', 'Jane Smith', '0987654321', 'jane.smith@example.com'),
       ('Institute of Literature', '789 Elm Road, Villagetown', 'Michael Johnson', '9876543210',
        'michael.johnson@example.com'),
       ('Institute of History', '321 Pine Lane, Hamletville', 'Emily Williams', '0123456789',
        'emily.williams@example.com'),
       ('Institute of Chemistry', '654 Birch Street, Countryside', 'David Brown', '1357924680',
        'david.brown@example.com'),
       ('Institute of Biology', '987 Maple Drive, Suburbia', 'Jessica Taylor', '2468013579',
        'jessica.taylor@example.com'),
       ('Institute of Computer Science', '159 Cedar Court, Metropolis', 'Christopher Martinez', '5678901234',
        'christopher.martinez@example.com'),
       ('Institute of Engineering', '753 Walnut Circle, Megalopolis', 'Amanda Anderson', '6789012345',
        'amanda.anderson@example.com'),
       ('Institute of Medicine', '852 Pineapple Street, Capital City', 'Daniel Garcia', '8901234567',
        'daniel.garcia@example.com'),
       ('Institute of Economics', '426 Cherry Avenue, Downtown', 'Samantha Wilson', '9012345678',
        'samantha.wilson@example.com');

INSERT INTO campus (campus_name, campus_number, campus_address)
VALUES ('Main Campus', 1, '123 University Avenue'),
       ('South Campus', 2, '456 College Road'),
       ('North Campus', 3, '789 Academic Street'),
       ('West Campus', 4, '321 Learning Lane'),
       ('East Campus', 5, '654 Education Boulevard'),
       ('Downtown Campus', 6, '987 Study Square'),
       ('Central Campus', 7, '159 Knowledge Court'),
       ('Campus A', 8, '753 Wisdom Way'),
       ('Campus B', 9, '852 Intellect Lane'),
       ('Campus C', 10, '426 Science Street');

INSERT INTO room (room_number, room_type, campus_id)
VALUES (101, 'Lecture Room', 1),
       (102, 'Lecture Room', 1),
       (103, 'Lecture Room', 1),
       (104, 'Lecture Room', 1),
       (105, 'Lecture Room', 1),
       (106, 'Lecture Room', 1),
       (107, 'Seminar Room', 1),
       (108, 'Seminar Room', 1),
       (109, 'Seminar Room', 1),
       (110, 'Seminar Room', 1),
       (111, 'Seminar Room', 1),
       (112, 'Seminar Room', 1),
       (113, 'Lab Room', 1),
       (114, 'Lab Room', 1),
       (115, 'Lab Room', 1),
       (116, 'Lab Room', 1),
       (117, 'Lab Room', 1),
       (118, 'Lab Room', 1),
       (119, 'Office Room', 1),
       (120, 'Office Room', 1),
       (121, 'Office Room', 1),
       (122, 'Office Room', 1),
       (123, 'Office Room', 1),
       (124, 'Office Room', 1),
       (125, 'Service Room', 1),
       (126, 'Service Room', 1),
       (127, 'Service Room', 1),
       (128, 'Service Room', 1),
       (129, 'Service Room', 1),
       (130, 'Service Room', 1),
       (201, 'Lecture Room', 1),
       (202, 'Lecture Room', 1),
       (203, 'Lecture Room', 1),
       (204, 'Lecture Room', 1),
       (205, 'Lecture Room', 1),
       (206, 'Lecture Room', 1),
       (207, 'Seminar Room', 1),
       (208, 'Seminar Room', 1),
       (209, 'Seminar Room', 1),
       (210, 'Seminar Room', 1),
       (211, 'Seminar Room', 1),
       (212, 'Seminar Room', 1),
       (213, 'Lab Room', 1),
       (214, 'Lab Room', 1),
       (215, 'Lab Room', 1),
       (216, 'Lab Room', 1),
       (217, 'Lab Room', 1),
       (218, 'Lab Room', 1),
       (219, 'Office Room', 1),
       (220, 'Office Room', 1),
       (221, 'Office Room', 1),
       (222, 'Office Room', 1),
       (223, 'Office Room', 1),
       (224, 'Office Room', 1),
       (225, 'Service Room', 1),
       (226, 'Service Room', 1),
       (227, 'Service Room', 1),
       (228, 'Service Room', 1),
       (229, 'Service Room', 1),
       (230, 'Service Room', 1),
       (301, 'Lecture Room', 1),
       (302, 'Lecture Room', 1),
       (303, 'Lecture Room', 1),
       (304, 'Lecture Room', 1),
       (305, 'Lecture Room', 1),
       (306, 'Lecture Room', 1),
       (307, 'Seminar Room', 1),
       (308, 'Seminar Room', 1),
       (309, 'Seminar Room', 1),
       (310, 'Seminar Room', 1),
       (311, 'Seminar Room', 1),
       (312, 'Seminar Room', 1),
       (313, 'Lab Room', 1),
       (314, 'Lab Room', 1),
       (315, 'Lab Room', 1),
       (316, 'Lab Room', 1),
       (317, 'Lab Room', 1),
       (318, 'Lab Room', 1),
       (319, 'Office Room', 1),
       (320, 'Office Room', 1),
       (321, 'Office Room', 1),
       (322, 'Office Room', 1),
       (323, 'Office Room', 1),
       (324, 'Office Room', 1),
       (325, 'Service Room', 1),
       (326, 'Service Room', 1),
       (327, 'Service Room', 1),
       (328, 'Service Room', 1),
       (329, 'Service Room', 1),
       (330, 'Service Room', 1),
       (401, 'Lecture Room', 1),
       (402, 'Lecture Room', 1),
       (403, 'Lecture Room', 1),
       (404, 'Lecture Room', 1),
       (405, 'Lecture Room', 1),
       (406, 'Lecture Room', 1),
       (407, 'Seminar Room', 1),
       (408, 'Seminar Room', 1),
       (409, 'Seminar Room', 1),
       (410, 'Seminar Room', 1),
       (411, 'Seminar Room', 1),
       (412, 'Seminar Room', 1),
       (413, 'Lab Room', 1),
       (414, 'Lab Room', 1),
       (415, 'Lab Room', 1),
       (416, 'Lab Room', 1),
       (417, 'Lab Room', 1),
       (418, 'Lab Room', 1),
       (419, 'Office Room', 1),
       (420, 'Office Room', 1),
       (421, 'Office Room', 1),
       (422, 'Office Room', 1),
       (423, 'Office Room', 1),
       (424, 'Office Room', 1),
       (425, 'Service Room', 1),
       (426, 'Service Room', 1),
       (427, 'Service Room', 1),
       (428, 'Service Room', 1),
       (429, 'Service Room', 1),
       (430, 'Service Room', 1),
       (101, 'Lecture Room', 2),
       (102, 'Lecture Room', 2),
       (103, 'Lecture Room', 2),
       (104, 'Lecture Room', 2),
       (105, 'Lecture Room', 2),
       (106, 'Lecture Room', 2),
       (107, 'Seminar Room', 2),
       (108, 'Seminar Room', 2),
       (109, 'Seminar Room', 2),
       (110, 'Seminar Room', 2),
       (111, 'Seminar Room', 2),
       (112, 'Seminar Room', 2),
       (113, 'Lab Room', 2),
       (114, 'Lab Room', 2),
       (115, 'Lab Room', 2),
       (116, 'Lab Room', 2),
       (117, 'Lab Room', 2),
       (118, 'Lab Room', 2),
       (119, 'Office Room', 2),
       (120, 'Office Room', 2),
       (121, 'Office Room', 2),
       (122, 'Office Room', 2),
       (123, 'Office Room', 2),
       (124, 'Office Room', 2),
       (125, 'Service Room', 2),
       (126, 'Service Room', 2),
       (127, 'Service Room', 2),
       (128, 'Service Room', 2),
       (129, 'Service Room', 2),
       (130, 'Service Room', 2),
       (201, 'Lecture Room', 2),
       (202, 'Lecture Room', 2),
       (203, 'Lecture Room', 2),
       (204, 'Lecture Room', 2),
       (205, 'Lecture Room', 2),
       (206, 'Lecture Room', 2),
       (207, 'Seminar Room', 2),
       (208, 'Seminar Room', 2),
       (209, 'Seminar Room', 2),
       (210, 'Seminar Room', 2),
       (211, 'Seminar Room', 2),
       (212, 'Seminar Room', 2),
       (213, 'Lab Room', 2),
       (214, 'Lab Room', 2),
       (215, 'Lab Room', 2),
       (216, 'Lab Room', 2),
       (217, 'Lab Room', 2),
       (218, 'Lab Room', 2),
       (219, 'Office Room', 2),
       (220, 'Office Room', 2),
       (221, 'Office Room', 2),
       (222, 'Office Room', 2),
       (223, 'Office Room', 2),
       (224, 'Office Room', 2),
       (225, 'Service Room', 2),
       (226, 'Service Room', 2),
       (227, 'Service Room', 2),
       (228, 'Service Room', 2),
       (229, 'Service Room', 2),
       (230, 'Service Room', 2),
       (301, 'Lecture Room', 2),
       (302, 'Lecture Room', 2),
       (303, 'Lecture Room', 2),
       (304, 'Lecture Room', 2),
       (305, 'Lecture Room', 2),
       (306, 'Lecture Room', 2),
       (307, 'Seminar Room', 2),
       (308, 'Seminar Room', 2),
       (309, 'Seminar Room', 2),
       (310, 'Seminar Room', 2),
       (311, 'Seminar Room', 2),
       (312, 'Seminar Room', 2),
       (313, 'Lab Room', 2),
       (314, 'Lab Room', 2),
       (315, 'Lab Room', 2),
       (316, 'Lab Room', 2),
       (317, 'Lab Room', 2),
       (318, 'Lab Room', 2),
       (319, 'Office Room', 2),
       (320, 'Office Room', 2),
       (321, 'Office Room', 2),
       (322, 'Office Room', 2),
       (323, 'Office Room', 2),
       (324, 'Office Room', 2),
       (325, 'Service Room', 2),
       (326, 'Service Room', 2),
       (327, 'Service Room', 2),
       (328, 'Service Room', 2),
       (329, 'Service Room', 2),
       (330, 'Service Room', 2),
       (401, 'Lecture Room', 2),
       (402, 'Lecture Room', 2),
       (403, 'Lecture Room', 2),
       (404, 'Lecture Room', 2),
       (405, 'Lecture Room', 2),
       (406, 'Lecture Room', 2),
       (407, 'Seminar Room', 2),
       (408, 'Seminar Room', 2),
       (409, 'Seminar Room', 2),
       (410, 'Seminar Room', 2),
       (411, 'Seminar Room', 2),
       (412, 'Seminar Room', 2),
       (413, 'Lab Room', 2),
       (414, 'Lab Room', 2),
       (415, 'Lab Room', 2),
       (416, 'Lab Room', 2),
       (417, 'Lab Room', 2),
       (418, 'Lab Room', 2),
       (419, 'Office Room', 2),
       (420, 'Office Room', 2),
       (421, 'Office Room', 2),
       (422, 'Office Room', 2),
       (423, 'Office Room', 2),
       (424, 'Office Room', 2),
       (425, 'Service Room', 2),
       (426, 'Service Room', 2),
       (427, 'Service Room', 2),
       (428, 'Service Room', 2),
       (429, 'Service Room', 2),
       (430, 'Service Room', 2),
       (101, 'Lecture Room', 3),
       (102, 'Lecture Room', 3),
       (103, 'Lecture Room', 3),
       (104, 'Lecture Room', 3),
       (105, 'Lecture Room', 3),
       (106, 'Lecture Room', 3),
       (107, 'Seminar Room', 3),
       (108, 'Seminar Room', 3),
       (109, 'Seminar Room', 3),
       (110, 'Seminar Room', 3),
       (111, 'Seminar Room', 3),
       (112, 'Seminar Room', 3),
       (113, 'Lab Room', 3),
       (114, 'Lab Room', 3),
       (115, 'Lab Room', 3),
       (116, 'Lab Room', 3),
       (117, 'Lab Room', 3),
       (118, 'Lab Room', 3),
       (119, 'Office Room', 3),
       (120, 'Office Room', 3),
       (121, 'Office Room', 3),
       (122, 'Office Room', 3),
       (123, 'Office Room', 3),
       (124, 'Office Room', 3),
       (125, 'Service Room', 3),
       (126, 'Service Room', 3),
       (127, 'Service Room', 3),
       (128, 'Service Room', 3),
       (129, 'Service Room', 3),
       (130, 'Service Room', 3),
       (201, 'Lecture Room', 3),
       (202, 'Lecture Room', 3),
       (203, 'Lecture Room', 3),
       (204, 'Lecture Room', 3),
       (205, 'Lecture Room', 3),
       (206, 'Lecture Room', 3),
       (207, 'Seminar Room', 3),
       (208, 'Seminar Room', 3),
       (209, 'Seminar Room', 3),
       (210, 'Seminar Room', 3),
       (211, 'Seminar Room', 3),
       (212, 'Seminar Room', 3),
       (213, 'Lab Room', 3),
       (214, 'Lab Room', 3),
       (215, 'Lab Room', 3),
       (216, 'Lab Room', 3),
       (217, 'Lab Room', 3),
       (218, 'Lab Room', 3),
       (219, 'Office Room', 3),
       (220, 'Office Room', 3),
       (221, 'Office Room', 3),
       (222, 'Office Room', 3),
       (223, 'Office Room', 3),
       (224, 'Office Room', 3),
       (225, 'Service Room', 3),
       (226, 'Service Room', 3),
       (227, 'Service Room', 3),
       (228, 'Service Room', 3),
       (229, 'Service Room', 3),
       (230, 'Service Room', 3),
       (301, 'Lecture Room', 3),
       (302, 'Lecture Room', 3),
       (303, 'Lecture Room', 3),
       (304, 'Lecture Room', 3),
       (305, 'Lecture Room', 3),
       (306, 'Lecture Room', 3),
       (307, 'Seminar Room', 3),
       (308, 'Seminar Room', 3),
       (309, 'Seminar Room', 3),
       (310, 'Seminar Room', 3),
       (311, 'Seminar Room', 3),
       (312, 'Seminar Room', 3),
       (313, 'Lab Room', 3),
       (314, 'Lab Room', 3),
       (315, 'Lab Room', 3),
       (316, 'Lab Room', 3),
       (317, 'Lab Room', 3),
       (318, 'Lab Room', 3),
       (319, 'Office Room', 3),
       (320, 'Office Room', 3),
       (321, 'Office Room', 3),
       (322, 'Office Room', 3),
       (323, 'Office Room', 3),
       (324, 'Office Room', 3),
       (325, 'Service Room', 3),
       (326, 'Service Room', 3),
       (327, 'Service Room', 3),
       (328, 'Service Room', 3),
       (329, 'Service Room', 3),
       (330, 'Service Room', 3),
       (401, 'Lecture Room', 3),
       (402, 'Lecture Room', 3),
       (403, 'Lecture Room', 3),
       (404, 'Lecture Room', 3),
       (405, 'Lecture Room', 3),
       (406, 'Lecture Room', 3),
       (407, 'Seminar Room', 3),
       (408, 'Seminar Room', 3),
       (409, 'Seminar Room', 3),
       (410, 'Seminar Room', 3),
       (411, 'Seminar Room', 3),
       (412, 'Seminar Room', 3),
       (413, 'Lab Room', 3),
       (414, 'Lab Room', 3),
       (415, 'Lab Room', 3),
       (416, 'Lab Room', 3),
       (417, 'Lab Room', 3),
       (418, 'Lab Room', 3),
       (419, 'Office Room', 3),
       (420, 'Office Room', 3),
       (421, 'Office Room', 3),
       (422, 'Office Room', 3),
       (423, 'Office Room', 3),
       (424, 'Office Room', 3),
       (425, 'Service Room', 3),
       (426, 'Service Room', 3),
       (427, 'Service Room', 3),
       (428, 'Service Room', 3),
       (429, 'Service Room', 3),
       (430, 'Service Room', 3),
       (101, 'Lecture Room', 4),
       (102, 'Lecture Room', 4),
       (103, 'Lecture Room', 4),
       (104, 'Lecture Room', 4),
       (105, 'Lecture Room', 4),
       (106, 'Lecture Room', 4),
       (107, 'Seminar Room', 4),
       (108, 'Seminar Room', 4),
       (109, 'Seminar Room', 4),
       (110, 'Seminar Room', 4),
       (111, 'Seminar Room', 4),
       (112, 'Seminar Room', 4),
       (113, 'Lab Room', 4),
       (114, 'Lab Room', 4),
       (115, 'Lab Room', 4),
       (116, 'Lab Room', 4),
       (117, 'Lab Room', 4),
       (118, 'Lab Room', 4),
       (119, 'Office Room', 4),
       (120, 'Office Room', 4),
       (121, 'Office Room', 4),
       (122, 'Office Room', 4),
       (123, 'Office Room', 4),
       (124, 'Office Room', 4),
       (125, 'Service Room', 4),
       (126, 'Service Room', 4),
       (127, 'Service Room', 4),
       (128, 'Service Room', 4),
       (129, 'Service Room', 4),
       (130, 'Service Room', 4),
       (201, 'Lecture Room', 4),
       (202, 'Lecture Room', 4),
       (203, 'Lecture Room', 4),
       (204, 'Lecture Room', 4),
       (205, 'Lecture Room', 4),
       (206, 'Lecture Room', 4),
       (207, 'Seminar Room', 4),
       (208, 'Seminar Room', 4),
       (209, 'Seminar Room', 4),
       (210, 'Seminar Room', 4),
       (211, 'Seminar Room', 4),
       (212, 'Seminar Room', 4),
       (213, 'Lab Room', 4),
       (214, 'Lab Room', 4),
       (215, 'Lab Room', 4),
       (216, 'Lab Room', 4),
       (217, 'Lab Room', 4),
       (218, 'Lab Room', 4),
       (219, 'Office Room', 4),
       (220, 'Office Room', 4),
       (221, 'Office Room', 4),
       (222, 'Office Room', 4),
       (223, 'Office Room', 4),
       (224, 'Office Room', 4),
       (225, 'Service Room', 4),
       (226, 'Service Room', 4),
       (227, 'Service Room', 4),
       (228, 'Service Room', 4),
       (229, 'Service Room', 4),
       (230, 'Service Room', 4),
       (301, 'Lecture Room', 4),
       (302, 'Lecture Room', 4),
       (303, 'Lecture Room', 4),
       (304, 'Lecture Room', 4),
       (305, 'Lecture Room', 4),
       (306, 'Lecture Room', 4),
       (307, 'Seminar Room', 4),
       (308, 'Seminar Room', 4),
       (309, 'Seminar Room', 4),
       (310, 'Seminar Room', 4),
       (311, 'Seminar Room', 4),
       (312, 'Seminar Room', 4),
       (313, 'Lab Room', 4),
       (314, 'Lab Room', 4),
       (315, 'Lab Room', 4),
       (316, 'Lab Room', 4),
       (317, 'Lab Room', 4),
       (318, 'Lab Room', 4),
       (319, 'Office Room', 4),
       (320, 'Office Room', 4),
       (321, 'Office Room', 4),
       (322, 'Office Room', 4),
       (323, 'Office Room', 4),
       (324, 'Office Room', 4),
       (325, 'Service Room', 4),
       (326, 'Service Room', 4),
       (327, 'Service Room', 4),
       (328, 'Service Room', 4),
       (329, 'Service Room', 4),
       (330, 'Service Room', 4),
       (401, 'Lecture Room', 4),
       (402, 'Lecture Room', 4),
       (403, 'Lecture Room', 4),
       (404, 'Lecture Room', 4),
       (405, 'Lecture Room', 4),
       (406, 'Lecture Room', 4),
       (407, 'Seminar Room', 4),
       (408, 'Seminar Room', 4),
       (409, 'Seminar Room', 4),
       (410, 'Seminar Room', 4),
       (411, 'Seminar Room', 4),
       (412, 'Seminar Room', 4),
       (413, 'Lab Room', 4),
       (414, 'Lab Room', 4),
       (415, 'Lab Room', 4),
       (416, 'Lab Room', 4),
       (417, 'Lab Room', 4),
       (418, 'Lab Room', 4),
       (419, 'Office Room', 4),
       (420, 'Office Room', 4),
       (421, 'Office Room', 4),
       (422, 'Office Room', 4),
       (423, 'Office Room', 4),
       (424, 'Office Room', 4),
       (425, 'Service Room', 4),
       (426, 'Service Room', 4),
       (427, 'Service Room', 4),
       (428, 'Service Room', 4),
       (429, 'Service Room', 4),
       (430, 'Service Room', 4),
       (101, 'Lecture Room', 5),
       (102, 'Lecture Room', 5),
       (103, 'Lecture Room', 5),
       (104, 'Lecture Room', 5),
       (105, 'Lecture Room', 5),
       (106, 'Lecture Room', 5),
       (107, 'Seminar Room', 5),
       (108, 'Seminar Room', 5),
       (109, 'Seminar Room', 5),
       (110, 'Seminar Room', 5),
       (111, 'Seminar Room', 5),
       (112, 'Seminar Room', 5),
       (113, 'Lab Room', 5),
       (114, 'Lab Room', 5),
       (115, 'Lab Room', 5),
       (116, 'Lab Room', 5),
       (117, 'Lab Room', 5),
       (118, 'Lab Room', 5),
       (119, 'Office Room', 5),
       (120, 'Office Room', 5),
       (121, 'Office Room', 5),
       (122, 'Office Room', 5),
       (123, 'Office Room', 5),
       (124, 'Office Room', 5),
       (125, 'Service Room', 5),
       (126, 'Service Room', 5),
       (127, 'Service Room', 5),
       (128, 'Service Room', 5),
       (129, 'Service Room', 5),
       (130, 'Service Room', 5),
       (201, 'Lecture Room', 5),
       (202, 'Lecture Room', 5),
       (203, 'Lecture Room', 5),
       (204, 'Lecture Room', 5),
       (205, 'Lecture Room', 5),
       (206, 'Lecture Room', 5),
       (207, 'Seminar Room', 5),
       (208, 'Seminar Room', 5),
       (209, 'Seminar Room', 5),
       (210, 'Seminar Room', 5),
       (211, 'Seminar Room', 5),
       (212, 'Seminar Room', 5),
       (213, 'Lab Room', 5),
       (214, 'Lab Room', 5),
       (215, 'Lab Room', 5),
       (216, 'Lab Room', 5),
       (217, 'Lab Room', 5),
       (218, 'Lab Room', 5),
       (219, 'Office Room', 5),
       (220, 'Office Room', 5),
       (221, 'Office Room', 5),
       (222, 'Office Room', 5),
       (223, 'Office Room', 5),
       (224, 'Office Room', 5),
       (225, 'Service Room', 5),
       (226, 'Service Room', 5),
       (227, 'Service Room', 5),
       (228, 'Service Room', 5),
       (229, 'Service Room', 5),
       (230, 'Service Room', 5),
       (301, 'Lecture Room', 5),
       (302, 'Lecture Room', 5),
       (303, 'Lecture Room', 5),
       (304, 'Lecture Room', 5),
       (305, 'Lecture Room', 5),
       (306, 'Lecture Room', 5),
       (307, 'Seminar Room', 5),
       (308, 'Seminar Room', 5),
       (309, 'Seminar Room', 5),
       (310, 'Seminar Room', 5),
       (311, 'Seminar Room', 5),
       (312, 'Seminar Room', 5),
       (313, 'Lab Room', 5),
       (314, 'Lab Room', 5),
       (315, 'Lab Room', 5),
       (316, 'Lab Room', 5),
       (317, 'Lab Room', 5),
       (318, 'Lab Room', 5),
       (319, 'Office Room', 5),
       (320, 'Office Room', 5),
       (321, 'Office Room', 5),
       (322, 'Office Room', 5),
       (323, 'Office Room', 5),
       (324, 'Office Room', 5),
       (325, 'Service Room', 5),
       (326, 'Service Room', 5),
       (327, 'Service Room', 5),
       (328, 'Service Room', 5),
       (329, 'Service Room', 5),
       (330, 'Service Room', 5),
       (401, 'Lecture Room', 5),
       (402, 'Lecture Room', 5),
       (403, 'Lecture Room', 5),
       (404, 'Lecture Room', 5),
       (405, 'Lecture Room', 5),
       (406, 'Lecture Room', 5),
       (407, 'Seminar Room', 5),
       (408, 'Seminar Room', 5),
       (409, 'Seminar Room', 5),
       (410, 'Seminar Room', 5),
       (411, 'Seminar Room', 5),
       (412, 'Seminar Room', 5),
       (413, 'Lab Room', 5),
       (414, 'Lab Room', 5),
       (415, 'Lab Room', 5),
       (416, 'Lab Room', 5),
       (417, 'Lab Room', 5),
       (418, 'Lab Room', 5),
       (419, 'Office Room', 5),
       (420, 'Office Room', 5),
       (421, 'Office Room', 5),
       (422, 'Office Room', 5),
       (423, 'Office Room', 5),
       (424, 'Office Room', 5),
       (425, 'Service Room', 5),
       (426, 'Service Room', 5),
       (427, 'Service Room', 5),
       (428, 'Service Room', 5),
       (429, 'Service Room', 5),
       (430, 'Service Room', 5),
       (101, 'Lecture Room', 6),
       (102, 'Lecture Room', 6),
       (103, 'Lecture Room', 6),
       (104, 'Lecture Room', 6),
       (105, 'Lecture Room', 6),
       (106, 'Lecture Room', 6),
       (107, 'Seminar Room', 6),
       (108, 'Seminar Room', 6),
       (109, 'Seminar Room', 6),
       (110, 'Seminar Room', 6),
       (111, 'Seminar Room', 6),
       (112, 'Seminar Room', 6),
       (113, 'Lab Room', 6),
       (114, 'Lab Room', 6),
       (115, 'Lab Room', 6),
       (116, 'Lab Room', 6),
       (117, 'Lab Room', 6),
       (118, 'Lab Room', 6),
       (119, 'Office Room', 6),
       (120, 'Office Room', 6),
       (121, 'Office Room', 6),
       (122, 'Office Room', 6),
       (123, 'Office Room', 6),
       (124, 'Office Room', 6),
       (125, 'Service Room', 6),
       (126, 'Service Room', 6),
       (127, 'Service Room', 6),
       (128, 'Service Room', 6),
       (129, 'Service Room', 6),
       (130, 'Service Room', 6),
       (201, 'Lecture Room', 6),
       (202, 'Lecture Room', 6),
       (203, 'Lecture Room', 6),
       (204, 'Lecture Room', 6),
       (205, 'Lecture Room', 6),
       (206, 'Lecture Room', 6),
       (207, 'Seminar Room', 6),
       (208, 'Seminar Room', 6),
       (209, 'Seminar Room', 6),
       (210, 'Seminar Room', 6),
       (211, 'Seminar Room', 6),
       (212, 'Seminar Room', 6),
       (213, 'Lab Room', 6),
       (214, 'Lab Room', 6),
       (215, 'Lab Room', 6),
       (216, 'Lab Room', 6),
       (217, 'Lab Room', 6),
       (218, 'Lab Room', 6),
       (219, 'Office Room', 6),
       (220, 'Office Room', 6),
       (221, 'Office Room', 6),
       (222, 'Office Room', 6),
       (223, 'Office Room', 6),
       (224, 'Office Room', 6),
       (225, 'Service Room', 6),
       (226, 'Service Room', 6),
       (227, 'Service Room', 6),
       (228, 'Service Room', 6),
       (229, 'Service Room', 6),
       (230, 'Service Room', 6),
       (301, 'Lecture Room', 6),
       (302, 'Lecture Room', 6),
       (303, 'Lecture Room', 6),
       (304, 'Lecture Room', 6),
       (305, 'Lecture Room', 6),
       (306, 'Lecture Room', 6),
       (307, 'Seminar Room', 6),
       (308, 'Seminar Room', 6),
       (309, 'Seminar Room', 6),
       (310, 'Seminar Room', 6),
       (311, 'Seminar Room', 6),
       (312, 'Seminar Room', 6),
       (313, 'Lab Room', 6),
       (314, 'Lab Room', 6),
       (315, 'Lab Room', 6),
       (316, 'Lab Room', 6),
       (317, 'Lab Room', 6),
       (318, 'Lab Room', 6),
       (319, 'Office Room', 6),
       (320, 'Office Room', 6),
       (321, 'Office Room', 6),
       (322, 'Office Room', 6),
       (323, 'Office Room', 6),
       (324, 'Office Room', 6),
       (325, 'Service Room', 6),
       (326, 'Service Room', 6),
       (327, 'Service Room', 6),
       (328, 'Service Room', 6),
       (329, 'Service Room', 6),
       (330, 'Service Room', 6),
       (401, 'Lecture Room', 6),
       (402, 'Lecture Room', 6),
       (403, 'Lecture Room', 6),
       (404, 'Lecture Room', 6),
       (405, 'Lecture Room', 6),
       (406, 'Lecture Room', 6),
       (407, 'Seminar Room', 6),
       (408, 'Seminar Room', 6),
       (409, 'Seminar Room', 6),
       (410, 'Seminar Room', 6),
       (411, 'Seminar Room', 6),
       (412, 'Seminar Room', 6),
       (413, 'Lab Room', 6),
       (414, 'Lab Room', 6),
       (415, 'Lab Room', 6),
       (416, 'Lab Room', 6),
       (417, 'Lab Room', 6),
       (418, 'Lab Room', 6),
       (419, 'Office Room', 6),
       (420, 'Office Room', 6),
       (421, 'Office Room', 6),
       (422, 'Office Room', 6),
       (423, 'Office Room', 6),
       (424, 'Office Room', 6),
       (425, 'Service Room', 6),
       (426, 'Service Room', 6),
       (427, 'Service Room', 6),
       (428, 'Service Room', 6),
       (429, 'Service Room', 6),
       (430, 'Service Room', 6),
       (101, 'Lecture Room', 7),
       (102, 'Lecture Room', 7),
       (103, 'Lecture Room', 7),
       (104, 'Lecture Room', 7),
       (105, 'Lecture Room', 7),
       (106, 'Lecture Room', 7),
       (107, 'Seminar Room', 7),
       (108, 'Seminar Room', 7),
       (109, 'Seminar Room', 7),
       (110, 'Seminar Room', 7),
       (111, 'Seminar Room', 7),
       (112, 'Seminar Room', 7),
       (113, 'Lab Room', 7),
       (114, 'Lab Room', 7),
       (115, 'Lab Room', 7),
       (116, 'Lab Room', 7),
       (117, 'Lab Room', 7),
       (118, 'Lab Room', 7),
       (119, 'Office Room', 7),
       (120, 'Office Room', 7),
       (121, 'Office Room', 7),
       (122, 'Office Room', 7),
       (123, 'Office Room', 7),
       (124, 'Office Room', 7),
       (125, 'Service Room', 7),
       (126, 'Service Room', 7),
       (127, 'Service Room', 7),
       (128, 'Service Room', 7),
       (129, 'Service Room', 7),
       (130, 'Service Room', 7),
       (201, 'Lecture Room', 7),
       (202, 'Lecture Room', 7),
       (203, 'Lecture Room', 7),
       (204, 'Lecture Room', 7),
       (205, 'Lecture Room', 7),
       (206, 'Lecture Room', 7),
       (207, 'Seminar Room', 7),
       (208, 'Seminar Room', 7),
       (209, 'Seminar Room', 7),
       (210, 'Seminar Room', 7),
       (211, 'Seminar Room', 7),
       (212, 'Seminar Room', 7),
       (213, 'Lab Room', 7),
       (214, 'Lab Room', 7),
       (215, 'Lab Room', 7),
       (216, 'Lab Room', 7),
       (217, 'Lab Room', 7),
       (218, 'Lab Room', 7),
       (219, 'Office Room', 7),
       (220, 'Office Room', 7),
       (221, 'Office Room', 7),
       (222, 'Office Room', 7),
       (223, 'Office Room', 7),
       (224, 'Office Room', 7),
       (225, 'Service Room', 7),
       (226, 'Service Room', 7),
       (227, 'Service Room', 7),
       (228, 'Service Room', 7),
       (229, 'Service Room', 7),
       (230, 'Service Room', 7),
       (301, 'Lecture Room', 7),
       (302, 'Lecture Room', 7),
       (303, 'Lecture Room', 7),
       (304, 'Lecture Room', 7),
       (305, 'Lecture Room', 7),
       (306, 'Lecture Room', 7),
       (307, 'Seminar Room', 7),
       (308, 'Seminar Room', 7),
       (309, 'Seminar Room', 7),
       (310, 'Seminar Room', 7),
       (311, 'Seminar Room', 7),
       (312, 'Seminar Room', 7),
       (313, 'Lab Room', 7),
       (314, 'Lab Room', 7),
       (315, 'Lab Room', 7),
       (316, 'Lab Room', 7),
       (317, 'Lab Room', 7),
       (318, 'Lab Room', 7),
       (319, 'Office Room', 7),
       (320, 'Office Room', 7),
       (321, 'Office Room', 7),
       (322, 'Office Room', 7),
       (323, 'Office Room', 7),
       (324, 'Office Room', 7),
       (325, 'Service Room', 7),
       (326, 'Service Room', 7),
       (327, 'Service Room', 7),
       (328, 'Service Room', 7),
       (329, 'Service Room', 7),
       (330, 'Service Room', 7),
       (401, 'Lecture Room', 7),
       (402, 'Lecture Room', 7),
       (403, 'Lecture Room', 7),
       (404, 'Lecture Room', 7),
       (405, 'Lecture Room', 7),
       (406, 'Lecture Room', 7),
       (407, 'Seminar Room', 7),
       (408, 'Seminar Room', 7),
       (409, 'Seminar Room', 7),
       (410, 'Seminar Room', 7),
       (411, 'Seminar Room', 7),
       (412, 'Seminar Room', 7),
       (413, 'Lab Room', 7),
       (414, 'Lab Room', 7),
       (415, 'Lab Room', 7),
       (416, 'Lab Room', 7),
       (417, 'Lab Room', 7),
       (418, 'Lab Room', 7),
       (419, 'Office Room', 7),
       (420, 'Office Room', 7),
       (421, 'Office Room', 7),
       (422, 'Office Room', 7),
       (423, 'Office Room', 7),
       (424, 'Office Room', 7),
       (425, 'Service Room', 7),
       (426, 'Service Room', 7),
       (427, 'Service Room', 7),
       (428, 'Service Room', 7),
       (429, 'Service Room', 7),
       (430, 'Service Room', 7),
       (101, 'Lecture Room', 8),
       (102, 'Lecture Room', 8),
       (103, 'Lecture Room', 8),
       (104, 'Lecture Room', 8),
       (105, 'Lecture Room', 8),
       (106, 'Lecture Room', 8),
       (107, 'Seminar Room', 8),
       (108, 'Seminar Room', 8),
       (109, 'Seminar Room', 8),
       (110, 'Seminar Room', 8),
       (111, 'Seminar Room', 8),
       (112, 'Seminar Room', 8),
       (113, 'Lab Room', 8),
       (114, 'Lab Room', 8),
       (115, 'Lab Room', 8),
       (116, 'Lab Room', 8),
       (117, 'Lab Room', 8),
       (118, 'Lab Room', 8),
       (119, 'Office Room', 8),
       (120, 'Office Room', 8),
       (121, 'Office Room', 8),
       (122, 'Office Room', 8),
       (123, 'Office Room', 8),
       (124, 'Office Room', 8),
       (125, 'Service Room', 8),
       (126, 'Service Room', 8),
       (127, 'Service Room', 8),
       (128, 'Service Room', 8),
       (129, 'Service Room', 8),
       (130, 'Service Room', 8),
       (201, 'Lecture Room', 8),
       (202, 'Lecture Room', 8),
       (203, 'Lecture Room', 8),
       (204, 'Lecture Room', 8),
       (205, 'Lecture Room', 8),
       (206, 'Lecture Room', 8),
       (207, 'Seminar Room', 8),
       (208, 'Seminar Room', 8),
       (209, 'Seminar Room', 8),
       (210, 'Seminar Room', 8),
       (211, 'Seminar Room', 8),
       (212, 'Seminar Room', 8),
       (213, 'Lab Room', 8),
       (214, 'Lab Room', 8),
       (215, 'Lab Room', 8),
       (216, 'Lab Room', 8),
       (217, 'Lab Room', 8),
       (218, 'Lab Room', 8),
       (219, 'Office Room', 8),
       (220, 'Office Room', 8),
       (221, 'Office Room', 8),
       (222, 'Office Room', 8),
       (223, 'Office Room', 8),
       (224, 'Office Room', 8),
       (225, 'Service Room', 8),
       (226, 'Service Room', 8),
       (227, 'Service Room', 8),
       (228, 'Service Room', 8),
       (229, 'Service Room', 8),
       (230, 'Service Room', 8),
       (301, 'Lecture Room', 8),
       (302, 'Lecture Room', 8),
       (303, 'Lecture Room', 8),
       (304, 'Lecture Room', 8),
       (305, 'Lecture Room', 8),
       (306, 'Lecture Room', 8),
       (307, 'Seminar Room', 8),
       (308, 'Seminar Room', 8),
       (309, 'Seminar Room', 8),
       (310, 'Seminar Room', 8),
       (311, 'Seminar Room', 8),
       (312, 'Seminar Room', 8),
       (313, 'Lab Room', 8),
       (314, 'Lab Room', 8),
       (315, 'Lab Room', 8),
       (316, 'Lab Room', 8),
       (317, 'Lab Room', 8),
       (318, 'Lab Room', 8),
       (319, 'Office Room', 8),
       (320, 'Office Room', 8),
       (321, 'Office Room', 8),
       (322, 'Office Room', 8),
       (323, 'Office Room', 8),
       (324, 'Office Room', 8),
       (325, 'Service Room', 8),
       (326, 'Service Room', 8),
       (327, 'Service Room', 8),
       (328, 'Service Room', 8),
       (329, 'Service Room', 8),
       (330, 'Service Room', 8),
       (401, 'Lecture Room', 8),
       (402, 'Lecture Room', 8),
       (403, 'Lecture Room', 8),
       (404, 'Lecture Room', 8),
       (405, 'Lecture Room', 8),
       (406, 'Lecture Room', 8),
       (407, 'Seminar Room', 8),
       (408, 'Seminar Room', 8),
       (409, 'Seminar Room', 8),
       (410, 'Seminar Room', 8),
       (411, 'Seminar Room', 8),
       (412, 'Seminar Room', 8),
       (413, 'Lab Room', 8),
       (414, 'Lab Room', 8),
       (415, 'Lab Room', 8),
       (416, 'Lab Room', 8),
       (417, 'Lab Room', 8),
       (418, 'Lab Room', 8),
       (419, 'Office Room', 8),
       (420, 'Office Room', 8),
       (421, 'Office Room', 8),
       (422, 'Office Room', 8),
       (423, 'Office Room', 8),
       (424, 'Office Room', 8),
       (425, 'Service Room', 8),
       (426, 'Service Room', 8),
       (427, 'Service Room', 8),
       (428, 'Service Room', 8),
       (429, 'Service Room', 8),
       (430, 'Service Room', 8),
       (101, 'Lecture Room', 9),
       (102, 'Lecture Room', 9),
       (103, 'Lecture Room', 9),
       (104, 'Lecture Room', 9),
       (105, 'Lecture Room', 9),
       (106, 'Lecture Room', 9),
       (107, 'Seminar Room', 9),
       (108, 'Seminar Room', 9),
       (109, 'Seminar Room', 9),
       (110, 'Seminar Room', 9),
       (111, 'Seminar Room', 9),
       (112, 'Seminar Room', 9),
       (113, 'Lab Room', 9),
       (114, 'Lab Room', 9),
       (115, 'Lab Room', 9),
       (116, 'Lab Room', 9),
       (117, 'Lab Room', 9),
       (118, 'Lab Room', 9),
       (119, 'Office Room', 9),
       (120, 'Office Room', 9),
       (121, 'Office Room', 9),
       (122, 'Office Room', 9),
       (123, 'Office Room', 9),
       (124, 'Office Room', 9),
       (125, 'Service Room', 9),
       (126, 'Service Room', 9),
       (127, 'Service Room', 9),
       (128, 'Service Room', 9),
       (129, 'Service Room', 9),
       (130, 'Service Room', 9),
       (201, 'Lecture Room', 9),
       (202, 'Lecture Room', 9),
       (203, 'Lecture Room', 9),
       (204, 'Lecture Room', 9),
       (205, 'Lecture Room', 9),
       (206, 'Lecture Room', 9),
       (207, 'Seminar Room', 9),
       (208, 'Seminar Room', 9),
       (209, 'Seminar Room', 9),
       (210, 'Seminar Room', 9),
       (211, 'Seminar Room', 9),
       (212, 'Seminar Room', 9),
       (213, 'Lab Room', 9),
       (214, 'Lab Room', 9),
       (215, 'Lab Room', 9),
       (216, 'Lab Room', 9),
       (217, 'Lab Room', 9),
       (218, 'Lab Room', 9),
       (219, 'Office Room', 9),
       (220, 'Office Room', 9),
       (221, 'Office Room', 9),
       (222, 'Office Room', 9),
       (223, 'Office Room', 9),
       (224, 'Office Room', 9),
       (225, 'Service Room', 9),
       (226, 'Service Room', 9),
       (227, 'Service Room', 9),
       (228, 'Service Room', 9),
       (229, 'Service Room', 9),
       (230, 'Service Room', 9),
       (301, 'Lecture Room', 9),
       (302, 'Lecture Room', 9),
       (303, 'Lecture Room', 9),
       (304, 'Lecture Room', 9),
       (305, 'Lecture Room', 9),
       (306, 'Lecture Room', 9),
       (307, 'Seminar Room', 9),
       (308, 'Seminar Room', 9),
       (309, 'Seminar Room', 9),
       (310, 'Seminar Room', 9),
       (311, 'Seminar Room', 9),
       (312, 'Seminar Room', 9),
       (313, 'Lab Room', 9),
       (314, 'Lab Room', 9),
       (315, 'Lab Room', 9),
       (316, 'Lab Room', 9),
       (317, 'Lab Room', 9),
       (318, 'Lab Room', 9),
       (319, 'Office Room', 9),
       (320, 'Office Room', 9),
       (321, 'Office Room', 9),
       (322, 'Office Room', 9),
       (323, 'Office Room', 9),
       (324, 'Office Room', 9),
       (325, 'Service Room', 9),
       (326, 'Service Room', 9),
       (327, 'Service Room', 9),
       (328, 'Service Room', 9),
       (329, 'Service Room', 9),
       (330, 'Service Room', 9),
       (401, 'Lecture Room', 9),
       (402, 'Lecture Room', 9),
       (403, 'Lecture Room', 9),
       (404, 'Lecture Room', 9),
       (405, 'Lecture Room', 9),
       (406, 'Lecture Room', 9),
       (407, 'Seminar Room', 9),
       (408, 'Seminar Room', 9),
       (409, 'Seminar Room', 9),
       (410, 'Seminar Room', 9),
       (411, 'Seminar Room', 9),
       (412, 'Seminar Room', 9),
       (413, 'Lab Room', 9),
       (414, 'Lab Room', 9),
       (415, 'Lab Room', 9),
       (416, 'Lab Room', 9),
       (417, 'Lab Room', 9),
       (418, 'Lab Room', 9),
       (419, 'Office Room', 9),
       (420, 'Office Room', 9),
       (421, 'Office Room', 9),
       (422, 'Office Room', 9),
       (423, 'Office Room', 9),
       (424, 'Office Room', 9),
       (425, 'Service Room', 9),
       (426, 'Service Room', 9),
       (427, 'Service Room', 9),
       (428, 'Service Room', 9),
       (429, 'Service Room', 9),
       (430, 'Service Room', 9),
       (101, 'Lecture Room', 10),
       (102, 'Lecture Room', 10),
       (103, 'Lecture Room', 10),
       (104, 'Lecture Room', 10),
       (105, 'Lecture Room', 10),
       (106, 'Lecture Room', 10),
       (107, 'Seminar Room', 10),
       (108, 'Seminar Room', 10),
       (109, 'Seminar Room', 10),
       (110, 'Seminar Room', 10),
       (111, 'Seminar Room', 10),
       (112, 'Seminar Room', 10),
       (113, 'Lab Room', 10),
       (114, 'Lab Room', 10),
       (115, 'Lab Room', 10),
       (116, 'Lab Room', 10),
       (117, 'Lab Room', 10),
       (118, 'Lab Room', 10),
       (119, 'Office Room', 10),
       (120, 'Office Room', 10),
       (121, 'Office Room', 10),
       (122, 'Office Room', 10),
       (123, 'Office Room', 10),
       (124, 'Office Room', 10),
       (125, 'Service Room', 10),
       (126, 'Service Room', 10),
       (127, 'Service Room', 10),
       (128, 'Service Room', 10),
       (129, 'Service Room', 10),
       (130, 'Service Room', 10),
       (201, 'Lecture Room', 10),
       (202, 'Lecture Room', 10),
       (203, 'Lecture Room', 10),
       (204, 'Lecture Room', 10),
       (205, 'Lecture Room', 10),
       (206, 'Lecture Room', 10),
       (207, 'Seminar Room', 10),
       (208, 'Seminar Room', 10),
       (209, 'Seminar Room', 10),
       (210, 'Seminar Room', 10),
       (211, 'Seminar Room', 10),
       (212, 'Seminar Room', 10),
       (213, 'Lab Room', 10),
       (214, 'Lab Room', 10),
       (215, 'Lab Room', 10),
       (216, 'Lab Room', 10),
       (217, 'Lab Room', 10),
       (218, 'Lab Room', 10),
       (219, 'Office Room', 10),
       (220, 'Office Room', 10),
       (221, 'Office Room', 10),
       (222, 'Office Room', 10),
       (223, 'Office Room', 10),
       (224, 'Office Room', 10),
       (225, 'Service Room', 10),
       (226, 'Service Room', 10),
       (227, 'Service Room', 10),
       (228, 'Service Room', 10),
       (229, 'Service Room', 10),
       (230, 'Service Room', 10),
       (301, 'Lecture Room', 10),
       (302, 'Lecture Room', 10),
       (303, 'Lecture Room', 10),
       (304, 'Lecture Room', 10),
       (305, 'Lecture Room', 10),
       (306, 'Lecture Room', 10),
       (307, 'Seminar Room', 10),
       (308, 'Seminar Room', 10),
       (309, 'Seminar Room', 10),
       (310, 'Seminar Room', 10),
       (311, 'Seminar Room', 10),
       (312, 'Seminar Room', 10),
       (313, 'Lab Room', 10),
       (314, 'Lab Room', 10),
       (315, 'Lab Room', 10),
       (316, 'Lab Room', 10),
       (317, 'Lab Room', 10),
       (318, 'Lab Room', 10),
       (319, 'Office Room', 10),
       (320, 'Office Room', 10),
       (321, 'Office Room', 10),
       (322, 'Office Room', 10),
       (323, 'Office Room', 10),
       (324, 'Office Room', 10),
       (325, 'Service Room', 10),
       (326, 'Service Room', 10),
       (327, 'Service Room', 10),
       (328, 'Service Room', 10),
       (329, 'Service Room', 10),
       (330, 'Service Room', 10),
       (401, 'Lecture Room', 10),
       (402, 'Lecture Room', 10),
       (403, 'Lecture Room', 10),
       (404, 'Lecture Room', 10),
       (405, 'Lecture Room', 10),
       (406, 'Lecture Room', 10),
       (407, 'Seminar Room', 10),
       (408, 'Seminar Room', 10),
       (409, 'Seminar Room', 10),
       (410, 'Seminar Room', 10),
       (411, 'Seminar Room', 10),
       (412, 'Seminar Room', 10),
       (413, 'Lab Room', 10),
       (414, 'Lab Room', 10),
       (415, 'Lab Room', 10),
       (416, 'Lab Room', 10),
       (417, 'Lab Room', 10),
       (418, 'Lab Room', 10),
       (419, 'Office Room', 10),
       (420, 'Office Room', 10),
       (421, 'Office Room', 10),
       (422, 'Office Room', 10),
       (423, 'Office Room', 10),
       (424, 'Office Room', 10),
       (425, 'Service Room', 10),
       (426, 'Service Room', 10),
       (427, 'Service Room', 10),
       (428, 'Service Room', 10),
       (429, 'Service Room', 10),
       (430, 'Service Room', 10);

INSERT INTO teacher (teacher_full_name, teacher_phone, teacher_qualification, teacher_academic_degree,
                     teacher_experience)
VALUES ('Mark Johnson', '1234567890', 'Ph.D.', 'Associate Professor', 10),
       ('Emily Smith', '0987654321', 'M.Sc.', 'Assistant Professor', 5),
       ('David Brown', '9876543210', 'Ph.D.', 'Professor', 15),
       ('Jessica Wilson', '0123456789', 'M.Sc.', 'Associate Professor', 8),
       ('Michael Davis', '1357924680', 'Ph.D.', 'Professor', 20),
       ('Sarah Miller', '2468013579', 'M.Sc.', 'Assistant Professor', 6),
       ('Kevin Martinez', '5678901234', 'Ph.D.', 'Associate Professor', 12),
       ('Laura Taylor', '6789012345', 'M.Sc.', 'Professor', 18),
       ('John Anderson', '8901234567', 'Ph.D.', 'Assistant Professor', 7),
       ('Amanda Wilson', '9012345678', 'M.Sc.', 'Professor', 16);

INSERT INTO discipline (discipline_name, discipline_description, discipline_hours)
VALUES ('Mathematics', 'Introduction to Mathematics', 60),
       ('Physics', 'Fundamentals of Physics', 80),
       ('Literature', 'World Literature', 50),
       ('History', 'Modern History', 70),
       ('Chemistry', 'Basic Chemistry', 65),
       ('Biology', 'Cell Biology', 75),
       ('Computer Science', 'Programming Basics', 85),
       ('Engineering', 'Mechanical Engineering', 90),
       ('Medicine', 'Anatomy and Physiology', 100),
       ('Economics', 'Microeconomics', 55);

INSERT INTO teacher_discipline (teacher_id, discipline_id)
VALUES (1, 1),
       (1, 2),
       (2, 1),
       (2, 3),
       (3, 4),
       (4, 4),
       (5, 1),
       (6, 5),
       (7, 6),
       (10, NULL),
       (NULL, 10),
       (8, 3);

INSERT INTO study_plan (study_plan_number, study_plan_year)
VALUES ('SP2023', 2023),
       ('SP2024', 2024),
       ('SP2025', 2025),
       ('SP2026', 2026),
       ('SP2027', 2027),
       ('SP2028', 2028),
       ('SP2029', 2029),
       ('SP2030', 2030),
       ('SP2031', 2031),
       ('SP2032', 2032);

INSERT INTO study_plan_discipline (study_plan_id, discipline_id)
VALUES (1, 1),
       (1, 2),
       (1, 9),
       (1, 7),
       (2, 2),
       (2, 1),
       (2, 3),
       (2, 7),
       (3, 7),
       (3, 8),
       (3, 9),
       (3, 5),
       (4, 6),
       (4, 4),
       (4, 8),
       (4, 1),
       (5, 3),
       (5, 5),
       (5, 4),
       (5, 7),
       (6, 3),
       (6, 4),
       (6, 8),
       (6, 6),
       (7, 7),
       (7, 6),
       (7, 8),
       (7, 9),
       (8, 8),
       (8, 2),
       (8, 9),
       (8, 10),
       (9, 3),
       (9, 6),
       (9, 4),
       (9, 7),
       (10, 10),
       (10, 5),
       (10, 8),
       (10, 9);

INSERT INTO direction_training (direction_training_code, direction_training_name, direction_training_education_level,
                                direction_training_description, institute_id, study_plan_id)
VALUES ('DT001', 'Mathematics Education', 'Bachelor', 'Program for future mathematics teachers', 1, 1),
       ('DT002', 'Physics Education', 'Bachelor', 'Program for future physics teachers', 2, 2),
       ('DT003', 'Literature Studies', 'Bachelor', 'Program for literature enthusiasts', 3, 3),
       ('DT004', 'History Studies', 'Bachelor', 'Program for aspiring historians', 4, 4),
       ('DT005', 'Chemistry Education', 'Bachelor', 'Program for future chemistry teachers', 5, 5),
       ('DT006', 'Biology Education', 'Bachelor', 'Program for future biology teachers', 6, 6),
       ('DT007', 'Computer Science', 'Bachelor', 'Program for future computer scientists', 7, 7),
       ('DT008', 'Engineering Studies', 'Bachelor', 'Program for future engineers', 8, 8),
       ('DT009', 'Medicine Studies', 'Bachelor', 'Program for future medical professionals', 9, 9),
       ('DT010', 'Economics Studies', 'Bachelor', 'Program for future economists', 10, 10);

INSERT INTO study_group (study_group_number, study_group_course, direction_training_id)
VALUES ('A1', 1, 1),
       ('A2', 2, 2),
       ('B1', 3, 3),
       ('B2', 2, 4),
       ('C1', 1, 5),
       ('C2', 4, 6),
       ('D1', 4, 7),
       ('D2', 1, 8),
       ('E1', 2, 9),
       ('E2', 3, 10);

INSERT INTO schedule (lesson_start_datetime, lesson_type, lesson_end_datetime, teacher_id, room_id, discipline_id,
                      study_group_id)
VALUES ('2024-04-23 08:00:00', 'Lecture', '2024-04-23 09:30:00', 1, 1, 1, 1),
       ('2024-04-23 09:45:00', 'Lab', '2024-04-23 11:15:00', 2, 2, 2, 2),
       ('2024-04-23 11:30:00', 'Seminar', '2024-04-23 13:00:00', 3, 3, 3, 3),
       ('2024-04-23 13:15:00', 'Workshop', '2024-04-23 14:45:00', 4, 4, 4, 4),
       ('2024-04-23 15:00:00', 'Discussion', '2024-04-23 16:30:00', 5, 5, 5, 5),
       ('2024-04-24 08:00:00', 'Lecture', '2024-04-24 09:30:00', 6, 6, 6, 6),
       ('2024-04-24 09:45:00', 'Lab', '2024-04-24 11:15:00', 7, 7, 7, 7),
       ('2024-04-24 11:30:00', 'Seminar', '2024-04-24 13:00:00', 8, 8, 8, 8),
       ('2024-04-24 13:15:00', 'Workshop', '2024-04-24 14:45:00', 9, 9, 9, 9),
       ('2024-04-24 15:00:00', 'Discussion', '2024-04-24 16:30:00', 10, 10, 10, 10);

INSERT INTO hostel (hostel_name, hostel_address, hostel_number_place, hostel_phone, hostel_email,
                    hostel_commandant_fullname)
VALUES ('Main Hostel', '123 Hostel Street', 500, '1234567890', 'main.hostel@example.com', 'Alex Johnson'),
       ('South Hostel', '456 Dormitory Road', 300, '0987654321', 'south.hostel@example.com', 'Emma Smith'),
       ('North Hostel', '789 Residence Lane', 400, '9876543210', 'north.hostel@example.com', 'Jack Brown'),
       ('West Hostel', '321 Accommodation Avenue', 600, '0123456789', 'west.hostel@example.com', 'Sophia Wilson'),
       ('East Hostel', '654 Lodging Lane', 350, '1357924680', 'east.hostel@example.com', 'Noah Davis'),
       ('Downtown Hostel', '987 Living Street', 450, '2468013579', 'downtown.hostel@example.com', 'Ava Miller'),
       ('Central Hostel', '159 Dorm Street', 550, '5678901234', 'central.hostel@example.com', 'James Martinez'),
       ('Hostel A', '753 Boarding Lane', 250, '6789012345', 'hostel.a@example.com', 'Olivia Taylor'),
       ('Hostel B', '852 Housing Road', 350, '8901234567', 'hostel.b@example.com', 'William Anderson'),
       ('Hostel C', '426 Shelter Lane', 400, '9012345678', 'hostel.c@example.com', 'Isabella Wilson');

INSERT INTO student (student_fullname, student_birthdate, student_gender, student_email, student_phone, student_address,
                     student_passport, student_SNILS, student_card_number, student_study_form,
                     student_accumulated_rating, hostel_id, study_group_id)
VALUES ('Alex Johnson', '2000-01-01', 'Male', 'alex.johnson@example.com', '1234567890', '123 Hostel Street',
        'AA1234567', '123-456-789 00', 12345, 'Full-time', 44.54, 1, 1),
       ('Emma Smith', '2000-02-02', 'Female', 'emma.smith@example.com', '0987654321', '456 Dormitory Road', 'BB2345678',
        '234-567-890 11', 23456, 'Full-time', 44.21, 2, 2),
       ('Jack Brown', '2000-03-03', 'Male', 'jack.brown@example.com', '9876543210', '789 Residence Lane', 'CC3456789',
        '345-678-901 22', 34567, 'Full-time', 44.70, 3, 3),
       ('Sophia Wilson', '2000-04-04', 'Female', 'sophia.wilson@example.com', '0123456789', '321 Accommodation Avenue',
        'DD4567890', '456-789-012 33', 45678, 'Full-time', 44.10, 4, 4),
       ('Noah Davis', '2000-05-05', 'Male', 'noah.davis@example.com', '1357924680', '654 Lodging Lane', 'EE5678901',
        '567-890-123 44', 56789, 'Full-time', 44.61, 5, 5),
       ('Ava Miller', '2000-06-06', 'Female', 'ava.miller@example.com', '2468013579', '987 Living Street', 'FF6789012',
        '678-901-234 55', 67890, 'Full-time', 44.33, 6, 6),
       ('James Martinez', '2000-07-07', 'Male', 'james.martinez@example.com', '5678901234', '159 Dorm Street',
        'GG7890123', '789-012-345 66', 78901, 'Full-time', 34.83, 7, 7),
       ('Olivia Taylor', '2000-08-08', 'Female', 'olivia.taylor@example.com', '6789012345', '753 Boarding Lane',
        'HH8901234', '890-123-456 77', 89012, 'Full-time', 34.01, 8, 8),
       ('William Anderson', '2000-09-09', 'Male', 'william.anderson@example.com', '8901234567', '852 Housing Road',
        'II9012345', '901-234-567 88', 90123, 'Full-time', 34.93, 9, 9),
       ('Isabella Wilson', '2000-10-10', 'Female', 'isabella.wilson@example.com', '9012345678', '426 Shelter Lane',
        'JJ0123456', '012-345-678 99', 12345, 'Full-time', 34.47, 10, 10);

INSERT INTO attendance (attendance_bool, attendance_datetime, student_id, discipline_id)
VALUES (true, '2024-04-23 08:00:00', 1, 1),
       (true, '2024-04-23 09:45:00', 2, 2),
       (true, '2024-04-23 11:30:00', 3, 3),
       (true, '2024-04-23 13:15:00', 4, 4),
       (true, '2024-04-23 15:00:00', 5, 5),
       (true, '2024-04-24 08:00:00', 6, 6),
       (true, '2024-04-24 09:45:00', 7, 7),
       (true, '2024-04-24 11:30:00', 8, 8),
       (true, '2024-04-24 13:15:00', 9, 9),
       (true, '2024-04-24 15:00:00', 10, 10);

INSERT INTO exam_sheet (exam_sheet_number, mark, date_exam, semester, student_id, teacher_id, discipline_id)
VALUES ('ES001', 85, '2024-04-30', 2, 1, 1, 1),
       ('ES002', 78, '2024-04-30', 2, 2, 2, 2),
       ('ES003', 92, '2024-04-30', 2, 3, 3, 3),
       ('ES004', 80, '2024-04-30', 2, 4, 4, 4),
       ('ES005', 88, '2024-04-30', 2, 5, 5, 5),
       ('ES006', 79, '2024-04-30', 2, 6, 6, 6),
       ('ES007', 90, '2024-04-30', 2, 7, 7, 7),
       ('ES008', 82, '2024-04-30', 2, 8, 8, 8),
       ('ES009', 93, '2024-04-30', 2, 9, 9, 9),
       ('ES010', 87, '2024-04-30', 2, 10, 10, 10);

INSERT INTO rfid_tag (teacher_id, student_id)
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5),
       (6, 6),
       (7, 7),
       (8, 8),
       (9, 9),
       (10, 10);

INSERT INTO users (user_login, user_password, user_status, teacher_id, student_id)
VALUES ('admin', 'admin123', 3, null, null),
       ('teacher1', 'teacher123', 2, 1, null),
       ('teacher2', 'teacher123', 2, 2, null),
       ('teacher3', 'teacher123', 2, 3, null),
       ('teacher4', 'teacher123', 2, 4, null),
       ('teacher5', 'teacher123', 2, 5, null),
       ('student1', 'student123', 1, null, 1),
       ('student2', 'student123', 1, null, 2),
       ('student3', 'student123', 1, null, 3),
       ('student4', 'student123', 1, null, 4),
       ('student5', 'student123', 2, null, 5);



INSERT INTO test (test_number, test_name, discipline_id)
VALUES (1, 'Тест по алгебре', 1),
       (2, 'Тест по геометрии', 1),
       (3, 'Тест по высшей математике', 1),

       (1, 'Тест по механике', 2),
       (2, 'Тест по термодинамике', 2),
       (3, 'Тест по электродинамике', 2),

       (1, 'Тест по киевской Руси', 4),
       (2, 'Тест по Руси в эпоху феодальной раздробленности', 4),
       (3, 'Тест по Российскому государству в XVI веке', 4),

       (1, 'Тест по роману Преступление и наказание', 3),
       (2, 'Тест по роману Война и мир', 3),
       (3, 'Тест по роману Евгений Онегин', 3),

       (1, 'Тест по органической химии', 5),

       (1, 'Тест по клеточной биологии', 6),

       (1, 'Тест по геоморфологии', 7),

       (1, 'Тест по английскому языку', 8),

       (1, 'Тест по программированию', 9),

       (1, 'Тест по искусству Ренессанса', 10);

INSERT INTO question (question_text, test_id)
VALUES ('Что такое квадратный корень из 9?', 1),
       ('Что представляет собой система линейных уравнений?', 1),
       ('Какие методы факторизации многочленов вы можете использовать для нахождения корней квадратного трехчлена?', 1),
       ('Каково определение комплексных чисел, и какие особенности их умножения и деления?', 1),
       ('Что такое арифметическая прогрессия, и каковы формулы для нахождения ее общего члена и суммы n членов?', 1),

       ('Что такое периметр прямоугольника?', 2),
       ('Что такое диаметр окружности?', 2),
       ('Что такое площадь треугольника?', 2),
       ('Что такое радиус круга?', 2),
       ('Какая формула вычисления объема куба?', 2),

       ('Что такое производная функции?', 3),
       ('Какие бывают типы точек экстремума функции?', 3),
       ('Что такое интеграл функции?', 3),
       ('Какие методы численного интегрирования существуют?', 3),
       ('Что такое уравнение Эйлера для графа?', 3),

       ('Что такое закон сохранения энергии?', 4),
       ('Какие силы действуют на тело в системе отсчета, движущейся с постоянной скоростью?', 4),
       ('Что такое второй закон Ньютона?', 4),
       ('Что такое центр масс системы тел?', 4),
       ('Как называется закон, утверждающий, что каждое действие имеет равное и противоположное противодействие?', 4),

       ('Что такое первый закон термодинамики?', 5),
       ('Какая формула связывает изменение внутренней энергии системы с работой и теплом?', 5),
       ('Что такое энтропия?', 5),
       ('Какая формула связывает энтропию и тепловой поток?', 5),
       ('Что такое тепловая машина?', 5),

       ('Какое явление описывает закон Ома?', 6),
       ('Что такое электрический ток?', 6),
       ('Что такое магнитное поле?', 6),
       ('Какая формула описывает закон Фарадея?', 6),
       ('Что такое электромагнитная индукция?', 6),

       ('Кто основал город Киев?', 7),
       ('Когда было крещение киевских князей?', 7),
       ('Какую роль играло княжество Киевское в формировании Древнерусского государства?', 7),
       ('Что такое Правда Ярослава Мудрого?', 7),
       ('Какие земли входили в состав Киевской Руси наиболее расцвета ее времен?', 7),

       ('Что привело к раздроблению Руси в эпоху феодальной раздробленности?', 8),
       ('Как назывались независимые государства, возникшие в результате раздробления Руси?', 8),
       ('Какой период в истории Руси характеризовался борьбой за центральную власть между князьями и боярами?', 8),
       ('Кто был лидером в процессе объединения Руси в конце эпохи феодальной раздробленности?', 8),
       ('Какая битва положила конец эпохе феодальной раздробленности Руси?', 8),

       ('Кто был правителем России в начале 16 века?', 9),
       ('Что стало ключевым событием для России в 16 веке?', 9),
       ('Какие земли были присоединены к России в 16 веке?', 9),
       ('Кто был последним из правителей России в 16 веке?', 9),
       ('Какие реформы были введены в Российском государстве в этот период?', 9),

       ('Кто является главным героем романа "Преступление и наказание"?', 10),
       ('Как называется город, в котором происходят основные события романа?', 10),
       ('Как звали младшую сестру главного героя?', 10),
       ('Какое преступление совершил главный герой?', 10),
       ('Как звали девушку, в которую влюблен главный герой?', 10),

       ('Кто является автором романа "Война и мир"?', 11),
       ('В каком году начинаются события романа "Война и мир"?', 11),
       ('Какое событие послужило началом войны в романе?', 11),
       ('Как называется главный герой романа "Война и мир"?', 11),
       ('Как звали главную героиню романа?', 11),

       ('Кто является автором романа "Евгений Онегин"?', 12),
       ('Как звали главного героя романа?', 12),
       ('Как называется деревня, где жил Евгений Онегин?', 12),
       ('Как звали сестру главного героя?', 12),
       ('В кого был влюблен Татьяна Ларина?', 12),

       ('Как называется углеводород, состоящий из одного атома углерода и четырех атомов водорода?', 13),
       ('Что такое алкены в органической химии?', 13),
       ('Что такое алканы в органической химии?', 13),
       ('Что такое ароматические углеводороды?', 13),
       ('Что такое функциональная группа в органической химии?', 13),

       ('Что такое цитоплазма в клетке?', 14),
       ('Что такое митохондрии?', 14),
       ('Какая функция у эндоплазматического ретикулума?', 14),
       ('Что такое лизосомы?', 14),
       ('Что такое ядро клетки?', 14),

       ('Что такое геоморфология?', 15),
       ('Что изучает геоморфология?', 15),
       ('Что такое рельеф?', 15),
       ('Какие процессы формирования рельефа изучает геоморфология?', 15),
       ('Какие факторы влияют на формирование рельефа?', 15),

       ('Какая часть речи обозначает действие в предложении?', 16),
       ('Как переводится на английский язык слово "кот"?', 16),
       ('Как называется глагол во второй форме (Past Simple) от слова "go"?', 16),
       ('Какой правильный порядок слов в утвердительном предложении в Present Simple?', 16),
       ('Как переводится на английский язык фраза "Я говорю по-английски"?', 16),

       ('Что такое переменная в программировании?', 17),
       ('Что такое условный оператор в программировании?', 17),
       ('Что такое цикл в программировании?', 17),
       ('Что такое функция в программировании?', 17),
       ('Что такое массив в программировании?', 17),

       ('Что стало характерным чертой искусства Ренессанса?', 18),
       ('Кто известен как «отец искусства Ренессанса»?', 18),
       ('Какая техника была широко использована в живописи Ренессанса?', 18),
       ('Какой художественный прием характерен для произведений Леонардо да Винчи?', 18),
       ('Какой сюжет часто встречается в работах искусства Ренессанса?', 18);

INSERT INTO answer (answer_text, is_correct, question_id)
VALUES ('3', TRUE, 1),
       ('6', FALSE, 1),
       ('9', FALSE, 1),
       ('12', FALSE, 1),

       ('Набор уравнений с одной неизвестной', TRUE, 2),
       ('Система уравнений с квадратами', FALSE, 2),
       ('Набор произвольных уравнений', FALSE, 2),
       ('Набор уравнений, где все уравнения линейны', FALSE, 2),

       ('Метод разложения на множители и метод группировки', TRUE, 3),
       ('Метод замены переменных', FALSE, 3),
       ('Метод факторизации и метод квадратного уравнения', FALSE, 3),
       ('Метод линейных уравнений', FALSE, 3),

       ('Числа, в которых присутствует квадратный корень', TRUE, 4),
       ('Числа, содержащие дробную часть', FALSE, 4),
       ('Числа, в которых присутствует мнимая единица i', FALSE, 4),
       ('Числа, содержащие только целую часть', FALSE, 4),

       ('Последовательность, где каждый член увеличивается в два раза', TRUE, 5),
       ('Последовательность, где каждый следующий член умножается на предыдущий', FALSE, 5),
       ('Последовательность, где разница между соседними членами постоянна', FALSE, 5),
       ('Последовательность, где каждый член увеличивается на 1', FALSE, 5),

       ('Сумма всех сторон прямоугольника', TRUE, 6),
       ('Среднее арифметическое всех сторон прямоугольника', FALSE, 6),
       ('Площадь, ограниченная сторонами прямоугольника', FALSE, 6),
       ('Сумма всех углов прямоугольника', FALSE, 6),

       ('Длина от одного края окружности до противоположного через ее центр', TRUE, 7),
       ('Расстояние от центра окружности до любой точки на ее окружности', FALSE, 7),
       ('Длина окружности', FALSE, 7),
       ('Расстояние между двумя крайними точками окружности', FALSE, 7),
       ('Половина произведения основания и высоты треугольника', TRUE, 8),
       ('Сумма всех сторон треугольника', FALSE, 8),
       ('Сумма всех углов треугольника', FALSE, 8),
       ('Расстояние между основанием и вершиной треугольника', FALSE, 8),

       ('Расстояние от центра круга до его окружности', TRUE, 9),
       ('Диаметр окружности, деленный на 2', FALSE, 9),
       ('Сумма длин радиусов всех точек на окружности', FALSE, 9),
       ('Расстояние между двумя точками на окружности', FALSE, 9),

       ('a^3, где a - длина стороны куба', TRUE, 10),
       ('a^2, где a - длина стороны куба', FALSE, 10),
       ('a^3, где a - длина диагонали куба', FALSE, 10),
       ('a^2, где a - длина диагонали куба', FALSE, 10),

       ('Показатель изменения функции по отношению к ее аргументу', TRUE, 11),
       ('Показатель изменения функции по отношению к ее производной', FALSE, 11),
       ('Сумма всех значений функции', FALSE, 11),
       ('Случайная величина', FALSE, 11),

       ('Минимум, максимум, точка перегиба', TRUE, 12),
       ('Только минимум', FALSE, 12),
       ('Только максимум', FALSE, 12),
       ('Только точка перегиба', FALSE, 12),

       ('Обратная операция дифференцирования', TRUE, 13),
       ('Сумма всех значений функции', FALSE, 13),
       ('Произведение всех значений функции', FALSE, 13),
       ('Показатель изменения функции по отношению к ее аргументу', FALSE, 13),

       ('Метод прямоугольников, метод трапеций, метод Симпсона', TRUE, 14),
       ('Метод Эйлера, метод Рунге-Кутты', FALSE, 14),
       ('Метод Гаусса', FALSE, 14),

       ('Метод Ньютона', FALSE, 14),
       ('Сумма степеней вершин, инцидентных каждой вершине, равна нулю', TRUE, 15),
       ('Сумма степеней вершин, инцидентных каждой вершине, равна двойному числу рёбер', FALSE, 15),
       ('Произведение степеней всех вершин равно нулю', FALSE, 15),
       ('Сумма степеней всех вершин равна двойному числу рёбер', FALSE, 15),

       ('Сумма кинетической и потенциальной энергии в изолированной системе остается постоянной', TRUE, 16),
       ('Сила, приложенная к телу, равна произведению массы тела на его ускорение', FALSE, 16),
       ('Энергия, необходимая для подъема тела на определенную высоту', FALSE, 16),
       ('Сила трения, пропорциональная скорости тела', FALSE, 16),

       ('Силы инерции', TRUE, 17),
       ('Только сила тяжести', FALSE, 17),
       ('Только сила трения', FALSE, 17),
       ('Сумма всех сил', FALSE, 17),

       ('Ускорение тела пропорционально силе, действующей на него, и обратно пропорционально его массе', TRUE, 18),
       ('Сила, приложенная к телу, равна произведению массы тела на его ускорение', FALSE, 18),
       ('Сила трения пропорциональна массе тела', FALSE, 18),
       ('Сила трения пропорциональна квадрату скорости тела', FALSE, 18),

       ('Точка, в которой можно представить всю массу системы, как сосредоточенную', TRUE, 19),
       ('Точка, в которой сосредоточена вся масса тела', FALSE, 19),
       ('Точка, в которой сумма моментов всех сил равна нулю', FALSE, 19),
       ('Точка, в которой сумма всех сил равна нулю', FALSE, 19),

       ('Третий закон Ньютона', TRUE, 20),
       ('Закон всемирного тяготения', FALSE, 20),
       ('Закон Архимеда', FALSE, 20),
       ('Принцип относительности', FALSE, 20),

       ('Энергия не создается и не уничтожается, а только преобразуется из одной формы в другую', TRUE, 21),
       ('Энергия сохраняется только в замкнутых системах', FALSE, 21),
       ('Энергия создается только в открытых системах', FALSE, 21),
       ('Энергия не может быть преобразована в работу', FALSE, 21),

       ('ΔU = Q - W', TRUE, 22),
       ('ΔU = Q + W', FALSE, 22),
       ('ΔU = Q / W', FALSE, 22),
       ('ΔU = Q * W', FALSE, 22),

       ('Мера беспорядка в системе', TRUE, 23),
       ('Мера порядка в системе', FALSE, 23),
       ('Мера энергии в системе', FALSE, 23),
       ('Мера тепла в системе', FALSE, 23),

       ('ΔS = Q / T', TRUE, 24),
       ('ΔS = Q * T', FALSE, 24),
       ('ΔS = T / Q', FALSE, 24),
       ('ΔS = T - Q', FALSE, 24),

       ('Устройство, которое преобразует тепловую энергию в механическую работу', TRUE, 25),
       ('Устройство, которое преобразует механическую работу в тепловую энергию', FALSE, 25),
       ('Устройство, которое преобразует тепловую энергию в химическую энергию', FALSE, 25),
       ('Устройство, которое преобразует энергию вращения в тепловую энергию', FALSE, 25),

       ('Связь между напряжением, силой тока и сопротивлением в электрической цепи', TRUE, 26),
       ('Связь между зарядом и напряженностью электрического поля', FALSE, 26),
       ('Связь между зарядом и индукцией магнитного поля', FALSE, 26),
       ('Связь между электрическим полем и силой тока', FALSE, 26),

       ('Поток заряженных частиц через поперечное сечение проводника за единицу времени', TRUE, 27),
       ('Сила, с которой электрический заряд движется в электрическом поле', FALSE, 27),
       ('Потенциальная разность между двумя точками в электрической цепи', FALSE, 27),
       ('Сила, с которой электрический заряд движется в магнитном поле', FALSE, 27),

       ('Пространство, в котором оказывается сила на движущиеся заряды', TRUE, 28),
       ('Пространство, в котором оказывается сила на неподвижные заряды', FALSE, 28),
       ('Сумма всех электрических полей в системе', FALSE, 28),
       ('Сумма всех электрических зарядов в системе', FALSE, 28),

       ('ε = -d(Ф) / dt', TRUE, 29),
       ('ε = -Ф * dt', FALSE, 29),
       ('ε = d(Ф) * dt', FALSE, 29),
       ('ε = Ф / dt', FALSE, 29),

       ('Явление возникновения электрического тока в проводнике под действием изменяющегося магнитного поля', TRUE, 30),
       ('Явление возникновения магнитного поля в проводнике под действием изменяющегося электрического поля', FALSE,
        30),
       ('Явление возникновения магнитного поля в проводнике под действием постоянного электрического поля', FALSE, 30),
       ('Явление возникновения электрического поля в проводнике под действием постоянного магнитного поля', FALSE, 30),

       ('Князь Кий', TRUE, 31),
       ('Князь Владимир', FALSE, 31),
       ('Князь Олег', FALSE, 31),
       ('Князь Ярослав', FALSE, 31),

       ('В 988 году', TRUE, 32),
       ('В 1054 году', FALSE, 32),
       ('В 1037 году', FALSE, 32),
       ('В 1015 году', FALSE, 32),

       ('Играло центральную роль в объединении славянских племен', TRUE, 33),
       ('Играло роль торгового центра', FALSE, 33),
       ('Играло роль в формировании монархической системы правления', FALSE, 33),
       ('Играло роль в распространении христианства на территории Руси', FALSE, 33),

       ('Первая писанная русская законодательная редакция', TRUE, 34),
       ('Правила поведения во времена князя Ярослава', FALSE, 34),
       ('Сборник летописей о Киевской Руси', FALSE, 34),
       ('Документ, регулирующий отношения с соседними государствами', FALSE, 34),

       ('Восточная Европа, от Балтийского до Черного моря', TRUE, 35),
       ('Только территория нынешней Украины', FALSE, 35),
       ('Только территория нынешней России', FALSE, 35),
       ('Вся Европа', FALSE, 35),

       ('Смерть князя Ярослава Мудрого и последующий распад центральной власти', TRUE, 36),
       ('Монгольское нашествие', FALSE, 36),
       ('Религиозные конфликты', FALSE, 36),
       ('Торговые споры', FALSE, 36),

       ('Княжества', TRUE, 37),
       ('Уезды', FALSE, 37),
       ('Графства', FALSE, 37),
       ('Области', FALSE, 37),

       ('Период Смутного времени', TRUE, 38),
       ('Период Монгольского нашествия', FALSE, 38),
       ('Период правления Ивана Грозного', FALSE, 38),
       ('Период Великой Отечественной войны', FALSE, 38),

       ('Московский князь', TRUE, 39),
       ('Новгородский князь', FALSE, 39),
       ('Киевский князь', FALSE, 39),
       ('Смоленский князь', FALSE, 39),

       ('Куликовская битва', TRUE, 40),
       ('Битва на Игре', FALSE, 40),
       ('Битва на Калке', FALSE, 40),
       ('Полтавская битва', FALSE, 40),

       ('Иван III (Иван Грозный)', TRUE, 41),
       ('Петр I', FALSE, 41),
       ('Александр Невский', FALSE, 41),
       ('Дмитрий Донской', FALSE, 41),

       ('Завершение процесса освобождения от татаро-монгольского ига', TRUE, 42),
       ('Основание Московского университета', FALSE, 42),
       ('Строительство Эрмитажа', FALSE, 42),
       ('Открытие морского пути в Индию', FALSE, 42),

       ('Казань, Астрахань', TRUE, 43),
       ('Крым', FALSE, 43),
       ('Сибирь', FALSE, 43),
       ('Кавказ', FALSE, 43),

       ('Иван IV (Иван Грозный)', TRUE, 44),
       ('Петр I', FALSE, 44),
       ('Алексей Михайлович', FALSE, 44),
       ('Феодор I', FALSE, 44),

       ('Опричнина, реформа административно-территориального деления, кодекс законов - Судебник', TRUE, 45),
       ('Реформы Петра I, включая введение губерний и обновление армии', FALSE, 45),
       ('Строительство Петропавловской крепости', FALSE, 45),
       ('Проведение Пугачевского восстания', FALSE, 45),

       ('Родион Раскольников', TRUE, 46),
       ('Соня Мармеладова', FALSE, 46),
       ('Дмитрий Прокофьич', FALSE, 46),
       ('Александр Лужин', FALSE, 46),

       ('Санкт-Петербург', TRUE, 47),
       ('Москва', FALSE, 47),
       ('Париж', FALSE, 47),
       ('Лондон', FALSE, 47),

       ('Дуня', TRUE, 48),
       ('Соня', FALSE, 48),
       ('Пульхерия', FALSE, 48),
       ('Алена Ивановна', FALSE, 48),

       ('Убийство старухи-процентщицы', TRUE, 49),
       ('Грабеж банка', FALSE, 49),
       ('Поджог жилого дома', FALSE, 49),
       ('Хищение денег', FALSE, 49),

       ('Соня Мармеладова', TRUE, 50),
       ('Алена Ивановна', FALSE, 50),
       ('Дуня', FALSE, 50),
       ('Авдотья Романовна', FALSE, 50),

       ('Лев Толстой', TRUE, 51),
       ('Федор Достоевский', FALSE, 51),
       ('Иван Тургенев', FALSE, 51),
       ('Александр Пушкин', FALSE, 51),

       ('1805 год', TRUE, 52),
       ('1812 год', FALSE, 52),
       ('1855 год', FALSE, 52),
       ('1905 год', FALSE, 52),

       ('Наполеоновская война', TRUE, 53),
       ('Война России с Турцией', FALSE, 53),
       ('Революция', FALSE, 53),
       ('Борьба за независимость', FALSE, 53),

       ('Пьер Безухов', TRUE, 54),
       ('Андрей Болконский', FALSE, 54),
       ('Наташа Ростова', FALSE, 54),
       ('Николай Ростов', FALSE, 54),

       ('Наташа Ростова', TRUE, 55),
       ('Соня Мармеладова', FALSE, 55),
       ('Анна Каренина', FALSE, 55),
       ('Марья Болконская', FALSE, 55),

       ('Александр Пушкин', TRUE, 56),
       ('Лев Толстой', FALSE, 56),
       ('Федор Достоевский', FALSE, 56),
       ('Николай Гоголь', FALSE, 56),

       ('Евгений Онегин', TRUE, 57),
       ('Иван Грозный', FALSE, 57),
       ('Дмитрий Прокофьич', FALSE, 57),
       ('Петр Великий', FALSE, 57),

       ('Онегино', TRUE, 58),
       ('Татариново', FALSE, 58),
       ('Ларино', FALSE, 58),
       ('Петровское', FALSE, 58),

       ('Ольга Ларина', TRUE, 59),
       ('Татьяна Ларина', FALSE, 59),
       ('Анна Каренина', FALSE, 59),
       ('Марья Болконская', FALSE, 59),

       ('В Онегина', TRUE, 60),
       ('В Петра', FALSE, 60),
       ('В Ленского', FALSE, 60),
       ('В Григория', FALSE, 60),

       ('Метан', TRUE, 61),
       ('Этан', FALSE, 61),
       ('Пропан', FALSE, 61),
       ('Бутан', FALSE, 61),

       ('Ненасыщенные углеводороды, содержащие две углерод-углеродные двойные связи', TRUE, 62),
       ('Насыщенные углеводороды, содержащие только одиночные связи', FALSE, 62),
       ('Углеводороды, содержащие атомы кислорода', FALSE, 62),
       ('Углеводороды, содержащие атомы азота', FALSE, 62),

       ('Насыщенные углеводороды, содержащие только одиночные связи', TRUE, 63),
       ('Ненасыщенные углеводороды, содержащие две углерод-углеродные двойные связи', FALSE, 63),
       ('Углеводороды, содержащие атомы кислорода', FALSE, 63),
       ('Углеводороды, содержащие атомы азота', FALSE, 63),

       ('Углеводороды, содержащие ароматическое ядро, обычно кольцо из шести атомов углерода', TRUE, 64),
       ('Насыщенные углеводороды, содержащие только одиночные связи', FALSE, 64),
       ('Ненасыщенные углеводороды, содержащие две углерод-углеродные двойные связи', FALSE, 64),
       ('Углеводороды, содержащие атомы кислорода', FALSE, 64),

       ('Группа атомов, определяющая основные свойства и реакции органических соединений', TRUE, 65),
       ('Группа атомов, не влияющая на свойства органических соединений', FALSE, 65),
       ('Группа атомов, определяющая только физические свойства органических соединений', FALSE, 65),
       ('Группа атомов, определяющая только химические свойства органических соединений', FALSE, 65),

       ('Гелеподобное вещество внутри клетки, где располагаются органоиды и включения', TRUE, 66),
       ('Мембранная оболочка, разделяющая клетку на внутреннюю и внешнюю среду', FALSE, 66),
       ('Ядро клетки, где происходит синтез белков', FALSE, 66),
       ('Вещество, обеспечивающее жесткость и форму клетки', FALSE, 66),

       ('Органоиды клетки, ответственные за процесс аэробного дыхания и выработку энергии', TRUE, 67),
       ('Органоиды клетки, ответственные за синтез белков', FALSE, 67),
       ('Вещества, участвующие в делении клетки', FALSE, 67),
       ('Вещества, разрушающие старые и поврежденные клеточные компоненты', FALSE, 67),

       ('Синтез и транспорт белков', TRUE, 68),
       ('Разрушение старых и поврежденных клеточных компонентов', FALSE, 68),
       ('Хранение и переработка веществ', FALSE, 68),
       ('Аэробное дыхание и выработка энергии', FALSE, 68),

       ('Органоиды, содержащие ферменты для переваривания старых органелл', TRUE, 69),
       ('Мембраны, разделяющие клетку на внутренние отделы', FALSE, 69),
       ('Вещества, обеспечивающие жесткость и форму клетки', FALSE, 69),
       ('Мембраны, ответственные за транспорт веществ через клеточную мембрану', FALSE, 69),

       ('Центральный органоид, содержащий генетический материал и управляющий жизнедеятельностью клетки', TRUE, 70),
       ('Органоиды, ответственные за процесс аэробного дыхания и выработку энергии', FALSE, 70),
       ('Органоиды, ответственные за синтез белков', FALSE, 70),
       ('Органоиды, содержащие ферменты для переваривания старых органелл', FALSE, 70),

       ('Наука о формах рельефа и процессах их образования', TRUE, 71),
       ('Наука о водных системах Земли', FALSE, 71),
       ('Наука о составе минералов', FALSE, 71),
       ('Наука о климате', FALSE, 71),

       ('Формы рельефа и процессы, которые их формируют', TRUE, 72),
       ('Живые организмы и их взаимодействие с окружающей средой', FALSE, 72),
       ('Гидросфера и атмосфера', FALSE, 72),
       ('Состав и строение земной коры', FALSE, 72),

       ('Формы рельефа, характеризующие изменения высоты земной поверхности', TRUE, 73),
       ('Водные и атмосферные явления', FALSE, 73),
       ('Самые высокие горные вершины', FALSE, 73),
       ('Коренные породы Земли', FALSE, 73),

       ('Эрозионные, тектонические, агляционные, абразионные', TRUE, 74),
       ('Биологические и антропогенные', FALSE, 74),
       ('Магматические и метаморфические', FALSE, 74),
       ('Гидрологические и метеорологические', FALSE, 74),

       ('Климат, геологические процессы, растительный покров, деятельность человека', TRUE, 75),
       ('Только растительный покров', FALSE, 75),
       ('Только деятельность человека', FALSE, 75),
       ('Только геологические процессы', FALSE, 75),

       ('Глагол', TRUE, 76),
       ('Существительное', FALSE, 76),
       ('Прилагательное', FALSE, 76),
       ('Наречие', FALSE, 76),

       ('Cat', TRUE, 77),
       ('Dog', FALSE, 77),
       ('Mouse', FALSE, 77),
       ('Bird', FALSE, 77),

       ('Went', TRUE, 78),
       ('Goed', FALSE, 78),
       ('Gone', FALSE, 78),
       ('Going', FALSE, 78),

       ('Подлежащее, сказуемое, дополнение', TRUE, 79),
       ('Сказуемое, подлежащее, дополнение', FALSE, 79),
       ('Дополнение, подлежащее, сказуемое', FALSE, 79),
       ('Подлежащее, дополнение, сказуемое', FALSE, 79),

       ('I speak English', TRUE, 80),
       ('I talk Russian', FALSE, 80),
       ('I understand French', FALSE, 80),
       ('I read German', FALSE, 80),

       ('Переменная - это символическое имя, связанное с некоторым значением или объектом, которое может изменяться в процессе выполнения программы',
        TRUE, 81),
       ('Переменная - это оператор для управления потоком выполнения программы', FALSE, 81),
       ('Переменная - это условие, по которому принимается решение в программе', FALSE, 81),
       ('Переменная - это циклическая конструкция в программе', FALSE, 81),

       ('Условный оператор - это конструкция в программировании, которая выполняет определенный блок кода при выполнении определенного условия',
        TRUE, 82),
       ('Условный оператор - это конструкция в программировании, которая выполняет определенный блок кода не зависимо от условий',
        FALSE, 82),
       ('Условный оператор - это конструкция в программировании, которая повторяет определенный блок кода определенное количество раз',
        FALSE, 82),
       ('Условный оператор - это конструкция в программировании, которая вызывает функцию', FALSE, 82),

       ('Цикл - это конструкция в программировании, позволяющая выполнять определенный блок кода несколько раз', TRUE,
        83),
       ('Цикл - это конструкция в программировании, которая выполняет определенный блок кода при выполнении определенного условия',
        FALSE, 83),
       ('Цикл - это конструкция в программировании, которая выполняет определенный блок кода не зависимо от условий',
        FALSE, 83),
       ('Цикл - это конструкция в программировании, которая вызывает функцию', FALSE, 83),

       ('Функция - это набор инструкций, которые выполняют определенную задачу и могут быть вызваны из других частей программы',
        TRUE, 84),
       ('Функция - это переменная, содержащая данные', FALSE, 84),
       ('Функция - это условный оператор', FALSE, 84),
       ('Функция - это цикл', FALSE, 84),

       ('Массив - это структура данных, которая хранит набор элементов одного типа, доступ к которым осуществляется по индексу',
        TRUE, 85),
       ('Массив - это функция, возвращающая случайное число', FALSE, 85),
       ('Массив - это условный оператор', FALSE, 85),
       ('Массив - это цикл', FALSE, 85),

       ('Возрождение интереса к античной культуре, гармония форм и пропорций', TRUE, 86),
       ('Использование ярких красок и контрастных цветов', FALSE, 86),
       ('Абстрактные формы и символизм', FALSE, 86),
       ('Отказ от изображения человека в произведениях искусства', FALSE, 86),

       ('Гиотто', TRUE, 87),
       ('Микеланджело', FALSE, 87),
       ('Леонардо да Винчи', FALSE, 87),
       ('Донателло', FALSE, 87),

       ('Масляная живопись', TRUE, 88),
       ('Фреска', FALSE, 88),
       ('Акварель', FALSE, 88),
       ('Графика', FALSE, 88),

       ('Сфумато - плавное переходы от одного тона к другому без резких контуров', TRUE, 89),
       ('Хиароскуро - игра света и тени', FALSE, 89),
       ('Использование ярких контрастных цветов', FALSE, 89),
       ('Абстракция и символизм', FALSE, 89),

       ('Библейские сюжеты, мифология, портреты', TRUE, 90),
       ('Геометрические абстракции', FALSE, 90),
       ('Сюжеты из средневековых рыцарских романов', FALSE, 90),
       ('Пейзажи и натюрморты', FALSE, 90);

INSERT INTO attempt (attempt_number, attempt_datetime, attempt_result, test_id, student_id)
VALUES (1, '2024-04-05 14:30:00', 56, 4, 1),
       (2, '2024-04-12 08:45:00', 30, 4, 1),
       (3, '2024-04-18 11:20:00', 91, 4, 1),
       (1, '2024-04-20 16:55:00', 56, 5, 1),
       (1, '2024-04-07 09:10:00', 31, 1, 2),
       (2, '2024-04-29 13:25:00', 76, 1, 2),
       (1, '2024-04-14 17:40:00', 24, 2, 2),
       (2, '2024-04-03 10:15:00', 89, 2, 2),
       (1, '2024-04-26 12:30:00', 58, 13, 3),
       (1, '2024-04-08 15:50:00', 21, 17, 3),
       (1, '2024-04-22 07:05:00', 54, 16, 3),
       (1, '2024-04-09 18:25:00', 74, 15, 3),
       (1, '2024-04-15 20:40:00', 36, 7, 4),
       (2, '2024-04-27 11:00:00', 97, 7, 4),
       (1, '2024-04-16 22:15:00', 80, 8, 4),
       (1, '2024-04-11 09:35:00', 45, 9, 4),
       (1, '2024-04-19 14:55:00', 96, 10, 5),
       (1, '2024-04-02 08:20:00', 91, 11, 5),
       (1, '2024-04-25 16:10:00', 40, 12, 5),
       (2, '2024-04-28 19:45:00', 87, 12, 5);

INSERT INTO test_result (result_per_question, answer_id, attempt_id)
VALUES (100, 1, 1),
       (75, 2, 1),
       (50, 3, 1),
       (25, 4, 1),
       (80, 5, 2),
       (60, 6, 2),
       (40, 7, 2),
       (20, 8, 2),
       (90, 9, 3),
       (70, 10, 3),
       (50, 11, 3),
       (30, 12, 3),
       (75, 13, 4),
       (55, 14, 4),
       (35, 15, 4),
       (15, 16, 4),
       (85, 17, 5),
       (65, 18, 5),
       (45, 19, 5),
       (25, 20, 5),
       (80, 21, 6),
       (60, 22, 6),
       (40, 23, 6),
       (20, 24, 6),
       (70, 25, 7),
       (50, 26, 7),
       (30, 27, 7),
       (10, 28, 7),
       (90, 29, 8),
       (70, 30, 8),
       (50, 31, 8),
       (30, 32, 8),
       (75, 33, 9),
       (55, 34, 9),
       (35, 35, 9),
       (15, 36, 9),
       (85, 37, 10);
