Class Riches.Util
{

ClassMethod DebugMerge(strMessage As %String = "", ByRef pArray) As %Status
{
	Merge ^TESTunit($I(^TESTunit)) = pArray
	Set tValue = ""
	If $Get(pArray) '= "" Set tValue = " = "_pArray
	Set ^TESTunit(^TESTunit) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage_tValue
	Quit $$$OK
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

ClassMethod GetStatusText(pStatus As %Status) As %String
{
	If $$$ISOK(pStatus) Quit "OK"
	Set tErrorText = $SYSTEM.Status.GetErrorText(pStatus)
	Set tReturn = $REPLACE(tErrorText,"ERROR #5001:","")
	Quit tReturn
}

ClassMethod EncodeLogicalDisplay(pLogical As %String = "", pDisplay As %String = "") As %String
{
	Do ..DebugTEST("Riches.Util - EncodeLogicalDisplay")
	Do ..DebugTEST("pLogical = "_pLogical)
	Do ..DebugTEST("pDisplay = "_pDisplay)
	Set delim = "^"
	If (pLogical [ delim) {
		Set pLogical = $Replace(pLogical,delim,"?")
	}
	If (pDisplay [ delim) {
		Set pDisplay = $Replace(pDisplay,delim,"?")
	}
	Set tLogicalDisplay = delim_pLogical_delim_pDisplay
	Do ..DebugTEST("tLogicalDisplay = "_tLogicalDisplay)
	Set tQuoteJS = ##class(%CSP.Page).QuoteJS(tLogicalDisplay)
	Do ..DebugTEST("tQuoteJS = "_tQuoteJS)
	Quit tQuoteJS
}

ClassMethod ExecuteQueryOneValue(pQuery As %String, ByRef pResult As %String) As %Status
{
	Do ..DebugTEST("Riches.Util - ExecuteQueryOneValue")
	Do ..DebugTEST("pQuery = "_pQuery)
	Set pResult = ""
	Set rs = ##class(%ResultSet).%New()
	Set tSC = rs.Prepare(pQuery)
	Do ..DebugStatus(tSC)
	If $$$ISOK(tSC) {
		Set tSC = rs.Execute()
		Do ..DebugStatus(tSC)
		If $$$ISOK(tSC), rs.Next() Set pResult = rs.GetData(1)
	}
	Do rs.Close()
	Set rs = ""
	Do ..DebugTEST("pResult = "_pResult)
	Quit tSC
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

}
