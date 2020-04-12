-- this function creates a trigger that triggers upon updating a book in the database
-- checks if its stock_count dips below 5
-- if it does, order the amount of orders that the book in question received in the past month.
-- update all related tables (book_order, order, book) with relevant information
-- create an order in order, attach a book_order to it with the quantity ordered, and update the book's stock_count
create or replace function auto_order_books_function() returns trigger as 
$body$
	declare 
		temprow record;
	begin
		-- scans every book in the database
		for temprow in (select * from book) loop
			-- only works on books that have less than 5 in stock
            if(temprow.stock_count < 5) then
				-- create order to attach a new book_order to
                insert into orders
				values((select max(id)+1 from orders), current_date, 0);
				
				-- inserts a new book_order
                -- ATTRIBUTES --
                -- book id: current book
                -- order_id: most recent order
                -- quantity: the amount ordered of that book in the past month
                -- is_restock: true, as this is an automatically ordered restock
                insert into book_order
				values(temprow.id, (select max(id) from orders), (select distinct sum(book_order.quantity) 
				from book inner join book_order on book.id = book_order.book_id inner join orders on book_order.order_id = orders.id
				where date_part('month', to_date(orders.date, 'yyyy-MM-DD')) = date_part('month', current_date) -1
				and book.id in (select book.id from book where book.stock_count < 5 and book.stock_count >0)
			 																		and book.id=temprow.id), true);
			 	
                 -- updates the current book with the newly ordered number of that book (number of that book ordered in the past month) + the existing amount of that book
                update book
				set stock_count =
					stock_count + (select distinct  sum(book_order.quantity) 
					from book inner join book_order on book.id = book_order.book_id inner join orders on book_order.order_id = orders.id
					where date_part('month', to_date(orders.date, 'yyyy-MM-DD')) = date_part('month', current_date) -1
					and book.id in (select book.id from book where book.stock_count < 5 and book.stock_count > 0)
					and book.id=temprow.id)
				where book.stock_count < 5 and book.stock_count >0 and book.id=temprow.id;
			end if;
		end loop;
		return null;
	end;
$body$
language plpgsql;