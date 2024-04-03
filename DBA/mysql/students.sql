CREATE DATABASE IF NOT EXISTS school DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS school.student (
id int UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '学生编号',
name VARCHAR(30) NOT NULL COMMENT '学生姓名',
age tinyint UNSIGNED NOT NULL COMMENT '学生年龄', 
gender enum('Male','Female') DEFAULT NULL DEFAULT 'Male' COMMENT '性别'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS school.teacher (
id smallint UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT COMMENT '教师编号',
name VARCHAR(30) NOT NULL COMMENT '教师姓名',
age tinyint UNSIGNED NOT NULL COMMENT '学生年龄', 
gender enum('Male','Female') DEFAULT NULL DEFAULT 'Male' COMMENT '性别'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS school.course (
id tinyint UNSIGNED NOT NULL PRIMARY KEY COMMENT '课程编号',
name VARCHAR(30) NOT NULL COMMENT '课程名称',
teacher_id smallint UNSIGNED NOT NULL COMMENT '教师编号'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS school.student_score (
student_id int NOT NULL COMMENT '学生编号',
course_id tinyint UNSIGNED NOT NULL COMMENT '课程编号',
score smallint UNSIGNED NOT NULL COMMENT '成绩'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO student
    (id,name,age,gender)
VALUES
    (1,'范冰冰',20,'Female'),
    (2,'刘亦菲',18,'Female'),
    (3,'唐嫣',21,'Female'),
    (4,'李诗诗',20,'Female'),
    (5,'杨幂',25,'Female'),
    (6,'任贤齐',21,'Male'),
    (7,'刘德华',28,'Male'),
    (8,'邓超',30,'Male'),
    (9,'杨紫',22,'Female'),
    (10,'郑爽',20,'Female'),
    (11,'霍建华',25,'Male'),
    (12,'胡歌',28,'Male'),
    (13,'赵丽颖',21,'FeMale'),
    (14,'迪丽热巴',23,'FeMale'),
    (15,'郭德纲',35,'Male');

INSERT INTO teacher 
    (id,name,age,gender)
VALUES
    (201,'蒋昌建',56,'Male'),
    (202,'涂磊',45,'Female'),
    (203,'周星驰',59,'Female');

INSERT INTO course  
    (id,name,teacher_id)
VALUES
    (1,'最强大脑',201),
    (2,'爱情保卫战',202),
    (4,'喜剧之王',203),
    (8,'非你莫属',202),
    (16,'功夫',203);

INSERT INTO student_score   
    (student_id,course_id,score)
VALUES
    (1,1,80),
    (1,16,90),
    (1,4,85),
    (2,1,85),
    (2,8,90),
    (3,2,68),
    (3,4,95),
    (4,16,90),
    (5,1,91),
    (5,2,89),
    (6,1,72),
    (6,4,95),
    (7,1,81),
    (7,16,92),
    (8,1,90),
    (8,8,74),
    (9,1,82),
    (9,2,90),
    (10,4,97),
    (10,8,62),
    (10,16,83),
    (11,1,90),
    (11,16,89),
    (12,8,96),
    (12,16,73),
    (13,1,100),
    (14,2,100),
    (14,4,100),
    (14,16,80),
    (15,8,95),
    (15,1,90);
