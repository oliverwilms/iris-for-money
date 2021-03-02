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
	Set delim = "^"
	If (pLogical [ delim) {
		Set pLogical = $Replace(pLogical,delim,"?")
	}
	If (pDisplay [ delim) {
		Set pDisplay = $Replace(pDisplay,delim,"?")
	}
	Set tLogicalDisplay = delim_pLogical_delim_pDisplay
	Quit tLogicalDisplay
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

ClassMethod OutputDebug(pDebug As %String = "") As %Status
{
	Do ..DebugTEST("Riches.Util - OutputDebug")
	Do ..DebugTEST("pDebug = "_pDebug)
	Write "<table border=1>",!
	If (pDebug = "PREVIEW") {
		Set pp = ""
		For {
			Set pp = $Order(^RichesDEBUG(pp))
			If (pp = "") Quit
			Set qq = $Order(^RichesDEBUG(pp,""))
			If (qq = "") Continue
			Set tDebugLine = $Get(^RichesDEBUG(pp,qq))
			Set tSC = ..OutputDebugLine(tDebugLine,(pp = 0))
			If $$$ISERR(tSC) Quit
		}
	}
	Write "</table>",!
	Quit $$$OK
}

ClassMethod OutputDebugLine(pDebugLine As %String = "", pHeader As %String = 0) As %Status
{
	Do ..DebugTEST("Riches.Util - OutputDebugLine")
	Do ..DebugTEST("pDebugLine = "_pDebugLine)
	Write "<tr>",!
	Set delim = ","
	Set tLen = $Length(pDebugLine,delim)
	For pp=1:1:tLen {
		Set tDebugPiece = $Piece(pDebugLine,delim,pp)
		If (pp = 1) Set tLineId = tDebugPiece
		Set tSC = ..OutputDebugPiece(tDebugPiece,pHeader)
		If $$$ISERR(tSC) Quit
	}
	Set q = """"
	Set qClick = q_"goDeleteLine("_tLineId_")"_q
	Set qType = q_"button"_q
	Write "<th><button type=",qType," onclick=",qClick,">Delete</button></th>",!
	Write "</tr>",!
	If (pHeader = 0) Quit $$$OK
	Set q = """"
	Set qName = q_"select1"_q
	Set qID = q_"select1"_q
	Set tSelect1 = "<select name="_qName_" id="_qID_">"
	Set qValue = q_""_q
	Set tOption0 = "<option value="_qValue_"></option>"
	Set qValue = q_"Nickname"_q
	Set tOption1 = "<option value="_qValue_">Nickname</option>"
	Set qValue = q_"SortOrder"_q
	Set tOption2 = "<option value="_qValue_">Sort</option>"
	Set qValue = q_"Type"_q
	Set tOption3 = "<option value="_qValue_">Type</option>"
	Set tSelect2 = "</select>"
	Write "<tr>",!
	For pp=1:1:tLen {
		Set tDebugPiece = "<div>"_tSelect1_tOption0_tOption1_tOption2_tOption3_tSelect2_"</div>"
		Set tSC = ..OutputDebugPiece(tDebugPiece,0)
	}
	Write "</tr>",!
	Quit $$$OK
}

ClassMethod OutputDebugPiece(pDebugPiece As %String = "", pHeader As %String = 0) As %Status
{
	Do ..DebugTEST("Riches.Util - OutputDebugPiece")
	Do ..DebugTEST("pDebugPiece = "_pDebugPiece)
	If pHeader {
		Set td1 = "<th>"
	} Else {
		Set td1 = "<td>"
	}
	Write td1
	Write pDebugPiece
	If pHeader {
		Set td1 = "</th>"
	} Else {
		Set td1 = "</td>"
	}
	Write td1,!
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

ClassMethod QuoteJSLogicalDisplay(pLogical As %String = "", pDisplay As %String = "") As %String
{
	Set tLogicalDisplay = ..EncodeLogicalDisplay(pLogical,pDisplay)
	Quit ##class(%CSP.Page).QuoteJS(tLogicalDisplay)
}

}
