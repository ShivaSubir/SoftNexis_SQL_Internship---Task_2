use employees_sample;

/* 
Department Salary Summary: 
Calculated active employee count, average salary range, minimum salary range, maximum salary range, difference between maximum & minimum salary range
*/
select d.dept_name as Department, count(distinct e.emp_no) as Employees,
round(avg(s.salary), 2) as Avg_Salary, format(min(s.salary), 0) as Min_Salary,
format(max(s.salary), 0) as Max_Salary, format(max(s.salary) - min(s.salary), 0) as Salary_Range
from departments d join dept_emp de on d.dept_no = de.dept_no
join employees e on de.emp_no = e.emp_no join salaries s on e.emp_no = s.emp_no
where de.to_date > curdate() and s.to_date > curdate()
group by d.dept_name order by Avg_Salary desc;

/*
Yearly Hiring Trends (1985-1995):
Calculated counts of new hires per year & used LAG function to calculate year over year change & growth percentage
*/
select year(hire_date) as Hire_Year, count(*) as New_Hires, 
count(*) - lag(count(*)) over (order by year(hire_date)) as YOY_Change,
concat(round(100 * (count(*) - lag(count(*)) over (order by year(hire_date))) / lag(count(*)) over (order by year(hire_date)), 1), '%') as Growth_Rate
from employees group by Hire_Year having Hire_Year between 1985 and 1995
order by Hire_Year;

/*
High Earning Departments:
Filters grouped department results to show only large departments (> 10000 staff) with an average salary above $70000
*/
select d.dept_name, round(avg(s.salary)) as avg_salary, count(*) as employees
from departments d join dept_emp de on d.dept_no = de.dept_no 
join salaries s on de.emp_no = s.emp_no where s.to_date > curdate()
group by d.dept_name having avg(s.salary) > 70000 and count(*) > 10000;

/*
Salary Distribution of Sales Department:
Grouped current sales department salaries into $10000 brackets & calculated each bracket's percentage share
*/
select d.dept_name, floor(s.salary / 10000) * 10000 as Salary_Bucket,
count(*) as Employees, lpad(concat(round(100 * count(*) / sum(count(*))
over (partition by d.dept_name), 1), '%'), 5, ' ') as Distribution
from departments d join dept_emp de on d.dept_no = de.dept_no
join salaries s on de.emp_no = s.emp_no where s.to_date > curdate()
and d.dept_name = 'Sales' group by d.dept_name, Salary_Bucket
order by Salary_Bucket;


-- Validation Queries:

/*
Verified total current active employees
Count of distinct employees who currently have an active salary record - to_date in the future
*/
select count(distinct emp_no) as total_current_employees
from salaries where to_date > curdate();

/*
Checked for Null department assignments
Verified data completeness by counting any department records missing a department number
*/
select count(*) as null_dept_count from dept_emp where dept_no is null;
