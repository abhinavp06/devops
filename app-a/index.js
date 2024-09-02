const express = require('express')
const app = express()
const port = 3000

app.use(express.json())

app.get('/', (req, res) => {
  console.log("Hi, this is app-a!")
  res.status(200).json({success: true, message: "Hi, this is app-a!"})
})

app.post('/cron', (req,res) => {
    const name = req.body?.name;

    if(!name) res.status(400);

    console.log(`Hello, ${name}. This is a cronjob log from app-a!`);

    res.status(200).json({success: true, message: `Hello, ${name}. This is a cronjob log from app-a!`})
})

app.listen(port, () => {
  console.log(`app-a listening on port ${port}`)
});