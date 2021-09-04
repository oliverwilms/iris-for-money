Class Riches.Category Extends (%Persistent, %JSON.Adaptor, %Populate)
{

Property Type As %String(VALUELIST = ",I,E");

Property Nickname As %String;

Property SortOrder As %String;

ClassMethod AddTestData(amount As %Integer)
{
	Do ..Populate(amount)
}

ClassMethod GetColumns(ByRef pColumns) As %String
{
	/*
	Set tOption0 = "<option value="_qValue_"></option>"
	Set qValue = q_"Nickname"_q
	Set tOption1 = "<option value="_qValue_">Nickname</option>"
	Set qValue = q_"SortOrder"_q
	Set tOption2 = "<option value="_qValue_">Sort</option>"
	Set qValue = q_"Type"_q
	Set tOption3 = "<option value="_qValue_">Type</option>"
	*/
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Nickname","Nickname")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("SortOrder","Sort")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Type","Type")
	Quit $$$OK
}

ClassMethod OutputFormData(iNickname As %String = "", iSortOrder As %String = "") As %Status
{
	Set q = """"
	Set qHidden = q_"hidden"_q
	Set qRadio = q_"radio"_q
	Set qSize = q_"50"_q
	Set qSubmit = q_"submit"_q
	Set qText = q_"text"_q
	Set qID = "iChoose"
	Write "<input type=",qHidden," id=",qID," name=",qID," size=",qSize," value=",q,"Category",q,"><br>",!
	Write "<table><tr><td>",!
	Set qName = q_"iType"_q
	Set qID = q_"TypeIncome"_q
	Write "<input type=",qRadio," id=",qID," name=",qName," value=",qID,">",!
	Write "<label for=",qID,">Income</label><br>",!
	Write "</td><td>",!
	Set qID = q_"TypeExpense"_q
	Write "<input type=",qRadio," id=",qID," name=",qName," value=",qID,">",!
	Write "<label for=",qID,">Expense</label><br>",!
	Write "</td></tr></table>",!
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
	Do ##class(Util).DebugTEST("Riches.Category - OutputTableData")
	Do ##class(Util).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE Session = '"_pWhere_"'"  // This did not return any result
	If (pWhere '= "") Set tWHERE = " WHERE Session LIKE '"_$TRANSLATE(pWhere," ","%")_"'"
	Set tQuery = "SELECT * FROM Riches.Category"_tWHERE
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
		Write !,"<td>",tResult.Type,"</td>"
		Write !,"<td>",tResult.SortOrder,"</td></tr>"
	}
	Quit tSC
}

ClassMethod SubmitFormData(ByRef pRequestData, Output pAction, Output pId) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Category - SubmitFormData")
	Do ##class(Util).DebugMerge("pRequestData = ",.pRequestData)
	Set tSC = $$$OK
	If ($Data(pRequestData("iNickname",1))) {
		Set iNickname = pRequestData("iNickname",1)
	}
	If ($Data(pRequestData("iSortOrder",1))) {
		Set iSortOrder = pRequestData("iSortOrder",1)
	}
	If ($Data(pRequestData("iType",1))) {
		Set iType = pRequestData("iType",1)
		Set iType = $ZCONVERT(iType,"U")
		If (iType [ "EXP") Set iType = "E"
		If (iType [ "INCOME") Set iType = "I"
	}
	If ($Get(iNickname) '= "") {
		Set objCategory = ##class(Riches.Category).%New()
		Set objCategory.Nickname = iNickname
		Set objCategory.SortOrder = $Get(iSortOrder)
		Set objCategory.Type = $Get(iType)
		Set tSC = objCategory.%Save()
		Do ##class(Util).DebugStatus(tSC)
		If $$$ISOK(tSC) {
			Set pAction = "ADD"
		 	Set pId = ##class(Util).EncodeLogicalDisplay(objCategory.%Id(),objCategory.Nickname)
		}
	}
	Quit tSC
}

ClassMethod TestValue(pValue As %String = "", Output pCategoryId, Output pId, pVerbose As %Integer = 0) As %Status
{
	Do:pVerbose ##class(Util).DebugTEST("Riches.Category - TestValue")
	Do:pVerbose ##class(Util).DebugTEST("pValue = "_pValue)
	Set pId = ""
	Set tSC = $$$OK
	Set iNickname = pValue
	Set tQuote = $Select(($Extract(pValue,1)="'"):"",1:"'")
	Set pQuery = "SELECT ID FROM Riches.Category WHERE NICKNAME = "_tQuote_pValue_tQuote
	Set tSC = ##class(Util).ExecuteQueryOneValue(pQuery,.pCategoryId)
	If ($Get(pCategoryId) = "") {
		Set objCategory = ##class(Riches.Category).%New()
		If (tQuote = "") Set iNickname = $Extract(iNickname,2,*-1)
		Set objCategory.Nickname = iNickname
		Set objCategory.SortOrder = $Get(iSortOrder)
		Set tSC = objCategory.%Save()
		Do:pVerbose ##class(Util).DebugStatus(tSC)
		If $$$ISOK(tSC) {
			Set pCategoryId = objCategory.%Id()
		 	Set pId = ##class(Util).EncodeLogicalDisplay(objCategory.%Id(),objCategory.Nickname)
		}
	}
	Do:pVerbose ##class(Util).DebugTEST("pCategoryId = "_$Get(pCategoryId,pId))
	Do:pVerbose ##class(Util).DebugTEST("pId = "_pId)
	Quit tSC
}

Storage Default
{
<Data name="CategoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Type</Value>
</Value>
<Value name="3">
<Value>Nickname</Value>
</Value>
<Value name="4">
<Value>SortOrder</Value>
</Value>
</Data>
<DataLocation>^Riches.CategoryD</DataLocation>
<DefaultData>CategoryDefaultData</DefaultData>
<ExtentSize>6</ExtentSize>
<IdLocation>^Riches.CategoryD</IdLocation>
<IndexLocation>^Riches.CategoryI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>1</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Nickname">
<AverageFieldSize>5</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="SortOrder">
<AverageFieldSize>1.67</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<Property name="Type">
<AverageFieldSize>.33</AverageFieldSize>
<Selectivity>33.3333%</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^Riches.CategoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
