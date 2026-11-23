--CreateDepartment Table
);
--CreateProject Table
dept_id INT,
);
--CreateEmployeeTable
dept_id INT,
project_idINT,
);
--InsertDepartments
INSERTINTODepartment(dept_id,dept_name)
VALUES
(1,'IT'),
(2,'HR'),
(3,'Finance'),
(4,'Marketing'),
(5, 'Operations');
--InsertProjects
INSERTINTOProject(project_id,project_name,
(101,'EnterpriseCloud',160000.00,1),
(102,'MachineLearningPlatform',210000.00,1),
(103, 'TalentAcquisitionSystem',85000.00,2),
(104, 'Audit&AccountingSuite',125000.00,3),
(105,'Social MediaGrowth', 95000.00,4),
(106, 'LogisticsOptimization',185000.00,5),
(107,'Customer iOS App',145000.00,1),
(108,'CorporateWellness',65000.00, 2);
--Insert30Employees
INSERTINTOEmployee(emp_id,emp_name,
(1,'Rahul', 66000.00,'2022-02-15',1,101),
(2,'Priya',74000.00,'2021-04-10',1, 102),
(3,'Amit',59000.00,'2023-07-05',1,107),
(4,'Sneha',82000.00,'2020-09-18',1,101),
(5, 'Vikram',70000.00,'2022-10-12',1,102),
(6,'Anjali',63000.00,'2024-01-25',1,107),
(7, 'Kunal',53000.00,'2022-05-14',2,103),
(8, 'Pooja',49000.00, '2023-02-18', 2, 108),
(9,'Rakesh',62000.00,'2021-08-22',2,103),
(10,'Neha',56000.00,'2022-11-04',2,108),
(11,'Deepak',48000.00, '2024-04-19',2,103),
(12,'Sunita',60000.00,'2020-11-15',2,108),
(13,'Sanjay',77000.00,'2021-03-21', 3,104),
(14, 'Kavita',69000.00,'2022-06-11',3,104),
(15,'Rajesh',84000.00,'2019-11-14',3,104),
(16,'Anita',61000.00,'2023-09-08',3,104),
(17,'Manoj',72000.00,'2021-12-05',3,104),
(18,'Swati',57000.00,'2024-02-14',3,104),
(19,'Gaurav',55000.00,'2022-03-30',4,105),
(20,'Divya',64000.00,'2021-07-25',4, 105),
(21,'Harsh',58000.00, '2023-05-16',4, 105),
(22,'Simran',67000.00,'2020-10-10',4, 105),
(23,'Tarun',52000.00,'2024-03-01',4,105),
(24,'Shalini',71000.00,'2022-12-08',4,105),
(25,'Alok',61000.00,'2021-02-19',5,106),
(26,'Megha',75000.00, '2020-05-28',5,106),
(27, 'Varun',68000.00,'2022-08-20',5,106),
(28,'Tanvi',58000.00,'2023-06-15', 5,106),
(29,'Mohit',78000.00,'2019-09-12',5, 106),
(30,'Kriti',65000.00, '2024-02-28',5,106);
SELECT *
FROM Employee
WHERE salary>70000;
SELECT emp_name,salary
FROM Employee;
SELECT
COUNT(*)AStotal_employees,
AVG(salary)AS average_salary,
MAX(salary)AShighest_salary,
MIN(salary)ASlowest_salary,
FROM Employee;
SELECT
d.dept_name,
COUNT(e.emp_id)AS employee_count,
FROM Departmentd
GROUP BYd.dept_id,d.dept_name;
SELECT
d.dept_name,
FROM Departmentd
GROUP BYd.dept_id, d.dept_name
HAVINGAVG(e.salary)>65000;
SELECT
emp_name,
salary,
ELSE'LowSalary'
FROM Employee;
FROM Employee
ORDERBYsalaryDESC;
SELECT
e.emp_name,
d.dept_name,
p.project_name,
FROM Employeee
