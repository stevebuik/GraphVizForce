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
				
				// Get list of ERDEntityField
				List<String> includedFieldNames = objectToFieldsMap.get(objectName);
				includedFieldNames.sort();
				List<ERDEntityField> erdFields = getIncludedERDEntityFieldListByObjectName(objectName,includedFieldNames);
				
				// Add ERDEntity to Map
				ERDEntity entity = new ERDEntity();
				entity.objectName = objectName;
				entity.isCustom = objectResult.isCustom();
				entity.fieldList = erdFields;
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
						/*
						System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@childRelationship:' + childRelationship.getChildSObject());
						System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@childRelationship:' + childRelationship.getField());
						System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@childRelationship:' + childRelationship.getRelationshipName());
						System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@childRelationship:' + childRelationship.isCascadeDelete());
						System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@childRelationship:' + childRelationship.isDeprecatedAndHidden());
						System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@childRelationship:' + childRelationship.isRestrictedDelete());
						*/
						
						// Add ERDEntityRelationship to List of relationsihp for an object
						ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
						entityRelationship.lookupFieldName = childRelationship.getField().getDescribe().getName();
						entityRelationship.parentObjectName = objectName;
						entityRelationship.childObjectName = childName;
						entityRelationship.isCascadeDelete = childRelationship.isCascadeDelete();
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
	
	public List<String> getFieldNamesByObjectName(String objectName)
	{
		List<String> fieldNames = new List<String>();
		List<Schema.DescribeSobjectResult> objectResults = Schema.describeSObjects(new List<String>{objectName});
		if(!objectResults.isEmpty())
		{
			Map<String, Schema.SObjectField> objectFieldMap = objectResults[0].fields.getMap();
			List<Schema.SObjectField> fieldValues = objectFieldMap.values();
			
			for(Schema.SObjectField field : fieldValues)
			{
				Schema.DescribeFieldResult fieldResult = field.getDescribe();
				fieldNames.add(fieldResult.getName());
			}
		}
		fieldNames.sort();
		return fieldNames;
	}
	
	public List<String> getAvailableObjectsForGroup(String selectedGroup,
													List<String> allObjectNames,
													Map<String, Map<String, List<String>>> erdMap)
	{
		Set<String> availableObjects = new Set<String>(allObjectNames);
		
		for(String grp : erdMap.keySet())
		{
			if(grp != selectedGroup)
			{
				for(String obj : erdMap.get(grp).keySet())
				{
					if(availableObjects.contains(obj))
					{
						availableObjects.remove(obj);
					}
				}
			}
		}
		
		List<String> sorted = new List<String>(availableObjects);
		sorted.sort();
		return sorted;
	}
	
	/****************Local Functions*****************/
	private List<ERDEntityField> getIncludedERDEntityFieldListByObjectName(String objectName, List<String> includedFieldNames)
	{
		List<ERDEntityField> erdFields = new List<ERDEntityField>();
		//Set<String> includedFieldNameSet = new Set<String>(includedFieldNames);
		Map<String,String> fieldNameToFieldTypeMap = new Map<String,String>();
		List<Schema.DescribeSobjectResult> objectResults = Schema.describeSObjects(new List<String>{objectName});
		
		if(!objectResults.isEmpty())
		{
			// collect field schema
			Map<String, Schema.SObjectField> objectFieldMap = objectResults[0].fields.getMap();
			List<Schema.SObjectField> fieldValues = objectFieldMap.values();
			
			// Setup field name to field type map
			for(Schema.SObjectField field : fieldValues)
			{
				Schema.DescribeFieldResult fieldResult = field.getDescribe();
				String fieldName = fieldResult.getName();
				Schema.DisplayType displayType= fieldResult.getType();
				String fieldType = ERDDisplayType.getDisplayTypeLabel(displayType);
				fieldNameToFieldTypeMap.put(fieldName,fieldType);
			}
			
			for(String includedFieldName : includedFieldNames)
			{
				ERDEntityField erdField = new ERDEntityField(includedFieldName,fieldNameToFieldTypeMap.get(includedFieldName));
				erdFields.add(erdField);
			}
		}
		
		return erdFields;
	}
}