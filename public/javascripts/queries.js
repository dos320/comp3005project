const Pool = require('pg').Pool
const pool = new Pool({
    user: 'me',
    host: 'localhost',
    database: 'Bookstore',
    password: 'password',
    port: 5432,
});


const getUsers = (req, res) =>{
    pool.query('select * from users order by id asc', (error, results) => {
        if(error){
            throw error
        }
        res.status(200).json(results.rows);
    })
}

const loginUser = (request, response) =>{
    const {email, password} = request.body
    console.log(email + ", " + password);
   
    pool.query('select * from users where email = $1 and password = $2', [email, password], (error, results) =>{
        if(error){
            throw error;
        }
        //console.log("error");
        response.status(200).json(results.rows);
    });
}

const searchBooksByName = (request, response) =>{
    //const id = parseInt(request.params.id);
    const {query} = request.body
    console.log(query);
    pool.query('select * from book where upper(title) like upper(concat(\'%\',\'' + query + '\', \'%\'))', (error, results)=>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    });
}

const searchBooksByGenre = (request, response) => {
    const {query} = request.body;
    pool.query('select * from book where upper(book.genre) like upper(concat(\'%\', \'' + query + '\', \'%\'))', (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchBooksByPublisher = (request, response) => {
    const {query} = request.body;
    pool.query('select * from book where publisher_id = (select id from publisher where upper(name) like upper(concat(\'%\',\''+ query + '\', \'%\')))', (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchBooksByPriceLessThan = (request, response) => {
    const {query} = request.body;
    pool.query('select * from book where price <= $1', [query], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchBooksByPriceGreaterThan = (request, response) => {
    const {query} = request.body;
    pool.query('select * from book where price >= $1', [query], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchBooksByAuthor = (request, response) => {
    const {query} = request.body;
    pool.query('select * from book where book.id in (select book.id from book inner join writes on writes.book_id=book.id inner join author on writes.author_id=author.id where author_id=(select id from author where upper(name) like upper(concat(\'%\',\''+ query + '\', \'%\'))))', (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchForBookPublisher = (request, response) => {
    const {publisherID} = request.body
    pool.query('select publisher.name from publisher where publisher.id = $1', [publisherID], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    });
}

const createNewOrder = (request, response) =>{
    const {userID} = request.body;
    pool.query('insert into orders values ((select max(id)+1 from orders), current_date, $1)', [userID], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const createBookOrder = (request, response) =>{
    const {bookID, quantity} = request.body;
    pool.query('insert into book_order values ($1, (select max(id) from orders), $2)', [bookID, quantity], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const changeStockCount = (request, response) =>{
    const {bookID, quantity} = request.body;
    pool.query('update book set stock_count = stock_count - $2 where id = $1', [bookID, quantity], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchForMyOrders = (request, response) => {
    const {userID} = request.body;
    pool.query('select * from orders where user_id = $1', [userID], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const getExpenditures = (request, response) =>{
    pool.query('select * from book_order inner join book on book.id=book_order.book_id inner join orders on book_order.order_id = orders.id where is_restock = true', (error, results)=>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const getSalesPerGenre = (request, response) =>{
    let strSQL = "select genre, sum(quantity*(book.price - (book.price*book.pub_percentage))) from book inner join book_order on book.id = book_order.book_id where is_restock = false group by genre";
    pool.query(strSQL, (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const getSalesPerAuthor = (request, response) =>{
    let strSQL = "select author.name, author.alt_names, sum((book.price - (book.price*book.pub_percentage))*book_order.quantity) from book inner join writes on book.id = writes.book_id inner join author on author.id = writes.author_id inner join book_order on book.id = book_order.book_id group by author.name, author.alt_names";
    pool.query(strSQL, (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

// adds a book with a given publisher name (and the publisher exists)
const addBook = (request, response) => {
    const {bookTitle, bookPublisher, bookISBN, bookGenre, bookNumPages, bookDatePublished, bookPrice, bookStockCount, bookPubPercentage, bookPubPrice} = request.body;
    pool.query("insert into book values((select max(id)+1 from book), (select id from publisher where name=$2), $1, $3, $4, $5, $6, $7, $8, $9, $10)", [bookTitle, bookPublisher, bookISBN, bookGenre, bookNumPages, bookDatePublished, bookPrice, bookStockCount, bookPubPercentage, bookPubPrice], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const addBookWithNewPublisher = (request, response) =>{
    const {bookTitle, bookISBN, bookGenre, bookNumPages, bookDatePublished, bookPrice, bookStockCount, bookPubPercentage, bookPubPrice} = request.body;
    pool.query("insert into book values((select max(id)+1 from book), (select max(id) from publisher), $1, $2, $3, $4, $5, $6, $7, $8, $9)", [bookTitle, bookISBN, bookGenre, bookNumPages, bookDatePublished, bookPrice, bookStockCount, bookPubPercentage, bookPubPrice], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })

}

const removeBook = (request, response) => {
    const {bookTitle} = request.body;
    pool.query("delete from book where title = $1", [bookTitle], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchForAuthor = (request, response) => {
    const {bookTitle} = request.body;
    pool.query("select author.name from book inner join writes on book.id = writes.book_id inner join author on writes.author_id = author.id where book.title = $1", [bookTitle], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchForPublisherByName = (request, response) => {
    const {bookPublisher} = request.body;
    pool.query("select * from publisher where name = $1", [bookPublisher], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const createUser = (request, response) =>{
    const { registerName, registerEmail, registerPassword, registerBillingBuildingNum, registerBillingStreetName, registerBillingPostalCode, registerBillingCity, registerBillingProvince, registerBillingCountry, registerCardType, registerCardNumber, registerShippingBuildingNum, registerShippingStreetName, registerShippingPostalCode, registerShippingCity, registerShippingProvince, registerShippingCountry} = request.body;
    console.log(request.body);
    pool.query("insert into users values((select max(id)+1 from users), $1::text, $2, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, false, $3)", [registerName, registerEmail, registerPassword, registerBillingBuildingNum, registerBillingStreetName, registerBillingPostalCode, registerBillingCity, registerBillingProvince, registerBillingCountry, registerCardType, registerCardNumber, registerShippingBuildingNum, registerShippingStreetName, registerShippingPostalCode, registerShippingCity, registerShippingProvince, registerShippingCountry], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const searchForAuthorByName = (request, response) => {
    const {authorName} = request.body;
    pool.query("select * from author where name = $1 or $1=ANY(alt_names)", [authorName], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const addAuthor = (request, response) =>{
    const {authorName, birthday, altNames} = request.body;
    pool.query("insert into author values((select max(id)+1 from author), $1, $3, $2)", [authorName, birthday, altNames], (error, results)=>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const addWrites = (request, response) =>{
    const {authorID} = request.body;
    pool.query("insert into writes values($1, (select max(id) from book))", [authorID], (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const addWritesNewAuthor = (request, response) => {
    pool.query("insert into writes values((select max(id) from author), (select max(id) from book))", (error, results) => {
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const addPublisher = (request, response) =>{
    const {publisherName, publisherBuildingNum, publisherStreetName, publisherCity, publisherProvince, publisherCountry, publisherPostalCode, publisherEmail, publisherBankAccountNum, publisherBankName} = request.body;
    pool.query("insert into publisher values((select max(id)+1 from publisher), $1, $2, $3, $4, $5, $6, $7, $8, $9, $10)", [publisherName, publisherBuildingNum, publisherStreetName, publisherCity, publisherProvince, publisherCountry, publisherPostalCode, publisherEmail, publisherBankAccountNum, publisherBankName], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

const getDetailsOfOrder = (request, response) =>{
    const {id} = request.body;
    pool.query("select (select title from book where book.id=book_order.book_id), (select date from orders where orders.id= $1), order_id, quantity, is_restock from book_order where book_order.order_id = $1", [id], (error, results) =>{
        if(error){
            throw error;
        }
        response.status(200).json(results.rows);
    })
}

module.exports = {
    getUsers,
    loginUser,
    searchBooksByName,
    searchForBookPublisher,
    createNewOrder,
    createBookOrder,
    changeStockCount,
    searchForMyOrders,
    getExpenditures,
    getSalesPerGenre,
    getSalesPerAuthor,
    addBook,
    addBookWithNewPublisher,
    removeBook,
    searchForAuthor,
    searchBooksByGenre,
    searchBooksByPublisher,
    searchBooksByAuthor,
    searchBooksByPriceLessThan,
    searchBooksByPriceGreaterThan,
    createUser,
    searchForAuthorByName,
    addAuthor,
    addWrites,
    addWritesNewAuthor,
    searchForPublisherByName,
    addPublisher,
    getDetailsOfOrder,
}

/*
export default{
    _getUsers: getUsers
};*/

