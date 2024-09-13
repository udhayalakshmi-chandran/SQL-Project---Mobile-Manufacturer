--SQL Advance Case Study


/*Q1--BEGIN . List all the states in which we have customers who have bought cellphones 
from 2005 till today.*/

Select distinct l.[State] from [dbo].[DIM_LOCATION] as l left join [dbo].[FACT_TRANSACTIONS] as f 
on l.IDLocation=f.IDLocation left join [dbo].[DIM_DATE] as d on d.DATE=f.Date where d.[YEAR]>=2005

--Q1--END

--Q2--BEGIN What state in the US is buying the most 'Samsung' cell phones? 
	
Select Distinct top 1 l.[State], l.[Country], m.[Manufacturer_Name],sum(f.Quantity) as Qty  from [dbo].[DIM_MODEL] as mo left join 
[dbo].[DIM_MANUFACTURER] as m on m.IDManufacturer=mo.IDManufacturer left join
[dbo].[FACT_TRANSACTIONS] as f on f.IDModel=mo.IDModel left join
[dbo].[DIM_LOCATION] as l on f.IDLocation=l.IDLocation where l.Country='US' and m.Manufacturer_Name='Samsung'
group by l.[State], l.[Country],m.[Manufacturer_Name] order by sum(f.Quantity) desc


--Q2--END

--Q3--BEGIN . Show the number of transactions for each model per zip code per state.      

Select distinct l.ZipCode, mo.Model_Name,l.[State],count(t.TotalPrice) as No_of_transac from [dbo].[DIM_LOCATION] as l
left join [dbo].[FACT_TRANSACTIONS] as t on l.[IDLocation] = t.[IDLocation] left join
[dbo].[DIM_MODEL] as mo on mo.IDModel=t.IDModel Group by l.[State],mo.Model_Name, l.ZipCode 
order by No_of_transac desc


--Q3--END

--Q4--BEGIN Show the cheapest cellphone (Output should contain the price also)
Select top 1 m.[Manufacturer_Name], mo.[Model_Name], mo.[Unit_price] from [dbo].[DIM_MODEL] as mo
left join [dbo].[DIM_MANUFACTURER] as m on m.IDManufacturer=mo.IDManufacturer
order by mo.Unit_price

--Q4--END

/*Q5--BEGIN  Find out the average price for each model in the top5 manufacturers in 
terms of sales quantity and order by average price.*/ 

With top_manufacturer as (
Select top 5 m.[IDManufacturer], m.[Manufacturer_Name], SUM(t.[Quantity]) as Sales_Quantity from  [dbo].[DIM_MODEL] as mo
join [dbo].[DIM_MANUFACTURER] as m on mo.IDManufacturer = m.IDManufacturer 
join [dbo].[FACT_TRANSACTIONS] as t on t.IDModel = mo.IDModel 
group by m.[IDManufacturer], m.[Manufacturer_Name]
order by  SUM(t.[Quantity]) desc
)
Select tm.Manufacturer_Name,mo.[Model_Name], AVG(mo.[Unit_price]) as Avg_Price
from [dbo].[DIM_MODEL] as mo
join top_manufacturer as tm on mo.IDManufacturer = tm.IDManufacturer 
group by mo.[Model_Name],tm.Manufacturer_Name
order by Avg_Price

--Q5--END

/*Q6--BEGIN . List the names of the customers and the average amount spent in 2009, 
where the average is higher than 500*/

Select c.[Customer_Name], AVG(t.[TotalPrice]) as Average_Amount , d.[YEAR] from [dbo].[DIM_CUSTOMER] as c join 
[dbo].[FACT_TRANSACTIONS] as t on c.IDCustomer=t.IDCustomer inner join [dbo].[DIM_DATE] as d on d.DATE=t.Date  group by d.YEAR, c.Customer_Name 
having d.YEAR like '2009' and  AVG(t.[TotalPrice])>=500 order by Average_Amount desc


--Q6--END
	
/*Q7--BEGIN  List if there is any model that was in the top 5 in terms of quantity, 
simultaneously in 2008, 2009 and 2010 */
	
 
/*Select top 5 mo.IDModel, mo.[Model_Name], sum(t.[Quantity]) as Qty, d.[YEAR] from [dbo].[DIM_MODEL] as mo inner join [dbo].[FACT_TRANSACTIONS] as t
on mo.IDModel=t.IDModel left join [dbo].[DIM_DATE] as d on d.DATE=t.Date where d.YEAR in (2008) group by mo.IDModel, mo.[Model_Name], d.[YEAR]
union
Select top 5 mo.IDModel, mo.[Model_Name], sum(t.[Quantity]) as Qty, d.[YEAR]  from [dbo].[DIM_MODEL] as mo inner join [dbo].[FACT_TRANSACTIONS] as t
on mo.IDModel=t.IDModel inner join [dbo].[DIM_DATE] as d on d.DATE=t.Date where d.YEAR in (2009) group by mo.IDModel, mo.[Model_Name], d.[YEAR]
union
Select top 5 mo.IDModel, mo.[Model_Name], sum(t.[Quantity]) as Qty, d.[YEAR] from [dbo].[DIM_MODEL] as mo inner join [dbo].[FACT_TRANSACTIONS] as t
on mo.IDModel=t.IDModel inner join [dbo].[DIM_DATE] as d on d.DATE=t.Date where d.YEAR in (2010) group by mo.IDModel, mo.[Model_Name], d.[YEAR]
 
 order by d.YEAR,sum(t.Quantity) desc*/

With ModelSales as (
Select t.IDModel, m.Model_Name, d.YEAR, Sum(t.Quantity) AS TotalQuantity,
Rank() OVER (PARTITION BY d.YEAR ORDER BY Sum(t.Quantity) DESC) AS QuantityRank
From FACT_TRANSACTIONS t
join DIM_MODEL m ON t.IDModel = m.IDModel 
join [dbo].[DIM_DATE] as d on d.DATE=t.Date
where d.YEAR IN (2008, 2009, 2010)
group by t.IDModel, m.Model_Name, d.YEAR
)

Select IDModel, Model_Name, [Year] From ModelSales
where QuantityRank <= 5

--Q7--END

/*Q8--BEGIN Show the manufacturer with the 2nd top sales in the year of 2009 and the 
manufacturer with the 2nd top sales in the year of 2010.*/ 

/*Select  m.[Manufacturer_Name],d.[YEAR], Sum(t.[TotalPrice]) as Sales_Amount,
RANK() over (order by Sum(t.[TotalPrice]) desc)R 
from [dbo].[DIM_DATE]  as d inner join
[dbo].[FACT_TRANSACTIONS] as t on d.DATE=t.Date inner join [dbo].[DIM_MODEL] as mo on mo.IDModel=t.IDModel
inner join [dbo].[DIM_MANUFACTURER] as m on m.IDManufacturer=mo.IDManufacturer  Group by d.YEAR,m.Manufacturer_Name having d.YEAR in (2009) 

 union

Select  m.[Manufacturer_Name],d.[YEAR], Sum(t.[TotalPrice]) as Sales_Amount,
RANK() over (order by Sum(t.[TotalPrice]) desc)R
from [dbo].[DIM_DATE]  as d inner join
[dbo].[FACT_TRANSACTIONS] as t on d.DATE=t.Date inner join [dbo].[DIM_MODEL] as mo on mo.IDModel=t.IDModel
inner join [dbo].[DIM_MANUFACTURER] as m on m.IDManufacturer=mo.IDManufacturer Group by d.YEAR,m.Manufacturer_Name having d.YEAR in (2010)

order by R, Sum(t.TotalPrice) desc
offset 2 rows
Fetch next 2 rows only*/

With Top_Sales as (
Select m.[Manufacturer_Name], d.[YEAR], Sum(t.[TotalPrice]) as SalesAmount,
Rank() over (partition by d.[YEAR] order by Sum(t.[TotalPrice]) desc) as [Rank] from [dbo].[FACT_TRANSACTIONS] as t
join [dbo].[DIM_MODEL] mo on t.IDModel=mo.IDModel join [dbo].[DIM_MANUFACTURER] as m on m.IDManufacturer = mo.IDManufacturer
join [dbo].[DIM_DATE] d on d.DATE = t.Date 
group by m.[Manufacturer_Name], d.[YEAR] having d.YEAR in (2009,2010))

Select [Manufacturer_Name], [YEAR], SalesAmount from Top_Sales
where [Rank] = 2



--Q8--END
--Q9--BEGIN  Show the manufacturers that sold cellphones in 2010 but did not in 2009.
	
Select distinct m.IDManufacturer, m.Manufacturer_Name from DIM_MANUFACTURER m
join DIM_MODEL mo on m.IDManufacturer = mo.IDManufacturer
join FACT_TRANSACTIONS t on mo.IDModel = t.IDModel
where YEAR(t.Date) = 2010 and m.IDManufacturer not in 

(Select distinct m2.IDManufacturer from DIM_MANUFACTURER m2
join DIM_MODEL mo2 on m2.IDManufacturer = mo2.IDManufacturer
join FACT_TRANSACTIONS t2 on mo2.IDModel = t2.IDModel
where YEAR(t2.Date) = 2009)


--Q9--END

/*Q10--BEGIN Find top 10 customers and their average spend, average quantity by each 
year. Also find the percentage of change in their spend.*/
	
With CustomerSpend as(
SElect c.[IDCustomer], c.[Customer_Name], Year(t.[Date])[Year],Avg(t.[TotalPrice]) as Avg_Spend, Avg(t.[Quantity]) as Avg_Qty,
Rank() over(partition by Year(t.[Date]) order by sum(t.[TotalPrice]) desc) as RankbySpend
from [dbo].[DIM_CUSTOMER] as c join [dbo].[FACT_TRANSACTIONS] as t on c.IDCustomer = t.IDCustomer
group by c.[IDCustomer], c.[Customer_Name], Year(t.[Date]))

Select c1.[IDCustomer], c1.[Customer_Name], c1.[Year] as CurrentYear , c2.[Year] as PreviousYear,
c1.Avg_Spend as CurrentSpend, c2.Avg_Spend as PreviousSpend,
((c1.Avg_Spend-c2.Avg_Spend)*100/c2.Avg_Spend) as Pct_Change
from CustomerSpend as c1 join CustomerSpend as c2
on c1.IDCustomer = c2.IDCustomer and c1.[Year] = c2.[Year] + 1
where c1.RankbySpend <=10
Order by c1.Year, c1.RankbySpend

--Q10--END

