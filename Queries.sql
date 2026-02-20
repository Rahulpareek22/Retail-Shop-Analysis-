use project;
select * from sales_data;
describe sales_data;

-- change datatype 

ALTER TABLE sales_data
MODIFY Purchase_date DATE;


-- Get the total sales 
select round(sum(Sales)) as total_sales,round(sum(Profit)) as total_profit from sales_data;

-- total quantity sold 
select sum(Quantity) as total_quantity_sold from sales_data 
where year(Purchase_date)=2024;

-- total order month wise
select monthname(Purchase_date) as purchase_month,count(Receipt_ID) as total_order from sales_data
group by Purchase_month
order by total_order desc;

-- total profit 
select round(sum(Profit)) as total_profit from sales_data;


-- top store by sales and profit 

select Store_Name,round(sum(sales)) as total_sales,round(sum(Profit)) as total_profit 
from sales_data
group by Store_name 
order by total_sales desc;

-- most profitble product category and region 
-- Category
select Category,round(sum(Profit)) as total_profit 
from sales_data
group by Category 
order by total_profit desc;

-- Region
select Region ,round(sum(Profit)) as total_profit from sales_data
group by Region
order by total_profit desc ;

-- is dicount effect profit  

select  Discount ,round(sum(profit)) as profit from sales_data
group by Discount
order by Discount asc;

-- 5 most and least profitable sub category
-- most profitable sub-category
select sub_category , round(sum(profit)) as total_profit
from sales_data
group by sub_category
order by  total_profit desc
limit 5; 

-- most least profitable sub-category
select sub_category , round(sum(profit)) as total_profit
from sales_data
group by sub_category
order by  total_profit asc
limit 5;

-- above avg and below avg sales 

select monthname(Purchase_date) as purchase_month,round(sum(sales)) as total_sales,
case when sum(sales) > (select avg(month_total) from (select sum(sales) as month_total from sales_data
                group by month(Purchase_date)) as monthly_avg) then 'above average'
	 when sum(sales) < (select avg(month_total) from (select sum(sales) as month_total from sales_data
                group by month(Purchase_date)) as monthly_avg) then 'below average'
        else 'equal'
end as sales_status
from sales_data
group by month(Purchase_date), monthname(Purchase_date)
order by month(Purchase_date)
;
    
 
 --  most preffered payment mode
select Payment_Method ,count(*) as customers from sales_data
group by Payment_Method 
order by customers desc;


-- lag and lead values for profit in each sub_category

select Category, sub_category, monthname(purchase_date) as purchase_month ,sales, Profit ,
lag(Profit) over(partition by month(purchase_date) order by profit ) as previous_profit,
lead(Profit) over(partition by month(purchase_date) order by profit ) as next_profit 
from sales_data ;

-- Customer Segment performance within each Region
With segment_performance as (
    Select Region, Customer_Segment, 
           round(sum(Sales)) as total_sales,
           round(avg(Profit)) as avg_profit
    from sales_data 
    group by Region, Customer_Segment
)
select *,
    rank() over(partition by Region order by total_sales desc) as sales_rank,
    rank() over (partition by Region order by avg_profit desc) as profit_rank
from segment_performance ;