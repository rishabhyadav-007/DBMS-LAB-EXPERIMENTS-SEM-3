-- Add manager_id column
ALTER TABLE Employee ADD COLUMN manager_id INT;
ALTER TABLE Employee ADD FOREIGN KEY (manager_id) REFERENCES Employee(emp_id);
-- Assign department heads (NULL) and reporting managers
-- IT Department
UPDATE Employee SET manager_id = 1 WHERE emp_id IN (2, 4);
UPDATE Employee SET manager_id = 2 WHERE emp_id IN (3, 5);
UPDATE Employee SET manager_id = 3 WHERE emp_id = 6;
-- HR Department
UPDATE Employee SET manager_id = 7 WHERE emp_id IN (8, 9);
UPDATE Employee SET manager_id = 8 WHERE emp_id IN (10, 12);
UPDATE Employee SET manager_id = 9 WHERE emp_id = 11;
-- Finance Department
UPDATE Employee SET manager_id = 13 WHERE emp_id IN (14, 15);
UPDATE Employee SET manager_id = 14 WHERE emp_id IN (16, 18);
UPDATE Employee SET manager_id = 15 WHERE emp_id = 17;
-- Marketing Department
UPDATE Employee SET manager_id = 19 WHERE emp_id IN (20, 21);
UPDATE Employee SET manager_id = 20 WHERE emp_id IN (22, 24);
UPDATE Employee SET manager_id = 21 WHERE emp_id = 23;
-- Operations Department
UPDATE Employee SET manager_id = 25 WHERE emp_id IN (26, 27);
UPDATE Employee SET manager_id = 26 WHERE emp_id IN (28, 30);
UPDATE Employee SET manager_id = 27 WHERE emp_id = 29;
Create a view showing employee count, average salary, minimum salary, maximumsalary, and total
CREATE OR REPLACE VIEW department_salary_summary AS
SELECT
d.dept_id,
d.dept_name,
COUNT(e.emp_id) AS employee_count,
AVG(e.salary) AS average_salary,
MIN(e.salary) AS minimum_salary,
MAX(e.salary) AS maximum_salary,
FROM Department d
JOIN Employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;
-- Display View
SELECT * FROM department_salary_summary;
Create a view containing each employee and their immediate manager.
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT
e.emp_id,
e.emp_name,
e.dept_id,
d.dept_name,
e.manager_id,
m.emp_name AS manager_name,
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
LEFT JOIN Employee m ON e.manager_id = m.emp_id;
-- Display View
SELECT * FROM employee_hierarchy ORDER BY emp_id;
-- Test 1: Updating complex joined view
UPDATE employee_hierarchy
SET salary = salary + 1000
WHERE emp_id = 6;
-- Check Employee record
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 6;
-- Test 2: Updating grouped/aggregate view
UPDATE department_salary_summary
SET average_salary = average_salary + 1000
WHERE dept_id = 1;
-- Anchor Member: Department Heads
SELECT
e.emp_id,
e.emp_name,
e.manager_id,
1 AS level,
FROM Employee e
WHERE e.manager_id IS NULL
UNION ALL
-- Recursive Member: Subordinates
SELECT
e.emp_id,
e.emp_name,
e.manager_id,
rc.level + 1,
CONCAT(rc.reporting_path, ' -> ', e.emp_name)
FROM Employee e
JOIN reporting_chain rc ON e.manager_id = rc.emp_id
)
SELECT emp_id, emp_name, manager_id, level, reporting_path
FROM reporting_chain
ORDER BY reporting_path;
