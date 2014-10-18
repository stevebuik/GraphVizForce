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
							Map<String, List<ERDEntityRelationship>> objectChildRelationshipMap,
							List<ERDEntityRelationship> allObjectRelationshipList)
	{
		
		System.debug(LoggingLevel.ERROR,'====> setupERDMaps is called');
		Set<String> objectNameSet = new Set<String>(objectNameList);
		
		for(String objectName : objectNameList)
		{
			Schema.DescribeSobjectResult objectResult = objectNameSObjectResultMap.get(objectName);
			
			// Add ERDEntity to Map
			ERDEntity entity = new ERDEntity();
			entity.objectName = objectName;
			entity.isCustom = objectResult.isCustom();
			objectERDEntityMap.put(objectName,entity);
			
			List<Schema.ChildRelationship> childRelationshipForObject = objectResult.getChildRelationships();
			List<ERDEntityRelationship> entityRleationshipListForObject = new List<ERDEntityRelationship>();
			
			System.debug(LoggingLevel.ERROR,'====> childRelationshipForObject:' + childRelationshipForObject);
			
			// For all the child relationship of an object
			for(Schema.ChildRelationship childRelationship : childRelationshipForObject)
			{
				// Get the child relationship object name
				Schema.Sobjecttype childObjectType = childRelationship.getChildSObject();
				Schema.DescribeSObjectResult childObjectResult = childObjectType.getDescribe();
				String childName = childObjectResult.getName();
				
				System.debug(LoggingLevel.ERROR,'====> childName:' + childName);
				System.debug(LoggingLevel.ERROR,'====> objectNameSet.contains(childName):' + objectNameSet.contains(childName));
				
				// Ensure the child object is in the groupObjectMap, which is specified by user in the UI
				//if(ERDUtils.isValidObjectName(childName,objectNameList))
				if(objectNameSet.contains(childName))
				{
					System.debug(LoggingLevel.ERROR, '====> childName is selected by user');
					// Add ERDEntityRelationship to List of relationsihp for an object
					ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
					entityRelationship.parentObjectName = objectName;
					entityRelationship.childObjectName = childName;
					entityRleationshipListForObject.add(entityRelationship);
				}
			}
			
			System.debug(LoggingLevel.ERROR, '====> entityRleationshipListForObject:' + entityRleationshipListForObject);
			
			// Add List of relationship for an object to the full List
			allObjectRelationshipList.addAll(entityRleationshipListForObject);
			// Add List of relationship for an object to the Map
			objectChildRelationshipMap.put(objectName, entityRleationshipListForObject);
			
		}
	}
	
	public String interpretSubgraphContent(TemplateEngine templateEngine,
											Map<String,List<String>> groupObjectMap,
											Map<String, ERDEntity> objectERDEntityMap, 
											Map<String, List<ERDEntityRelationship>> objectChildRelationshipMap
											)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		
		Set<String> groupNameSet = groupObjectMap.keySet();
		
		// For each group of objects specified by user in UI
		for(String groupName : groupNameSet){
			// Prepare List of entities, List of relationships
			List<ERDEntity> entities = new List<ERDEntity>();
			List<ERDEntityRelationship> entityRelationships = new List<ERDEntityRelationship>();
			List<String> objNamesInGroup = groupObjectMap.get(groupName);
			
			for(String objName : objNamesInGroup){
				
				System.debug(LoggingLevel.ERROR, '====> objName:' + objName);
				entities.add(objectERDEntityMap.get(objName));
				entityRelationships.addAll(objectChildRelationshipMap.get(objName));
				System.debug(LoggingLevel.ERROR, '====> entityRelationships:' + entityRelationships);
			}
			
			// Generate the subgraph section with group index, groupname, object names for the group, entity List and relationship List
			String groupSubGraph = generateSubgraph(templateEngine, subgraphIndex,groupName,entities,entityRelationships);
			subgraphsContent += groupSubGraph;
			subgraphIndex++;
		}
		
		return subgraphsContent;
	}
	
	public String interpretCrossGroupRelationshipContent(TemplateEngine templateEngine, List<ERDEntityRelationship> allObjectRelationshipList)
	{
		String crossGroupRelationshipContent = '';
		
		if(!allObjectRelationshipList.isEmpty())
		{
            for(ERDEntityRelationship crossRelationship : allObjectRelationshipList){
				crossGroupRelationshipContent += templateEngine.render(TemplateType.RELATIONSHIP,
									new Map<String, String>{
										'from' => crossRelationship.parentObjectName,
										'to' => crossRelationship.childObjectName
									});                    
            }
        }
        
        return crossGroupRelationshipContent;
	}
	
	public String renderERDGraphvizContent(TemplateEngine templateEngine, String subgraphContent, String crossGroupRelationshipContent)
	{
		// Render ERD graphviz content using template engine
		return templateEngine.render(TemplateType.MAIN,
					new Map<String, String>{
						'content' => subgraphContent + crossGroupRelationshipContent
					});
	}
	
	
	private String generateSubgraph(
		TemplateEngine templateEngine,
		Integer subgraphIndex, 
		String groupName, 
		List<ERDEntity> entities, 
		List<ERDEntityRelationship> entityRelationships){

		String entityOutput = '';
		String entityRelationshipOutput = '';
		
		for(ERDEntity entity : entities){
			entityOutput += templateEngine.render(TemplateType.ENTITY,
				new Map<String, String>{
					'name' => entity.objectName
				});
		}
		
		System.debug(LoggingLevel.ERROR, '====> entityRelationshipOutput before:' + entityRelationshipOutput);
		
		for(ERDEntityRelationship relation : entityRelationships){
			System.debug(LoggingLevel.ERROR, '====> relation:' + relation);
			
			String relationshipContent = templateEngine.render(TemplateType.RELATIONSHIP,
				new Map<String, String>{
					'from' => relation.parentObjectName,
					'to' => relation.childObjectName
				});
			
			System.debug(LoggingLevel.ERROR, '====> relationshipContent:' + relationshipContent);
			
			entityRelationshipOutput += relationshipContent;
		}
		
		
		System.debug(LoggingLevel.ERROR, '====> entityRelationshipOutput after:' + entityRelationshipOutput);
		
		return templateEngine.render(TemplateType.CLUSTER,
					new Map<String, String>{
						'sequence' => ''+subgraphIndex,
						'name' => groupName,
						'content' => entityOutput + entityRelationshipOutput
					});
		
	}
}