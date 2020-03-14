const Pool = require('pg').Pool
const pool = new Pool({
    user: 'me',
    host: 'localhost',
    database: 'project',
    password: 'password',
    port: 5432,
});

/*
const getUsers = (req, res) =>{
    pool.query('select * from users order by id asc', (error, results) => {
        if(error){
            throw error
        }
        res.status(200).json(results.rows);
    })
}*/

