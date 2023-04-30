-- Who is the senior most employee based on job title?

select employee_id,last_name,first_name,title,hire_date,date_part('year',age(current_date,hire_date)) as senior
from employee
order by senior desc
limit 1;


-- 2. Which countries have the most Invoices?
select billing_Country,count(*) as cnt
from invoice
group by billing_Country
order by cnt desc
limit 1;


-- 3. What are top 3 values of total invoice along with invoice_id?

select invoice_id,total
from invoice
order by total desc
limit 3



/* 
4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals
*/
select * from invoice

select billing_city,sum(total) as total
from invoice
group by billing_city
order by total desc
limit 1



/*
5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money
*/

select c.customer_id,first_name,last_name,city,country,sum(total) as total
from customer c
join invoice i on c.customer_id = i.customer_id
group by c.customer_id,first_name,last_name,city,country
order by total desc
limit 1



/*
6 . Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A
*/


select distinct c.email,c.first_name,c.last_name,g.name 
from genre g
join Track t on t.genre_id = g.genre_id
join Invoice_line il on il.track_id = t.track_id
join Invoice i on i.invoice_id = il.invoice_id
join customer c on c.customer_id=i.customer_id
where g.name = 'Rock'
order by email asc;




/*
7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
*/
select * from artist


select a.name, count(*) as cnt
from Artist a 
join album ab on a.artist_id = ab.artist_id
join track t on ab.album_id = t.album_id
join genre g on g.genre_id  = t.genre_id
where g.name = 'Rock'
group by a.name
order by cnt desc
limit 10

/*
8. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first
*/

select name,milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc



------

/*
9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
*/


select c.customer_id,c.first_name ,c.last_name,ar.name as artist_name,sum(il.unit_price*quantity) as total_spend
from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on t.track_id =il.track_id
join album al on t.album_id = al.album_id
join artist ar on ar.artist_id = al.artist_id
group by c.customer_id,c.first_name,ar.name,c.last_name
order by total_spend desc;

/*
10. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres
*/

-- most popular music for each country
-- find most purchase number(count) country wise



with cte as (
	select billing_country as country,g.name as genre_name,count(*) as cnt ,dense_rank() over(partition by billing_country order by count(*) desc) as rnk
	from genre g 
	join track t on t.genre_id = g.genre_id
	join invoice_line il on t.track_id = il.track_id
	join invoice i on i.invoice_id  = il.invoice_id
	group by billing_country,g.name
)
select country,genre_name ,cnt from cte 
where rnk  = 1

--


/*
11. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount
*/


with cte as (
	select c.customer_id,c.first_name,c.last_name,country,sum(total) as total,
					dense_rank() over(partition by country order by sum(total) desc) as rnk
	from customer c
	join invoice i on i.customer_id = c.customer_id
	group by c.customer_id,c.first_name,c.last_name,country
)
select customer_id,first_name,last_name,total from cte
where rnk = 1	