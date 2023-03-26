/*SQL PROJECT- MUSIC STORE DATA ANALYSIS
Question Set 1 - Easy
1. Who is the senior most employee based on job title?*/
select * from employee order by levels desc limit 1;
/*2. Which countries have the most Invoices?*/
select  billing_country, count(*) from invoice group by billing_country order by count(*) desc limit 1;
/*3. What are top 3 values of total invoice ? */
select total from invoice order by total desc limit 3;
/*4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals*/
select billing_city, sum(total) from invoice group by billing_city order by sum(total) desc limit 1; 
/*5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money*/
select concat(c.first_name,c.last_name) as name,sum(i.total) as amount 
from customer c join invoice i 
on c.customer_id = i.customer_id
group by c.customer_id
order by amount desc 
limit 1;
/* Question Set 2 – Moderate
1. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A*/
select distinct c.email, concat(c.first_name,c.last_name) as name 
from customer c join invoice i on c.customer_id = i.customer_id 
join invoice_line il on i.invoice_id = il.invoice_id 
where il.track_id in ( select track.track_id from track 
				   join genre on track.genre_id = genre.genre_id 
				   where genre.name = 'Rock' )
order by c.email;
/* 2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */
select distinct a.name, count(t.track_id) as track_ct from artist a join album al on a.artist_id = al.artist_id 
join track t on al.album_id = t.album_id 
join genre g on t.genre_id = g.genre_id
where g.name='Rock' group by a.artist_id order by track_ct desc limit 10;
/* 3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */
select name, milliseconds from track where milliseconds > (select avg(milliseconds) from track) order by milliseconds desc;

/*Question Set 3 – Advance
1. Find how much amount spent by customer on artists? Write a query to return
customer name, artist name and total spent*/
select c.customer_id, c.first_name, c.last_name, a.name, sum(il.unit_price*il.quantity) as total_sales 
from customer c join invoice i on c.customer_id = i.customer_id 
join invoice_line il on i.invoice_id = il.invoice_id 
join track t on il.track_id = t.track_id
join album ab on t.album_id = ab.album_id
join artist a on ab.artist_id = a.artist_id group by 1,2,3,4 order by 5 desc;
/*2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres*/
with popular_genre as 
(
	select i.billing_country, g.name, count(il.quantity) as purchases,
	row_number() over(partition by i.billing_country order by count(il.quantity) desc) as row_no 
	from invoice i join invoice_line il on i.invoice_id = il.invoice_id 
	join track t on il.track_id = t.track_id 
	join genre g on t.genre_id = g.genre_id 
	group by 1,2 order by 1 asc, 3 desc

)
select * from popular_genre where row_no <=1

/*3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/
with top_customer as 
(
	select c.country,c.customer_id,c.first_name,c.last_name,sum(i.total) as amount,
	row_number() over (partition by c.country order by sum(total) desc) as row_no
	from customer c join invoice i on c.customer_id = i.customer_id
	group by 1,2,3,4 order by 1 asc, 5 desc
	
)
select * from top_customer where row_no <=1
commit;
