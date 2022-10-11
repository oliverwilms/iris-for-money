Class Riches.Count
{

Parameter OUT = "X";

ClassMethod Average(param As %String = "") As %Status
{
	Kill ^AVERAGE
	Set delim = $Extract(param)
	If (delim = "") Set delim = "^"
	Set tFromMM = $Piece(param,delim,2)
	Set tFromYY = $Piece(param,delim,3)
	Set tToMM = $Piece(param,delim,4)
	Set tToYY = $Piece(param,delim,5)
	Set tDebug = 1
	Do:tDebug ##class(Util).DebugTEST("Riches.Count - Average")
	If (tFromYY = "") Set tFromYY = 2021
	If (tFromMM = "") Set tFromMM = 10
	If (tToMM = "") Set tToYY = 2022
	If (tToYY = "") Set tToMM = 9
	Set yy = tFromYY - 1
	For {
		Set yy = $Order(^COUNT(yy))
		If (yy = "") { Quit }
		Set mm = $Select((yy = tFromYY):(tFromMM - 1),1:0)
		For {
			Set mm = $Order(^COUNT(yy,mm))
			If (mm = "") { Quit }
			Set cc = ""
			For {
				Set cc = $Order(^COUNT(yy,mm,cc))
				If (cc = "") { Quit }
				Set data = $Get(^COUNT(yy,mm,cc))
				Set diff = $Piece(data,delim,2) - $Piece(data,delim,3)
				Set aver = $Get(^AVERAGE(cc))
				Set ^AVERAGE(cc) = aver + diff
			}
		}
	}
	Set param = delim
	Set $Piece(param,delim,2) = tFromMM
	Set $Piece(param,delim,3) = tFromYY
	Set $Piece(param,delim,4) = tToMM
	Set $Piece(param,delim,5) = tToYY
	Quit $$$OK
}

ClassMethod AverageParam(pWhere As %String = "") As %String
{
	// pWhere = iAverage = 12 AND iFilter = PREV|A|^10^2021^9^2022 AND iStartDate >= '2021/1/10' AND iEndDate <= '12/31/10'
	If (pWhere [ "iAverage") {
		Set tAverage = $Piece(pWhere," AND ",1,1)
		Set tAverage = $Piece(tAverage,"iAverage = ",2)
		Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	Set tFilter = ""
	Set tOrder = -1  // Show newest first
	Set (tToYY, tToMM) = ""
	// iFilter = PREV|A|^10^2021^9^2022
	If (pWhere [ "iFilter") {
		Set tFilter = $Piece(pWhere," AND ",1,1)
		Set tFilter = $Piece(tFilter,"iFilter = ",2)
		If (tFilter [ "|A|") {
			Set param = $Piece(tFilter,"|A|",2,*)
		}
	//	Do:tDebug ##class(Util).DebugTEST("tFilter = "_tFilter)
		Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	If ($Get(param) '= "") {
		Set delim = $Extract(param)
		If (delim = "") Set delim = "^"
		Set tFromMM = $Piece(param,delim,2)
		Set tFromYY = $Piece(param,delim,3)
		Set tToMM = $Piece(param,delim,4)
		Set tToYY = $Piece(param,delim,5)
	}
	If (tToMM = "") Set tToYY = ""
	If (tToYY = "") {
		Set tDate = $ZDATE($HOROLOG)
		Set tToYY = $Piece(tDate,"/",3)
		Set tToMM = +$Piece(tDate,"/",1)  // Drop leading zero
		Set tToDD = 1
		Set $Piece(tDate,"/",2) = tToDD
		Set tDateH = $ZDATEH(tDate)
		Set tDate = $ZDATE(tDateH - 1)
		Set tToYY = $Piece(tDate,"/",3)
		Set tToMM = +$Piece(tDate,"/",1)  // Drop leading zero
	}
	If ($Extract(tFilter,1,4) = "NEXT") {
		Set tToMM = $Order(^COUNT(tToYY,tToMM),1)
		If (tToMM = "") {
			Set tToYY = $Order(^COUNT(tToYY),1)
			If (tToYY '= "") {
				Set tToMM = $Order(^COUNT(tToYY,tToMM),1)
			}
		}
		Set tFromMM = $Order(^COUNT(tFromYY,tFromMM),1)
		If (tFromMM = "") {
			Set tFromYY = $Order(^COUNT(tFromYY),1)
			If (tFromYY '= "") {
				Set tFromMM = $Order(^COUNT(tFromYY,tFromMM),1)
			}
		}
	}
	If ($Extract(tFilter,1,4) = "PREV") {
		Set tToMM = $Order(^COUNT(tToYY,tToMM),-1)
		If (tToMM = "") {
			Set tToYY = $Order(^COUNT(tToYY),-1)
			If (tToYY '= "") {
				Set tToMM = $Order(^COUNT(tToYY,tToMM),-1)
			}
		}
		Set tFromMM = $Order(^COUNT(tFromYY,tFromMM),-1)
		If (tFromMM = "") {
			Set tFromYY = $Order(^COUNT(tFromYY),-1)
			If (tFromYY '= "") {
				Set tFromMM = $Order(^COUNT(tFromYY,tFromMM),-1)
			}
		}
	}
	//Set tReturn = "^"_tYear_"^"_tMonth
	If (tToYY = "") {
	//	Do ..OutputTableNada()
 	//	Quit tReturn
	}
	Set delim = $Get(delim,"^")
	Set tFromMM = $Get(tFromMM)
	Set tFromYY = $Get(tFromYY)
	Set tToMM = $Get(tToMM)
	Set tToYY = $Get(tToYY)
	Set param = delim_tFromMM_delim_tFromYY_delim_tToMM_delim_tToYY
	Do ..Average(.param)
	Quit $Get(param)
}

ClassMethod Count(param As %String = "") As %Status
{
	Kill ^COUNT
	Set tDebug = 0
	Do:tDebug ##class(Util).DebugTEST("Riches.Count - Count")
	If ($Get(param) = "") Set param = "Category"
	Do:tDebug ##class(Util).DebugTEST("param = "_param)
	Set ^COUNT = param
	Set tSC = $$$OK
	Set tTable = "Riches.Transact"
	Set tWHERE = ""
	Set tQuery = "SELECT * FROM "_tTable_tWHERE
	Do:tDebug ##class(Util).DebugTEST("tQuery = "_tQuery)
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(.tQuery)  // Create a cached query
	If $$$ISERR(tSC) Do ##class(Util).DebugStatus(tSC)
	If $$$ISERR(tSC) { Quit tSC }
	#dim tResult As %SQL.StatementResult
	Set tResult = tStatement.%Execute()
	IF (tResult.%SQLCODE=0) { /*WRITE !,"Created a query",!*/ }
	ELSEIF (tResult.%SQLCODE=-361) { /*WRITE !,"Query exists: ",tResult.%Message*/ }
	ELSE { /*WRITE !,"CREATE QUERY error: ",tResult.%SQLCODE," ",tResult.%Message*/ QUIT tSC}
	Set (tSumCredit, tSumDebit) = 0
	While tResult.%Next() {
		Set (tYear, tMonth) = 0
		Set tTranDate = tResult.TranDate
		Do ..DateParts(tTranDate,.tYear,.tMonth)
		Set tAccount = tResult.Account
		If (param = "Account") {
			Set tCategory = tResult.Account
		}
		If (param = "Category") {
			Set tCategory = tResult.Category
			If (tCategory = "") Set tCategory = 0
			If $Data(^TRANSLATE("Category",tCategory)) Set tCategory = $Get(^TRANSLATE("Category",tCategory))
		}
		If (param = "Merchant") {
			Set tCategory = tResult.Merchant
		}
		If (tCategory = "") Set tCategory = 0
		Set tDebit = tResult.AmountDebit
		Set tCredit = tResult.AmountCredit
		If (tAccount '= ""),$Data(^TRANSLATE("Credit-Debit",tAccount)) {
			Set tCreditDebit = $Get(^TRANSLATE("Credit-Debit",tAccount))
			If (tCreditDebit = "Credit is Debit") {
				Set tData = tCredit
				Set tCredit = tDebit
				Set tDebit = tData
			}
		}
		Set tData = $Get(^COUNT(tYear,tMonth,tCategory))
		Set tCount = $Piece(tData,"^",1)
		Set tSumCredit = $Piece(tData,"^",2)
		Set tSumDebit = $Piece(tData,"^",3)
		Set tCount = tCount + 1
		Set tSumCredit = tSumCredit + tCredit
		Set tSumDebit = tSumDebit + tDebit
		Set ^COUNT(tYear,tMonth,tCategory) = tCount_"^"_tSumCredit_"^"_tSumDebit
	}
	Do ..Count2()
	Set tTotal = tResult.%ROWCOUNT
	Write tTotal," Transactions counted.",!
	Quit $$$OK
}

ClassMethod Count2() As %Status
{
	Set tYear = ""
	For {
		Set tYear = $Order(^COUNT(tYear))
		If (tYear = "") { QUIT }
		Set tMonth = ""
		For {
			Set tMonth = $Order(^COUNT(tYear,tMonth))
			If (tMonth = "") { QUIT }
			Set tSub = ""
			Set (tSumCount, tSumCredit, tSumDebit) = 0
			For {
				Set tSub = $Order(^COUNT(tYear,tMonth,tSub),1,tData)
				If (tSub = "") { QUIT }
				Set tSumCount = tSumCount + $Piece(tData,"^",1)
				Set tSumCredit = tSumCredit + $Piece(tData,"^",2)
				Set tSumDebit = tSumDebit + $Piece(tData,"^",3)
			}
			Set ^COUNT(tYear,tMonth) = tSumCount_"^"_tSumCredit_"^"_tSumDebit
		}
	}
	Quit $$$OK
}

ClassMethod DateParts(pDate As %String, Output pYear As %Integer, Output pMonth As %Integer, Output pDay As %Integer) As %Status
{
	Set tSC = $$$OK
	If (pDate ? 1.N) {
		Set dformat = 1
		Set pDate = $ZDate(pDate,dformat)
	}
	If (pDate ? 1.2N1"/"1.2N1"/"1.4N) {
		Set pMonth = $Piece(pDate,"/",1)
		Set pDay = $Piece(pDate,"/",2)
		Set pYear = $Piece(pDate,"/",3)
	}
	Set pYear = +$Get(pYear)
	Set pMonth = +$Get(pMonth)  // Month beginning with zero messed up Subscripts order
	Set pDay = +$Get(pDay)
	Quit tSC
}

ClassMethod GetHeader(param As %String = "") As %String
{
	Quit $Get(tHead)
}

ClassMethod GetLink(pYear As %String = "", pMonth As %String = "", pCategory As %String = "") As %String
{
	Set delim = "^"
	Set tFilter = delim_pYear_delim_pMonth_delim_pCategory
	Set tLink = "GlobalsContest.csp?iFilter="_tFilter
	Quit tLink
}

ClassMethod GetNickname(pTable As %String, pId As %String) As %String
{
	Set tNickname = ""
	If $Get(pTable) = "" Set pTable = "Riches.Category"
	Set tObject = $CLASSMETHOD(pTable,"%OpenId",$Get(pId))
	If $Data(tObject),$IsObject(tObject) Set tNickname = tObject.Nickname
	Quit tNickname
}

ClassMethod OutputTableAverage(pWhere As %String = "", pTrClick As %String = "", pMaxRows = -1) As %String
{
	Set tDebug = 1
	Do:tDebug ##class(Util).DebugTEST("Riches.Count - OutputTableAverage")
	Do:tDebug ##class(Util).DebugTEST("pWhere = "_pWhere)
	If (pWhere = "") Quit ..OutputTableCount2(pWhere,pTrClick,pMaxRows)
	Set tAverage = (pWhere [ "iAverage")
	If (tAverage = 0) Quit ..OutputTableData(pWhere,pTrClick,pMaxRows)
	If (pTrClick = "") Set pMaxRows = -1  // ?
	// pWhere = iAverage = 12 AND iFilter = PREV|A|^10^2021^9^2022 AND iStartDate >= '2021/1/10' AND iEndDate <= '12/31/10'
	If (pWhere [ "iAverage") {
		Set tAverage = $Piece(pWhere," AND ",1,1)
		Set tAverage = $Piece(tAverage,"iAverage = ",2)
	//	Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	Set tFilter = ""
	Set tOrder = -1  // Show newest first
	Set (tYear, tMonth) = ""
	// iFilter = NEXT^2022^12
	// iFilter = PREV|A|^10^2021^9^2022
	If (pWhere [ "iFilter") {
		Set tFilter = $Piece(pWhere," AND ",1,1)
		Set tFilter = $Piece(tFilter,"iFilter = ",2)
		If (tFilter [ "|A|") {
			Set param = $Piece(tFilter,"|A|",2,*)
		}
	//	Set tMonth = $Piece(tFilter,"^",3)
	//	Do:tDebug ##class(Util).DebugTEST("tFilter = "_tFilter)
	//	Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	If (tMonth = "") Set tYear = ""
	If (tYear = "") {
		Set tDate = $ZDATE($HOROLOG)
		Set tYear = $Piece(tDate,"/",3)
		Set tMonth = +$Piece(tDate,"/",1)  // Drop leading zero
	}
	If ($Extract(tFilter,1,4) = "NEXT") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),1)
			}
		}
	}
	If ($Extract(tFilter,1,4) = "PREV") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),-1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
			}
		}
	}
	Set tReturn = "^"_tYear_"^"_tMonth
	If (tYear = "") {
		Do ..OutputTableNada()
 		Quit tReturn
	}
	//Do ..Average(.param)
	Set param = ..AverageParam(pWhere)
	Do ..OutputTableHeadAverage($Get(param))
 	Set (tSumData) = 0
 	Write !,"<tbody>"
	Set tCategory = ""
	//Set node = $NAME(^SORT(tYear,tMonth))
	Set node = $NAME(^SORT)
	Kill @node
	//Set tRow = 0
	For {
		Set tCategory = $Order(^AVERAGE(tCategory),1,tData)
		If (tCategory = "") { QUIT }
	//	Set tCount = $Piece(tData,"^",1)
	//	Set tCredit = $Piece(tData,"^",2)
	//	Set tDebit = $Piece(tData,"^",3)
		Set tReturn = "^"_tYear_"^"_tMonth_"^"_tCategory
		Set tClick = $Replace(pTrClick,"#",tReturn)
		If ..#OUT [ "W" Write !,"<tr onclick=""",tClick,""";>"
		Set tNickname = ..GetNickname("Riches.Category",tCategory)
		Set tSort = 0 - $ZABS(tData)
		If ..#OUT [ "W" Write "<td>",tNickname,"</td><td>",tData,"</td><td>",tData,"</td><td>",tData,"</td></tr>"
		If ..#OUT [ "X" Set @node@(tSort,tCategory,tNickname) = tData
		Set tSumData = tSumData + tData
	//	Set tSumCount = tSumCount + tCount
	//	Set tSumCredit = tSumCredit + tCredit
	//	Set tSumDebit = tSumDebit + tDebit
	}
	Set tSC = ..OutputTableNodeAverage(param)
	Write !,"</tbody>"
	//Set tDifference = tSumCredit - tSumDebit
	Do ..OutputTableFootAverage(param,tSumData)
 	Set tReturn = ..Param2Return(param)
 	Quit tReturn
	Quit $$$OK
}

ClassMethod OutputTableCount2(pWhere As %String = "", pTrClick As %String = "", pMaxRows = -1) As %String
{
	Set tDebug = 1
	Do:tDebug ##class(Util).DebugTEST("Riches.Count - OutputTableCount2")
	Do:tDebug ##class(Util).DebugTEST("pWhere = "_pWhere)
	If (pTrClick = "") Set pMaxRows = -1  // ?
	Set tFilter = ""
	Set tOrder = -1  // Show newest first
	Set (tYear, tMonth) = ""
	// iFilter = NEXT^2022^12
	If (pWhere [ "iFilter") {
		Set tFilter = $Piece(pWhere," AND ",1,1)
		Set tFilter = $Piece(tFilter,"iFilter = ",2)
		Set tYear = $Piece(tFilter,"^",2)
		Set tMonth = $Piece(tFilter,"^",3)
		Do:tDebug ##class(Util).DebugTEST("tFilter = "_tFilter)
		Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	If (tMonth = "") Set tYear = ""
	If (tYear = "") {
		Set tDate = $ZDATE($HOROLOG)
		Set tYear = $Piece(tDate,"/",3)
		Set tMonth = +$Piece(tDate,"/",1)  // Drop leading zero
	}
	If ($Extract(tFilter,1,4) = "NEXT") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),1)
			}
		}
	}
	If ($Extract(tFilter,1,4) = "PREV") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),-1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
			}
		}
	}
	Set tReturn = "^"_tYear_"^"_tMonth
	If (tYear = "") {
		Do ..OutputTableNada()
 		Quit tReturn
	}
	If (tMonth = "") {
		Do ..OutputTableNada()
 		Quit tReturn
	}
	// ^COUNT = "Category"
	If ($Data(^COUNT) < 10) {
		Do ..OutputTableNada()
		Quit tReturn
	}
	Set tMonth = tMonth + 1
	Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
	If (tMonth = "") {
		Set tYear = $Order(^COUNT(tYear),tOrder)
		Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
	}
	Set pHead = "Month^Count^Debit^Credit^Difference"
	Do ..OutputTableHead(pHead)
	Set (tSumCount, tSumCredit, tSumDebit) = 0
	Write !,"<tbody>"
	Set tData = $Get(^COUNT(tYear,tMonth))
	For {
		For {
			Set tCategory = "^"_tYear_"^"_tMonth
			Set tClick = $Replace(pTrClick,"#",tCategory)
			Set tCount = $Piece(tData,"^",1)
			Set tCredit = $Piece(tData,"^",2)
			Set tDebit = $Piece(tData,"^",3)
			Set tSC = ..OutputTableRow(tClick,tCategory,tData)
			Set tSumCount = tSumCount + tCount
			Set tSumCredit = tSumCredit + tCredit
			Set tSumDebit = tSumDebit + tDebit
			Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
			If (tMonth = "") { QUIT }
		}
		Set tYear = $Order(^COUNT(tYear),tOrder,tData)
		If (tYear = "") { QUIT }
		Set tMonth = $Order(^COUNT(tYear,tMonth),tOrder,tData)
	}
	Write !,"</tbody>"
	Set tDifference = tSumCredit - tSumDebit
	Do ..OutputTableFoot(1,tSumCount,tSumCredit,tSumDebit,tDifference)
	Quit tReturn
}

ClassMethod OutputTableData(pWhere As %String = "", pTrClick As %String = "", pMaxRows = -1) As %String
{
	Set tDebug = 1
	Do:tDebug ##class(Util).DebugTEST("Riches.Count - OutputTableData")
	Do:tDebug ##class(Util).DebugTEST("pWhere = "_pWhere)
	If (pTrClick = "") Set pMaxRows = -1  // ?
	Set tFilter = ""
	Set (tYear, tMonth) = ""
	// iFilter = NEXT^2022^12
	If (pWhere [ "iFilter") {
		Set tFilter = $Piece(pWhere," AND ",1,1)
		Set tFilter = $Piece(tFilter,"iFilter = ",2)
		Set tYear = $Piece(tFilter,"^",2)
		Set tMonth = $Piece(tFilter,"^",3)
		Do:tDebug ##class(Util).DebugTEST("tFilter = "_tFilter)
		Set pWhere = $Piece(pWhere," AND ",2,*)
	}
	If (tMonth = "") Set tYear = ""
	If (tYear = "") {
		Set tDate = $ZDATE($HOROLOG)
		Set tYear = $Piece(tDate,"/",3)
		Set tMonth = +$Piece(tDate,"/",1)  // Drop leading zero
	}
	If ($Extract(tFilter,1,4) = "NEXT") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),1)
			}
		}
	}
	If ($Extract(tFilter,1,4) = "PREV") {
		Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
		If (tMonth = "") {
			Set tYear = $Order(^COUNT(tYear),-1)
			If (tYear '= "") {
				Set tMonth = $Order(^COUNT(tYear,tMonth),-1)
			}
		}
	}
	If (tYear = "") {
		Do ..OutputTableNada()
	 	Set tReturn = "^"_tYear_"^"_tMonth
 		Quit tReturn
	}
	If (tMonth = "") {
		Do ..OutputTableNada()
	 	Set tReturn = "^"_tYear_"^"_tMonth
 		Quit tReturn
	}
 	Do ..OutputTableHead()
 	Set (tSumCount, tSumCredit, tSumDebit) = 0
 	Write !,"<tbody>"
	Set tCategory = ""
	Set node = $NAME(^SORT(tYear,tMonth))
	Kill @node
	//Set tRow = 0
	For {
		Set tCategory = $Order(^COUNT(tYear,tMonth,tCategory),1,tData)
		If (tCategory = "") { QUIT }
		Set tCount = $Piece(tData,"^",1)
		Set tCredit = $Piece(tData,"^",2)
		Set tDebit = $Piece(tData,"^",3)
		Set tReturn = "^"_tYear_"^"_tMonth_"^"_tCategory
		Set tClick = $Replace(pTrClick,"#",tReturn)
		If ..#OUT [ "W" Write !,"<tr onclick=""",tClick,""";>"
		Set tNickname = ..GetNickname("Riches.Category",tCategory)
		Set tSort = 0 - $ZABS(tCredit - tDebit)
		If ..#OUT [ "W" Write "<td>",tNickname,"</td><td>",tCount,"</td><td>",tDebit,"</td><td>",tCredit,"</td></tr>"
		If ..#OUT [ "X" Set @node@(tSort,tCategory,tNickname) = tData
		Set tSumCount = tSumCount + tCount
		Set tSumCredit = tSumCredit + tCredit
		Set tSumDebit = tSumDebit + tDebit
	}
	Set tSC = ..OutputTableNode(tYear,tMonth,pTrClick)
	Write !,"</tbody>"
	Set tDifference = tSumCredit - tSumDebit
	Do ..OutputTableFoot(1,tSumCount,tSumCredit,tSumDebit,tDifference)
 	Set tReturn = "^"_tYear_"^"_tMonth
 	Quit tReturn
}

ClassMethod OutputTableFoot(pColSpan As %String, pCount As %String, pCredit As %String, pDebit As %String, pDifference As %String) As %Status
{
	Set pColSpan = $Get(pColSpan)
	Set pCount = $Get(pCount)
	Set pCredit = $Get(pCredit)
	Set pDebit = $Get(pDebit)
	Set pDifference = $Get(pDifference)
	Set q = """"
	Set qColSpan = q_pColSpan_q
	Write !,"<tfoot>"
	Write !,"<tr><td colspan=",qColSpan,">Sum</td>"
	Do ##class(Util).OutputTableDataRight(pCount)
	Do ##class(Util).OutputTableDataRight(pDebit)
	Do ##class(Util).OutputTableDataRight(pCredit)
	Do ##class(Util).OutputTableDataRight(pDifference)
	Write !,"</tr>"
	Write !,"</tfoot>"
	Quit $$$OK
}

ClassMethod OutputTableFootAverage(param As %String, pData As %String) As %Status
{
	Set delim = $Extract(param)
	If (delim = "") Set delim = "^"
	Set tFromMM = $Piece(param,delim,2)
	Set tFromYY = $Piece(param,delim,3)
	Set tToMM = $Piece(param,delim,4)
	Set tToYY = $Piece(param,delim,5)
	Set pColSpan = $Get(pColSpan,1)
	Set q = """"
	Set qColSpan = q_pColSpan_q
	Write !,"<tfoot>"
	Write !,"<tr><td colspan=",qColSpan,">Sum</td>"
	Do ..OutputTdsPeriodAverage(param,"",pData)
	Write "</tr>"
	Write !,"</tfoot>"
	Quit $$$OK
}

ClassMethod OutputTableHead(pHead As %String = "") As %Status
{
	If (pHead = "") Set pHead = "Category^Count^Debit^Credit^Difference"
	Write !,"<thead>"
	Write !,"<tr>"
	For ii = 1:1:$Length(pHead,"^") {
		Write !,"<th>",$Piece(pHead,"^",ii),"</th>"
	}
	Write !,"</tr>"
	Write !,"</thead>"
	Quit $$$OK
}

ClassMethod OutputTableHeadAverage(param As %String = "") As %Status
{
	//Set tHead = ..GetHeader($Get(param))
	Set delim = $Extract(param)
	If (delim = "") Set delim = "^"
	Set tFromMM = $Piece(param,delim,2)
	Set tFromYY = $Piece(param,delim,3)
	Set tToMM = $Piece(param,delim,4)
	Set tToYY = $Piece(param,delim,5)
	Set delim = "^"
	Write !,"<thead>"
	Write !,"<tr>"
	Set tData = "Category"
	//Set tHead = "Category^1^2^3^4^5^6^7^8^9^10^11^12^Average"
	Set tHead = "Category"_delim
	Write !,"<th>",tData,"</th>"
	Set yy = tFromYY - 1
	For {
		Set yy = $Order(^COUNT(yy))
		If (yy = "") { Quit }
		If (yy > tToYY) { Quit }
		Set mm = $Select((yy = tFromYY):(tFromMM - 1),1:0)
		For {
			Set mm = $Order(^COUNT(yy,mm))
			If (mm = "") { Quit }
			If (yy = tToYY),(mm > tToMM) { Quit }
			Set tData = mm_"/"_yy
			Set tHead = tHead_tData_delim
			Set tFilter = delim_yy_delim_mm
			Set tClick = "javascript:goClickCount2('"_tFilter_"')"
			Write !,"<th onclick="_tClick_">",tData,"</th>"
		}
	}
	Set tData = "Average"
	Set tHead = tHead_"Average"
	Write !,"<th>",tData,"</th>"
	Write !,"</tr>"
	Write !,"</thead>"
	Quit $$$OK
}

ClassMethod OutputTableNada() As %Status
{
	Write !,"<tr><td>Nothing to show here</td></tr>"
	Quit $$$OK
}

ClassMethod OutputTableNode(pYear As %String = "", pMonth As %String = "", pTrClick As %String = "") As %String
{
	Set tYear = pYear
	Set tMonth = pMonth
	Set node = $NAME(^SORT(tYear,tMonth))
	Set tSort = ""
	For {
		Set tSort = $Order(@node@(tSort))
		If (tSort = "") { QUIT }
		Set tCategory = ""
		For {
			Set tCategory = $Order(@node@(tSort,tCategory))
			If (tCategory = "") { QUIT }
			Set tNickname = ""
			For {
				Set tNickname = $Order(@node@(tSort,tCategory,tNickname),1,tData)
				If (tNickname = "") { QUIT }
				Set tReturn = "^"_tYear_"^"_tMonth_"^"_tCategory
				Set tClick = $Replace(pTrClick,"#",tReturn)
				Set tSC = ..OutputTableRow(tClick,tNickname,tData)
			}
		}
	}
	Quit $$$OK
}

ClassMethod OutputTableNodeAverage(param As %String = "", pTrClick As %String = "") As %String
{
	Set delim = $Extract(param)
	If (delim = "") Set delim = "^"
	Set tFromMM = $Piece(param,delim,2)
	Set tFromYY = $Piece(param,delim,3)
	Set tToMM = $Piece(param,delim,4)
	Set tToYY = $Piece(param,delim,5)

	//Set tYear = pYear
	//Set tMonth = pMonth
	//Set node = $NAME(^SORT(tYear,tMonth))
	Set node = $NAME(^SORT)
	Set tSort = ""
	For {
		Set tSort = $Order(@node@(tSort))
		If (tSort = "") { QUIT }
		Set tCategory = ""
		For {
			Set tCategory = $Order(@node@(tSort,tCategory))
			If (tCategory = "") { QUIT }
			Set tNickname = ""
			For {
				Set tNickname = $Order(@node@(tSort,tCategory,tNickname),1,tData)
				If (tNickname = "") { QUIT }
				//Set tReturn = "^"_tYear_"^"_tMonth_"^"_tCategory
				//Set tClick = $Replace(pTrClick,"#","tReturn")
				Set tSC = ..OutputTableRowAverage(param,tCategory,tData)
			}
		}
	}
	Quit $$$OK
}

ClassMethod OutputTdsPeriodAverage(param As %String = "", pCategory As %String = "", pData As %String) As %Status
{
	Set delim = $Extract(param)
	If (delim = "") Set delim = "^"
	Set tFromMM = $Piece(param,delim,2)
	Set tFromYY = $Piece(param,delim,3)
	Set tToMM = $Piece(param,delim,4)
	Set tToYY = $Piece(param,delim,5)
	Set tCount = 0
	Set tData = ""
	Set yy = tFromYY - 1
	For {
		Set yy = $Order(^COUNT(yy))
		If (yy = "") { Quit }
		If (yy > tToYY) { Quit }
		Set mm = $Select((yy = tFromYY):(tFromMM - 1),1:0)
		For {
			Set mm = $Order(^COUNT(yy,mm))
			If (mm = "") { Quit }
			If (yy = tToYY),(mm > tToMM) { Quit }
			If (pCategory = "") Set tData = $Get(^COUNT(yy,mm))
			If (pCategory '= "") {
				Set tData = $Get(^COUNT(yy,mm,pCategory))
				Set tFilter = delim_yy_delim_mm_delim_pCategory
				Set tClick = "javascript:goClickCount1('"_tFilter_"')"
			}
			Set tCredit = $Piece(tData,"^",2)
			Set tDebit = $Piece(tData,"^",3)
			Set tDifference = tCredit - tDebit
			Set tDifferenceJ = $JUSTIFY(tDifference,0,2)
			
			Do ##class(Util).OutputTableDataRight(tDifferenceJ,$Get(tClick))
			Set tCount = tCount + 1
		}
	}
	If (tCount > 0) Set tAverage = $Get(pData) / tCount
	Set tAverageJ = $JUSTIFY($Get(tAverage),0,2)
	Do ##class(Util).OutputTableDataRight(tAverageJ)
	Quit $$$OK
}

ClassMethod OutputTableRow(pTrClick As %String, pCategory As %String, pData As %String) As %Status
{
	Set pTrClick = $Get(pTrClick)
	Set pCategory = $Get(pCategory)
	Set pData = $Get(pData)
	Set tCount = $Piece(pData,"^",1)
	Set tCredit = $Piece(pData,"^",2)
	Set tDebit = $Piece(pData,"^",3)
	Set tDifference = tCredit - tDebit
	Set tCreditJ = $JUSTIFY(tCredit,0,2)
	Set tDebitJ = $JUSTIFY(tDebit,0,2)
	Set tDifferenceJ = $JUSTIFY(tDifference,0,2)
	Write !,"<tr onclick=""",pTrClick,""";>"
	Write "<td>",pCategory,"</td>"
	Do ##class(Util).OutputTableDataRight(tCount)
	Do ##class(Util).OutputTableDataRight(tDebitJ)
	Do ##class(Util).OutputTableDataRight(tCreditJ)
	Do ##class(Util).OutputTableDataRight(tDifferenceJ)
	Write "</tr>"
	Quit $$$OK
}

ClassMethod OutputTableRowAverage(param As %String, pCategory As %String, pData As %String) As %Status
{
	Set delim = $Extract(param)
	If (delim = "") Set delim = "^"
	Set tFromMM = $Piece(param,delim,2)
	Set tFromYY = $Piece(param,delim,3)
	Set tToMM = $Piece(param,delim,4)
	Set tToYY = $Piece(param,delim,5)
	
	Set pTrClick = $Get(pTrClick)
	Set pCategory = $Get(pCategory)
	Set tNickname = ..GetNickname("Riches.Category",pCategory)

	Write !,"<tr onclick=""",pTrClick,""";>"
	Write "<td>",tNickname,"</td>"
	Do ..OutputTdsPeriodAverage(param,pCategory,pData)
	Write "</tr>"
	Quit $$$OK
}

ClassMethod Param2Return(param As %String = "") As %String
{
	Set delim = $Extract(param)
	Set dd = $Select((delim="^"):"|",1:"^")
	Set pReturn = dd_"A"_dd_param
	Quit pReturn
}

ClassMethod Return2Dates(pReturn As %String, Output pStartDate As %String, Output pEndDate As %String)
{
	Set pReturn = $Get(pReturn)
	Set tYear = $Piece(pReturn,"^",2)
	If (tYear = "") Set tYear = 1841
	Set tMonth = $Piece(pReturn,"^",3)
	If (tMonth = "") Set tMonth = 1
	Set tDay = 1
	Set pStartDate = tMonth_"/"_tDay_"/"_tYear
	Set tMonth = tMonth + 1
	If (tMonth > 12) {
		Set tMonth = 1
		Set tYear = tYear + 1
	}
	Set tDate = tMonth_"/"_tDay_"/"_tYear
	Set tDateH = $ZDATEH(tDate)
	Set pEndDate = $ZDATE(tDateH - 1)
	Return
}

}
