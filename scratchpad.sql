-- DDL
create table Location
(Location_ID serial primary key, 
 Location_Name varchar(50),  
 Address varchar(100) ,
 City varchar(50), 
 State varchar(2));


create table Employee 
(Emp_ID varchar(8) PRIMARY key, 
 Emp_Name varchar(50),
 Email varchar(100), 
 Hire_date date, 
 Location_ID int references Location (Location_ID));
 
create table Education 
(Ed_ID serial primary key, 
 Emp_ID varchar(8) references Employee(Emp_ID), 
 Education_Level varchar(50));
 
 
 create table Department 
 (Dep_ID  serial  primary key, 
  Dep_name varchar(50));

Create Table Department_Location
(Dep_ID int references Department (Dep_ID),
 Location_ID int references Location (Location_ID),
PRIMARY KEY(Dep_ID, Location_ID));
 

create table Job 
(ID serial  primary key, 
 Job_Name varchar(100));

create table Job_History
(JobHist_ID serial primary key,
Job_ID  int references Job(ID), 
 Employee_ID varchar(8) references Employee(Emp_ID), 
 Department_ID int references Department(Dep_ID), 
 Start_Date date, 
 End_Date date, 
 Manager_ID varchar(8) references Employee (Emp_ID)
 );
 
 create table Salary
 (Salary_ID serial primary key,
  JobHist_ID int references Job_History(JobHist_ID ),
  salary money );
-----------------------------------------------------------
-- Populate Data from proj_stg table
--select * from proj_stg
insert into Location (Location_Name,Address,City,State)  select Distinct location,address,city,state from proj_stg;

insert into  Employee  (Emp_ID ,  Emp_Name , Email ,  Hire_date  ,Location_ID) 
select Distinct p.Emp_ID, p.Emp_NM, p.Email, p.hire_dt, l.Location_ID 
from proj_stg p
join Location l ON l.Location_Name = p.location;

insert into Education (Emp_ID, Education_Level) 
select Distinct p.Emp_ID , p.education_lvl from proj_stg p;

insert into Department (Dep_name)
select distinct department_nm from proj_stg;

insert into Department_Location (Dep_ID, Location_ID)
select DISTINCT d.Dep_ID, l.Location_ID from proj_stg p
join Location l ON l.Location_Name = p.location
join Department d On d.Dep_name = p.department_nm;

insert into Job (Job_Name)
select DISTINCT job_title from proj_stg;

insert into Job_History (Job_ID, Employee_ID, Department_ID, Start_Date, End_Date, Manager_ID)
select j.ID, e.Emp_ID, d.Dep_ID, p.start_dt, p.end_dt, m.Emp_ID from proj_stg p
join Employee e ON e.Emp_ID = p.Emp_ID
join Job j ON j.Job_Name = p.job_title
join Department d ON d.Dep_name = p.department_nm
left join Employee m ON m.Emp_Name = p.manager;

insert into Salary (jobHist_ID, Salary)
select jh.JobHist_ID, p.salary from proj_stg p
join Job_History jh on  jh.Employee_ID = p.Emp_ID and jh.Start_Date= p.start_dt;


------------------------------------------------------
-- CRUD
--1
select e.Emp_Name, j.Job_Name, d.Dep_name from Employee e
join Job_History jh ON e.Emp_ID = jh.Employee_ID
join Job j ON j.ID =  jh.Job_ID
join Department d ON d.Dep_ID = jh.Department_ID;

--2
Insert into Job (Job_Name) values ('Web Programmer');

select * from job;
--3
update Job set Job_Name = 'web developer'
where Job_Name ='Web Programmer';
--4
DELETE from Job where Job_Name = 'web developer';
--5
select  d.Dep_name ,count(jh.Employee_ID )
from Job_History jh
join Department d On d.Dep_ID =jh.Department_ID
where jh.end_date > CURRENT_DATE
Group by d.Dep_name ;

--6
select e.emp_name, j.Job_Name, d.Dep_Name, m.Emp_Name, jh.Start_Date, jh.End_Date from Job_History jh
Join Employee e ON e.Emp_ID = jh.Employee_ID
Join Job j On j.ID = jh.Job_ID
Join Department d on d.Dep_ID =jh.Department_ID
join employee m ON m.emp_Id = jh.Manager_ID
where e.emp_name = 'Toni Lembeck';

--------- optional part

-- 1
CREATE VIEW EmployeeAttributes AS
SELECT e.Emp_ID ,e.Emp_Name ,e.Email  ,e.Hire_date , j.Job_Name ,s.salary ,d.Dep_name , e.Emp_Name as manager, 
jh.Start_date ,jh.End_date ,l.Location_Name ,l.Address ,l.City ,l.State ,edu.Education_Level
from Employee e join Job_History jh on  e.Emp_ID = jh.Employee_ID
join Job j on jh.Job_ID= j.ID
join Education edu on edu.Emp_ID= e.Emp_ID
join Department d on d.Dep_ID= jh.Department_ID
join Location l on l.Location_ID = e.Location_ID
join Salary s on s.JobHist_ID= jh.JobHist_ID 
join Employee m on m.Emp_ID = jh.Manager_ID;

--2


create or replace FUNCTION EmployeeJobs(emp_name_para varchar(50))   
returns TABLE (Emp_name_ varchar(50), job_Name varchar(50), Dep_name varchar(50),manager varchar(50), start_date date, end_date date)
LANGUAGE plpgsql AS $$
BEGIN
RETURN QUERY
select e.Emp_Name, j.Job_Name,d.Dep_Name, m.Emp_Name as manager, jh.Start_date, jh.End_Date 
from Employee e join Job_History jh on  e.Emp_ID = jh.Employee_ID
join Job j on jh.Job_ID= j.ID
join Department d on d.Dep_ID= jh.Department_ID
join Employee m on m.Emp_ID = jh.Manager_ID
where e.Emp_Name= emp_name_para;
End; $$;
--3
CREATE USER jonathan;
REVOKE select on Salary from jonathan;