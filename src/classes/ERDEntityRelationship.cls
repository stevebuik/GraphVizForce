/*
Name: ERDEntityRelationship
Purpose: 
This class is the data model for ERD relationship

Version		Author			Date		Details				Feature
1.0			Jason Guan		13/06/2014	Initial Creation	
*/
public with sharing class ERDEntityRelationship
{
	public String parentObjectName {get;set;}
	public String childObjectName {get;set;}
}