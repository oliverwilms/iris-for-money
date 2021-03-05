Class UnitTest.REST Extends %UnitTest.TestCase
{

ClassMethod MakeRequest(pQuery As %String = "Insert into Riches.Category (Nickname) values ('Wages')", pVerbose As %String = 1) As %Status
{
	Set tErrorCount = 0
	Set type = "POST"
	Set location = "/restapi/sql/"_##class(%CSP.Page).EscapeURL(pQuery)
	Set test = 0
	Set reset = 1
	Do {
		Set tRetryFlag = 0
		Set pResponse = $$$NULLOREF
		Set tRequest = ##class(%Net.HttpRequest).%New()
		// InitiateAuthentication does not exist in HealthShare versions
		Try {
			Set tRequest.InitiateAuthentication = ""

			If (location [ "restapi") {
				Set tRequest.InitiateAuthentication = "Basic"
				Set tRequest.Username = "_SYSTEM"
				Set tRequest.Password = "SYS"
			}
		} Catch {
		}

		//Set tRequest.Server = ""  // This defaults to 'localhost', i.e. your current machine if not specified.
		Set tRequest.Port = 52773
		Set tSC = tRequest.Send(type,location,test,reset)
		#dim tResponse As %Net.HttpResponse
		Set tResponse = tRequest.HttpResponse
		If $IsObject(tResponse) {
			//If (tResponse.StatusCode = 500), ($Increment(tErrorCount) = 1) Set tRetryFlag = 1
			//If (tResponse.StatusCode = 503), ($Increment(tErrorCount) = 1) Set tRetryFlag = 1
			Set tLogResponse = tResponse.StatusCode_" / "_tResponse.ReasonPhrase
			If pVerbose Write "StatusCode/Reason = "_tLogResponse,!
		} Else {
			If pVerbose Write "HttpResponse = "_tResponse,!
		}
	} While tRetryFlag
	Quit $$$OK
}

ClassMethod Setup() As %Status
{
	Set ^UnitTestRoot = "/opt/irisapp/src"
	ZW ^UnitTestRoot
	Quit $$$OK
}

Method TestSQL()
{
	Set tQuery = "Select COUNT (*) FROM Riches.Category WHERE Nickname = 'Wages'"
	Set tSC = ##class(Riches.Util).ExecuteQueryOneValue(tQuery,.tValue)
	Do $$$AssertEquals(tCountBefore, 0)
}

ClassMethod goTest(pVerbose As %String = 1) As %Status
{
	Set tQuery = "Select COUNT (*) FROM Riches.Category WHERE Nickname = 'Wages'"
	Set tSC = ##class(Riches.Util).ExecuteQueryOneValue(tQuery,.tValue)
	If pVerbose Write "Count before = ",tValue,!
	Set tSC = ..MakeRequest()
	Set tQuery = "Select COUNT (*) FROM Riches.Category WHERE Nickname = 'Wages'"
	Set tSC = ##class(Riches.Util).ExecuteQueryOneValue(tQuery,.tValue)
	If pVerbose Write "Count after = ",tValue,!
	If (tValue = 1) Write "Test passed.",!
	If (tValue '= 1) Write "Test failed.",!
	Quit tSC
}

}
