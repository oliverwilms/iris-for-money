Class Riches.Model.CategoryREST Extends Riches.Model.Base
{

Parameter Version = "1.0.0";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!-- Server Info -->
<Route Url="/" Method="GET" Call="GetInfo" Cors="true"/>
<!-- Get all records of Category class -->
<Route Url="/category/all" Method="GET" Call="GetAllCategory"/>
<!-- Swagger specs -->
<Route Url="/_spec" Method="GET" Call="SwaggerSpec" />
<!-- GET method to return JSON for a given Category id-->
<Route Url="/category/:id" Method="GET" Call="GetCategory"/>
<!-- Update a Category with id-->
<Route Url="/category/:id" Method="PUT" Call="UpdateCategory"/>
<!-- Delete a Category with id-->
<Route Url="/category/:id" Method="DELETE" Call="DeleteCategory"/>
<!-- GET method to return JSON for a given Category id-->
<Route Url="/category/generate/:amount" Method="GET" Call="GenerateCategory"/>

<!-- Create a Category-->
<Route Url="/category/" Method="POST" Call="CreateCategory"/>

</Routes>
}

/// CategoryREST general information
ClassMethod GetInfo() As %Status
{
  SET version = ..#Version
  SET info = {
    "version": (version)
  }
  RETURN ..%ProcessResult($$$OK, info)
}

/// Retreive all the records of Riches.Category
ClassMethod GetAllCategory() As %Status
{

    #dim tSC As %Status = $$$OK

    Set rset = ##class(Riches.Category).ExtentFunc()

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Write "["
    if rset.%Next() {
        Set Category = ##class(Riches.Category).%OpenId(rset.ID)    
        Do Category.%JSONExport()
    }
    While rset.%Next() {   
        Write ","
        Set Category = ##class(Riches.Category).%OpenId(rset.ID)    
        Do Category.%JSONExport()
    }
    Write "]"
    Quit tSC
}

/// Populate records of Riches.Category
ClassMethod GenerateCategory(amount As %Integer = 10) As %Status
{
    do ##class(Riches.Category).Populate(amount)
    SET ret = {
        "New records generated": (amount)  
    }
    RETURN ..%ProcessResult($$$OK, ret)
}

/// Return one record of Riches.Category
ClassMethod GetCategory(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException


    #; Set the response header to plain text
    Set %response.ContentType = ..#CONTENTTYPEJSON

    Set Category = ##class(Riches.Category).%OpenId(id)

    If '$IsObject(Category) Quit ..Http404()

    Do Category.%JSONExport()

    Quit tSC
}

/// Creates a new Riches.Category record
ClassMethod CreateCategory() As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set Category = ##class(Riches.Category).%New()
    Set data = {}.%FromJSON(%request.Content)


    $$$TOE(tSC,Category.%JSONImport(data))
    $$$TOE(tSC,Category.%Save())

    Set %response.Status = 204
    Set %response.ContentType = ..#CONTENTTYPEJSON
    //d data.%ToJSON()
    Do Category.%JSONExport()

    Quit tSC
}

/// Update a record in Riches.Category with id
ClassMethod UpdateCategory(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set Category = ##class(Riches.Category).%OpenId(id)
    If '$IsObject(Category) Return ..Http404()
    Set data = {}.%FromJSON(%request.Content)


    $$$TOE(tSC,Category.%JSONImport(data))
    $$$TOE(tSC,Category.%Save())

    Set %response.Status = 200

    Set %response.ContentType = ..#CONTENTTYPEJSON
    Do Category.%JSONExport()

    Quit tSC
}

/// Delete a record with id in Riches.Category
ClassMethod DeleteCategory(id As %Integer) As %Status
{
	#dim tSC As %Status = $$$OK
    #dim e As %Exception.AbstractException
    Set Category = ##class(Riches.Category).%OpenId(id)
    If '$IsObject(Category) Return ..Http404()

    $$$TOE(tSC,Category.%DeleteId(id))

    Set %response.Status = 200

    Set %response.ContentType = ..#CONTENTTYPEJSON

    Quit tSC
}

}
