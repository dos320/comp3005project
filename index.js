const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const port = 3000;
const db = require('./public/javascripts/queries');

app.use(express.static(__dirname + "/public/"));
app.use(bodyParser.json());
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
);

app.get('/', (req, res)=>{
    //res.json({info: 'test'});
    res.sendFile('./index.html', {root: __dirname});
});

app.get('/api/users', db.getUsers);
app.post('/api/loginUser', db.loginUser);

app.listen(port, ()=>{
    console.log(`App running on port ${port}.`);
});