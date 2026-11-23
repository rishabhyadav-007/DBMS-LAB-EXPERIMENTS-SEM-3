CREATE DATABASE IF NOT EXISTS BankingDB;
USE BankingDB;
-- Accounts table storing customer balances
CREATE TABLE IF NOT EXISTS Accounts (
account_no   INT PRIMARY KEY,
holder_name  VARCHAR(100) NOT NULL,
account_type VARCHAR(20)  NOT NULL,
balance      DECIMAL(12, 2) NOT NULL CHECK (balance >= 0)
);
-- Transaction log table for audit trails
CREATE TABLE IF NOT EXISTS Transaction_Logs (
log_id       INT AUTO_INCREMENT PRIMARY KEY,
from_acc     INT,
to_acc       INT,
amount       DECIMAL(12, 2),
status       VARCHAR(20),
log_time     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Seed initial accounts
INSERT INTO Accounts (account_no, holder_name, account_type, balance) VALUES
(101, 'Ananya Gupta',   'Savings',  62000.00),
(102, 'Rohan Malhotra', 'Savings',  41000.00),
(103, 'Divya Nair',     'Current',  88000.00);
SELECT * FROM Accounts;
START TRANSACTION;
-- Step 1: Debit from Account 101
UPDATE Accounts
SET balance = balance - 10000.00
WHERE account_no = 101;
-- Step 2: Credit to Account 102
UPDATE Accounts
SET balance = balance + 10000.00
WHERE account_no = 102;
-- Step 3: Record transaction in audit log
INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
VALUES (101, 102, 10000.00, 'SUCCESS');
-- Commit all changes permanently
COMMIT;
SELECT * FROM Accounts;
START TRANSACTION;
-- Step 1: Attempt to debit an amount higher than current balance
UPDATE Accounts
SET balance = balance - 60000.00
WHERE account_no = 101;
-- If application detects error or constraint check fails:
ROLLBACK;
SELECT * FROM Accounts WHERE account_no IN (101, 103);
Savepoint: sp_transfer1
Transfer 2: Transfer ₹10,000 from 101 to non-existent account 999 (Fails)
Rollback only to sp_transfer1 so Transfer 1 remains intact.
START TRANSACTION;
-- Valid Transfer 1: 101 -> 102 (₹5,000)
UPDATE Accounts SET balance = balance - 5000.00 WHERE account_no = 101;
UPDATE Accounts SET balance = balance + 5000.00 WHERE account_no = 102;
INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
VALUES (101, 102, 5000.00, 'SUCCESS');
-- Set Savepoint
SAVEPOINT sp_transfer1;
-- Invalid Transfer 2: Target account does not exist
UPDATE Accounts SET balance = balance - 10000.00 WHERE account_no = 101;
UPDATE Accounts SET balance = balance + 10000.00 WHERE account_no = 999; -- 0 rows affected
-- Application detects that target account does not exist; rolls back Transfer 2 only
ROLLBACK TO SAVEPOINT sp_transfer1;
-- Log the partial failure
INSERT INTO Transaction_Logs (from_acc, to_acc, amount, status)
VALUES (101, 999, 10000.00, 'FAILED_INVALID_ACC');
-- Commit remaining valid operations
COMMIT;
SELECT * FROM Accounts;
SELECT * FROM Transaction_Logs;
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE Accounts SET balance = 90000.00 WHERE account_no = 101; (Uncommitted)
SELECT balance FROM Accounts WHERE account_no = 101;
Result: 90,000.00 (Dirty Read)
ROLLBACK; (Update reverted)
SELECT balance FROM Accounts WHERE account_no = 101;
Result: 35,000.00 (Data was phantom/dirty)
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT balance FROM Accounts WHERE account_no = 102;
UPDATE Accounts SET balance = balance + 5000.00 WHERE account_no = 102;
COMMIT;
SELECT balance FROM Accounts WHERE account_no = 102;
Result: 50,000.00 (Value changed! Non-Repeatable Read)
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT COUNT(*) FROM Accounts WHERE balance >= 50000.00;
Result: 2 accounts (102, 103)
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
INSERT INTO Accounts VALUES (104, 'Ananya Sen', 'Savings', 60000.00);
COMMIT;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM Accounts WHERE balance >= 50000.00;
START TRANSACTION;
INSERT INTO Accounts VALUES (105, 'Karan Roy', 'Savings', 70000.00);
(Session 2 blocks waiting for Range Lock)
COMMIT;
(Unblocks and inserts successfully)
COMMIT;
