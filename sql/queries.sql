/*
    COMP3005 Project: By Howard Zhang (101069043) - queries.sql
*/

-- getUsers
select * from users 
order by id asc

-- loginUser
select * from users 
where email = $1 and password = $2

-- searchBooksByName
select * from book 
where upper(title) like upper(concat(\'%\',\'' + query + '\', \'%\'))

-- searchBooksByGenre
select * from book 
where upper(book.genre) like upper(concat(\'%\', \'' + query + '\', \'%\'))

-- searchBooksByPublisher
select * from book 
where publisher_id = (
    select id from publisher 
    where upper(name) like upper(concat(\'%\',\''+ query + '\', \'%\')))

-- searchBooksByPriceLessThan
select * from book 
where price <= $1

-- searchBooksByPriceGreaterThan
select * from book 
where price >= $1

-- searchBooksByAuthor
select * from book 
where book.id 
in (
    select book.id from book 
    inner join writes on writes.book_id=book.id 
    inner join author on writes.author_id=author.id 
    where author_id=(
        select id from author 
        where upper(name) like upper(concat(\'%\',\''+ query + '\', \'%\'))))

-- searchForBookPublisher
select id, name, building_number, street_name, city, province, country, postal_code, email_address, 
(
    select phone_number from pub_phone_number 
    where publisher_id = $1) 
from publisher where publisher.id = $1

-- createNewOrder
insert into orders values ((select max(id)+1 from orders), current_date, $1)

-- createBookOrder
insert into book_order values ($1, (select max(id) from orders), $2)

-- changeStockCount
update book set stock_count = stock_count - $2 where id = $1

-- searchForMyOrders
select * from orders where user_id = $1

-- getExpenditures
select * from book_order 
inner join book on book.id=book_order.book_id 
inner join orders on book_order.order_id = orders.id 
where is_restock = true

-- getSalesPerGenre
select genre, sum(quantity*(book.price - (book.price*book.pub_percentage))) from book 
inner join book_order 
on book.id = book_order.book_id 
where is_restock = false 
group by genre

-- getSalesPerAuthor
select author.name, author.alt_names, 
sum((book.price - (book.price*book.pub_percentage))*book_order.quantity) 
from book 
inner join writes on book.id = writes.book_id 
inner join author on author.id = writes.author_id 
inner join book_order on book.id = book_order.book_id 
group by author.name, author.alt_names

-- addBook
insert into book values((select max(id)+1 from book), 
(select id from publisher where name=$2), $1, $3, $4, $5, $6, $7, $8, $9, $10)

-- addBookWithNewPublisher
insert into book values((select max(id)+1 from book), 
(select max(id) from publisher), $1, $2, $3, $4, $5, $6, $7, $8, $9)

-- removeBook
with i as (
    delete from book where title = $1), 
j as (
    delete from writes 
    where writes.book_id = (select id from book where upper(title) = upper($1)))
delete from book_order 
where book_order.book_id = (select id from book where book.title = $1);

-- searchForAuthor
select author.name from book 
inner join writes on book.id = writes.book_id 
inner join author on writes.author_id = author.id 
where book.title = $1

-- searchForPublisherByName
select * from publisher 
where name = $1

-- createUser
with i as (
    insert into users 
    values((select max(id)+1 from users), $1::text, $2, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, false, $3)
    ) 
insert into user_phone_number 
values ((select max(id)+1 from users), $18)

-- searchForAuthorByName
select * from author 
where name = $1 or $1=ANY(alt_names)

-- addAuthor
insert into author 
values((select max(id)+1 from author), $1, $3, $2)

-- addWrites
insert into writes 
values($1, (select max(id) from book))

-- addWritesNewAuthor
insert into writes 
values((select max(id) from author), (select max(id) from book))

-- addPublisher
with i as (
    insert into publisher 
    values((select max(id)+1 from publisher), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)) 
insert into pub_phone_number 
values ((select max(id)+1 from publisher), $11);

-- getDetailsOfOrder
select (select title from book where book.id=book_order.book_id), 
(select date from orders where orders.id= $1), order_id, quantity, is_restock 
from book_order 
where book_order.order_id = $1

