create database music;
use music;
select* from album2;
drop table album;


# Q1. who is the senior most employee based on the job title
select* from employee
order by levels desc
limit 5;


# Q2. which countries have the most invoice
select billing_country, count(invoice_id) from invoice
group by billing_country;


# Q3. what are the top 3 values of total invoice
select total from invoice
order by total desc
limit 3;


# Q4. which city has the best customers? we would like to throw a permotion music festival in the city we made the most money. write a query that returns one city
# that has the highest sum of invoice totals. return both city name and sum of all invoice total

select c.city, sum(i.total)sum_invoice
from customer as c
join invoice as i
on c.customer_id = i.customer_id
group by c.city
order by sum_invoice desc;


# Q5. who is the best customer? the customer who has spent the most money will be declared the best customer. write a query that returns the person who has spent
# the most money
select c.customer_id,c.first_name, c.last_name, sum(i.total)total
from customer as c
join invoice as i
on c.customer_id=i.customer_id
group by c.customer_id,c.first_name,c.last_name
order by total desc
limit 5;


----------------------------------------------------------- Moderate Level ----------------------------------------------------------------------------

# Q1. write a query to return the email, first_name, last_name, & genre of all rock music listeners. return your list ordered aplphabetically by email starting with A
select distinct email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
select track_id from track
join genre on track.genre_id = genre.genre_id
where genre.name = "rock"
)
order by email;


# Q2. lets invite the artists who have written the most rock music in our dataset. write a query that returns 
# the artist name and total track count of the top 10 rock 
select artist.artist_id, artist.name, count(artist.artist_id)total
from track
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id = album2.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name = "Rock"
group by artist_id,name
order by total desc
limit 10;


# Q3. return all the track names that have a song lenght longer than the average song length. return the name and milliseconds for each track. order by the song length
# with the longest songs listed first
select name, milliseconds
from track
where milliseconds > (
select avg(milliseconds)avgerage
from track)
order by milliseconds desc;


----------------------------------------------------- Advance Level ------------------------------------------------------------------------
# Q1. find how much amount spent by each customer on artist? write a query to return customer name, artist name and total spent
with best_selling_artist as (
 select artist.artist_id as artist_id, artist.name as artist_name,
 sum(invoice_line.unit_price*invoice_line.quantity)as total_sales
 from invoice_line
 join track 
 on track.track_id = invoice_line.track_id
 join album2
 on album2.album_id = track.album_id
 join artist
 on artist.artist_id = album2.artist_id
 group by artist_id, artist_name
 order by total_sales desc
 limit 1
 )
 select c.customer_id, c.first_name,c.last_name, bsa.artist_name,
 sum(il.unit_price*il.quantity)as amount_spent
 from invoice i
 join customer c on c.customer_id = i.customer_id
 join invoice_line il on il.invoice_id = i.invoice_id
 join track t on t.track_id = il.track_id
 join album2 alb on alb.album_id = t.album_id
 join best_selling_artist bsa on bsa.artist_id = alb.artist_id
 
 group by customer_id,first_name,last_name,artist_name
 order by amount_spent;
 
 # Q2: we want to find out the most popular music genre for each country. we determine the most popular genre as the genre with the highest amount of purchase
 # write a query that returns each country along with the top genre. for countries where the maximum number of purchases is shared return all genres.
with popular_genre as(
 select count(invoice_line.quantity)as purchase,customer.country,genre.name,genre.genre_id,
 ROW_NUMBER() OVER(PARTITION BY customer.country order by count(invoice_line.quantity)desc)as rowno
 from invoice_line
 join invoice on invoice.invoice_id=invoice_line.invoice_id
 join customer on customer.customer_id = invoice.customer_id
 join track on track.track_id = invoice_line.track_id
 join genre on genre.genre_id = track.genre_id
 group by customer.country,genre.name,genre.genre_id 
 order by customer.country asc,purchase desc
 )
 select * from popular_genre where rowno <=1;
 
 
# write a query that determines the customer that has spent the most on music for each country.write a query that returns a country along with the top customner and
# how much they spent. for countries where the top amount spent is shared, provide all customers who spent this amount
with c_w_c as(
 select customer.customer_id,first_name,last_name,billing_country,sum(total)as total_spending,
 ROW_NUMBER() over(partition by billing_country order by sum(total)desc)as rowno
 from invoice
 join customer on customer.customer_id = invoice.customer_id
 group by customer.customer_id,first_name,last_name,billing_country
 order by billing_country asc,total_spending desc
)
select * from c_w_c where rowno <= 1