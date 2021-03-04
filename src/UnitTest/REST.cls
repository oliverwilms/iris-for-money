Class UnitTest.REST Extends %UnitTest.TestCase
{

ClassMethod Setup() As %Status
{
	Set ^UnitTestRoot = "/opt/irisapp/src"
	ZW ^UnitTestRoot
	Quit $$$OK
}

Method TestSQL()
{
	Set tQuery = "Select COUNT (*) FROM Riches.Category WHERE Nickname = 'Wages'"
	Set tCountBefore = ##class(Riches.Util).ExecuteQueryOneValue(tQuery)
	Do $$$AssertEquals(tCountBefore, 0)
}

}
