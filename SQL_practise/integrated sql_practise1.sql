create database ABC_RetailBank_DB;
use ABC_RetailBank_DB;
create table Departments(department_id int primary key,
department_name varchar(40) not null unique,
location varchar(30) not null);
Create table Employees(emp_id int primary key,
emp_name varchar(50) not null,
department_id int,
manager_id int null,
salary decimal(10,2) check(salary>=30000),
joining_date date not null,
bonus decimal(10,2) null,
status varchar(15) Default 'Active',
constraint FDID foreign key(department_id)
references Departments(department_id)on update cascade on delete cascade);
Create table Projects(project_id int Primary Key,
project_name varchar(60) not null,
department_id int,
budget decimal(12,2) check(budget>0),
constraint FPDID foreign key(department_id) references Departments(department_id)on update cascade on delete cascade);
insert into Departments(department_id,department_name,location) values(1,'HR','Mumbai'),
(2,'IT','Bengaluru'),(3,'Finance','Pune'),(4,'Operations','Hyderabad'),
(5,'Risk','Chennai');
insert into Employees(emp_id,emp_name,department_id,salary,joining_date) values
(101,'Arun',1,45000,'2022-01-10'),(102,'Priya',2,72000,'2021-03-15'),
(103,'Meera',2,68000,'2023-02-20'),(104,'John',3,85000,'2020-07-12'),
(105,'Rahul',1,52000,'2021-11-25'),(106,'Neha',4,49000,'2022-08-18'),
(107,'David',4,54000,'2021-06-30'),(108,'Sara',5,76000,'2022-10-05');
insert into projects(project_id,project_name,department_id,budget) values
(1,'Payroll Upgrade',1,250000),(2,'Mobile Banking App',2,1200000),
(3,'AML Automation',3,850000),(4,'Operations Dashboard',4,350000),
(5,'Risk Engine',5,950000);
set sql_safe_updates=0;
update employees
set Status='Inactive' where emp_name='Meera';
UPDATE employees e
JOIN employees m
ON m.emp_name =
CASE
    WHEN e.emp_name = 'Priya' THEN 'John'
    WHEN e.emp_name = 'Meera' THEN 'John'
    WHEN e.emp_name = 'Rahul' THEN 'Arun'
    WHEN e.emp_name = 'Neha' THEN 'David'
    WHEN e.emp_name = 'Sara' THEN 'John'
END
SET e.manager_id = m.emp_id
WHERE e.emp_name IN ('Priya', 'Meera', 'Rahul', 'Neha', 'Sara');
update employees
set Bonus= 
case
	when emp_name='Arun' then 5000
	when emp_name='John' then 12000
	when emp_name='Neha' then 3000
	when emp_name='Sara' then 7000
	else bonus
end
where emp_name in('Arun','John','Neha','Sara');
alter table employees
add column email varchar(100);
update employees
set email=
case
	WHEN emp_name = 'Arun' THEN 'arun@abcretailbank.com'
    WHEN emp_name = 'Priya' THEN 'priya@abcretailbank.com'
    WHEN emp_name = 'Meera' THEN 'meera@abcretailbank.com'
    WHEN emp_name = 'John' THEN 'john@abcretailbank.com'
    WHEN emp_name = 'Rahul' THEN 'rahul@abcretailbank.com'
    WHEN emp_name = 'Neha' THEN 'neha@abcretailbank.com'
    WHEN emp_name = 'David' THEN 'david@abcretailbank.com'
    WHEN emp_name = 'Sara' THEN 'sara@abcretailbank.com'
    ELSE email
end
WHERE emp_name IN ('Arun','Priya','Meera','John','Rahul','Neha','David','Sara');
start transaction;
update employees
set salary=salary+5000 
where emp_name='Rahul';
rollback;
start transaction;
update employees
set salary= salary*1.10
where department_id=
(select department_id from departments where 
department_name='Risk');
savepoint sp1;
update employees
set salary= salary*0.95
where department_id=
(select department_id from departments where 
department_name='Operations');
rollback to sp1;
commit;
select e.emp_name,d.department_name,
p.project_name,e.salary,e.bonus,
avg(e.salary) over(partition by e.department_id) as Dept_avg_salary,
dense_rank() over(order by e.salary desc) as Company_salary_rank 
from employees e inner join departments d on e.department_id=d.department_id
inner join projects p on p.department_id=e.department_id
where e.status='Active'and e.salary>(select avg(e1.salary) from employees e1 where e.department_id=e1.department_id)
and p.budget>(select avg(p1.budget) from projects p1)
order by e.salary desc,e.emp_name;


