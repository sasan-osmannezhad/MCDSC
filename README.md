# MCDSC
metro collage data science projects
This code is creating a database named BankSO with several tables. Each table is designed to store specific types of information related to a banking system. Here’s a simplified explanation:

UserLogins: Stores usernames and passwords.
UserSecurityQuestions: Stores security questions for users.
AccountType: Stores different types of accounts.
SavingsInterestRates: Stores interest rates for savings accounts.
AccountStatusType: Stores different statuses an account can have.
FailedTransactionErrorType: Stores different types of transaction errors.
LoginErrorLog: Logs login errors.
Employee: Stores information about bank employees.
TransactionType: Stores different types of transactions.
FailedTransactionLog: Logs failed transactions.
The CREATE TABLE statements define the structure of each table, and the INSERT INTO statement adds records to the LoginErrorLog table. The IDENTITY property is used to automatically generate unique numbers when new records are added to a table. The FOREIGN KEY in FailedTransactionLog references the FailedTransactionErrorTypeID in FailedTransactionErrorType, enforcing referential integrity between the two tables. The CONSTRAINT keyword is used to assign names to the primary keys and the foreign key. The PRIMARY KEY constraints ensure that the key columns contain unique, non-null values. The NOT NULL constraints ensure that the column cannot contain null values. The IDENTITY(1,1) arguments specify that the identity value starts at 1 and increments by 1 for each new record.
