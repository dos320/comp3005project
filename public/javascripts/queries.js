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
    })
}

const searchBooksByName = (req, res) =>{
    const id = parseInt(request.params.id);

    pool.query('select * from book where id = $1', [id], (error, results)=>{
        if(error){
            throw error;
        }
        res.status(200).json(results.rows);
    })
}

module.exports = {
    getUsers,
    loginUser,
}

/*
export default{
    _getUsers: getUsers
};*/

