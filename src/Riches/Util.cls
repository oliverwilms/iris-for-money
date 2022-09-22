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

ClassMethod ExecuteQueryOneValue(pQuery As %String, ByRef pResult As %String, pVerbose As %Integer = 0) As %Status
{
	Do:pVerbose ..DebugTEST("Riches.Util - ExecuteQueryOneValue")
	Do:pVerbose ..DebugTEST("pQuery = "_pQuery)
	Set pResult = ""
	Set rs = ##class(%ResultSet).%New()
	Set tSC = rs.Prepare(pQuery)
	Do:pVerbose ..DebugStatus(tSC)
	If $$$ISOK(tSC) {
		Set tSC = rs.Execute()
		Do:pVerbose ..DebugStatus(tSC)
		If $$$ISOK(tSC), rs.Next() Set pResult = rs.GetData(1)
	}
	Do rs.Close()
	Set rs = ""
	Do:pVerbose ..DebugTEST("pResult = "_pResult)
	Quit tSC
}

ClassMethod GetColumnListCSV(pClassname As %String = "") As %String
{
	If (pClassname = "") Set pClassname = "Riches.Category"
	Try {
		Set tColumnListCSV = $CLASSMETHOD(pClassname,"GetColumnListCSV")
	} Catch {
	}
	Quit $Get(tColumnListCSV)
}

ClassMethod GetOptionsTableColumns(pClassname As %String = "", Output pOptions As %String) As %String
{
	/*
	Set q = """"
	Set qValue = q_""_q
	Set tOption0 = "<option value="_qValue_"></option>"
	Set qValue = q_"Nickname"_q
	Set tOption1 = "<option value="_qValue_">Nickname</option>"
	Set qValue = q_"SortOrder"_q
	Set tOption2 = "<option value="_qValue_">Sort</option>"
	Set qValue = q_"Type"_q
	Set tOption3 = "<option value="_qValue_">Type</option>"
	*/
	Set q = """"
	Set qValue = q_""_q
	Set pOptions = "<option value="_qValue_"></option>"
	If (pClassname = "") Set pClassname = "Riches.Category"
	Try {
		Set tSC = $CLASSMETHOD(pClassname,"GetColumns",.pColumns)
	} Catch {
	}
	For ii = 1:1:$Get(pColumns,0) {
		Set tLogicalDisplay = $Get(pColumns(ii))
		Set delim = $Extract(tLogicalDisplay,1)
		Set tLogical = $Piece(tLogicalDisplay,delim,2)
		Set tDisplay = $Piece(tLogicalDisplay,delim,3)
		Set qValue = q_tLogical_q
		Set pOptions = pOptions_"<option value="_qValue_">"_tDisplay_"</option>"
	}
	Quit pOptions
}

ClassMethod GetOptionsTableNames(pSelected As %String = "", Output pOptions As %String) As %String
{
	/*
  <option value="Riches.Category">Category</option>
  <option value="Riches.Merchant">Merchant</option>
  <option value="Riches.Transact">Transact</option>
	*/
	Set q = """"
	Set qValue = q_""_q
	Set pOptions = "<option value="_qValue_"></option>"
	For ii = "Category", "Merchant", "Transact" {
		Set tLogical = "Riches."_ii
		Set tDisplay = ii
		Set qValue = q_tLogical_q
		Set selected = $Select((tLogical = pSelected):" selected",1:"")
		Set pOptions = pOptions_"<option value="_qValue_selected_">"_tDisplay_"</option>"
	}
	Quit pOptions
}

ClassMethod ImportDebug(pAccount As %String = "", pTable As %String = "", pDebug As %String = "") As %Status
{
	Do ..DebugTEST("Riches.Util - ImportDebug")
	Do ..DebugTEST("pAccount = "_pAccount)
	Do ..DebugTEST("pTable = "_pTable)
	If ($Data(^RichesDEBUG) = 0) Quit $$$OK
	Kill ^RichesImport
	If (pDebug = "") {
		//Set pTable = pDebug
		Set pDebug = "PREVIEW"
	}
	If (pDebug = "PREVIEW") {
		Set pp = ""
		For {
			Set pp = $Order(^RichesDEBUG(pp))
			If (pp = "") Quit
			Set qq = $Order(^RichesDEBUG(pp,""))
			If (qq = "") Continue
			Set tDebugLine = $Get(^RichesDEBUG(pp,qq))
			Set pDebug = 0
			Set tSC = ..ImportDebugLine(tDebugLine,(pp = 0),pp,pAccount,pTable,pDebug)
			If $$$ISERR(tSC) Quit
		}
	}
	Quit $$$OK
}

ClassMethod ImportDebugLine(pDebugLine As %String = "", pHeader As %String = 0, pId As %String = "", pAccount As %String = "", pTable As %String = "", pDebug As %String = 0) As %Status
{
	Do:pDebug ..DebugTEST("Riches.Util - ImportDebugLine")
	Do:pDebug ..DebugTEST("pDebugLine = "_pDebugLine)
	If (pId '= "") Set ^RichesImport(pId) = pDebugLine
	If (pHeader = 0) Quit $$$OK
	Kill ^RichesHeader, ^RichesColumn
	Set tClassname = pTable
	If (tClassname = "") Set tClassname = "Riches.Transact"
	Set delim = ","
	Set tLen = $Length(pDebugLine,delim)
	For pp=2:1:tLen {
		Set tDebugPiece = $Piece(pDebugLine,delim,pp)
		Set tDebugPiece = ..UnquotedString(tDebugPiece)
		If ($Get(tDebugPiece) '= "") {
			Set ^RichesHeader(tDebugPiece) = pp
		}
	}
	Set ^RichesColumn("Account") = $Get(^RichesHeader("Account"))
	Set ^RichesColumn("AmountCredit") = $Get(^RichesHeader("AmountCredit"),$Get(^RichesHeader("Credit")))
	Set ^RichesColumn("AmountDebit") = $Get(^RichesHeader("AmountDebit"),$Get(^RichesHeader("Debit")))
	Set ^RichesColumn("Category") = $Get(^RichesHeader("Category"))
	Set ^RichesColumn("SubCategory") = $Get(^RichesHeader("SubCategory"))
	Set ^RichesColumn("Merchant") = $Get(^RichesHeader("Merchant"))
	Set ^RichesColumn("TranDate") = $Get(^RichesHeader("TranDate"),$Get(^RichesHeader("Date")))
	Set ^RichesColumn("TranTime") = $Get(^RichesHeader("TranTime"),$Get(^RichesHeader("Time")))
	Set ^RichesColumn("CheckNumber") = $Get(^RichesHeader("CheckNumber"),$Get(^RichesHeader("Check")))
	Set ^RichesColumn("Memo") = $Get(^RichesHeader("Memo"))
	Set ^RichesColumn("Status") = $Get(^RichesHeader("Status"))
	Quit $$$OK
}

ClassMethod ImportRichesImport() As %Status
{
	Do ..DebugTEST("Riches.Util - ImportRichesImport")
	Set tSC = $$$OK
	If ($Get(pDebug) = "") {
		//Set pTable = pDebug
		Set pDebug = "PREVIEW"
	}
	If (pDebug = "PREVIEW") {
		Set pp = ""
		For {
			Set pp = $Order(^RichesImport(pp))
			If (pp = "") { Quit }
			If (pp = 0) { Continue }  // Skip Header line
			If (pp = -1) { Continue }  // ???
			Set tDebugLine = $Get(^RichesImport(pp))
			//Set pDebug = 0
			Set tSC = ..ImportRichesImportLine(tDebugLine)
			If $$$ISERR(tSC) Quit
		}
	}
	Quit tSC
}

ClassMethod ImportRichesImportLine(pLine As %String = "", pTable As %String = "", pDebug As %String = 1) As %Status
{
	Do:pDebug ..DebugTEST("Riches.Util - ImportRichesImportLine")
	Do:pDebug ..DebugTEST("pLine = "_pLine)
	If (pTable = "") Set pTable = "Riches.Transact"
	Set delim = ","  // Fails if Memo contains comma
	Set q = """"
	Set delim = delim_q
	Set tInsert = "Insert into "_pTable
	Set tColumns = ""
	Set tValues = ""
	Set cc = ""
	For {
		Set cc = $Order(^RichesColumn(cc),1,pp)
		If (cc = "") { Quit }
		If (+$Get(pp) < 1) { Continue }
		Set tColumns = tColumns_","_cc
		Set x = q_$Piece(pLine,delim,pp)
		Set x = $Replace(x,",","~")  // Replace comma with tilde
		Set x = ..UnquotedString(x)
		If ($Length(x) > 50) Set x = $Extract(x,1,50)
		Set tValues = tValues_","_x
	}

	Set tInsert = tInsert_" ("_$Extract(tColumns,2,*)_") values ("_$Extract(tValues,2,*)_")"
	Set tSC = ..InsertSQL(tInsert)
	Quit tSC
}

/// Insert into Riches.Transact (Account,TranDate,Merchant,Category,AmountDebit,AmountCredit) values ('Chase Better Banking Checking','1-3-2021','Aldi','Groceries','51.41','')
/// %Message = Field 'Riches.Transact.AmountCredit' (value <EMPTY STRING>) failed validation
/// 				Field 'Riches.Transact.TranDate' (value '1-3-2021') failed validation
ClassMethod InsertSQL(pQuery As %String = "", pDebug As %String = 0) As %Status
{
	Set tSC = ##class(Riches.REST).TestQuery(pQuery,.tTestQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(tTestQuery)
	If $$$ISERR(tSC) {
		Set pDebug = 1
		Do ..DebugStatus(tSC)
		Write "%Prepare failed:"
		Do $System.Status.DisplayError(tSC) // QUIT
	} Else {
		#Dim rset As %SQL.StatementResult
		// Execute the current statement and return the result. The result of the execute is always the return value.
		// Success/Failure information is reported in the result object as %SQLCODE, %Message, %ROWCOUNT, and/or %ROWID.
		Set rset = tStatement.%Execute()
		If (0 '= rset.%SQLCODE) {
			Set pDebug = 1	
		}
	}
	Try {
		Do:pDebug ..DebugTEST("Riches.Util - InsertSQL")
		Do:pDebug ..DebugTEST("pQuery = "_pQuery)
		Do:pDebug ..DebugTEST("TestQuery = "_tTestQuery)
		Do:pDebug ..DebugTEST("%SQLCODE = "_rset.%SQLCODE)
		Do:pDebug ..DebugTEST("%Message = "_rset.%Message)
		Do:pDebug ..DebugTEST("%ROWID = "_rset.%ROWID)
	} Catch { }
	Quit tSC
}

ClassMethod OutputDebug(pAccount As %String = "", pTable As %String = "", pDebug As %String = "") As %Status
{
	Do ..DebugTEST("Riches.Util - OutputDebug")
	Do ..DebugTEST("pAccount = "_pAccount)
	Do ..DebugTEST("pTable = "_pTable)
	If ($Data(^RichesDEBUG) = 0) Quit $$$OK
	If (pDebug = "") {
		//Set pTable = pDebug
		Set pDebug = "PREVIEW"
	}
	Write "<table border=1>",!
	If (pDebug = "PREVIEW") {
		Set pp = ""
		For {
			Set pp = $Order(^RichesDEBUG(pp))
			If (pp = "") Quit
			Set qq = $Order(^RichesDEBUG(pp,""))
			If (qq = "") Continue
			Set tDebugLine = $Get(^RichesDEBUG(pp,qq))
			Set pDebug = 0
			Set tSC = ..OutputDebugLine(tDebugLine,(pp = 0),pp,pAccount,pTable,pDebug)
			If $$$ISERR(tSC) Quit
		}
	}
	Write "</table>",!
	Quit $$$OK
}

ClassMethod OutputDebugLine(pDebugLine As %String = "", pHeader As %String = 0, pId As %String = "", pAccount As %String = "", pTable As %String = "", pDebug As %String = 0) As %Status
{
	Do:pDebug ..DebugTEST("Riches.Util - OutputDebugLine")
	Do:pDebug ..DebugTEST("pDebugLine = "_pDebugLine)
	Set q = """"
	Set delim = ","
	Set tLen = $Length(pDebugLine,delim)
	For pp=1:1:tLen {
		Set tDebugPiece = $Piece(pDebugLine,delim,pp)
		If (pp = 1) {
			Set tLineId = tDebugPiece  // Is tLineId same as pId ?
			Write "<tr id=",q,"tr_",pId,q,">",!
			Set qID = q_"div_"_pId_"_0"_q
			Set tDiv = "<div id="_qID_">"_tDebugPiece_"</div>"
			Set tSC = ..OutputDebugPiece(tDiv,pHeader,pDebug)
			If $$$ISERR(tSC) Quit
			// Add a table cell for iAccount
			Set tDebugPiece = $Get(pAccount)
		}
		Set qID = q_"div_"_pId_"_"_pp_q
		Set tDiv = "<div id="_qID_">"_tDebugPiece_"</div>"
		Set tSC = ..OutputDebugPiece(tDiv,pHeader,pDebug)
		If $$$ISERR(tSC) Quit
	}
	Write "<th>",!
	Set x = $Select((pHeader = 0):"goClickLine",1:"goClickHeader")
	Set qClick = q_x_"("_tLineId_")"_q
	Set qType = q_"button"_q
	Write "<button type=",qType," onclick=",qClick,">Import</button>",!
	Write "</th>",!
	Write "</tr>",!
	If (pHeader = 0) Quit $$$OK
	// Row of <select> for choosing table column to import to
	Set tClassname = pTable
	//Set tClassname = "Riches.Category"
	Set q = """"
	Set tSelect2 = "</select>"
	Set onchange = "onchangeSel(this)"
	Write "<tr>",!
	For pp=1:1:tLen {
		If (pp = 1) {
			Set qID = q_"div_col_count"_q
			Set qStyle = q_"display:none"_q
			Set tDebugPiece = "<div id="_qID_" style="_qStyle_">"_tLen_"</div>"
			Set tSC = ..OutputDebugPiece(tDebugPiece,0)
			If $$$ISERR(tSC) Quit
			// Add a <select> for iAccount
		}
		Set qName = q_"sel_"_pp_q
		Set qID = q_"sel_"_pp_q
		Set tSelect1 = "<select name="_qName_" id="_qID_"onchange="_q_onchange_q_">"
		Set tDebugPiece = "<div>"_tSelect1_..GetOptionsTableColumns(tClassname)_tSelect2_"</div>"
		Set tSC = ..OutputDebugPiece(tDebugPiece,0)
	}
	Write "</tr>",!
	Quit $$$OK
}

ClassMethod OutputDebugPiece(pDebugPiece As %String = "", pHeader As %String = 0, pDebug As %String = 0) As %Status
{
	Do:pDebug ..DebugTEST("Riches.Util - OutputDebugPiece")
	Do:pDebug ..DebugTEST("pDebugPiece = "_pDebugPiece)
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

ClassMethod OutputSelectTable(pName As %String = "iTable", pID As %String = "iTable", pCaption As %String = "Insert into table:", pSelected As %String) As %Status
{
	/*
<label for="iTable">Insert into table:</label>
<select name="iTable" id="iTable" onchange="onchangeTable(this.value)">
  <option value="Riches.Category">Category</option>
  <option value="Riches.Merchant">Merchant</option>
  <option value="Riches.Transact">Transact</option>
</select>
	*/
	Set pDebug = 1
	Do:pDebug ..DebugTEST("Riches.Util - OutputSelectTable")
	Do:pDebug ..DebugTEST("pSelected = "_$Get(pSelected))
	Set q = """"
	Set qName = q_pName_q
	Set qID = q_pID_q
	Write "<label for=",qID,">",pCaption,"</label>",!
	Write "<select name=",qName," id=",qID," onchange=",q,"onchangeTable(this.value)",q,">",!
	Write ..GetOptionsTableNames($Get(pSelected))
	Write "</select>",!
	Quit $$$OK
}

ClassMethod QuoteJSLogicalDisplay(pLogical As %String = "", pDisplay As %String = "") As %String
{
	Set tLogicalDisplay = ..EncodeLogicalDisplay(pLogical,pDisplay)
	Quit ##class(%CSP.Page).QuoteJS(tLogicalDisplay)
}

ClassMethod SQLGrantAccess() As %Status
{
	&sql(GRANT INSERT,SELECT,UPDATE ON Riches.Account,Riches.Category,Riches.Merchant,Riches.SubCategory,Riches.Transact TO UnknownUser)
	if SQLCODE < 0 throw ##class(%Exception.SQL).CreateFromSQLCODE(%SQLCODE,"Grant roles")
	Quit $$$OK
}

ClassMethod UnquotedString(pQuotedString As %String = "") As %String
{
	Set q = """"
	Set tReturn = pQuotedString
	If ($Extract(pQuotedString,1) = q),($Extract(pQuotedString,*) = q) {
		Set tReturn = $Extract(pQuotedString,2,*-1)
	}
	Quit tReturn
}

}
