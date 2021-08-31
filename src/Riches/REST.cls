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
	If ($Extract(pDebug,*) = $Char(13)) Set pDebug = $Extract(pDebug,1,*-1)
	Set ^RichesDEBUG(pIndex,tIncrement) = pIndex_","_ pDebug
	Quit $$$OK
}

/// Insert into Riches.Transact (Account,TranDate,Merchant,Category,AmountDebit,AmountCredit) values ('Chase Better Banking Checking','1-3-2021','Aldi','Groceries','51.41','')
/// %Message = Field 'Riches.Transact.AmountCredit' (value <EMPTY STRING>) failed validation
/// 				Field 'Riches.Transact.TranDate' (value '1-3-2021') failed validation
ClassMethod PostSQL(pQuery As %String = "", pIndex As %String = -1) As %Status
{
	Do ..DebugTEST("Riches.REST - PostSQL")
	Do ..DebugTEST("pQuery = "_pQuery)
	Do ..DebugTEST("pIndex = "_pIndex)
	Set tSC = ..TestQuery(pQuery,.pQuery)
	Do ..DebugTEST("TestQuery = "_pQuery)
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

ClassMethod TestFiles(pColumns As %String = "", ByRef pValues As %String) As %Status
{
	Do ..DebugTEST("Riches.REST - TestFiles")
	Do ..DebugTEST("pColumns = "_pColumns)
	Do ..DebugTEST("pValues = "_$Get(pValues))
	Set tCOLUMNS = $ZCONVERT(pColumns,"U")
	Do ..DebugTEST("tCOLUMNS = "_tCOLUMNS)
	Set tSC = $$$OK
	Set tLength = $Length(pColumns,",")
	Do ..DebugTEST("tLength = "_tLength)
	For ii = 1:1:tLength {
		Do ..DebugTEST("ii = "_ii)
		Set tCNAME = $Piece(tCOLUMNS,",",ii)
		Do ..DebugTEST("tCNAME = "_tCNAME)
		Set tValue = $Piece(pValues,",",ii)
		Do ..DebugTEST("tValue = "_tValue)
		If (tValue = "''") Set tValue = "Unassigned"
		If (tCNAME = "ACCOUNT") {
			Set tSC = ##class(Riches.Account).TestValue(tValue,.tFileId,.pId)
			Do ..DebugTEST("tFileId = "_tFileId)
			Do ..DebugTEST("pId = "_pId)
			Set $Piece(pValues,",",ii) = tFileId
		}
		If (tCNAME = "CATEGORY") {
			Set tSC = ##class(Riches.Category).TestValue(tValue,.tFileId,.pId)
			Do ..DebugTEST("tFileId = "_tFileId)
			Do ..DebugTEST("pId = "_pId)
			Set $Piece(pValues,",",ii) = tFileId
		}
		If (tCNAME = "MERCHANT") {
			Set tSC = ##class(Riches.Merchant).TestValue(tValue,.tFileId,.pId)
			Do ..DebugTEST("tFileId = "_tFileId)
			Do ..DebugTEST("pId = "_pId)
			Set $Piece(pValues,",",ii) = tFileId
		}
	}
	Quit tSC
}

ClassMethod TestQuery(pQuery As %String = "", Output pQuery2 As %String) As %Status
{
	Do ..DebugTEST("Riches.REST - TestQuery")
	Do ..DebugTEST("pQuery = "_pQuery)
	Set tCOMMAND = $ZCONVERT($Piece(pQuery," ",1),"U")
	Do ..DebugTEST("tCOMMAND = "_tCOMMAND)
	Set tPIECE2 = $ZCONVERT($Piece(pQuery," ",2),"U")
	Do ..DebugTEST("tPIECE2 = "_tPIECE2)
	If (tCOMMAND = "INSERT"),(tPIECE2 = "INTO") {
		Set tTable = $Piece(pQuery," ",3)
		Do ..DebugTEST("tTable = "_tTable)
		Set tPiece4 = $Piece(pQuery," ",4)
		Do ..DebugTEST("tPiece4 = "_tPiece4)
		Set tPIECE5 = $ZCONVERT($Piece(pQuery," ",5),"U")
		Do ..DebugTEST("tPIECE5 = "_tPIECE5)
		If (tPIECE5 = "VALUES") {
			Set tColumns = tPiece4
			Do ..DebugTEST("tColumns = "_tColumns)
			Set tCOLUMNS = $ZCONVERT(tColumns,"U")
			Do ..DebugTEST("tCOLUMNS = "_tCOLUMNS)
			Set tParValues = $Piece(pQuery," ",6,999)
			If ($Extract(tParValues,1) = "("),($Extract(tParValues,*) = ")") {
				Set tValues = $Extract(tParValues,2,*-1)
			}
			Set tValues = $Get(tValues,tParValues)
			Do ..DebugTEST("tValues = "_$Get(tValues))
			Set tSC = ..UnQuoteValues(tValues,.tValues)
			Set tSC = ..TestFiles(tCOLUMNS,.tValues)
			If (tCOLUMNS [ "DATE") {
				Set tLength = $Length(tColumns,",")
				Do ..DebugTEST("tLength = "_tLength)
				For ii = 1:1:tLength {
					Do ..DebugTEST("ii = "_ii)
					Set tCNAME = $Piece(tCOLUMNS,",",ii)
					If (tCNAME [ "AMOUNT") {
						Set tValue = $Piece(tValues,",",ii)
						Do ..DebugTEST("tValue = "_tValue)
						Set tSC = ..UnQuote(tValue,.tAValue)
						If ($Get(tAValue) = "''") {
							Set tAmount = 0
							Do ..DebugTEST("tAmount = "_$Get(tAmount))
							Set $Piece(tValues,",",ii) = $Get(tAmount)
							Do ..DebugTEST("tValues = "_tValues)
						}
					}
					If (tCNAME [ "DATE") {
						Set tValue = $Piece(tValues,",",ii)
						Do ..DebugTEST("tValue = "_tValue)
						Set tSC = ..UnQuote(tValue,.tDValue)
						If ($Get(tDValue) ? 1.N1"-"1.N1"-"1.N) {
							Set tDate = $ZDATEH(tDValue,8)
							Do ..DebugTEST("tDate = "_$Get(tDate))
							Set $Piece(tValues,",",ii) = $Get(tDate)
							Do ..DebugTEST("tValues = "_tValues)
						}
					}
					If (tCNAME [ "TIME") {
						Set tValue = $Piece(tValues,",",ii)
						Do ..DebugTEST("tValue = "_tValue)
						Set tSC = ..UnQuote(tValue,.tTValue)
						If ($Get(tTValue) = "''") {
							Set tTime = 0
							Do ..DebugTEST("tTime = "_$Get(tTime))
							Set $Piece(tValues,",",ii) = $Get(tTime)
							Do ..DebugTEST("tValues = "_tValues)
						}
					}
				}
				Set tParValues = "("_$Get(tValues)_")"
				Set $Piece(pQuery," ",6,999) = tParValues
				Do ..DebugTEST("pQuery = "_pQuery)
			}
		}
	}
	Set pQuery2 = pQuery
	Do ..DebugTEST("pQuery2 = "_pQuery2)
	Quit $$$OK
}

ClassMethod UnQuote(pQuote As %String = "", Output pUnQuote As %String) As %Status
{
	Set boolContinue = 1
	While boolContinue {
		Set tFirst = $Extract(pQuote,1)
		Set tLast = $Extract(pQuote,*)
		If (tFirst = "'") {
			If (tFirst = tLast) {
				Set pQuote = $Extract(pQuote,2,*-1)
			} Else { Set boolContinue = 0 }
		} ElseIf (tFirst = """") {
			If (tFirst = tLast) {
				Set pQuote = $Extract(pQuote,2,*-1)
			} Else { Set boolContinue = 0 }
		} Else { Set boolContinue = 0 }
	}
	Set pUnQuote = pQuote
	If (pUnQuote = "") Set pUnQuote = "''"
	Quit $$$OK
}

ClassMethod UnQuoteValues(pQuote As %String = "", Output pUnQuote As %String) As %Status
{
	Do ..DebugTEST("Riches.REST - UnQuoteValues")
	Set tLength = $Length(pQuote,",")
	Do ..DebugTEST("tLength = "_tLength)
	For ii = 1:1:tLength {
		Do ..DebugTEST("ii = "_ii)
		Set tValue = $Piece(pQuote,",",ii)
		Do ..DebugTEST("tValue = "_tValue)
		Set tSC = ..UnQuote(tValue,.tUnValue)
		Do ..DebugTEST("tUnValue = "_tUnValue)
		Set $Piece(pUnQuote,",",ii) = tUnValue
	}
	Quit $$$OK
}

}
