public with sharing class ERDEntityField {
	public String fieldName{get;set;}
	public String fieldType{get;set;}
	
	public ERDEntityField(String fName, String fType)
    {
    	this.fieldName = fName;
    	this.fieldType = fType;
    }
}