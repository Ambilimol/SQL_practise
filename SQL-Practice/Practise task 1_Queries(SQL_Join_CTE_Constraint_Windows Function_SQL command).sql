create database ABC_Finance_DB;
use ABC_Finance_DB;
create table departments(department_id int primary key,department_name VARCHAR(30) not null unique);
create table employees(emp_id int Primary Key,emp_name varchar(50) not null,department_id int,
manager_id int null,salary decimal(10,2) check(salary>=30000),joining_date date not null,bonus decimal(10,2) null,
status varchar(15) Default "Active");
alter table employees
add constraint FKY_DID foreign key(department_id) 
references departments(department_id) on update cascade on delete cascade;
create table projects(project_id int primary key,project_name varchar(50) not null,department_id int,
budget decimal(10,2) check(budget>0),constraint FKY_PDID foreign key(department_id) references departments(department_id)
on update cascade on delete cascade);
insert into departments(department_id,department_name) values(1,"HR"),(2,"IT"),
(3,"Finance"),(4,"Operations");
insert into employees(emp_id,emp_name,department_id,salary,joining_date) values(101,"Arun",1,45000,"2022-01-10"),(102,"Priya",2,60000,"2021-03-15"),
(103,"Meera",2,55000,"2023-02-20"),(104,"John",3,70000,"2020-07-12"),(105,"Rahul",1,50000,"2021-11-25"),(106,"Neha",4,48000,"2022-08-18"),
(107,"David",4,52000,"2021-06-30");
update employees
set status="Inactive" where emp_id=103;
update employees
set manager_id=104 where emp_id in (102,103);
update employees
set manager_id=101 where emp_id=105;
update employees
set manager_id=107 where emp_id=106;
update employees
set bonus=5000 where emp_id=101;
update employees
set bonus=case
when emp_id=103 then 3000
when emp_id=104 then 10000
when emp_id=106 then 2500
else bonus
end
where emp_id in(103,104,106);
insert into projects(project_id,project_name,department_id,budget) values(1,"Payroll System",1,250000),
(2,"Mobile App",2,800000),(3,"Audit Automation",3,600000),(4,"Operations Dashboard",4,350000);
set sql_safe_updates=0;
update employees
set status="Active" where emp_name="Meera";
with employee_salary as(select e.emp_name,d.department_name,p.project_name,e.salary,
avg(e.salary) over(partition by d.department_id) as department_avg_salary,p.budget,e.status,
IFNULL(e.bonus,0) AS bonus from
employees e inner join departments d on e.department_id=d.department_id
inner join projects p on e.department_id=p.department_id )
select emp_name,department_name,project_name,salary,bonus,department_avg_salary
from employee_salary where status='Active' and salary >department_avg_salary
and budget>500000 order by department_name, salary desc;
