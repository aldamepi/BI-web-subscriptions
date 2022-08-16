use webSubscriptions;

-- CREATE TABLE -- Table Data Import Wizard


ALTER TABLE subscriptions RENAME column MyUnknownColumn to id;

select * from subscriptions;


-- 1
-- Write a query that calculates cumulative growth of the number of subscription purchases each
-- month, split by subscription type. 

select date_format(sale_date, '%b %y') as saleMonth, license_name, operation_type, billing_period, count(billing_plan_price) as n_purchases
from subscriptions
where operation_type = 'purchase' and billing_period = 'month'
group by saleMonth, license_name;

--  

select license_name, sale_year, sale_month, count(billing_plan_price) as n_purchases
from subscriptions
where operation_type = 'purchase' and billing_period = 'month'
group by sale_year, sale_month, license_name
order by license_name, sale_year, sale_month;

--


select *, purch_growth/lag(n_purchases) over(PARTITION BY license_name) as cum_growth
from (
	select *, n_purchases-lag(n_purchases) over(PARTITION BY license_name) as purch_growth
	from(  
		select license_name, sale_year, sale_month, count(billing_plan_price) as n_purchases
		from subscriptions
		where operation_type = 'purchase' and billing_period = 'month'
		group by sale_year, sale_month, license_name
		order by license_name, sale_year, sale_month
        ) group1
	) w1;



-- FINAL ANSWER 1:


select *, (n_purchases/lag(n_purchases) over(PARTITION BY license_name))-1 as cum_growth
from(  
	select license_name, sale_year, sale_month, count(billing_plan_price) as n_purchases
	from subscriptions
	where operation_type = 'purchase' and billing_period = 'month'
	group by sale_year, sale_month, license_name
	order by license_name, sale_year, sale_month
	) group1;
	






--
--


-- 2
-- perform a cohort analysis to calculate % Retention Rate. Focus on the users who have bought only monthly subscriptions

select * from subscriptions;


-- Get the first month of purchase

select *, min(sale_month) over(partition by license_id) as first_purch
from subscriptions
where sale_month not in(6,12) and billing_period = 'month';


-- Retention Gap

select license_id, sale_month, first_purch,
	sale_month - first_purch as n_months
from(
	select *, min(sale_month) over(partition by license_id) as first_purch
	from subscriptions
	where sale_month not in(6,12) and billing_period = 'month'    
	)fm;



-- Cohort Analysis

select first_purch as 'Month of First Purchase',
sum(case when n_months = 0 then 1 else 0 end) as 'Number of users',
sum(case when n_months = 1 then 1 else 0 end) as 'January 2021',
sum(case when n_months = 2 then 1 else 0 end) as 'February 2021',
sum(case when n_months = 3 then 1 else 0 end) as 'March 2021',
sum(case when n_months = 4 then 1 else 0 end) as 'April 2021',
sum(case when n_months = 5 then 1 else 0 end) as 'May 2021'
from(
	select license_id, sale_month, first_purch,
		sale_month - first_purch as n_months
	from(
		select *, min(sale_month) over(partition by license_id) as first_purch
		from subscriptions
		where sale_month not in(6,12) and billing_period = 'month'    
		)fm
	)gap
group by first_purch
order by first_purch;



-- Cohort Analysis with percentages

select first_purch as 'Month of First Purchase',
sum(case when n_months = 0 then 1 else 0 end) as 'Number of users',
concat(cast(round(100*sum(case when n_months = 1 then 1 else 0 end)/sum(case when n_months = 0 then 1 else 0 end),1) as char),'%') as 'January 2021',
concat(cast(round(100*sum(case when n_months = 2 then 1 else 0 end)/sum(case when n_months = 0 then 1 else 0 end),1) as char),'%') as 'February 2021',
concat(cast(round(100*sum(case when n_months = 3 then 1 else 0 end)/sum(case when n_months = 0 then 1 else 0 end),1) as char),'%') as 'March 2021',
concat(cast(round(100*sum(case when n_months = 4 then 1 else 0 end)/sum(case when n_months = 0 then 1 else 0 end),1) as char),'%') as 'April 2021',
concat(cast(round(100*sum(case when n_months = 5 then 1 else 0 end)/sum(case when n_months = 0 then 1 else 0 end),1) as char),'%') as 'May 2021'
from(
	select license_id, sale_month, first_purch,
		sale_month - first_purch as n_months
	from(
		select *, min(sale_month) over(partition by license_id) as first_purch
		from subscriptions
		where sale_month not in(6,12) and billing_period = 'month'    
		)fm
	)gap
group by first_purch
order by first_purch;








	





