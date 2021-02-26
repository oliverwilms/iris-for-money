Class Riches.RequestData Extends %Persistent
{

Property RequestDate As %Date;

Property RequestTime As %Time;

Property Page As %String;

Property Name As %String;

Property Index As %Integer;

Property Order As %Integer;

Property Value As %String;

Property Status As %Status;

ClassMethod LogRequest(ByRef pRequestData, pPage As %String = "") As %Status
{
	Do ##class(Util).DebugTEST("Riches.RequestData - LogRequest")
	Do ##class(Util).DebugMerge("pRequestData = ",.pRequestData)
	Set objRequestData = ..%New()
	Set objRequestData.RequestDate = $Piece($Horolog,",",1)
	Set objRequestData.RequestTime = $Piece($Horolog,",",2)
	Set objRequestData.Page = pPage
	Set tSC = objRequestData.%Save()
	If $$$ISERR(tSC) Quit tSC
	Set tId = objRequestData.%Id()
	Merge ^Riches.RequestDataD(tId) = pRequestData
	Set tName = $Order(pRequestData(""))
	If (tName = "") {
		Set objRequestData.Status = tSC
		Set tSC2 = objRequestData.%Save()
		Do ##class(Riches.Util).DebugStatus(tSC2)
		Set objRequestData = ""
		Quit $$$OK
	}
	Set tCompare = tId
	For {
		Set tCompare = tCompare - 1
		If (tCompare < 1) Quit
		Set objOther = ..%OpenId(tCompare)
		Set tOther = objOther.Page
		If (pPage '= tOther) { Set tDiff = 1 Continue }
		Set tDiff = 0
		Set tName = ""
		For {
			Set tName = $Order(pRequestData(tName))
			If (tName = "") Quit
			Set tIndex = ""
			For {
				Set tIndex = $Order(pRequestData(tName,tIndex))
				If (tIndex = "") Quit
				Set tValue = $Get(pRequestData(tName,tIndex))
				Set tOther = $Get(^Riches.RequestDataD(tCompare,tName,tIndex))
				If (tValue '= tOther) { Set tDiff = 1 Quit }
			}
			If tDiff Quit
		}
		Set objOther = ""
		If (tDiff = 0) {
			Set tSC = $$$ERROR($$$GeneralError,"Duplicate Request")
			Quit
		}
	}
	Set objRequestData.Status = tSC
	Set tSC2 = objRequestData.%Save()
	Do ##class(Riches.Util).DebugStatus(tSC2)
	Set objRequestData = ""
	Quit tSC
}

Storage Default
{
<Data name="RequestDataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>RequestDate</Value>
</Value>
<Value name="3">
<Value>RequestTime</Value>
</Value>
<Value name="4">
<Value>Page</Value>
</Value>
<Value name="5">
<Value>Name</Value>
</Value>
<Value name="6">
<Value>Index</Value>
</Value>
<Value name="7">
<Value>Order</Value>
</Value>
<Value name="8">
<Value>Value</Value>
</Value>
<Value name="9">
<Value>Status</Value>
</Value>
</Data>
<DataLocation>^Riches.RequestDataD</DataLocation>
<DefaultData>RequestDataDefaultData</DefaultData>
<IdLocation>^Riches.RequestDataD</IdLocation>
<IndexLocation>^Riches.RequestDataI</IndexLocation>
<StreamLocation>^Riches.RequestDataS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
