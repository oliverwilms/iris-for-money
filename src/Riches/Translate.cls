Class Riches.Translate
{

ClassMethod Setup() As %Status
{
	Set ^TRANSLATE("Account","Original") = "Translated"
	Set ^TRANSLATE("Category","Restaurant") = "Restaurants"
	Set ^TRANSLATE("Credit-Debit","Hhonors") = "Credit is Debit"
	Quit $$$OK
}

}
