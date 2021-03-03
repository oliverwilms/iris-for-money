## iris-for-money
This is my entry for InterSystems Grand Prix Contest 2021.
http://localhost:32768/irisapp/Transact.csp
![screenshot](https://github.com/oliverwilms/bilder/blob/main/Riches_Transact.PNG)
If you are prompted to login, enter _SYSTEM and SYS

## Inspiration
I have been using Microsoft Money for a very long time. Last week, after Windows Update, it quit working for me. I quickly put data in multiple worksheets in Excel, but I wanted more control to manage my money. This is very much a work in progress. Please be patient with me as I make it work.

## What it does
Creates /crud web app in IRIS and CRUD endpoints to play with persistent data in Sample.Person class. 
It uses [swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) module to provide documentation and test environment for API.



## Challenges I ran into
Not enough time

## Accomplishments that I am proud of
I was able to import data from a CSV file that I had exported from Excel.

## What I learned
a lot!

## Built with
Cache Server Pages, IRIS Community Edition in Docker

## Installation with ZPM

zpm:USER>install iris-for-money

## Installation with Docker

## Prerequisites
Make sure you have [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) and [Docker desktop](https://www.docker.com/products/docker-desktop) installed.


Clone/git pull the repo into any local directory e.g. like it is shown below:

```
$ git clone git@github.com:oliverwilms/iris-for-money.git
```

Open the terminal in this directory and run:

```
$ docker-compose up -d --build
```

## How to Work With it

This template creates /crud REST web-application on IRIS which implements 4 types of communication: GET, POST, PUT and DELETE aka CRUD operations. 
The API is available on localhost:52773/crud/
This REST API goes with  OpenAPI (swagger) documentation. you can check it localhost:52773/crud/_spec
THis spec can be examined with different tools, such as [SwaggerUI](https://swagger.io/tools/swagger-ui/), [Postman](postman.com), etc.
Or you can install [swagger-ui](https://openexchange.intersystems.com/package/iris-web-swagger-ui) with:
```
zpm:IRISAPP>install swagger-ui
``` 
And check the documentation on localhost:52773/swagger-ui/index.html


# Testing GET requests

To test GET you need to have some data. You can create it with POST request (see below), or you can create some fake testing data. to do that open IRIS terminal and call:

```
IRISAPP>do ##class(Sample.Person).AddTestData(10)
```
This will create 10 random records in Sample.Person class.


You can get swagger Open API 2.0 documentation on:
```
localhost:yourport/_spec
```

This REST API exposes two GET requests: all the data and one record.
To get all the data in JSON call:

```
localhost:52773/crud/persons/all
```

To request the data for a particular record provide the id in GET request like 'localhost:52773/crud/persons/id' . E.g.:

```
localhost:52773/crud/persons/1
```

This will return JSON data for the person with ID=1, something like that:

```
{"Name":"Elon Mask","Title":"CEO","Company":"Tesla","Phone":"123-123-1233","DOB":"1982-01-19"}
```

# Testing POST request

Create a POST request e.g. in Postman with raw data in JSON. e.g.

```
{"Name":"Elon Mask","Title":"CEO","Company":"Tesla","Phone":"123-123-1233","DOB":"1982-01-19"}
```

Adjust the authorisation if needed - it is basic for container with default login and password for IRIR Community edition container

and send the POST request to localhost:52773/crud/persons/

This will create a record in Sample.Person class of IRIS.

# Testing PUT request

PUT request could be used to update the records. This needs to send the similar JSON as in POST request above supplying the id of the updated record in URL.
E.g. we want to change the record with id=5. Prepare in Postman the JSON in raw like following:

```
{"Name":"Jeff Besos","Title":"CEO","Company":"Amazon","Phone":"123-123-1233","DOB":"1982-01-19"}
```

and send the put request to:
```
localhost:52773/crud/persons/5
```

# Testing DELETE request

For delete request this REST API expects only the id of the record to delete. E.g. if the id=5 the following DELETE call will delete the record:

```
localhost:52773/crud/persons/5
```

## How to start coding

http://x.x.x.x:32768/irisapp/Transact.csp

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
