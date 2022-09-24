Class Riches.Translate
{

ClassMethod Setup() As %Status
{
	Set ^TRANSLATE("Account","Original") = "Translated"
	Set ^TRANSLATE("Category","Restaurant") = "Restaurants"
	Set ^TRANSLATE("Credit-Debit","Hhonors") = "Credit is Debit"
	Quit $$$OK
}

ClassMethod TranslateImportLine(pLine As %String = "", pTable As %String = "", pDebug As %String = 0) As %String
{
	Do:pDebug ##class(Util).DebugTEST("Riches.Translate - TranslateImportLine")
	Do:pDebug ##class(Util).DebugTEST("pLine = "_pLine)
	If (pTable = "") Set pTable = "Riches.Transact"
	Set delim = ","  // Fails if Memo contains comma
	Set q = """"
	Set delim = delim_q
	Set tAccount = ""
	Set tCategory = ""
	Set tCredit = ""
	Set tDebit = ""
	Set cc = ""
	For {
		Set cc = $Order(^RichesColumn(cc),1,pp)
		If (cc = "") { Quit }
		If (+$Get(pp) < 1) { Continue }
		Set x = q_$Piece(pLine,delim,pp)
		//Set x = $Replace(x,",","~")  // Replace comma with tilde
		//Set x = ..UnquotedString(x)
		//If ($Length(x) > 50) Set x = $Extract(x,1,50)
		Set tValues(cc) = x
	}
	Set tReturn = pLine
	Set x = $Get(tValues("Account"))
	Set tAccount = ##class(Util).UnquotedString(x)
	Do:pDebug ##class(Util).DebugTEST("tAccount = "_tAccount)
	Set tCreditDebit = ""
	If (tAccount '= "") Set tCreditDebit = ($Get(^TRANSLATE("Credit-Debit",tAccount)))
	Do:pDebug ##class(Util).DebugTEST("tCreditDebit = "_tCreditDebit)
	If (tCreditDebit = "Credit is Debit") {
		Set pDebug = 1
		Set tCredit = $Get(tValues("AmountDebit"),$Get(tValues("Debit")))
		Do:pDebug ##class(Util).DebugTEST("tCredit = "_tCredit)
		Set tDebit = $Get(tValues("AmountCredit"),$Get(tValues("Credit")))
		Do:pDebug ##class(Util).DebugTEST("tDebit = "_tDebit)
		Set pp = $Get(^RichesColumn("AmountCredit"),$Get(^RichesColumn("Credit")))
		Do:pDebug ##class(Util).DebugTEST("pp = "_pp)
		Set $Piece(tReturn,delim,pp) = $Extract(tCredit,2,*)
		Set pp = $Get(^RichesColumn("AmountDebit"),$Get(^RichesColumn("Debit")))
		Do:pDebug ##class(Util).DebugTEST("pp = "_pp)
		Set $Piece(tReturn,delim,pp) = $Extract(tDebit,2,*)
	}
	Set x = $Get(tValues("Category"))
	Set tCategory = ##class(Util).UnquotedString(x)
	Do:pDebug ##class(Util).DebugTEST("tCategory = "_tCategory)
	If (tCategory '= ""),($Get(^TRANSLATE("Category",tCategory)) '= "") {
		Set pDebug = 1
		Set tCategory = $Get(^TRANSLATE("Category",tCategory))
		Set pp = $Get(^RichesColumn("Category"))
		Set $Piece(tReturn,delim,pp) = tCategory_q
	}
	Do:pDebug ##class(Util).DebugTEST("Riches.Translate - TranslateImportLine")
	Do:pDebug ##class(Util).DebugTEST("pLine = "_pLine)
	Do:pDebug ##class(Util).DebugTEST("tReturn = "_tReturn)
	Quit tReturn
}

}
