Create an audit table to log salary changes.
CREATE TABLE IF NOT EXISTS Employee_Salary_Audit (
audit_id INT AUTO_INCREMENT PRIMARY KEY,
emp_id INT NOT NULL,
old_salary DECIMAL(10, 2),
new_salary DECIMAL(10, 2),
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
action VARCHAR(30)
);
DELIMITER //
CREATE TRIGGER validate_employee_salary_insert
BEGIN
IF NEW.salary < 30000 OR NEW.salary > 150000 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Salary must be between 30000 and 150000';
END IF;
END//
DELIMITER ;
DELIMITER //
CREATE TRIGGER validate_employee_salary_update
BEGIN
IF NEW.salary < 30000 OR NEW.salary > 150000 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Salary must be between 30000 and 150000';
END IF;
END//
DELIMITER ;
DELIMITER //
CREATE TRIGGER audit_salary_update
BEGIN
IF OLD.salary <> NEW.salary THEN
INSERT INTO Employee_Salary_Audit (emp_id, old_salary, new_salary, action)
VALUES (NEW.emp_id, OLD.salary, NEW.salary, 'SALARY UPDATE');
END IF;
END//
DELIMITER ;
rollback.
DELIMITER //
CREATE PROCEDURE transfer_employee(
IN p_emp_id INT,
)
BEGIN
DECLARE v_emp_count INT DEFAULT 0;
DECLARE v_dept_count INT DEFAULT 0;
DECLARE v_old_dept_id INT;
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
ROLLBACK;
RESIGNAL;
END;
START TRANSACTION;
-- Validate employee exists
SELECT COUNT(*) INTO v_emp_count FROM Employee
WHERE emp_id = p_emp_id;
IF v_emp_count = 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Employee does not exist';
END IF;
-- Validate department exists
SELECT COUNT(*) INTO v_dept_count FROM Department
WHERE dept_id = p_new_dept_id;
IF v_dept_count = 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Department does not exist';
END IF;
-- Check if employee is already in the target department
SELECT dept_id INTO v_old_dept_id FROM Employee
WHERE emp_id = p_emp_id;
IF v_old_dept_id = p_new_dept_id THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Employee is already in this department';
END IF;
-- Perform transfer
UPDATE Employee
SET dept_id = p_new_dept_id
WHERE emp_id = p_emp_id;
COMMIT;
END//
DELIMITER ;
CALL transfer_employee(6, 4);
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.emp_id = 6;
-- Test A: Invalid employee
CALL transfer_employee(99, 4);
-- Test B: Invalid department
CALL transfer_employee(6, 99);
-- Test C: Same department
CALL transfer_employee(6, 4);
-- Test invalid update (<30,000)
UPDATE Employee SET salary = 20000 WHERE emp_id = 6;
-- Test valid update (within 30,000 to 150,000)
UPDATE Employee SET salary = 85000 WHERE emp_id = 6;
SELECT audit_id, emp_id, old_salary, new_salary, changed_at, action
FROM Employee_Salary_Audit
ORDER BY audit_id;
