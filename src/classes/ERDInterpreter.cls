/**
* ERD interpreter to convert schema data into Graphviz content
*/
public with sharing class ERDInterpreter
{
	public List<String> getObjectNameList(Map<String,List<String>> groupObjectMap)
	{
		List<String> objectNameList = new List<String>();
		
		if(groupObjectMap != null)
		for(List<String> namesList : groupObjectMap.values())
		{
			objectNameList.addAll(namesList);
		}
		
		return objectNameList;
	}
	
	public Map<String,Schema.DescribeSobjectResult> getObjectNameSObjectResultMap(List<String> objectNameList)
	{
		Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap = new Map<String,Schema.DescribeSobjectResult>();
		List<Schema.DescribeSobjectResult> allObjectResults = Schema.describeSObjects(objectNameList);
		
		for(String objectName : objectNameList)
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
	
	public void setupERDMaps(List<String> objectNameList,
							Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap, 
							Map<String, ERDEntity> objectERDEntityMap, 
							//Map<String, List<ERDEntityRelationship>> objectChildRelationshipMap,
							List<ERDEntityRelationship> allObjectRelationshipList)
	{
		
		Set<String> objectNameSet = new Set<String>(objectNameList);
		
		for(String objectName : objectNameList)
		{
			Schema.DescribeSobjectResult objectResult = objectNameSObjectResultMap.get(objectName);
			List<String> objectFieldNames = getFieldNamesForObject(objectResult);
			
			// Add ERDEntity to Map
			ERDEntity entity = new ERDEntity();
			entity.objectName = objectName;
			entity.isCustom = objectResult.isCustom();
			entity.fieldNameList = objectFieldNames;
			objectERDEntityMap.put(objectName,entity);
			
			List<Schema.ChildRelationship> childRelationshipForObject = objectResult.getChildRelationships();
			List<ERDEntityRelationship> entityRleationshipListForObject = new List<ERDEntityRelationship>();
			
			
			// For all the child relationship of an object
			for(Schema.ChildRelationship childRelationship : childRelationshipForObject)
			{
				// Get the child relationship object name
				Schema.Sobjecttype childObjectType = childRelationship.getChildSObject();
				Schema.DescribeSObjectResult childObjectResult = childObjectType.getDescribe();
				String childName = childObjectResult.getName();
				
				// Ensure the child object is in the groupObjectMap, which is specified by user in the UI
				//if(ERDUtils.isValidObjectName(childName,objectNameList))
				if(objectNameSet.contains(childName) && !ERDUtils.isEnitityRelationshipExists(objectName,childName,allObjectRelationshipList))
				{
					// Add ERDEntityRelationship to List of relationsihp for an object
					ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
					entityRelationship.parentObjectName = objectName;
					entityRelationship.childObjectName = childName;
					allObjectRelationshipList.add(entityRelationship);
				}
			}
			
			
			// Add List of relationship for an object to the full List
			//allObjectRelationshipList.addAll(entityRleationshipListForObject);
			// Add List of relationship for an object to the Map
			//objectChildRelationshipMap.put(objectName, entityRleationshipListForObject);
			
		}
	}
	
	private List<String> getFieldNamesForObject(Schema.DescribeSobjectResult objectResult)
	{
		List<String> fieldNames = new List<String>();
		Map<String, Schema.SObjectField> objectFieldMap = objectResult.fields.getMap();
		List<Schema.SObjectField> fieldValues = objectFieldMap.values();
		
		for(Schema.SObjectField field : fieldValues)
		{
			Schema.DescribeFieldResult fieldResult = field.getDescribe();
			fieldNames.add(fieldResult.getName());
		}
		
		return fieldNames;
	}
	
}