Class Riches.Merchant Extends %Persistent
{

Property Nickname As %String;

Property DefaultCat As Category;

Property DefaultSubCat As SubCategory;

Property SortOrder As %String;

ClassMethod GetColumns(ByRef pColumns) As %String
{
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Nickname","Nickname")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("SortOrder","Sort")
	Quit $$$OK
}

ClassMethod OutputFormData(iNickname As %String = "", iSortOrder As %String = "") As %Status
{
	Set q = """"
	Set qHidden = q_"hidden"_q
	Set qSize = q_"50"_q
	Set qSubmit = q_"submit"_q
	Set qText = q_"text"_q
	Set qID = "iChoose"
	Write "<input type=",qHidden," id=",qID," name=",qID," size=",qSize," value=",q,"Merchant",q,"><br>",!
	Write "<table><tr><td>",!
	Set qID=q_"iNickname"_q
	Write "<label for=",qID,">Nickname:</label>",!
	Write "</td><td>",!
	Write "<input type=",qText," id=",qID," name=",qID," size=",qSize," value=",q,$Get(iNickname),q,"><br>",!
	Write "</td></tr>",!
	Write "<tr><td>",!
	Set qID=q_"iSortOrder"_q
	Write "<label for=",qID,">Sort Order:</label>",!
	Write "</td><td>",!
	Write "<input type=",qText," id=",qID," name=",qID," size=",qSize," value=",q,$Get(iSortOrder),q,"><br>",!
	Write "</td></tr></table>",!
	Set qValue = q_"Submit"_q
	Write "<input type=",qSubmit," value=",qValue,">",!
	Quit $$$OK
}

ClassMethod OutputTableData(pWhere As %String = "", pTrClick As %String = "window.location='Transact.csp?iAccount=#';", pMaxRows = -1) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Merchant - OutputTableData")
	Do ##class(Util).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE Session = '"_pWhere_"'"  // This did not return any result
	If (pWhere '= "") Set tWHERE = " WHERE Session LIKE '"_$TRANSLATE(pWhere," ","%")_"'"
	Set tQuery = "SELECT * FROM Riches.Merchant"_tWHERE
	Do ##class(Util).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
 	While tResult.%Next() {
	 	Set tValue = ##class(Util).QuoteJSLogicalDisplay(tResult.ID,tResult.Nickname)
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tValue),tQuote,">"
		Write !,"<td>",tResult.Nickname,"</td>"
		Write !,"<td>",tResult.SortOrder,"</td></tr>"
	}
	Quit tSC
}

ClassMethod SubmitFormData(ByRef pRequestData, Output pAction, Output pId) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Merchant - SubmitFormData")
	Do ##class(Util).DebugMerge("pRequestData = ",.pRequestData)
	Set tSC = $$$OK
	If ($Data(pRequestData("iNickname",1))) {
		Set iNickname = pRequestData("iNickname",1)
	}
	If ($Data(pRequestData("iSortOrder",1))) {
		Set iSortOrder = pRequestData("iSortOrder",1)
	}
	If ($Get(iNickname) '= "") {
		Set objMerchant = ##class(Riches.Merchant).%New()
		Set objMerchant.Nickname = iNickname
		Set objMerchant.SortOrder = $Get(iSortOrder)
		Set tSC = objMerchant.%Save()
		Do ##class(Util).DebugStatus(tSC)
		If $$$ISOK(tSC) {
			Set pAction = "ADD"
		 	Set pId = ##class(Util).EncodeLogicalDisplay(objMerchant.%Id(),objMerchant.Nickname)
		}
	}
	Quit tSC
}

ClassMethod TestValue(pValue As %String = "", Output pMerchantId, Output pId, pVerbose As %Integer = 0) As %Status
{
	Do:pVerbose ##class(Util).DebugTEST("Riches.Merchant - TestValue")
	Do:pVerbose ##class(Util).DebugTEST("pValue = "_pValue)
	Set pId = ""
	Set tSC = $$$OK
	Set iNickname = pValue
	Set tQuote = $Select(($Extract(pValue,1)="'"):"",1:"'")
	Set pQuery = "SELECT ID FROM Riches.Merchant WHERE NICKNAME = "_tQuote_pValue_tQuote
	Set tSC = ##class(Util).ExecuteQueryOneValue(pQuery,.pMerchantId)
	If ($Get(pMerchantId) = "") {
		Set objMerchant = ##class(Riches.Merchant).%New()
		If (tQuote = "") Set iNickname = $Extract(iNickname,2,*-1)
		Set objMerchant.Nickname = iNickname
		Set objMerchant.SortOrder = $Get(iSortOrder)
		Set tSC = objMerchant.%Save()
		Do:pVerbose ##class(Util).DebugStatus(tSC)
		If $$$ISOK(tSC) {
			Set pMerchantId = objMerchant.%Id()
		 	Set pId = ##class(Util).EncodeLogicalDisplay(objMerchant.%Id(),objMerchant.Nickname)
		}
	}
	Do:pVerbose ##class(Util).DebugTEST("pMerchantId = "_$Get(pMerchantId,pId))
	Do:pVerbose ##class(Util).DebugTEST("pId = "_pId)
	Quit tSC
}

Storage Default
{
<Data name="MerchantDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Nickname</Value>
</Value>
<Value name="3">
<Value>DefaultCat</Value>
</Value>
<Value name="4">
<Value>DefaultSubCat</Value>
</Value>
<Value name="5">
<Value>SortOrder</Value>
</Value>
</Data>
<DataLocation>^Riches.MerchantD</DataLocation>
<DefaultData>MerchantDefaultData</DefaultData>
<IdLocation>^Riches.MerchantD</IdLocation>
<IndexLocation>^Riches.MerchantI</IndexLocation>
<StreamLocation>^Riches.MerchantS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
