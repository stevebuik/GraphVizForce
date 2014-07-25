/*
Name: ERDUtils
Purpose: 
This class is to provide utility functionalities for the ERD Generator

Version		Author			Date		Details				Feature
1.0			Jason Guan		14/06/2014	Initial Creation	
*/
public with sharing class ERDUtils
{
	public static Boolean isValidObjectName(String objName, List<String> objNames)
	{
		if(objNames != null)
		{
			for(String objNameToMatch : objNames)
			{
				if(objName == objNameToMatch)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	public static Boolean isEnitityExists(String objectName, List<ERDEntity> entities)
	{
		if(entities != null)
		{
			for(ERDEntity entity : entities)
			{
				if(entity.objectName == objectName)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	public static Boolean isEnitityRelationshipExists(String parentObjectName, String childObjectName, List<ERDEntityRelationship> relationships)
	{
		if(relationships != null)
		{
			for(ERDEntityRelationship relationship : relationships)
			{
				if(relationship.parentObjectName == parentObjectName && relationship.childObjectName == childObjectName)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	public static List<Schema.SObjectType> getObjectTypesByChildRelationships(List<Schema.Childrelationship> childRelationships)
	{
		List<Schema.Sobjecttype> objectTypes = new List<Schema.Sobjecttype>();
		for(Schema.Childrelationship childRelationship : childRelationships)
		{
			Schema.Sobjecttype objectType = childRelationship.getChildSObject();
			objectTypes.add(objectType);
		}
		return objectTypes;
	}
	
	public static List<Schema.DescribeSObjectResult> getObjectResultsByObjectTypes(List<Schema.SObjectType> objectTypes, List<String> objectNames)
	{
		List<Schema.DescribeSObjectResult> objectResults = new List<Schema.DescribeSObjectResult>();
		for(Schema.SObjectType objectType : objectTypes)
		{
			Schema.DescribeSObjectResult objectResult = objectType.getDescribe();
			
			if(ListUtils.getStringItemIndex(objectResult.getName(), objectNames) != -1)
			{
				objectResults.add(objectResult);
			}
		}
		return objectResults;
	}
	
	public static List<Schema.DescribeSObjectResult> getCustomObjectResultsByObjectTypes(List<Schema.SObjectType> objectTypes)
	{
		List<Schema.DescribeSObjectResult> objectResults = new List<Schema.DescribeSObjectResult>();
		for(Schema.SObjectType objectType : objectTypes)
		{
			Schema.DescribeSObjectResult objectResult = objectType.getDescribe();
			
			if(objectResult.isCustom())
			{
				objectResults.add(objectResult);
			}
		}
		return objectResults;
	}
	
	
	
}