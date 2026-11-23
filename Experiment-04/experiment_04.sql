EXCEPT. Compare the execution plans of selected queries using EXPLAIN.
SELECT
e.emp_id,
e.emp_name,
e.salary,
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
SELECT
d.dept_id,
d.dept_name,
e.emp_name,
FROM Department d
LEFT JOIN Employee e ON d.dept_id = e.dept_id
ORDER BY d.dept_id, e.emp_id;
SELECT
e1.emp_name AS employee_1,
e2.emp_name AS employee_2,
e1.dept_id,
e1.salary AS salary_1,
FROM Employee e1
INNER JOIN Employee e2
ON e1.dept_id = e2.dept_id AND e1.emp_id < e2.emp_id
ORDER BY e1.dept_id, e1.emp_id, e2.emp_id
LIMIT 10;
SELECT
e.emp_name,
d.dept_name,
p.project_name,
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
INNER JOIN Project p ON e.project_id = p.project_id
ORDER BY d.dept_name, e.emp_name;
SELECT
e.emp_id,
e.emp_name,
e.salary,
FROM Employee e
WHERE e.salary>(
SELECT AVG(e2.salary)
FROM Employee e2
WHERE e2.dept_id = e.dept_id
)
ORDER BY e.dept_id, e.salary DESC;
FROM Department d
WHERE EXISTS (
SELECT 1
FROM Employee e
WHERE e.dept_id = d.dept_id AND e.salary > 80000
)
ORDER BY d.dept_id;
Select employees who belong to IT (dept_id = 1) AND earn>70,000.
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id IN (
SELECT emp_id FROM Employee WHERE dept_id = 1
)
AND emp_id IN (
SELECT emp_id FROM Employee WHERE salary > 70000
)
ORDER BY emp_id;
Select employees earning>70,000 EXCEPT those in IT (dept_id = 1).
SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id IN (
SELECT emp_id FROM Employee WHERE salary > 70000
)
AND emp_id NOT IN (
SELECT emp_id FROM Employee WHERE dept_id = 1
)
ORDER BY emp_id;
EXPLAIN – EXECUTION PLAN
The EXPLAIN statement displays how the MySQL query optimizer executes a SELECT query,
EXPLAIN SELECT
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
WHERE e.salary>70000;
EXPLAIN SELECT
FROM Employee e
WHERE e.salary>(
SELECT AVG(e2.salary)
FROM Employee e2
WHERE e2.dept_id = e.dept_id
);
EXPLAIN SELECT
FROM Department d
WHERE EXISTS (
SELECT 1
FROM Employee e
WHERE e.dept_id = d.dept_id AND e.salary > 80000
);
INNER Employee Join access on Optimizer scans base tables and joins via hash
JOIN Department dept_id join or primary key index.
