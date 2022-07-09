## iris-for-money
I started developing this app for InterSystems Grand Prix Contest 2021.
I decided to revisit it for InterSystems Full Stack Contest 2022. I focus on Transact.csp page where previously it only allowed to INSERT new data into Transact table.
http://localhost:57700/irisapp/Transact.csp
![screenshot](https://github.com/oliverwilms/bilder/blob/main/Riches_transact.PNG)

If you are prompted to login, enter _SYSTEM and SYS

## Inspiration
I had been using Microsoft Money for a very long time. Last year, after Windows Update, it quit working for me. I quickly put data in multiple worksheets in Excel, but I miss some of the functionality offered by Microsoft Money. This remained an incomplete work much longer than I had anticipated. Please be patient with me as I continue my efforts to make it work.

## Getting Started
I wanted to import some data that I had entered into Excel. I exported a list of Categories into Categories.csv file (in data folder)
![screenshot](https://github.com/oliverwilms/bilder/blob/main/Data_Categories_CSV.PNG)

Point your browser at Account.csp: http://localhost:57700/irisapp/Account.csp

Click the Choose File button to browse and Open Categories.csv file. Click the Preview button to see a table grid with the data from the file.
Select the table you want to insert data into from the dropdown selection.

![screenshot](https://github.com/oliverwilms/bilder/blob/main/Riches_Account.PNG)

Identify the columns that contain the data to insert into the table using the dropdown selections just below the column headers before you click the Import button in a row that displays a category you want to import into the database.

## What it does

The CSP page posts a request to /restapi/sql/query where query is the query to run against IRIS database:

```
Insert into Riches.Category (Nickname) values ('Wages')
```

## Import Transactions
I have entered transaction data into Excel to keep track of Account Balances while I work on this app.

Again I go to http://localhost:57700/irisapp/Account.csp. This time I create a record in Account table.

![screenshot](https://github.com/oliverwilms/bilder/blob/main/Riches_Account_New.PNG)

## Data Model
/riches web app is another way to manage persistent data in Riches.Category class. It uses [swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) module to provide documentation and test environment for API.

## Challenges I ran into
All of a sudden I got 401 when using /restapi from Import page Account.csp. I got it resolved hours later.

## Accomplishments that I am proud of
I was able to import data from a CSV file that I had exported from Excel. As of today, Sunday, I am able to select from three tables to insert data into Category, Merchant, and Transact tables and I verified data got inserted into three different tables.

## What I learned
MatchRoles = %DB_IRISAPP to allow /restapi to work Unauthenticated.

You can verify that it works by going to http://localhost:57700/restapi/debug. I was very happy when I could see
```
{"BaseLogId":1}
```

## Built with
Cache Server Pages, IRIS Community Edition in Docker

## Installation with ZPM

zpm:USER>install iris-for-money

## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.


Clone/git pull the repo into any local directory e.g. like it is shown below:

```
$ git clone https://github.com/oliverwilms/iris-for-money.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```

## Unit Test

Open IRIS session inside the container:

```
$ docker exec -it iris-for-money_iris_1 iris session iris -U irisapp
```

If you are prompted to login, enter _SYSTEM and SYS

Execute UnitTest:
```
IRISAPP>do ##class(UnitTest.REST).goTest()
Count before = 2
StatusCode/Reason = 200 / OK
Count after = 3
Test failed. 
```

If your first test passes, run it again. The second test fails, because we do not really want multiple categories with the same Nickname 'Wages'.

## How to Work With it

iris-for-money includes /riches REST web-application on IRIS which implements 4 types of communication: GET, POST, PUT and DELETE aka CRUD operations. 
The API is available on localhost:57700/riches/
This REST API goes with  OpenAPI (swagger) documentation. You can check it localhost:57700/crud/_spec
This spec can be examined with different tools, such as [SwaggerUI](https://swagger.io/tools/swagger-ui/), [Postman](postman.com), etc.
Or you can install [swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) with:
```
zpm:IRISAPP>install swagger-ui
``` 
And check the documentation on localhost:57700/swagger-ui/index.html


# Testing GET requests

To test GET you need to have some data. You can create it with POST request (see below), or you can create some fake testing data. To do that open IRIS terminal and call:

```
IRISAPP>do ##class(Riches.Category).AddTestData(2)
```
This will create two random records in Riches.Category class.


You can get swagger Open API 2.0 documentation on:
```
localhost:yourport/_spec
```

This REST API exposes two GET requests: all the data and one record.
To get all the data in JSON call:

```
localhost:57700/riches/category/all
```

To request the data for a particular record provide the id in GET request like 'localhost:/riches/category/id' . E.g.:

```
localhost:57700/riches/category/1
```

This will return JSON data for the person with ID=1, something like that:

```
{"Nickname":"Wages"}
```

# Testing POST request

Create a POST request e.g. in Postman with raw data in JSON. e.g.

```
{"Nickname":"Income Tax"}
```

Adjust the authorisation if needed - it is basic for container with default login and password for IRIS Community edition container

and send the POST request to localhost:57700/riches/category/

This will create a record in Riches.Category class in IRIS.

# Testing PUT request

PUT request could be used to update the records. This needs to send the similar JSON as in POST request above supplying the id of the updated record in URL.
E.g. we want to change the record with id=5. Prepare in Postman the JSON in raw like following:

```
{"Nickname":"Groceries"}
```

and send the put request to:
```
localhost:57700/riches/category/5
```

# Testing DELETE request

For delete request this REST API expects only the id of the record to delete. E.g. if the id=5 the following DELETE call will delete the record:

```
localhost:57700/riches/category/5
```

## How to start coding

http://x.x.x.x:57700/irisapp/Transact.csp

This is a template, so you can use a template button on Github to create your own copy of this repository.
The repository is ready to code in VSCode with ObjectScript plugin.
Install [VSCode](https://code.visualstudio.com/) and [ObjectScript](https://marketplace.visualstudio.com/items?itemName=daimor.vscode-objectscript) plugin and open the folder in VSCode.
Once you start IRIS container VSCode connects to it and you can edit, compile and debug ObjectScript code.
Open /src/cls/PackageSample/ObjectScript.cls class and try to make changes - it will be compiled in running IRIS docker container.

Feel free to delete PackageSample folder and place your ObjectScript classes in a form
/src/cls/Package/Classname.cls

The script in Installer.cls will import everything under /src and /csp into IRIS.

## Collaboration 
Any collaboration is very welcome! Fork and send Pull requests!
