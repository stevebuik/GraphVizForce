/**
Name: ERDUtils
Purpose: 
This class is to provide utility functionalities for the ERD Generator
*/
public with sharing class ERDUtils
{
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
	
	public static Boolean isStandardUserLookupRelationship(ERDEntityRelationship relationship)
	{
		//System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@relationship:' + relationship);
		return (relationship.parentObjectName != null && relationship.parentObjectName == 'User' && 
				(relationship.lookupFieldName != null && (relationship.lookupFieldName == 'OwnerId' || relationship.lookupFieldName == 'CreatedById' || relationship.lookupFieldName == 'LastModifiedById')));
	}
	
	public static List<String> getAllObjectNames()
	{
		List<String> objectNames = new List<String>();
		
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		
		for(Schema.SObjectType sObjectType : globalDescribe.values())
		{
			Schema.DescribeSObjectResult sObjectResult = sObjectType.getDescribe();
			objectNames.add(sObjectResult.getName());
		}
		
		objectNames.sort();
		return objectNames;
	}
	
	public static List<ERDEntityGroup> getERDEntityGroups(Set<String> groups, Set<String> includedGroups)
	{
    	List<ERDEntityGroup> erdGroups = new List<ERDEntityGroup>();
    	
    	List<String> sortedGroups = new List<String>(groups);
    	sortedGroups.sort();
    	
    	for(String g : sortedGroups)
    	{
    		ERDEntityGroup grp = new ERDEntityGroup(g,includedGroups.contains(g));
    		erdGroups.add(grp);
    	}
    	return erdGroups;
	}
}