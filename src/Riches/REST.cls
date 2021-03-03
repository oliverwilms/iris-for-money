Class Riches.REST Extends %CSP.REST
{

Parameter UseSession As Integer = 1;

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/debug" Method="GET" Call="GetDebug" />
<Route Url="/debug/:debug" Method="POST" Call="PostDebug" />
<Route Url="/debug/:debug/:index" Method="POST" Call="PostDebug" />
<Route Url="/sql/:query" Method="POST" Call="PostSQL" />
</Routes>
}

ClassMethod DebugTEST(strMessage As %String = "") As %Status
{
	Set ^TESTunit($I(^TESTunit)) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage
	Quit $$$OK
}

ClassMethod StatusToText(pStatus As %Status) As %String
{
	Set tReturn = $System.Status.GetOneErrorText(pStatus)
	Quit tReturn
}

ClassMethod DebugStatus(pStatus As %Status) As %Status
{
	Set tStatus = ..StatusToText(pStatus)
	Quit ..DebugTEST(tStatus)
}

ClassMethod GetDebug() As %Status
{
	Do ..DebugTEST("Riches.REST - GetDebug")
	Set tBaseLogId = 0
	Set tBaseLogId = 1 + tBaseLogId
	Do ..DebugTEST("tBaseLogId = "_tBaseLogId)
	Set data = {}
	Set data.BaseLogId = tBaseLogId
	Write data.%ToJSON()
	Quit $$$OK
}

ClassMethod PostDebug(pDebug As %String = "", pIndex As %String = -1) As %Status
{
	Do ..DebugTEST("Riches.REST - PostDebug")
	Do ..DebugTEST("pDebug = "_pDebug)
	Do ..DebugTEST("pIndex = "_pIndex)
	Set tIncrement = $Increment(^RichesDEBUG)
	Set ^RichesDEBUG(pIndex,tIncrement) = pIndex_","_ pDebug
	Quit $$$OK
}

ClassMethod PostSQL(pQuery As %String = "", pIndex As %String = -1) As %Status
{
	Do ..DebugTEST("Riches.REST - PostSQL")
	Do ..DebugTEST("pQuery = "_pQuery)
	Do ..DebugTEST("pIndex = "_pIndex)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(pQuery)
	If $$$ISERR(tSC) {
		Do ..DebugStatus(tSC)
		Write "%Prepare failed:"
		Do $System.Status.DisplayError(tSC) QUIT
	} Else {
		#Dim rset As %SQL.StatementResult
		// Execute the current statement and return the result. The result of the execute is always the return value.
		// Success/Failure information is reported in the result object as %SQLCODE, %Message, %ROWCOUNT, and/or %ROWID.
		Set rset = tStatement.%Execute()
		Do ..DebugTEST("%SQLCODE = "_rset.%SQLCODE)
		Do ..DebugTEST("%Message = "_rset.%Message)
		Do ..DebugTEST("%ROWID = "_rset.%ROWID)
	}
	Quit tSC
}

}
