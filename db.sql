CREATE DATABASE tubes;

-- =============================================
-- 1. USER ACCOUNT (gabungan student + instructor)
-- =============================================

CREATE TABLE user_account (
    user_id SERIAL PRIMARY KEY,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student','instructor')),
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    region VARCHAR(100),            -- only for student
    highest_education VARCHAR(100), -- only for student
    disability BOOLEAN,             -- only for student
    department VARCHAR(100)         -- only for instructor
);

-- ==================================================
-- 2. COURSE MODULE
-- ==================================================
CREATE TABLE course_module (
    module_id SERIAL PRIMARY KEY,
    module_code VARCHAR(20) UNIQUE NOT NULL,
    module_name VARCHAR(100) NOT NULL,
    level INT NOT NULL,
    credits INT NOT NULL
);

-- ==================================================
-- 3. PRESENTATION (Semester / Session)
-- ==================================================
CREATE TABLE presentation (
    presentation_id SERIAL PRIMARY KEY,
    module_id INT NOT NULL REFERENCES course_module(module_id),
    instructor_id INT NOT NULL REFERENCES user_account(user_id),
    semester VARCHAR(50) NOT NULL,
    year INT NOT NULL
);

-- ==================================================
-- 4. ENROLLMENT (mahasiswa ke kelas)
-- ==================================================
CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES user_account(user_id),
    presentation_id INT NOT NULL REFERENCES presentation(presentation_id),
    final_result VARCHAR(50) NOT NULL,
    studied_credits INT NOT NULL
);

-- ==================================================
-- 5. ASSESSMENT
-- ==================================================
CREATE TABLE assessment (
    assessment_id SERIAL PRIMARY KEY,
    presentation_id INT NOT NULL REFERENCES presentation(presentation_id),
    assessment_name VARCHAR(100) NOT NULL,
    weight INT NOT NULL
);

-- ==================================================
-- 6. STUDENT ASSESSMENT
-- ==================================================
CREATE TABLE student_assessment (
    student_assessment_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL REFERENCES enrollment(enrollment_id),
    assessment_id INT NOT NULL REFERENCES assessment(assessment_id),
    score INT NOT NULL
);

-- ==================================================
-- 7. VLE ITEM
-- ==================================================
CREATE TABLE vle_item (
    vle_id SERIAL PRIMARY KEY,
    presentation_id INT NOT NULL REFERENCES presentation(presentation_id),
    vle_type VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL
);

-- ==================================================
-- 8. STUDENT VLE ACTIVITY
-- ==================================================
CREATE TABLE student_vle_activity (
    activity_id SERIAL PRIMARY KEY,
    enrollment_id INT NOT NULL REFERENCES enrollment(enrollment_id),
    vle_id INT NOT NULL REFERENCES vle_item(vle_id),
    clicks INT NOT NULL,
    activity_date DATE NOT NULL
);

-- A. INSTRUCTORS (Dummy - karena tidak ada di dataset asli)
INSERT INTO user_account (user_id, role, username, email, name, date_of_birth, gender, region, highest_education, disability, department) VALUES 
(1, 'instructor', 'inst_01', 'inst01@univ.ac.id', 'Prof. John Smith', '1975-03-12', 'M', NULL, NULL, NULL, 'Science'),
(2, 'instructor', 'inst_02', 'inst02@univ.ac.id', 'Dr. Sarah Jones', '1980-07-22', 'F', NULL, NULL, NULL, 'Maths'),
(3, 'instructor', 'inst_03', 'inst03@univ.ac.id', 'Prof. Alan Turing', '1978-11-05', 'M', NULL, NULL, NULL, 'Computing'),
(4, 'instructor', 'inst_04', 'inst04@univ.ac.id', 'Dr. Emily White', '1982-01-30', 'F', NULL, NULL, NULL, 'Psychology'),
(5, 'instructor', 'inst_05', 'inst05@univ.ac.id', 'Dr. Robert Brown', '1979-05-14', 'M', NULL, NULL, NULL, 'Social Science');

-- B. STUDENTS (Real Data from studentInfo.csv - Sampled diverse regions/genders)
INSERT INTO user_account (user_id, role, username, email, name, date_of_birth, gender, region, highest_education, disability) VALUES
(6, 'student', 'std_11391', '11391@student.univ.ac.id', 'Student 11391', '1995-01-01', 'M', 'East Anglian Region', 'HE Qualification', FALSE),
(7, 'student', 'std_28400', '28400@student.univ.ac.id', 'Student 28400', '1996-05-12', 'F', 'Scotland', 'HE Qualification', FALSE),
(8, 'student', 'std_30268', '30268@student.univ.ac.id', 'Student 30268', '1994-08-23', 'F', 'North Western Region', 'A Level or Equivalent', TRUE),
(9, 'student', 'std_31604', '31604@student.univ.ac.id', 'Student 31604', '1995-11-02', 'F', 'South East Region', 'A Level or Equivalent', FALSE),
(10, 'student', 'std_32885', '32885@student.univ.ac.id', 'Student 32885', '1997-02-14', 'F', 'West Midlands Region', 'Lower Than A Level', FALSE),
(11, 'student', 'std_38053', '38053@student.univ.ac.id', 'Student 38053', '1993-04-18', 'M', 'Wales', 'A Level or Equivalent', FALSE),
(12, 'student', 'std_45462', '45462@student.univ.ac.id', 'Student 45462', '1995-09-30', 'M', 'Scotland', 'HE Qualification', FALSE),
(13, 'student', 'std_45642', '45642@student.univ.ac.id', 'Student 45642', '1996-12-05', 'F', 'North Western Region', 'A Level or Equivalent', FALSE),
(14, 'student', 'std_52130', '52130@student.univ.ac.id', 'Student 52130', '1994-03-22', 'F', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(15, 'student', 'std_53025', '53025@student.univ.ac.id', 'Student 53025', '1998-07-07', 'M', 'North Region', 'Post Graduate Qualification', FALSE),
(16, 'student', 'std_57506', '57506@student.univ.ac.id', 'Student 57506', '1995-06-15', 'M', 'South Region', 'A Level or Equivalent', FALSE),
(17, 'student', 'std_62858', '62858@student.univ.ac.id', 'Student 62858', '1994-10-10', 'F', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(18, 'student', 'std_65002', '65002@student.univ.ac.id', 'Student 65002', '1996-01-25', 'F', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(19, 'student', 'std_70464', '70464@student.univ.ac.id', 'Student 70464', '1997-08-08', 'F', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(20, 'student', 'std_71361', '71361@student.univ.ac.id', 'Student 71361', '1993-11-19', 'M', 'Ireland', 'HE Qualification', FALSE),
(21, 'student', 'std_74372', '74372@student.univ.ac.id', 'Student 74372', '1995-02-28', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(22, 'student', 'std_75091', '75091@student.univ.ac.id', 'Student 75091', '1996-04-04', 'M', 'South West Region', 'A Level or Equivalent', FALSE),
(23, 'student', 'std_77363', '77363@student.univ.ac.id', 'Student 77363', '1994-09-09', 'M', 'East Midlands Region', 'A Level or Equivalent', FALSE),
(24, 'student', 'std_77736', '77736@student.univ.ac.id', 'Student 77736', '1998-12-12', 'F', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(25, 'student', 'std_78400', '78400@student.univ.ac.id', 'Student 78400', '1995-03-03', 'M', 'Yorkshire Region', 'Post Graduate Qualification', FALSE),
(26, 'student', 'std_84529', '84529@student.univ.ac.id', 'Student 84529', '1996-07-17', 'M', 'South Region', 'A Level or Equivalent', FALSE),
(27, 'student', 'std_85249', '85249@student.univ.ac.id', 'Student 85249', '1994-05-25', 'M', 'South West Region', 'A Level or Equivalent', FALSE),
(28, 'student', 'std_85514', '85514@student.univ.ac.id', 'Student 85514', '1997-10-31', 'M', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(29, 'student', 'std_92425', '92425@student.univ.ac.id', 'Student 92425', '1993-01-15', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(30, 'student', 'std_92437', '92437@student.univ.ac.id', 'Student 92437', '1995-06-20', 'F', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(31, 'student', 'std_92557', '92557@student.univ.ac.id', 'Student 92557', '1996-11-28', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(32, 'student', 'std_92819', '92819@student.univ.ac.id', 'Student 92819', '1994-02-10', 'M', 'East Midlands Region', 'Lower Than A Level', FALSE),
(33, 'student', 'std_94961', '94961@student.univ.ac.id', 'Student 94961', '1998-05-05', 'M', 'South Region', 'Lower Than A Level', FALSE),
(34, 'student', 'std_98725', '98725@student.univ.ac.id', 'Student 98725', '1995-08-18', 'F', 'North Western Region', 'HE Qualification', FALSE),
(35, 'student', 'std_101751', '101751@student.univ.ac.id', 'Student 101751', '1993-12-25', 'M', 'South Region', 'Lower Than A Level', FALSE),
(36, 'student', 'std_102506', '102506@student.univ.ac.id', 'Student 102506', '1996-03-30', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(37, 'student', 'std_102952', '102952@student.univ.ac.id', 'Student 102952', '1994-09-14', 'M', 'London Region', 'HE Qualification', FALSE),
(38, 'student', 'std_104476', '104476@student.univ.ac.id', 'Student 104476', '1997-01-08', 'M', 'Ireland', 'Post Graduate Qualification', FALSE),
(39, 'student', 'std_106247', '106247@student.univ.ac.id', 'Student 106247', '1995-04-22', 'M', 'South Region', 'HE Qualification', FALSE),
(40, 'student', 'std_106577', '106577@student.univ.ac.id', 'Student 106577', '1993-07-11', 'M', 'East Anglian Region', 'Lower Than A Level', FALSE),
(41, 'student', 'std_110157', '110157@student.univ.ac.id', 'Student 110157', '1996-10-24', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(42, 'student', 'std_111717', '111717@student.univ.ac.id', 'Student 111717', '1994-12-02', 'F', 'East Anglian Region', 'HE Qualification', FALSE),
(43, 'student', 'std_113295', '113295@student.univ.ac.id', 'Student 113295', '1998-06-18', 'M', 'East Anglian Region', 'Post Graduate Qualification', FALSE),
(44, 'student', 'std_114017', '114017@student.univ.ac.id', 'Student 114017', '1995-09-09', 'F', 'North Region', 'Post Graduate Qualification', FALSE),
(45, 'student', 'std_114999', '114999@student.univ.ac.id', 'Student 114999', '1993-02-15', 'F', 'North Western Region', 'HE Qualification', FALSE),
(46, 'student', 'std_115502', '115502@student.univ.ac.id', 'Student 115502', '1996-05-30', 'M', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(47, 'student', 'std_116663', '116663@student.univ.ac.id', 'Student 116663', '1994-08-04', 'M', 'East Anglian Region', 'HE Qualification', FALSE),
(48, 'student', 'std_117071', '117071@student.univ.ac.id', 'Student 117071', '1997-11-20', 'M', 'North Western Region', 'A Level or Equivalent', FALSE),
(49, 'student', 'std_120688', '120688@student.univ.ac.id', 'Student 120688', '1995-01-29', 'M', 'East Anglian Region', 'HE Qualification', FALSE),
(50, 'student', 'std_125005', '125005@student.univ.ac.id', 'Student 125005', '1993-04-12', 'M', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(51, 'student', 'std_126388', '126388@student.univ.ac.id', 'Student 126388', '1996-07-26', 'M', 'North Region', 'HE Qualification', FALSE),
(52, 'student', 'std_126848', '126848@student.univ.ac.id', 'Student 126848', '1994-10-08', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(53, 'student', 'std_127051', '127051@student.univ.ac.id', 'Student 127051', '1998-03-01', 'F', 'Wales', 'A Level or Equivalent', FALSE),
(54, 'student', 'std_129426', '129426@student.univ.ac.id', 'Student 129426', '1995-06-16', 'M', 'North Region', 'Post Graduate Qualification', FALSE),
(55, 'student', 'std_129955', '129955@student.univ.ac.id', 'Student 129955', '1993-09-28', 'M', 'West Midlands Region', 'A Level or Equivalent', TRUE),
(56, 'student', 'std_130509', '130509@student.univ.ac.id', 'Student 130509', '1996-01-05', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(57, 'student', 'std_132209', '132209@student.univ.ac.id', 'Student 132209', '1994-04-19', 'F', 'North Western Region', 'A Level or Equivalent', FALSE),
(58, 'student', 'std_132338', '132338@student.univ.ac.id', 'Student 132338', '1997-07-31', 'M', 'Scotland', 'HE Qualification', FALSE),
(59, 'student', 'std_132533', '132533@student.univ.ac.id', 'Student 132533', '1995-11-15', 'M', 'North Western Region', 'HE Qualification', FALSE),
(60, 'student', 'std_132556', '132556@student.univ.ac.id', 'Student 132556', '1993-02-27', 'M', 'West Midlands Region', 'Lower Than A Level', FALSE),
(61, 'student', 'std_132808', '132808@student.univ.ac.id', 'Student 132808', '1996-06-11', 'M', 'South Region', 'A Level or Equivalent', FALSE),
(62, 'student', 'std_133857', '133857@student.univ.ac.id', 'Student 133857', '1994-09-23', 'M', 'North Western Region', 'HE Qualification', FALSE),
(63, 'student', 'std_135086', '135086@student.univ.ac.id', 'Student 135086', '1998-01-04', 'F', 'North Western Region', 'Lower Than A Level', FALSE),
(64, 'student', 'std_135335', '135335@student.univ.ac.id', 'Student 135335', '1995-04-17', 'M', 'East Anglian Region', 'Lower Than A Level', FALSE),
(65, 'student', 'std_135400', '135400@student.univ.ac.id', 'Student 135400', '1993-07-29', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(66, 'student', 'std_135969', '135969@student.univ.ac.id', 'Student 135969', '1996-11-09', 'F', 'North Western Region', 'A Level or Equivalent', FALSE),
(67, 'student', 'std_137785', '137785@student.univ.ac.id', 'Student 137785', '1994-02-21', 'M', 'North Western Region', 'HE Qualification', FALSE),
(68, 'student', 'std_140939', '140939@student.univ.ac.id', 'Student 140939', '1997-06-03', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(69, 'student', 'std_141355', '141355@student.univ.ac.id', 'Student 141355', '1995-09-15', 'M', 'South West Region', 'A Level or Equivalent', FALSE),
(70, 'student', 'std_141377', '141377@student.univ.ac.id', 'Student 141377', '1993-12-28', 'M', 'South West Region', 'A Level or Equivalent', FALSE),
(71, 'student', 'std_142337', '142337@student.univ.ac.id', 'Student 142337', '1996-03-10', 'F', 'South East Region', 'A Level or Equivalent', FALSE),
(72, 'student', 'std_143899', '143899@student.univ.ac.id', 'Student 143899', '1994-06-22', 'M', 'Scotland', 'HE Qualification', FALSE),
(73, 'student', 'std_145114', '145114@student.univ.ac.id', 'Student 145114', '1998-10-04', 'F', 'North Western Region', 'Lower Than A Level', FALSE),
(74, 'student', 'std_146100', '146100@student.univ.ac.id', 'Student 146100', '1995-01-16', 'M', 'North Region', 'A Level or Equivalent', FALSE),
(75, 'student', 'std_146188', '146188@student.univ.ac.id', 'Student 146188', '1993-04-29', 'F', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(76, 'student', 'std_146224', '146224@student.univ.ac.id', 'Student 146224', '1996-08-11', 'M', 'North Region', 'A Level or Equivalent', FALSE),
(77, 'student', 'std_147876', '147876@student.univ.ac.id', 'Student 147876', '1994-11-23', 'F', 'North Western Region', 'A Level or Equivalent', FALSE),
(78, 'student', 'std_148383', '148383@student.univ.ac.id', 'Student 148383', '1997-03-05', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(79, 'student', 'std_148993', '148993@student.univ.ac.id', 'Student 148993', '1995-06-17', 'F', 'East Anglian Region', 'Lower Than A Level', FALSE),
(80, 'student', 'std_149206', '149206@student.univ.ac.id', 'Student 149206', '1993-09-30', 'F', 'North Western Region', 'Lower Than A Level', FALSE),
(81, 'student', 'std_149594', '149594@student.univ.ac.id', 'Student 149594', '1996-01-12', 'M', 'South Region', 'HE Qualification', FALSE),
(82, 'student', 'std_151241', '151241@student.univ.ac.id', 'Student 151241', '1994-04-26', 'M', 'East Anglian Region', 'HE Qualification', FALSE),
(83, 'student', 'std_151944', '151944@student.univ.ac.id', 'Student 151944', '1998-08-08', 'F', 'North Western Region', 'A Level or Equivalent', FALSE),
(84, 'student', 'std_152154', '152154@student.univ.ac.id', 'Student 152154', '1995-11-20', 'M', 'Ireland', 'HE Qualification', FALSE),
(85, 'student', 'std_152431', '152431@student.univ.ac.id', 'Student 152431', '1993-03-04', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(86, 'student', 'std_152910', '152910@student.univ.ac.id', 'Student 152910', '1996-06-15', 'M', 'North Western Region', 'A Level or Equivalent', FALSE),
(87, 'student', 'std_152929', '152929@student.univ.ac.id', 'Student 152929', '1994-09-27', 'M', 'East Anglian Region', 'HE Qualification', FALSE),
(88, 'student', 'std_153212', '153212@student.univ.ac.id', 'Student 153212', '1997-01-09', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(89, 'student', 'std_154027', '154027@student.univ.ac.id', 'Student 154027', '1995-04-23', 'M', 'Wales', 'A Level or Equivalent', FALSE),
(90, 'student', 'std_154128', '154128@student.univ.ac.id', 'Student 154128', '1993-08-05', 'M', 'East Anglian Region', 'Post Graduate Qualification', FALSE),
(91, 'student', 'std_154247', '154247@student.univ.ac.id', 'Student 154247', '1996-11-17', 'M', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(92, 'student', 'std_154564', '154564@student.univ.ac.id', 'Student 154564', '1994-02-28', 'F', 'North Western Region', 'A Level or Equivalent', FALSE),
(93, 'student', 'std_154674', '154674@student.univ.ac.id', 'Student 154674', '1998-06-12', 'M', 'Scotland', 'HE Qualification', FALSE),
(94, 'student', 'std_155054', '155054@student.univ.ac.id', 'Student 155054', '1995-09-24', 'F', 'South Region', 'Lower Than A Level', FALSE),
(95, 'student', 'std_155106', '155106@student.univ.ac.id', 'Student 155106', '1993-01-06', 'M', 'Scotland', 'Lower Than A Level', FALSE),
(96, 'student', 'std_155452', '155452@student.univ.ac.id', 'Student 155452', '1996-04-19', 'M', 'West Midlands Region', 'Lower Than A Level', FALSE),
(97, 'student', 'std_156291', '156291@student.univ.ac.id', 'Student 156291', '1994-07-31', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(98, 'student', 'std_157163', '157163@student.univ.ac.id', 'Student 157163', '1997-11-12', 'M', 'East Anglian Region', 'HE Qualification', FALSE),
(99, 'student', 'std_157850', '157850@student.univ.ac.id', 'Student 157850', '1995-02-24', 'M', 'South Region', 'A Level or Equivalent', FALSE),
(100, 'student', 'std_158223', '158223@student.univ.ac.id', 'Student 158223', '1993-06-08', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(101, 'student', 'std_159670', '159670@student.univ.ac.id', 'Student 159670', '1996-09-20', 'M', 'West Midlands Region', 'A Level or Equivalent', FALSE),
(102, 'student', 'std_160350', '160350@student.univ.ac.id', 'Student 160350', '1994-01-04', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(103, 'student', 'std_161103', '161103@student.univ.ac.id', 'Student 161103', '1995-04-15', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(104, 'student', 'std_161271', '161271@student.univ.ac.id', 'Student 161271', '1997-07-30', 'F', 'Yorkshire Region', 'Lower Than A Level', FALSE),
(105, 'student', 'std_161725', '161725@student.univ.ac.id', 'Student 161725', '1993-11-11', 'M', 'South West Region', 'HE Qualification', FALSE),
(106, 'student', 'std_162391', '162391@student.univ.ac.id', 'Student 162391', '1996-02-23', 'M', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(107, 'student', 'std_163155', '163155@student.univ.ac.id', 'Student 163155', '1994-06-07', 'F', 'South Region', 'A Level or Equivalent', FALSE),
(108, 'student', 'std_163273', '163273@student.univ.ac.id', 'Student 163273', '1995-09-19', 'M', 'North Western Region', 'HE Qualification', FALSE),
(109, 'student', 'std_164098', '164098@student.univ.ac.id', 'Student 164098', '1998-01-02', 'F', 'East Anglian Region', 'A Level or Equivalent', FALSE),
(110, 'student', 'std_164539', '164539@student.univ.ac.id', 'Student 164539', '1995-04-14', 'M', 'Wales', 'HE Qualification', FALSE);

INSERT INTO course_module (module_id, module_code, module_name, level, credits) VALUES 
(1, 'AAA', 'Social Science Intro', 1, 30),
(2, 'BBB', 'Psychology and Health', 1, 30),
(3, 'CCC', 'Engineering First', 1, 30),
(4, 'DDD', 'Biological Science', 2, 60),
(5, 'EEE', 'Environmental Studies', 2, 60),
(6, 'FFF', 'Data Analysis', 3, 60),
(7, 'GGG', 'Research Methods', 3, 60);

INSERT INTO presentation (presentation_id, module_id, instructor_id, semester, year) VALUES 
(1, 1, 1, '2013J', 2013), (2, 1, 2, '2014J', 2014),
(3, 2, 3, '2013J', 2013), (4, 2, 4, '2014J', 2014), (5, 2, 5, '2013B', 2013), (6, 2, 1, '2014B', 2014),
(7, 3, 2, '2014J', 2014), (8, 3, 3, '2014B', 2014),
(9, 4, 4, '2013J', 2013), (10, 4, 5, '2014J', 2014), (11, 4, 1, '2013B', 2013), (12, 4, 2, '2014B', 2014),
(13, 5, 3, '2013J', 2013), (14, 5, 4, '2014J', 2014), (15, 5, 5, '2014B', 2014),
(16, 6, 1, '2013J', 2013), (17, 6, 2, '2014J', 2014), (18, 6, 3, '2013B', 2013), (19, 6, 4, '2014B', 2014),
(20, 7, 5, '2013J', 2013), (21, 7, 1, '2014J', 2014), (22, 7, 2, '2014B', 2014);

INSERT INTO enrollment (enrollment_id, student_id, presentation_id, final_result, studied_credits) VALUES 
-- Presentation 1 (AAA 2013J)
(1, 6, 1, 'Pass', 60), (2, 7, 1, 'Pass', 60), (3, 8, 1, 'Withdrawn', 60), (4, 9, 1, 'Pass', 60), (5, 10, 1, 'Pass', 60),
-- Presentation 2 (AAA 2014J)
(6, 11, 2, 'Pass', 60), (7, 12, 2, 'Pass', 60), (8, 13, 2, 'Fail', 60), (9, 14, 2, 'Pass', 60), (10, 15, 2, 'Pass', 60),
-- Presentation 3 (BBB 2013J)
(11, 16, 3, 'Pass', 30), (12, 17, 3, 'Fail', 30), (13, 18, 3, 'Withdrawn', 30), (14, 19, 3, 'Pass', 30), (15, 20, 3, 'Pass', 30),
-- Presentation 4 (BBB 2014J)
(16, 21, 4, 'Pass', 30), (17, 22, 4, 'Pass', 30), (18, 23, 4, 'Pass', 30), (19, 24, 4, 'Pass', 30), (20, 25, 4, 'Distinction', 30),
-- Presentation 5 (BBB 2013B)
(21, 26, 5, 'Pass', 30), (22, 27, 5, 'Fail', 30), (23, 28, 5, 'Pass', 30), (24, 29, 5, 'Pass', 30), (25, 30, 5, 'Pass', 30),
-- Presentation 6 (BBB 2014B)
(26, 31, 6, 'Pass', 30), (27, 32, 6, 'Pass', 30), (28, 33, 6, 'Pass', 30), (29, 34, 6, 'Withdrawn', 30), (30, 35, 6, 'Pass', 30),
-- Presentation 7 (CCC 2014J)
(31, 36, 7, 'Pass', 30), (32, 37, 7, 'Distinction', 30), (33, 38, 7, 'Pass', 30), (34, 39, 7, 'Fail', 30), (35, 40, 7, 'Pass', 30),
-- Presentation 8 (CCC 2014B)
(36, 41, 8, 'Pass', 30), (37, 42, 8, 'Pass', 30), (38, 43, 8, 'Pass', 30), (39, 44, 8, 'Pass', 30), (40, 45, 8, 'Pass', 30),
-- Presentation 9 (DDD 2013J)
(41, 46, 9, 'Pass', 60), (42, 47, 9, 'Pass', 60), (43, 48, 9, 'Fail', 60), (44, 49, 9, 'Pass', 60), (45, 50, 9, 'Pass', 60),
-- Presentation 10 (DDD 2014J)
(46, 51, 10, 'Pass', 60), (47, 52, 10, 'Pass', 60), (48, 53, 10, 'Pass', 60), (49, 54, 10, 'Distinction', 60), (50, 55, 10, 'Withdrawn', 60),
-- Presentation 11 (DDD 2013B)
(51, 56, 11, 'Pass', 60), (52, 57, 11, 'Pass', 60), (53, 58, 11, 'Fail', 60), (54, 59, 11, 'Pass', 60), (55, 60, 11, 'Pass', 60),
-- Presentation 12 (DDD 2014B)
(56, 61, 12, 'Pass', 60), (57, 62, 12, 'Pass', 60), (58, 63, 12, 'Pass', 60), (59, 64, 12, 'Pass', 60), (60, 65, 12, 'Pass', 60),
-- Presentation 13 (EEE 2013J)
(61, 66, 13, 'Pass', 60), (62, 67, 13, 'Pass', 60), (63, 68, 13, 'Pass', 60), (64, 69, 13, 'Pass', 60), (65, 70, 13, 'Withdrawn', 60),
-- Presentation 14 (EEE 2014J)
(66, 71, 14, 'Pass', 60), (67, 72, 14, 'Pass', 60), (68, 73, 14, 'Fail', 60), (69, 74, 14, 'Pass', 60), (70, 75, 14, 'Pass', 60),
-- Presentation 15 (EEE 2014B)
(71, 76, 15, 'Pass', 60), (72, 77, 15, 'Distinction', 60), (73, 78, 15, 'Pass', 60), (74, 79, 15, 'Pass', 60), (75, 80, 15, 'Pass', 60),
-- Presentation 16 (FFF 2013J)
(76, 81, 16, 'Pass', 60), (77, 82, 16, 'Pass', 60), (78, 83, 16, 'Pass', 60), (79, 84, 16, 'Withdrawn', 60), (80, 85, 16, 'Pass', 60),
-- Presentation 17 (FFF 2014J)
(81, 86, 17, 'Pass', 60), (82, 87, 17, 'Pass', 60), (83, 88, 17, 'Fail', 60), (84, 89, 17, 'Pass', 60), (85, 90, 17, 'Pass', 60),
-- Presentation 18 (FFF 2013B)
(86, 91, 18, 'Pass', 60), (87, 92, 18, 'Pass', 60), (88, 93, 18, 'Pass', 60), (89, 94, 18, 'Pass', 60), (90, 95, 18, 'Pass', 60),
-- Presentation 19 (FFF 2014B)
(91, 96, 19, 'Pass', 60), (92, 97, 19, 'Pass', 60), (93, 98, 19, 'Fail', 60), (94, 99, 19, 'Pass', 60), (95, 100, 19, 'Pass', 60),
-- Presentation 20 (GGG 2013J)
(96, 101, 20, 'Pass', 30), (97, 102, 20, 'Pass', 30), (98, 103, 20, 'Pass', 30), (99, 104, 20, 'Pass', 30),
-- Presentation 21 (GGG 2014J)
(100, 105, 21, 'Pass', 30), (101, 106, 21, 'Pass', 30), (102, 107, 21, 'Fail', 30),
-- Presentation 22 (GGG 2014B)
(103, 108, 22, 'Pass', 30), (104, 109, 22, 'Pass', 30), (105, 110, 22, 'Pass', 30);

INSERT INTO assessment (assessment_id, presentation_id, assessment_name, weight) VALUES 
-- Pres 1 (AAA 2013J)
(1, 1, 'TMA', 10), (2, 1, 'TMA', 20), (3, 1, 'TMA', 20), (4, 1, 'TMA', 50), (5, 1, 'Exam', 100),
-- Pres 2 (AAA 2014J)
(6, 2, 'TMA', 10), (7, 2, 'TMA', 20), (8, 2, 'TMA', 20), (9, 2, 'TMA', 50), (10, 2, 'Exam', 100),
-- Pres 3 (BBB 2013J)
(11, 3, 'TMA', 20), (12, 3, 'TMA', 20), (13, 3, 'CMA', 30), (14, 3, 'CMA', 30), (15, 3, 'Exam', 100),
-- Pres 4 (BBB 2014J)
(16, 4, 'TMA', 20), (17, 4, 'TMA', 20), (18, 4, 'CMA', 30), (19, 4, 'CMA', 30), (20, 4, 'Exam', 100),
-- Pres 5 (BBB 2013B)
(21, 5, 'TMA', 25), (22, 5, 'TMA', 25), (23, 5, 'CMA', 25), (24, 5, 'CMA', 25), (25, 5, 'Exam', 100),
-- Pres 6 (BBB 2014B)
(26, 6, 'TMA', 25), (27, 6, 'TMA', 25), (28, 6, 'CMA', 25), (29, 6, 'CMA', 25), (30, 6, 'Exam', 100),
-- Pres 7 (CCC 2014J)
(31, 7, 'TMA', 30), (32, 7, 'TMA', 30), (33, 7, 'TMA', 40), (34, 7, 'CMA', 0), (35, 7, 'Exam', 100),
-- Pres 8 (CCC 2014B)
(36, 8, 'TMA', 30), (37, 8, 'TMA', 30), (38, 8, 'TMA', 40), (39, 8, 'CMA', 0), (40, 8, 'Exam', 100),
-- Pres 9 (DDD 2013J)
(41, 9, 'TMA', 25), (42, 9, 'TMA', 25), (43, 9, 'TMA', 50), (44, 9, 'Exam', 50), (45, 9, 'Exam', 50),
-- Pres 10 (DDD 2014J)
(46, 10, 'TMA', 25), (47, 10, 'TMA', 25), (48, 10, 'TMA', 50), (49, 10, 'Exam', 50), (50, 10, 'Exam', 50),
-- Pres 11 (DDD 2013B)
(51, 11, 'TMA', 20), (52, 11, 'TMA', 20), (53, 11, 'TMA', 60), (54, 11, 'Exam', 100), (55, 11, 'CMA', 0),
-- Pres 12 (DDD 2014B)
(56, 12, 'TMA', 20), (57, 12, 'TMA', 20), (58, 12, 'TMA', 60), (59, 12, 'Exam', 100), (60, 12, 'CMA', 0),
-- Pres 13 (EEE 2013J)
(61, 13, 'TMA', 50), (62, 13, 'TMA', 50), (63, 13, 'Exam', 100), (64, 13, 'Exam', 0), (65, 13, 'CMA', 0),
-- Pres 14 (EEE 2014J)
(66, 14, 'TMA', 50), (67, 14, 'TMA', 50), (68, 14, 'Exam', 100), (69, 14, 'Exam', 0), (70, 14, 'CMA', 0),
-- Pres 15 (EEE 2014B)
(71, 15, 'TMA', 50), (72, 15, 'TMA', 50), (73, 15, 'Exam', 100), (74, 15, 'Exam', 0), (75, 15, 'CMA', 0),
-- Pres 16 (FFF 2013J)
(76, 16, 'TMA', 10), (77, 16, 'TMA', 20), (78, 16, 'TMA', 30), (79, 16, 'TMA', 40), (80, 16, 'Exam', 100),
-- Pres 17 (FFF 2014J)
(81, 17, 'TMA', 10), (82, 17, 'TMA', 20), (83, 17, 'TMA', 30), (84, 17, 'TMA', 40), (85, 17, 'Exam', 100),
-- Pres 18 (FFF 2013B)
(86, 18, 'TMA', 10), (87, 18, 'TMA', 20), (88, 18, 'TMA', 30), (89, 18, 'TMA', 40), (90, 18, 'Exam', 100),
-- Pres 19 (FFF 2014B)
(91, 19, 'TMA', 10), (92, 19, 'TMA', 20), (93, 19, 'TMA', 30), (94, 19, 'TMA', 40), (95, 19, 'Exam', 100),
-- Pres 20 (GGG 2013J)
(96, 20, 'TMA', 0), (97, 20, 'TMA', 0), (98, 20, 'TMA', 0), (99, 20, 'CMA', 0), (100, 20, 'Exam', 100),
-- Pres 21 (GGG 2014J)
(101, 21, 'TMA', 0), (102, 21, 'TMA', 0), (103, 21, 'TMA', 0), (104, 21, 'CMA', 0), (105, 21, 'Exam', 100),
-- Pres 22 (GGG 2014B)
(106, 22, 'TMA', 0), (107, 22, 'TMA', 0), (108, 22, 'TMA', 0), (109, 22, 'CMA', 0), (110, 22, 'Exam', 100);

INSERT INTO student_assessment (student_assessment_id, enrollment_id, assessment_id, score) VALUES 
-- Pres 1 (Enroll 1-5) -> Assessment 1-5
(1, 1, 1, 80), (2, 2, 2, 75), (3, 3, 3, 0), (4, 4, 1, 88), (5, 5, 2, 92),
-- Pres 2 (Enroll 6-10) -> Assessment 6-10
(6, 6, 6, 65), (7, 7, 7, 72), (8, 8, 8, 45), (9, 9, 6, 78), (10, 10, 7, 85),
-- Pres 3 (Enroll 11-15) -> Assessment 11-15
(11, 11, 11, 70), (12, 12, 12, 50), (13, 13, 13, 0), (14, 14, 11, 82), (15, 15, 12, 79),
-- Pres 4 (Enroll 16-20) -> Assessment 16-20
(16, 16, 16, 85), (17, 17, 17, 88), (18, 18, 18, 76), (19, 19, 16, 82), (20, 20, 17, 95),
-- Pres 5 (Enroll 21-25) -> Assessment 21-25
(21, 21, 21, 60), (22, 22, 22, 40), (23, 23, 23, 75), (24, 24, 21, 78), (25, 25, 22, 80),
-- Pres 6 (Enroll 26-30) -> Assessment 26-30
(26, 26, 26, 77), (27, 27, 27, 79), (28, 28, 28, 82), (29, 29, 26, 0), (30, 30, 27, 85),
-- Pres 7 (Enroll 31-35) -> Assessment 31-35
(31, 31, 31, 68), (32, 32, 32, 92), (33, 33, 33, 70), (34, 34, 31, 45), (35, 35, 32, 74),
-- Pres 8 (Enroll 36-40) -> Assessment 36-40
(36, 36, 36, 80), (37, 37, 37, 81), (38, 38, 38, 76), (39, 39, 36, 79), (40, 40, 37, 82),
-- Pres 9 (Enroll 41-45) -> Assessment 41-45
(41, 41, 41, 65), (42, 42, 42, 70), (43, 43, 43, 30), (44, 44, 41, 75), (45, 45, 42, 72),
-- Pres 10 (Enroll 46-50) -> Assessment 46-50
(46, 46, 46, 88), (47, 47, 47, 85), (48, 48, 48, 80), (49, 49, 46, 95), (50, 50, 47, 0),
-- Pres 11 (Enroll 51-55) -> Assessment 51-55
(51, 51, 51, 70), (52, 52, 52, 72), (53, 53, 53, 40), (54, 54, 51, 76), (55, 55, 52, 74),
-- Pres 12 (Enroll 56-60) -> Assessment 56-60
(56, 56, 56, 60), (57, 57, 57, 65), (58, 58, 58, 62), (59, 59, 56, 68), (60, 60, 57, 70),
-- Pres 13 (Enroll 61-65) -> Assessment 61-65
(61, 61, 61, 82), (62, 62, 62, 80), (63, 63, 63, 75), (64, 64, 61, 85), (65, 65, 62, 0),
-- Pres 14 (Enroll 66-70) -> Assessment 66-70
(66, 66, 66, 78), (67, 67, 67, 76), (68, 68, 68, 45), (69, 69, 66, 72), (70, 70, 67, 74),
-- Pres 15 (Enroll 71-75) -> Assessment 71-75
(71, 71, 71, 88), (72, 72, 72, 90), (73, 73, 73, 85), (74, 74, 71, 86), (75, 75, 72, 84),
-- Pres 16 (Enroll 76-80) -> Assessment 76-80
(76, 76, 76, 65), (77, 77, 77, 70), (78, 78, 78, 68), (79, 79, 76, 0), (80, 80, 77, 72),
-- Pres 17 (Enroll 81-85) -> Assessment 81-85
(81, 81, 81, 75), (82, 82, 82, 78), (83, 83, 83, 42), (84, 84, 81, 74), (85, 85, 82, 76),
-- Pres 18 (Enroll 86-90) -> Assessment 86-90
(86, 86, 86, 80), (87, 87, 87, 82), (88, 88, 88, 85), (89, 89, 86, 81), (90, 90, 87, 83),
-- Pres 19 (Enroll 91-95) -> Assessment 91-95
(91, 91, 91, 60), (92, 92, 92, 62), (93, 93, 93, 45), (94, 94, 91, 65), (95, 95, 92, 68),
-- Pres 20 (Enroll 96-99) -> Assessment 96-100
(96, 96, 96, 0), (97, 97, 96, 0), (98, 98, 100, 75), (99, 99, 100, 80),
-- Pres 21 (Enroll 100-102) -> Assessment 101-105
(100, 100, 105, 82), (101, 101, 105, 85), (102, 102, 105, 30),
-- Pres 22 (Enroll 103-105) -> Assessment 106-110
(103, 103, 110, 78), (104, 104, 110, 80), (105, 105, 110, 76);

INSERT INTO vle_item (vle_id, presentation_id, vle_type, title) VALUES 
-- Pres 1
(1, 1, 'resource', 'Syllabus AAA'), (2, 1, 'url', 'Link AAA 1'), (3, 1, 'oucontent', 'Book AAA 1'), (4, 1, 'forumng', 'Forum AAA'), (5, 1, 'quiz', 'Quiz AAA 1'),
-- Pres 2
(6, 2, 'resource', 'Syllabus AAA'), (7, 2, 'url', 'Link AAA 2'), (8, 2, 'oucontent', 'Book AAA 2'), (9, 2, 'forumng', 'Forum AAA'), (10, 2, 'quiz', 'Quiz AAA 2'),
-- Pres 3
(11, 3, 'resource', 'Syllabus BBB'), (12, 3, 'url', 'Link BBB 1'), (13, 3, 'oucontent', 'Book BBB 1'), (14, 3, 'forumng', 'Forum BBB'), (15, 3, 'quiz', 'Quiz BBB 1'),
-- Pres 4
(16, 4, 'resource', 'Syllabus BBB'), (17, 4, 'url', 'Link BBB 2'), (18, 4, 'oucontent', 'Book BBB 2'), (19, 4, 'forumng', 'Forum BBB'), (20, 4, 'quiz', 'Quiz BBB 2'),
-- Pres 5
(21, 5, 'resource', 'Syllabus BBB'), (22, 5, 'url', 'Link BBB 3'), (23, 5, 'oucontent', 'Book BBB 3'), (24, 5, 'forumng', 'Forum BBB'), (25, 5, 'quiz', 'Quiz BBB 3'),
-- Pres 6
(26, 6, 'resource', 'Syllabus BBB'), (27, 6, 'url', 'Link BBB 4'), (28, 6, 'oucontent', 'Book BBB 4'), (29, 6, 'forumng', 'Forum BBB'), (30, 6, 'quiz', 'Quiz BBB 4'),
-- Pres 7
(31, 7, 'resource', 'Syllabus CCC'), (32, 7, 'url', 'Link CCC 1'), (33, 7, 'oucontent', 'Book CCC 1'), (34, 7, 'forumng', 'Forum CCC'), (35, 7, 'quiz', 'Quiz CCC 1'),
-- Pres 8
(36, 8, 'resource', 'Syllabus CCC'), (37, 8, 'url', 'Link CCC 2'), (38, 8, 'oucontent', 'Book CCC 2'), (39, 8, 'forumng', 'Forum CCC'), (40, 8, 'quiz', 'Quiz CCC 2'),
-- Pres 9
(41, 9, 'resource', 'Syllabus DDD'), (42, 9, 'url', 'Link DDD 1'), (43, 9, 'oucontent', 'Book DDD 1'), (44, 9, 'forumng', 'Forum DDD'), (45, 9, 'quiz', 'Quiz DDD 1'),
-- Pres 10
(46, 10, 'resource', 'Syllabus DDD'), (47, 10, 'url', 'Link DDD 2'), (48, 10, 'oucontent', 'Book DDD 2'), (49, 10, 'forumng', 'Forum DDD'), (50, 10, 'quiz', 'Quiz DDD 2'),
-- Pres 11
(51, 11, 'resource', 'Syllabus DDD'), (52, 11, 'url', 'Link DDD 3'), (53, 11, 'oucontent', 'Book DDD 3'), (54, 11, 'forumng', 'Forum DDD'), (55, 11, 'quiz', 'Quiz DDD 3'),
-- Pres 12
(56, 12, 'resource', 'Syllabus DDD'), (57, 12, 'url', 'Link DDD 4'), (58, 12, 'oucontent', 'Book DDD 4'), (59, 12, 'forumng', 'Forum DDD'), (60, 12, 'quiz', 'Quiz DDD 4'),
-- Pres 13
(61, 13, 'resource', 'Syllabus EEE'), (62, 13, 'url', 'Link EEE 1'), (63, 13, 'oucontent', 'Book EEE 1'), (64, 13, 'forumng', 'Forum EEE'), (65, 13, 'quiz', 'Quiz EEE 1'),
-- Pres 14
(66, 14, 'resource', 'Syllabus EEE'), (67, 14, 'url', 'Link EEE 2'), (68, 14, 'oucontent', 'Book EEE 2'), (69, 14, 'forumng', 'Forum EEE'), (70, 14, 'quiz', 'Quiz EEE 2'),
-- Pres 15
(71, 15, 'resource', 'Syllabus EEE'), (72, 15, 'url', 'Link EEE 3'), (73, 15, 'oucontent', 'Book EEE 3'), (74, 15, 'forumng', 'Forum EEE'), (75, 15, 'quiz', 'Quiz EEE 3'),
-- Pres 16
(76, 16, 'resource', 'Syllabus FFF'), (77, 16, 'url', 'Link FFF 1'), (78, 16, 'oucontent', 'Book FFF 1'), (79, 16, 'forumng', 'Forum FFF'), (80, 16, 'quiz', 'Quiz FFF 1'),
-- Pres 17
(81, 17, 'resource', 'Syllabus FFF'), (82, 17, 'url', 'Link FFF 2'), (83, 17, 'oucontent', 'Book FFF 2'), (84, 17, 'forumng', 'Forum FFF'), (85, 17, 'quiz', 'Quiz FFF 2'),
-- Pres 18
(86, 18, 'resource', 'Syllabus FFF'), (87, 18, 'url', 'Link FFF 3'), (88, 18, 'oucontent', 'Book FFF 3'), (89, 18, 'forumng', 'Forum FFF'), (90, 18, 'quiz', 'Quiz FFF 3'),
-- Pres 19
(91, 19, 'resource', 'Syllabus FFF'), (92, 19, 'url', 'Link FFF 4'), (93, 19, 'oucontent', 'Book FFF 4'), (94, 19, 'forumng', 'Forum FFF'), (95, 19, 'quiz', 'Quiz FFF 4'),
-- Pres 20
(96, 20, 'resource', 'Syllabus GGG'), (97, 20, 'url', 'Link GGG 1'), (98, 20, 'oucontent', 'Book GGG 1'), (99, 20, 'forumng', 'Forum GGG'), (100, 20, 'quiz', 'Quiz GGG 1'),
-- Pres 21
(101, 21, 'resource', 'Syllabus GGG'), (102, 21, 'url', 'Link GGG 2'), (103, 21, 'oucontent', 'Book GGG 2'), (104, 21, 'forumng', 'Forum GGG'), (105, 21, 'quiz', 'Quiz GGG 2'),
-- Pres 22
(106, 22, 'resource', 'Syllabus GGG'), (107, 22, 'url', 'Link GGG 3'), (108, 22, 'oucontent', 'Book GGG 3'), (109, 22, 'forumng', 'Forum GGG'), (110, 22, 'quiz', 'Quiz GGG 3');

INSERT INTO student_vle_activity (activity_id, enrollment_id, vle_id, clicks, activity_date) VALUES 
-- Pres 1 (Enroll 1-5 use VLE 1-5)
(1, 1, 1, 12, '2013-02-01'), (2, 2, 2, 5, '2013-02-02'), (3, 3, 3, 1, '2013-02-03'), (4, 4, 4, 20, '2013-02-04'), (5, 5, 5, 8, '2013-02-05'),
-- Pres 2 (Enroll 6-10 use VLE 6-10)
(6, 6, 6, 15, '2014-02-01'), (7, 7, 7, 3, '2014-02-02'), (8, 8, 8, 2, '2014-02-03'), (9, 9, 9, 25, '2014-02-04'), (10, 10, 10, 10, '2014-02-05'),
-- Pres 3 (Enroll 11-15 use VLE 11-15)
(11, 11, 11, 6, '2013-03-01'), (12, 12, 12, 4, '2013-03-02'), (13, 13, 13, 1, '2013-03-03'), (14, 14, 14, 18, '2013-03-04'), (15, 15, 15, 5, '2013-03-05'),
-- Pres 4 (Enroll 16-20 use VLE 16-20)
(16, 16, 16, 20, '2014-03-01'), (17, 17, 17, 2, '2014-03-02'), (18, 18, 18, 8, '2014-03-03'), (19, 19, 19, 30, '2014-03-04'), (20, 20, 20, 12, '2014-03-05'),
-- Pres 5 (Enroll 21-25 use VLE 21-25)
(21, 21, 21, 5, '2013-11-01'), (22, 22, 22, 3, '2013-11-02'), (23, 23, 23, 7, '2013-11-03'), (24, 24, 24, 15, '2013-11-04'), (25, 25, 25, 9, '2013-11-05'),
-- Pres 6 (Enroll 26-30 use VLE 26-30)
(26, 26, 26, 14, '2014-11-01'), (27, 27, 27, 6, '2014-11-02'), (28, 28, 28, 8, '2014-11-03'), (29, 29, 29, 2, '2014-11-04'), (30, 30, 30, 10, '2014-11-05'),
-- Pres 7 (Enroll 31-35 use VLE 31-35)
(31, 31, 31, 11, '2014-02-10'), (32, 32, 32, 4, '2014-02-11'), (33, 33, 33, 9, '2014-02-12'), (34, 34, 34, 16, '2014-02-13'), (35, 35, 35, 3, '2014-02-14'),
-- Pres 8 (Enroll 36-40 use VLE 36-40)
(36, 36, 36, 13, '2014-10-10'), (37, 37, 37, 5, '2014-10-11'), (38, 38, 38, 7, '2014-10-12'), (39, 39, 39, 22, '2014-10-13'), (40, 40, 40, 6, '2014-10-14'),
-- Pres 9 (Enroll 41-45 use VLE 41-45)
(41, 41, 41, 9, '2013-04-01'), (42, 42, 42, 2, '2013-04-02'), (43, 43, 43, 1, '2013-04-03'), (44, 44, 44, 14, '2013-04-04'), (45, 45, 45, 7, '2013-04-05'),
-- Pres 10 (Enroll 46-50 use VLE 46-50)
(46, 46, 46, 25, '2014-04-01'), (47, 47, 47, 3, '2014-04-02'), (48, 48, 48, 6, '2014-04-03'), (49, 49, 49, 18, '2014-04-04'), (50, 50, 50, 1, '2014-04-05'),
-- Pres 11 (Enroll 51-55 use VLE 51-55)
(51, 51, 51, 8, '2013-10-01'), (52, 52, 52, 4, '2013-10-02'), (53, 53, 53, 2, '2013-10-03'), (54, 54, 54, 12, '2013-10-04'), (55, 55, 55, 9, '2013-10-05'),
-- Pres 12 (Enroll 56-60 use VLE 56-60)
(56, 56, 56, 11, '2014-10-01'), (57, 57, 57, 5, '2014-10-02'), (58, 58, 58, 4, '2014-10-03'), (59, 59, 59, 20, '2014-10-04'), (60, 60, 60, 7, '2014-10-05'),
-- Pres 13 (Enroll 61-65 use VLE 61-65)
(61, 61, 61, 19, '2013-05-01'), (62, 62, 62, 2, '2013-05-02'), (63, 63, 63, 6, '2013-05-03'), (64, 64, 64, 15, '2013-05-04'), (65, 65, 65, 1, '2013-05-05'),
-- Pres 14 (Enroll 66-70 use VLE 66-70)
(66, 66, 66, 16, '2014-05-01'), (67, 67, 67, 3, '2014-05-02'), (68, 68, 68, 1, '2014-05-03'), (69, 69, 69, 22, '2014-05-04'), (70, 70, 70, 8, '2014-05-05'),
-- Pres 15 (Enroll 71-75 use VLE 71-75)
(71, 71, 71, 28, '2014-11-15'), (72, 72, 72, 6, '2014-11-16'), (73, 73, 73, 9, '2014-11-17'), (74, 74, 74, 14, '2014-11-18'), (75, 75, 75, 5, '2014-11-19'),
-- Pres 16 (Enroll 76-80 use VLE 76-80)
(76, 76, 76, 7, '2013-06-01'), (77, 77, 77, 3, '2013-06-02'), (78, 78, 78, 5, '2013-06-03'), (79, 79, 79, 1, '2013-06-04'), (80, 80, 80, 10, '2013-06-05'),
-- Pres 17 (Enroll 81-85 use VLE 81-85)
(81, 81, 81, 12, '2014-06-01'), (82, 82, 82, 4, '2014-06-02'), (83, 83, 83, 2, '2014-06-03'), (84, 84, 84, 18, '2014-06-04'), (85, 85, 85, 6, '2014-06-05'),
-- Pres 18 (Enroll 86-90 use VLE 86-90)
(86, 86, 86, 9, '2013-12-01'), (87, 87, 87, 3, '2013-12-02'), (88, 88, 88, 7, '2013-12-03'), (89, 89, 89, 15, '2013-12-04'), (90, 90, 90, 4, '2013-12-05'),
-- Pres 19 (Enroll 91-95 use VLE 91-95)
(91, 91, 91, 5, '2014-12-01'), (92, 92, 92, 2, '2014-12-02'), (93, 93, 93, 1, '2014-12-03'), (94, 94, 94, 20, '2014-12-04'), (95, 95, 95, 8, '2014-12-05'),
-- Pres 20 (Enroll 96-99 use VLE 96-100)
(96, 96, 96, 2, '2013-07-01'), (97, 97, 97, 1, '2013-07-02'), (98, 98, 98, 3, '2013-07-03'), (99, 99, 99, 10, '2013-07-04'),
-- Pres 21 (Enroll 100-102 use VLE 101-105)
(100, 100, 101, 22, '2014-07-01'), (101, 101, 102, 5, '2014-07-02'), (102, 102, 103, 1, '2014-07-03'),
-- Pres 22 (Enroll 103-105 use VLE 106-110)
(103, 103, 106, 14, '2014-11-01'), (104, 104, 107, 6, '2014-11-02'), (105, 105, 108, 9, '2014-11-03');