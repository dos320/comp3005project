/*
    COMP3005 Project: By Howard Zhang (101069043) - index.js
*/
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
app.post('/api/searchBooksByName', db.searchBooksByName);
app.post('/api/searchBooksByGenre', db.searchBooksByGenre);
app.post('/api/searchBooksByPublisher', db.searchBooksByPublisher);
app.post('/api/searchBooksByPriceLessThan', db.searchBooksByPriceLessThan);
app.post('/api/searchBooksByPriceGreaterThan', db.searchBooksByPriceGreaterThan);
app.post('/api/searchForBookPublisher', db.searchForBookPublisher);
app.post('/api/createNewOrder', db.createNewOrder);
app.post('/api/createBookOrder', db.createBookOrder);
app.post('/api/changeStockCount', db.changeStockCount);
app.post('/api/searchForMyOrders', db.searchForMyOrders);
app.get('/api/getExpenditures', db.getExpenditures);
app.get('/api/getSalesPerGenre', db.getSalesPerGenre);
app.get('/api/getSalesPerAuthor', db.getSalesPerAuthor);
app.post('/api/addBook', db.addBook);
app.post('/api/removeBook', db.removeBook);
app.post('/api/searchForAuthor', db.searchForAuthor);
app.post('/api/createUser', db.createUser);
app.post('/api/searchForAuthorByName', db.searchForAuthorByName);
app.post('/api/addAuthor', db.addAuthor);
app.post('/api/addWrites', db.addWrites);
app.get('/api/addWritesNewAuthor', db.addWritesNewAuthor);
app.post('/api/searchForPublisherByName', db.searchForPublisherByName);
app.post('/api/addPublisher', db.addPublisher);
app.post('/api/addBookWithNewPublisher', db.addBookWithNewPublisher);
app.post('/api/searchBooksByAuthor', db.searchBooksByAuthor);
app.post('/api/getDetailsOfOrder', db.getDetailsOfOrder);

app.listen(port, ()=>{
    console.log(`App running on port ${port}.`);
});