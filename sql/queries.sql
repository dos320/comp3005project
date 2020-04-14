/*
    COMP3005 Project: By Howard Zhang (101069043) - queries.sql
*/
-- all of the $(number) symbols are used to represent values retrieved from the HTML front end.

-- getUsers
-- gets all the users from the database.
select * from users 
order by id asc

-- loginUser
-- used to validate the user's entered password and email to log them into the system.
select * from users 
where email = $1 and password = $2

-- searchBooksByName
-- used to conduct an approximate search for a book by its title based on a query provided by a user.
select * from book 
where upper(title) like upper(concat('%\', query, '%'))

-- searchBooksByGenre
-- used to conduct an approximate search for a book by its genre based on a query provided by a user.
select * from book 
where upper(book.genre) like upper(concat('%', query, '%'))

-- searchBooksByPublisher
-- used to conduct an approximate search for a book based on its publisher based on a query provided by a user.
select * from book 
where publisher_id = (
    select id from publisher 
    where upper(name) like upper(concat('%', query, '%')))

-- searchBooksByPriceLessThan
-- used to search for books that are less than or equal to a certain price based on a price provided by a user.
select * from book 
where price <= $1

-- searchBooksByPriceGreaterThan
-- used to search for books that are greater than or equal to a certain price based on a price provided by a user.
select * from book 
where price >= $1

-- searchBooksByAuthor
-- used to conduct an approximate search for a book based on an author name based on a query provided by a user.
select * from book 
where book.id 
in (
    select book.id from book 
    inner join writes on writes.book_id=book.id 
    inner join author on writes.author_id=author.id 
    where author_id=(
        select id from author 
        where upper(name) like upper(concat('%', query, '%'))))

-- searchForBookPublisher
-- used to getting information on a specific publisher based on a provided id
select id, name, building_number, street_name, city, province, country, postal_code, email_address, 
(
    select phone_number from pub_phone_number 
    where publisher_id = $1) 
from publisher where publisher.id = $1

-- createNewOrder
-- used to create a new order using a provided userID - used in conjunction with createBookOrder and changeStockCount.
insert into orders values ((select max(id)+1 from orders), current_date, $1)

-- createBookOrder
-- creates a new book_order using a provided bookID and quantity.
insert into book_order values ($1, (select max(id) from orders), $2)

-- changeStockCount
-- changes the stock count of a book (based on a provided ID) based on how many were purchased (provided value). This update potentially triggers the "order more books trigger".
update book set stock_count = stock_count - $2 where id = $1

-- searchForMyOrders
-- searches for all orders belonging to a given user
select * from orders where user_id = $1

-- getExpenditures
-- used to generate the expenditure report 
-- selects all the book purchases from book/orders/book_order that were restocks, and other info pertaining each of these orders.
-- the program then takes this information and creates a report using it.
select * from book_order 
inner join book on book.id=book_order.book_id 
inner join orders on book_order.order_id = orders.id 
where is_restock = true

-- getSalesPerGenre
-- used to generate the sales per genre report
-- selects all of the book sales from book_order/book, and groups them based on genre.
-- subtracts each book's publisher cut from the net gain
-- the program then takes this information and creates a report using it.
select genre, sum(quantity*(book.price - (book.price*book.pub_percentage))) from book 
inner join book_order 
on book.id = book_order.book_id 
where is_restock = false 
group by genre

-- getSalesPerAuthor
-- used to generate the sales per author report
-- subtracts each book's publisher cut from the net gain
-- selects from the book/author/writes/book_order tables
-- the program then takes this information and creates a report using it.
select author.name, author.alt_names, 
sum((book.price - (book.price*book.pub_percentage))*book_order.quantity) 
from book 
inner join writes on book.id = writes.book_id 
inner join author on author.id = writes.author_id 
inner join book_order on book.id = book_order.book_id 
group by author.name, author.alt_names

-- addBook
-- used when the provided publisher exists
-- adds a book to the database using values that are provided by the owner
-- increments the id counter to keep it unique
insert into book values((select max(id)+1 from book), 
(select id from publisher where name=$2), $1, $3, $4, $5, $6, $7, $8, $9, $10)

-- addBookWithNewPublisher
-- used when the provided publisher doesn't exist in the database.
-- adds a book to the database using values that are provided by the owner.
-- increments the id counter to keep it unique.
insert into book values((select max(id)+1 from book), 
(select max(id) from publisher), $1, $2, $3, $4, $5, $6, $7, $8, $9)

-- removeBook
-- removes a book and all associated connections from the database, based on information provided by the owner.
-- uses the with keyword as the plugin I use doesn't allow multiple statements in a single query 
with i as (
    delete from book where title = $1), 
j as (
    delete from writes 
    where writes.book_id = (select id from book where upper(title) = upper($1)))
delete from book_order 
where book_order.book_id = (select id from book where book.title = $1);

-- searchForAuthor
-- searches for an author in the database based on a provided book title
-- used to display information about authors who wrote a particular book
select author.name from book 
inner join writes on book.id = writes.book_id 
inner join author on writes.author_id = author.id 
where book.title = $1

-- searchForPublisherByName
-- searches for a publisher with a particular name
select * from publisher 
where name = $1

-- createUser
-- creates a new user with a bunch of user-provided values given during registration
-- increments the id in users to keep it unique
-- inserts into the user_phone_number table as well using the user's given phone number
-- uses with as muitlple statements are not allowed in a single query.
with i as (
    insert into users 
    values((select max(id)+1 from users), $1::text, $2, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, false, $3)
    ) 
insert into user_phone_number 
values ((select max(id)+1 from users), $18)

-- searchForAuthorByName
-- searches for authors using a provided name.
-- looks for that name in both both their name and their alt_names attributes, which is an array of varchars
select * from author 
where name = $1 or $1=ANY(alt_names)

-- addAuthor
-- adds a new author into the database using user-provided values.
-- increments the max id by 1, as this is a new author
insert into author 
values((select max(id)+1 from author), $1, $3, $2)

-- addWrites
-- inserts a new entry into writes to associate an existing author with a new book
-- used in conjunction with addAuthor
-- uses a user-provided authorID, the author must be existing
-- used in conjunction with addBook during book creation
insert into writes 
values($1, (select max(id) from book))

-- addWritesNewAuthor
-- adds a add new writes entry to a newly added author and book - used in conjunction with addAuthor
insert into writes 
values((select max(id) from author), (select max(id) from book))

-- addPublisher
-- adds a new publisher into the database using user-provided values
-- increments the id of publisher to keep the IDs unique
with i as (
    insert into publisher 
    values((select max(id)+1 from publisher), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)) 
insert into pub_phone_number 
values ((select max(id)+1 from publisher), $11);

-- getDetailsOfOrder
-- gets details of a book order, used by the program to display whenever the user clicks an order
-- uses a provided id fetched from the program
select (select title from book where book.id=book_order.book_id), 
(select date from orders where orders.id= $1), order_id, quantity, is_restock 
from book_order 
where book_order.order_id = $1

