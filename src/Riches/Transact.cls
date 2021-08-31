Class Riches.Transact Extends %Persistent
{

Property Account As Account;

Property AmountCredit As %Currency;

Property AmountDebit As %Currency;

Property Category As Category;

Property SubCategory As SubCategory;

Property Merchant As Merchant;

Property TranDate As %Date;

Property TranTime As %Time;

Property CheckNumber As %String;

Property Memo As %String;

Property Status As %String;

Property OtherSide As Transact;

Trigger Balance [ Event = INSERT, Time = AFTER ]
{
	// get row id of inserted row
	NEW id,SQLCODE,%msg,%ok,%oper
	SET id = {ID}
	SET aa = {Account}
	SET cr = {AmountCredit}
	SET db = {AmountDebit}
	SET tSC = ##class(Riches.Account).UpdateBalance(aa,cr,db)
}

ClassMethod GetColumns(ByRef pColumns) As %String
{
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Account","Account")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("AmountCredit","Credit")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("AmountDebit","Debit")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Category","Category")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("SubCategory","SubCategory")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Merchant","Merchant")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("TranDate","Date")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("TranTime","Time")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("CheckNumber","Check")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Memo","Memo")
	Set pColumns($Increment(pColumns)) = ##class(Riches.Util).EncodeLogicalDisplay("Status","Status")
	Quit $$$OK
}

ClassMethod OutputFormField(pField As %String = "Account", pCaption As %String = "", pValue As %String = "", split As %Boolean = 0) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Transact - OutputFormField")
	Do ##class(Util).DebugTEST("pField = "_pField)
	If split {
		Set prefixD = "dd"
		Set prefixI = "ii"
		Set tSize = 5
		Write "<td>",!
	} Else {
		Set prefixD = "d"
		Set prefixI = "i"
		Set tSize = 25
		Write "<tr>",!
	}
	Set q = """"
	Set qHref = "Chooser.csp?iChoose="_pField_"&iSplit="_split
	Do ##class(Util).DebugTEST("tURL = "_qHref)
	//Set qHref = q_##class(%CSP.Page).EscapeURL(tURL)_q
	//Do ##class(Util).DebugTEST("qHref = "_qHref)
	Set qID = q_prefixI_pField_q
	Set qIDD = q_prefixD_pField_q
	Set qSize = q_tSize_q
	Set qTarget = q_"iframe_ledger"_q
	Set qText = q_"text"_q
	Set qHide = q_"hidden"_q
	Set qValue = q_pValue_q
	If (pField = "Account") Set tQuery = "SELECT Nickname FROM Riches.Account WHERE ID = "_pValue
	If (pField = "Category") Set tQuery = "SELECT Nickname FROM Riches.Category WHERE ID = "_pValue
	If (pField = "Merchant") Set tQuery = "SELECT Nickname FROM Riches.Merchant WHERE ID = "_pValue
	If ($Get(tQuery) '= "") Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
	If (pField [ "Date") Set tDisplay = $ZDATE(pValue)
	If (pField [ "Time") Set tDisplay = $ZTIME(pValue)
	Set qDisplay = q_$Get(tDisplay,pValue)_q
	If split {
		Write "<table><tr>"
	} Else {
		Write "<td><label for=",qID,">",pCaption,":</label></td>",!
	}
	Write "<td>",!
	If $Data(tDisplay) {
		Write "<input type=",qText," id=",qIDD," size=",qSize," value=",qDisplay,$Get(onChange),">",!
		Write "<input type=",qHide," id=",qID," name=",qID," size=",qSize," value=",qValue,">",!
	} Else {
		Write "<input type=",qText," id=",qID," name=",qID," size=",qSize," value=",qValue,">",!
	}
	Write "</td>",!
	If split {
		Write "</tr><tr>",!
	}
	Write "<td><a href=",qHref," target=",qTarget,">Choose</a></td>",!
	If split {
		Write "</tr></table></td>",!
	} Else {
		Write "</tr>",!
	}
	Quit $$$OK
}

ClassMethod OutputFormHead(split As %Boolean = 0) As %Status
{
	Set q = """"
	Set qClick = q_"goSplit()"_q
	Set qType = q_"button"_q
	Write "<tr>",!
	If split {
		Write "<th>Category</th><th>SubCategory</th><th>Debit</th><th>Credit</th><th>Memo</th>",!
	} Else {
		Write "<th>Form</th><th>Display</th><th><button type=",qType," onclick=",qClick,">Split</button></th>",!
	}
	Write "</tr>",!
	Quit $$$OK
}

ClassMethod OutputFormSplit() As %Status
{
	Set split = 1
	/*
	Do ##class(Riches.Transact).OutputFormField("Account","Account",$Get(iAccount))
	Do ##class(Riches.Transact).OutputFormField("TranDate","Date",$Get(iTranDate,$Piece($Horolog,",",1)))
	Do ##class(Riches.Transact).OutputFormField("TranTime","Time",$Get(iTranTime,$Piece($Horolog,",",2)))
	Do ##class(Riches.Transact).OutputFormField("CheckNumber","Check",$Get(iCheckNumber))
	Do ##class(Riches.Transact).OutputFormField("Merchant","Merchant",$Get(iMerchant))
	*/
	Do ##class(Riches.Transact).OutputFormField("Category","Category",$Get(iiCategory),split)
	Do ##class(Riches.Transact).OutputFormField("SubCategory","SubCategory",$Get(iiSubCategory),split)
	Do ##class(Riches.Transact).OutputFormField("AmountDebit","Amount Debit",$Get(iiAmountDebit),split)
	Do ##class(Riches.Transact).OutputFormField("AmountCredit","Amount Credit",$Get(iiAmountCredit),split)
	Do ##class(Riches.Transact).OutputFormField("Memo","Memo",$Get(iiMemo),split)
	Quit $$$OK
}

ClassMethod OutputTableData(pWhere As %String = "", pTrClick As %String = "window.location='Transact.csp?iAccount=#';", pMaxRows = -1) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Transact - OutputTableData")
	Do ##class(Util).DebugTEST("pWhere = "_pWhere)
	Set tQuote = """"
	Set tSC = $$$OK
	Set tWHERE = ""
	If (pWhere '= "") Set tWHERE = " WHERE "_pWhere
	Set tQuery = "SELECT * FROM Riches.Transact"_tWHERE
	Do ##class(Util).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
	Write !,"<tr><th>Date</th><th>Time</th><th>Check</th><th>Merchant</th><th>Category</th><th>Debit</th><th>Credit</th></tr>"
 	While tResult.%Next() {
	 	//Set tValue = ##class(Util).EncodeLogicalDisplay(tResult.ID,tResult.Nickname)
		Set tValue = tResult.ID
		Write !,"<tr onclick=",tQuote,$Replace(pTrClick,"#",tValue),tQuote,">"
		Write !,"<td>",$ZDATE(tResult.TranDate),"</td>"
		Write !,"<td>",$ZTIME(tResult.TranTime),"</td>"
		Write !,"<td>",tResult.CheckNumber,"</td>"
		Set tQuery = "SELECT Nickname FROM Riches.Merchant WHERE ID = "_tResult.Merchant
		Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
		Write !,"<td>",tDisplay,"</td>"
		Set tQuery = "SELECT Nickname FROM Riches.Category WHERE ID = "_tResult.Category
		Set tSC = ##class(Util).ExecuteQueryOneValue(tQuery,.tDisplay)
		Write !,"<td>",tDisplay,"</td>"
		Write !,"<td>",tResult.AmountDebit,"</td>"
		Write !,"<td>",tResult.AmountCredit,"</td>"
		Write !,"</tr>"
	}
	Quit tSC
}

ClassMethod SubmitFormData(ByRef pRequestData, Output pAction, Output pId) As %Status
{
	Do ##class(Util).DebugTEST("Riches.Transact - SubmitFormData")
	Do ##class(Util).DebugMerge("pRequestData = ",.pRequestData)
	Set tSC = $$$OK
	If ($Data(pRequestData("iAccount",1))) {
		Set iAccount = pRequestData("iAccount",1)
	}
	If ($Get(iAccount) = "") {
		Set tSC = $$$ADDSC(tSC,$$$ERROR($$$GeneralError,"Account is required."))
	}
	Set iAmountCredit = 0
	If ($Data(pRequestData("iAmountCredit",1))) {
		Set iAmountCredit = pRequestData("iAmountCredit",1)
		If (iAmountCredit = "") Set iAmountCredit = 0
	}
	Set iAmountDebit = 0
	If ($Data(pRequestData("iAmountDebit",1))) {
		Set iAmountDebit = pRequestData("iAmountDebit",1)
		If (iAmountDebit = "") Set iAmountDebit = 0
	}
	If ($Data(pRequestData("iCategory",1))) {
		Set iCategory = pRequestData("iCategory",1)
	}
	If ($Get(iCategory) = "") {
		Set tSC = $$$ADDSC(tSC,$$$ERROR($$$GeneralError,"Category is required."))
	}
	If ($Data(pRequestData("iMerchant",1))) {
		Set iMerchant = pRequestData("iMerchant",1)
	}
	If ($Get(iMerchant) = "") {
		Set tSC = $$$ADDSC(tSC,$$$ERROR($$$GeneralError,"Merchant is required."))
	}
	Set iTranDate = $Piece($Horolog,",",1)
	Set iTranTime = $Piece($Horolog,",",2)
	If ($Data(pRequestData("iTranDate",1))) {
		Set iTranDate = pRequestData("iTranDate",1)
	}
	If ($Data(pRequestData("iTranTime",1))) {
		Set iTranTime = pRequestData("iTranTime",1)
	}
	If ($Data(pRequestData("iCheckNumber",1))) {
		Set iCheckNumber = pRequestData("iCheckNumber",1)
	}
	If ($Data(pRequestData("iMemo",1))) {
		Set iMemo = pRequestData("iMemo",1)
	}
	Do ##class(Util).DebugStatus(tSC)
	If $$$ISERR(tSC) Quit tSC
	TSTART
	&SQL(INSERT INTO Riches.Transact (Account,AmountCredit,AmountDebit,Category,Merchant,TranDate,TranTime,CheckNumber,Memo)
		VALUES (:iAccount,:iAmountCredit,:iAmountDebit,:iCategory,:iMerchant,:iTranDate,:iTranTime,:iCheckNumber,:iMemo))
	Do ##class(Util).DebugTEST("SQLCODE = "_SQLCODE)
	If SQLCODE TROLLBACK  Quit $$$ERROR($$$GeneralError,"Cannot INSERT Transact - SQLCODE = "_SQLCODE)
	&SQL(UPDATE Riches.Account SET CurrBalance = CurrBalance - :iAmountDebit + :iAmountCredit WHERE ID = :iAccount)
	If SQLCODE TROLLBACK  Quit $$$ERROR($$$GeneralError,"Cannot UPDATE Account - SQLCODE = "_SQLCODE)
	TCOMMIT
	Quit tSC
}

/*

select Account.Nickname, AmountCredit, AmountDebit, Category.Nickname, CheckNumber, Memo, Merchant.Nickname, OtherSide, Status, SubCategory, TranDate, TranTime
 from Riches.Transact, Riches.Account, Riches.Category, Riches.Merchant where Category.Id = Transact.Category and Merchant.Id = Transact.Merchant

*/
Storage Default
{
<Data name="TransactDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Account</Value>
</Value>
<Value name="3">
<Value>AmountCredit</Value>
</Value>
<Value name="4">
<Value>AmountDebit</Value>
</Value>
<Value name="5">
<Value>Category</Value>
</Value>
<Value name="6">
<Value>SubCategory</Value>
</Value>
<Value name="7">
<Value>Merchant</Value>
</Value>
<Value name="8">
<Value>TranDate</Value>
</Value>
<Value name="9">
<Value>TranTime</Value>
</Value>
<Value name="10">
<Value>CheckNumber</Value>
</Value>
<Value name="11">
<Value>Memo</Value>
</Value>
<Value name="12">
<Value>Status</Value>
</Value>
<Value name="13">
<Value>OtherSide</Value>
</Value>
</Data>
<DataLocation>^Riches.TransactD</DataLocation>
<DefaultData>TransactDefaultData</DefaultData>
<IdLocation>^Riches.TransactD</IdLocation>
<IndexLocation>^Riches.TransactI</IndexLocation>
<StreamLocation>^Riches.TransactS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
