Class Riches.SubCategory Extends %Persistent
{

Property Category As Category;

Property Nickname As %String;

Property SortOrder As %String;

Storage Default
{
<Data name="SubCategoryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Category</Value>
</Value>
<Value name="3">
<Value>Nickname</Value>
</Value>
<Value name="4">
<Value>SortOrder</Value>
</Value>
</Data>
<DataLocation>^Riches.SubCategoryD</DataLocation>
<DefaultData>SubCategoryDefaultData</DefaultData>
<IdLocation>^Riches.SubCategoryD</IdLocation>
<IndexLocation>^Riches.SubCategoryI</IndexLocation>
<StreamLocation>^Riches.SubCategoryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
