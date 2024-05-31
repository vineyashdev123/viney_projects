SELECT * FROM Sales_Data_Project.`tableconvert.com_oy7hyb`;
use Sales_Data_Project;
Select distinct status from `tableconvert.com_oy7hyb`; #can plot
select distinct year_id from `tableconvert.com_oy7hyb`;
select distinct PRODUCTLINE from `tableconvert.com_oy7hyb`;
select distinct COUNTRY from `tableconvert.com_oy7hyb`;
select distinct DEALSIZE from `tableconvert.com_oy7hyb`;
select distinct TERRITORY from `tableconvert.com_oy7hyb`;


# ANALYSIS
#sum of sales by product line
select PRODUCTLINE, count(SALES) as Total_Products_Sold,sum(SALES) Revenue # ALIAS/as is not necessary to be used
 from `tableconvert.com_oy7hyb` group by PRODUCTLINE 
 order by 2 desc; 
 
 #months active in year and monthly sales
 select YEAR_ID, MONTH_ID, count(MONTH_ID), sum(MONTH_ID) from `tableconvert.com_oy7hyb`group by YEAR_ID, MONTH_ID;
 
 select YEAR_ID, sum(sales) Revenue from 
 `tableconvert.com_oy7hyb` 
 group by YEAR_ID
 order by 2 desc;
 
 select DEALSIZE, sum(sales) Revenue from 
 `tableconvert.com_oy7hyb` 
 group by DEALSIZE
 order by 2 desc;
 
 #best month for sales in specific years? how much was earned?
 select MONTH_ID, sum(sales) Revenue, count(ORDERNUMBER) Frequency 
 from `tableconvert.com_oy7hyb` 
 where YEAR_ID = 2004 # change year to see for another year
 group by MONTH_ID
 order by 2 desc;
 
 #What product is sold max in 11 month
 select MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER) Frequency 
 from `tableconvert.com_oy7hyb` 
 where YEAR_ID = 2004 and MONTH_ID=11 # change year to see for another year
 group by MONTH_ID, PRODUCTLINE
 order by 2 desc;
 
 # who is our best customer using RFM analysis
 # had to convert initial orderdate which was in text format into datetime in another sheet by first adding new column then UPDATE `tableconvert.com_oy7hyb`
#SET ConvertedOrderDate = STR_TO_DATE(ORDERDATE, '%c/%e/%Y %H:%i'); and then dropping initial column and at last renaming the added column
Create table rfm_table as
 with rfm as (
 select 
 CUSTOMERNAME,
 sum(sales) MonetaryValue,
 avg(sales) Avgmonetaryvalue,
 count(ORDERNUMBER) Frequency,
 max(ORDERDATE) last_order_date,
  (select max(ORDERDATE) from `tableconvert.com_oy7hyb`) as max_order_date,
  DATEDIFF((select max(ORDERDATE) from `tableconvert.com_oy7hyb`), max(ORDERDATE)) as Recency
from `tableconvert.com_oy7hyb`
group by CUSTOMERNAME),
rfm_calc as 
(
select *,
NTILE(4) OVER (order by Recency) rfm_recency,
NTILE(4) OVER (order by Frequency) rfm_Frequency,
NTILE(4) OVER (order by Avgmonetaryvalue) rfm_monetary
from rfm)
select *, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell,
CONCAT(rfm_recency, rfm_frequency, rfm_monetary) AS rfm_cell_string
#cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + (rfm_monetary as varchar)rfm_cell_string
from rfm_calc;

select * from rfm_table;
select CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,rfm_segment from rfm_table;

#let's divide customers /created new column and gave them value in case statements.
alter table rfm_table add rfm_segment varchar(255);
update rfm_table set rfm_segment=
case
when rfm_cell_string in (111,112,122,121,123,132,211,212,114,141) then 'lost_customers'
when rfm_cell_string in (133,134,143,244,334,343,344,144) then 'slipping away, cant loose them'
when rfm_cell_string in (311,411,331) then 'new customers'
when rfm_cell_string in (222,223,233,322,231) then 'potential customers'
when rfm_cell_string in (323,333,321,422,332,432) then 'active'
when rfm_cell_string in (433,434,443,444) then 'loyal'
end;

#what products are most often sold?
select ORDERNUMBER, count(*) from `tableconvert.com_oy7hyb` 
where STATUS = 'Shipped'
group by ORDERNUMBER 
order by ORDERNUMBER desc;