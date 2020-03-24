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

module.exports = {
    getUsers,
    loginUser,
    searchBooksByName,
    searchForBookPublisher,
    createNewOrder,
    createBookOrder,
    changeStockCount,
    searchForMyOrders,
}

/*
export default{
    _getUsers: getUsers
};*/

