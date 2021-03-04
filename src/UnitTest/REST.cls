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
	Do $$$AssertEquals(##class(Production.Math).Square(2), 4)
}

}
