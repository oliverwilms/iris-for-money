Class Riches.Account Extends %Persistent
{

Property OpenDate As %Date;

Property CloseDate As %Date;

Property StatementDate As %Date;

Property Institution As %String;

Property StartBalance As %Currency;

Property CurrBalance As %Currency;

Property StatementBalance As %Currency;

Property Type As %String(VALUELIST = ",Checking,Savings,Credit Card,Loan,Mortgage,Other");

Property Website As %String;

Property Nickname As %String;

Property Rewards As %String;

/// If StartBalance is updated, also update Current Account Balance
Trigger Balance [ Event = UPDATE, Time = AFTER ]
{
	// get row id of inserted row
	NEW id,SQLCODE,%msg,%ok,%oper
	SET aa = {ID}
	SET cr = {StartBalance*N}
	SET db = {StartBalance*O}
	SET tSC = ##class(Riches.Account).UpdateBalance(aa,cr,db)
}

ClassMethod IdentifyAccountType(pValue As %String = "") As %String
{
	Set tAccountType = "Other"
	Set pValue = $ZCONVERT(pValue,"U")
	If (pValue [ "CHECK") Set tAccountType = "Checking"
	If (pValue [ "CRED") Set tAccountType = "Credit Card"
	If (pValue [ "LOAN") Set tAccountType = "Loan"
	If (pValue [ "MORT") Set tAccountType = "Mortgage"
	If (pValue [ "SAV") Set tAccountType = "Savings"
	Quit tAccountType
}

ClassMethod OutputFormData(iNickname As %String = "", iStartBalance As %String = "") As %Status
{
	Set q = """"
	Set qHidden = q_"hidden"_q
	Set qSize = q_"50"_q
	Set qSubmit = q_"submit"_q
	Set qText = q_"text"_q
	Set qID = "iChoose"
	Write "<input type=",qHidden," id=",qID," name=",qID," size=",qSize," value=",q,"Account",q,"><br>",!
	Write "<table>",!
	Do ..OutputTableAccountTypes()
	Write "</table>",!
	Write "<table><tr><td>"
	Set qID=q_"iNickname"_q
	Write "<label for=",qID,">Nickname:</label>",!
	Write "</td><td>",!
	Write "<input type=",qText," id=",qID," name=",qID," size=",qSize," value=",q,$Get(iNickname),q,"><br>",!
	Write "</td></tr>",!
	Write "<tr><td>",!
	Set qID=q_"iStartBalance"_q
	Write "<label for=",qID,">Start Balance:</label>",!
	Write "</td><td>",!
	Write "<input type=",qText," id=",qID," name=",qID," size=",qSize," value=",q,$Get(iStartBalance),q,"><br>",!
	Write "</td></tr></table>",!
	Set qValue = q_"Submit"_q
	Write "<input type=",qSubmit," value=",qValue,">",!
	Quit $$$OK
}

ClassMethod OutputTableAccountTypes() As %Status
{
	Set tSC = $$$OK
	Write "<tr><td>",!
	Do ##class(Util).OutputRadio("iType","TypeChecking","Checking")
	Write "</td><td>",!
	Do ##class(Util).OutputRadio("iType","TypeSavings","Savings")
	Write "</td><td>",!
	Do ##class(Util).OutputRadio("iType","TypeCreditCard","Credit Card")
	Write "</td><td>",!
	Do ##class(Util).OutputRadio("iType","TypeLoan","Loan")
	Write "</td><td>",!
	Do ##class(Util).OutputRadio("iType","TypeMortgage","Mortgage")
	Write "</td><td>",!
	Do ##class(Util).OutputRadio("iType","TypeOther","Other")
	Write "</td></tr>",!
	Quit $$$OK
}

ClassMethod OutputTableData(pWhere As %String = "", pTrClick As %String = "javascript:tableClickHandler(#);", pMaxRows = -1) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Account - OutputTableData")
	Do ##class(Util).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE Session = '"_pWhere_"'"  // This did not return any result
	If (pWhere '= "") Set tWHERE = " WHERE Session LIKE '"_$TRANSLATE(pWhere," ","%")_"'"
	Set tQuery = "SELECT * FROM Riches.Account"_tWHERE
	Do ##class(Util).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
	Write !,"<tr><th>Account</th><th>Type</th><th>Balance</th></tr>"
 	While tResult.%Next() {
	 	Set tValue = ##class(Util).QuoteJSLogicalDisplay(tResult.ID,tResult.Nickname)
	Do ##class(Util).DebugTEST("tValue = "_tValue)
		Set tClick = $Replace(pTrClick,"#",tValue)
	Do ##class(Util).DebugTEST("tClick = "_tClick)
		Write !,"<tr onclick=",tQuote,tClick,tQuote,">"
		Write !,"<td>",tResult.Nickname,"</td>"
		Write !,"<td>",tResult.Type,"</td>"
		Write !,"<td>",tResult.CurrBalance,"</td></tr>"
	}
	Quit tSC
}

ClassMethod SubmitFormData(ByRef pRequestData, Output pAction, Output pId) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Account - SubmitFormData")
	Do ##class(Util).DebugMerge("pRequestData = ",.pRequestData)
	Set tSC = $$$OK
	If ($Data(pRequestData("iNickname",1))) {
		Set iNickname = pRequestData("iNickname",1)
	}
	If ($Data(pRequestData("iStartBalance",1))) {
		Set iStartBalance = pRequestData("iStartBalance",1)
	}
	If ($Data(pRequestData("iType",1))) {
		Set iType = pRequestData("iType",1)
	}
	If ($Get(iStartBalance) = "") Set iStartBalance = 0
	If ($Get(iNickname) '= "") {
		Set objAccount = ##class(Riches.Account).%New()
		Set objAccount.Nickname = iNickname
		Set objAccount.StartBalance = $Get(iStartBalance)
		Set objAccount.CurrBalance = objAccount.StartBalance
		Set objAccount.Type = ..IdentifyAccountType($Get(iType))
		Set tSC = objAccount.%Save()
		Do ##class(Util).DebugStatus(tSC)
		If $$$ISOK(tSC) {
			Set pAction = "ADD"
		 	Set pId = ##class(Util).EncodeLogicalDisplay(objAccount.%Id(),objAccount.Nickname)
		}
	}
	Quit tSC
}

ClassMethod TestValue(pValue As %String = "", Output pAccountId, Output pId, pVerbose As %Integer = 0) As %Status
{
	Do:pVerbose ##class(Util).DebugTEST("Riches.Account - TestValue")
	Do:pVerbose ##class(Util).DebugTEST("pValue = "_pValue)
	Set (pAccountId,pId) = ""
	Set tSC = $$$OK
	Set iNickname = pValue
	Set tQuote = $Select(($Extract(pValue,1)="'"):"",1:"'")
	Set pQuery = "SELECT ID FROM Riches.Account WHERE NICKNAME = "_tQuote_pValue_tQuote
	Set tSC = ##class(Util).ExecuteQueryOneValue(pQuery,.pAccountId)
	Do:pVerbose ##class(Util).DebugTEST("pAccountId = "_pAccountId)
	If ($Get(pAccountId) = "") {
 //Do ##class(Util).DebugTEST("Riches.Account - If + 1")
		Set objAccount = ##class(Riches.Account).%New()
 //Do ##class(Util).DebugTEST("Riches.Account - If + 2")
		If (tQuote = "") Set iNickname = $Extract(iNickname,2,*-1)
 //Do ##class(Util).DebugTEST("Riches.Account - If + 3")
		Set objAccount.Nickname = iNickname
 //Do ##class(Util).DebugTEST("Riches.Account - If + 4")
		//Set objAccount.SortOrder = $Get(iSortOrder)
 //Do ##class(Util).DebugTEST("Riches.Account - If + 5")
		Set tSC = objAccount.%Save()
		Do:pVerbose ##class(Util).DebugStatus(tSC)
		If $$$ISOK(tSC) {
			Set pAccountId = objAccount.%Id()
		 	Set pId = ##class(Util).EncodeLogicalDisplay(objAccount.%Id(),objAccount.Nickname)
		}
	}
 //Do ##class(Util).DebugTEST("Riches.Account - Else")
	Do:pVerbose ##class(Util).DebugTEST("pAccountId = "_$Get(pAccountId,pId))
	Do:pVerbose ##class(Util).DebugTEST("pId = "_pId)
	Quit tSC
}

ClassMethod UpdateBalance(pAccount As %String, pCredit As %String, pDebit As %String, pVerbose As %Integer = 0) As %Status
{
	Do:pVerbose ##class(Util).DebugTEST("Riches.Account - UpdateBalance")
	Do:pVerbose ##class(Util).DebugTEST("pAccount = "_$Get(pAccount))
	Do:pVerbose ##class(Util).DebugTEST("pCredit = "_$Get(pCredit))
	Do:pVerbose ##class(Util).DebugTEST("pDebit = "_$Get(pDebit))
	Set tSC = $$$OK
	If ($Get(pAccount) = "") Quit tSC
	Set objAccount = ##class(Riches.Account).%OpenId(pAccount)
	If '$IsObject(objAccount) {
		Quit tSC
	}
	Set tBalance = objAccount.CurrBalance + $Get(pCredit) - $Get(pDebit)
	Set objAccount.CurrBalance = tBalance
	Set tSC = objAccount.%Save()
	Do:pVerbose ##class(Util).DebugStatus(tSC)
	Quit tSC
}

Storage Default
{
<Data name="AccountDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>OpenDate</Value>
</Value>
<Value name="3">
<Value>CloseDate</Value>
</Value>
<Value name="4">
<Value>StatementDate</Value>
</Value>
<Value name="5">
<Value>Institution</Value>
</Value>
<Value name="6">
<Value>StartBalance</Value>
</Value>
<Value name="7">
<Value>CurrBalance</Value>
</Value>
<Value name="8">
<Value>StatementBalance</Value>
</Value>
<Value name="9">
<Value>Type</Value>
</Value>
<Value name="10">
<Value>Website</Value>
</Value>
<Value name="11">
<Value>Nickname</Value>
</Value>
<Value name="12">
<Value>Rewards</Value>
</Value>
</Data>
<DataLocation>^Riches.AccountD</DataLocation>
<DefaultData>AccountDefaultData</DefaultData>
<IdLocation>^Riches.AccountD</IdLocation>
<IndexLocation>^Riches.AccountI</IndexLocation>
<StreamLocation>^Riches.AccountS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
