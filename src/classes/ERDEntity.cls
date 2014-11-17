/*
Name: ERDEntity
Purpose: 
This class is the data model for ERD
*/
public with sharing class ERDEntity
{
	public String objectName {get;set;}
	public Boolean isCustom {get;set;}
	public List<ERDEntityField> fieldList {get;set;}
}