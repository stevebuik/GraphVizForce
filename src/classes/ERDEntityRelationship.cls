/*
Name: ERDEntityRelationship
Purpose: 
This class is the data model for ERD relationship
*/
public with sharing class ERDEntityRelationship
{
	public String lookupFieldName {get;set;}
	public String parentObjectName {get;set;}
	public String childObjectName {get;set;}
	public Boolean isCascadeDelete {get;set;}	// Reflects Master Detail Relationship
}