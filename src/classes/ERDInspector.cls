/**
* ERD inspector to convert schema data into Graphviz content
*/
public with sharing class ERDInspector
{
	
	public void inspectERDSchema(Set<String> objectNameSet,
								Map<String, Map<String, List<String>>> erdMap,
								Map<String, List<ERDEntity>> groupToERDEntityListMap,
								List<ERDEntityRelationship> allObjectRelationshipList
								)
	{
		Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap = getObjectNameSObjectResultMap(objectNameSet);
		
		for(String grp : erdMap.keySet())
		{
			List<ERDEntity> erdEntityList = new List<ERDEntity>();
			Map<String, List<String>> objectToFieldsMap = erdMap.get(grp);
			for(String objectName : objectToFieldsMap.keySet())
			{
				Schema.DescribeSobjectResult objectResult = objectNameSObjectResultMap.get(objectName);
				List<String> objectFieldNames = objectToFieldsMap.get(objectName);
				
				// Add ERDEntity to Map
				ERDEntity entity = new ERDEntity();
				entity.objectName = objectName;
				entity.isCustom = objectResult.isCustom();
				entity.fieldNameList = objectFieldNames;
				erdEntityList.add(entity);
				
				// For all the child relationship of an object
				List<Schema.ChildRelationship> childRelationshipForObject = objectResult.getChildRelationships();
				for(Schema.ChildRelationship childRelationship : childRelationshipForObject)
				{
					// Get the child relationship object name
					Schema.Sobjecttype childObjectType = childRelationship.getChildSObject();
					Schema.DescribeSObjectResult childObjectResult = childObjectType.getDescribe();
					String childName = childObjectResult.getName();
					
					// Ensure the child object is in the objectNameSet, meaning it is specified by user in the UI
					// Ensure the relationship has not been added
					if(objectNameSet.contains(childName) && !ERDUtils.isEnitityRelationshipExists(objectName,childName,allObjectRelationshipList))
					{
						// Add ERDEntityRelationship to List of relationsihp for an object
						ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
						entityRelationship.parentObjectName = objectName;
						entityRelationship.childObjectName = childName;
						allObjectRelationshipList.add(entityRelationship);
					}
				}
			}
			groupToERDEntityListMap.put(grp,erdEntityList);
			
		}
		
	}
	
	
	private Map<String,Schema.DescribeSobjectResult> getObjectNameSObjectResultMap(Set<String> objectNameSet)
	{
		Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap = new Map<String,Schema.DescribeSobjectResult>();
		List<Schema.DescribeSobjectResult> allObjectResults = Schema.describeSObjects(new List<String>(objectNameSet));
		
		for(String objectName : objectNameSet)
		{
			for(Schema.DescribeSobjectResult objectResult : allObjectResults)
			{
				if(objectResult.getName() == objectName)
				{
					objectNameSObjectResultMap.put(objectName, objectResult);
					break;
				}
			}
		}
		
		return objectNameSObjectResultMap;
	}
}