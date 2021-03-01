Class Riches.REST Extends %CSP.REST
{

Parameter UseSession As Integer = 1;

Parameter HandleCorsRequest = 1;

Parameter CONTENTTYPE = "application/json";

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<Route Url="/debug" Method="GET" Call="GetBaseLogId" />
<Route Url="/debug/:debug" Method="POST" Call="PostDebug" />
<Route Url="/debug/:debug/:index" Method="POST" Call="PostDebug" />
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

ClassMethod GetBaseLogId() As %Status
{
	Do ..DebugTEST("Riches.REST - GetBaseLogId")
	Set tBaseLogId = 0
	Set tBaseLogId = 1 + tBaseLogId
	Do ..DebugTEST("tBaseLogId = "_tBaseLogId)
	Set data = {}
	Set data.BaseLogId = tBaseLogId
	Write data.%ToJSON()
	Quit $$$OK
}

ClassMethod OutputRadio(pName As %String = "", pID As %String = "", pCaption As %String) As %Status
{
	Set q = """"
	Set qRadio = q_"radio"_q
	Set qName = q_pName_q
	Set qID = q_pID_q
	Write "<input type=",qRadio," id=",qID," name=",qName," value=",qID,">",!
	Write "<label for=",qID,">",pCaption,"</label><br>",!
	Quit $$$OK
}

ClassMethod PostDebug(pDebug As %String = "", pIndex As %String = -1) As %Status
{
	Do ..DebugTEST("Riches.REST - PostDebug")
	Do ..DebugTEST("pDebug = "_pDebug)
	Do ..DebugTEST("pIndex = "_pIndex)
	Set ^RichesDEBUG($I(^RichesDEBUG)) = pIndex_","_ pDebug
	Quit $$$OK
}

}
