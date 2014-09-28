/*
Name: ERDGenerator
Purpose: generate an ERD that Graphviz can understand
*/

public with sharing class ERDGenerator
{
	private Integer describeChildCount = 0;

	//private TemplateEngine.StaticResourceTemplateSource templateSource = new TemplateEngine.StaticResourceTemplateSource('DefaultTemplate');
	private TemplateEngine.CalloutTemplateSource templateSource = new TemplateEngine.CalloutTemplateSource('https://dl.dropboxusercontent.com/u/1270824/erd-templates/default.txt');
	
	private TemplateEngine templateEngine = new TemplateEngine(templateSource);
	
	
	/*
	public String generateERD(Map<String,List<String>> standardGroupingMap, Map<String,List<String>> customGroupingMap)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		List<ERDEntityRelationship> allRelationships = new List<ERDEntityRelationship>();
		
		if(standardGroupingMap != null)
		{
			for(String standardGroup : standardGroupingMap.keySet())
			{
				List<String> standardObjectNames = standardGroupingMap.get(standardGroup);
				String standardSubgraph = generateSubgraph(subgraphIndex,standardGroup,standardObjectNames,allRelationships);
				subgraphsContent += standardSubgraph;
				subgraphIndex++;
			}
		}
		
		if(customGroupingMap != null)
		{
			for(String customGroup : customGroupingMap.keySet())
			{
				List<String> customObjectNames = customGroupingMap.get(customGroup);
				String customSubgraph = generateSubgraph(subgraphIndex,customGroup,customObjectNames,allRelationships);
				subgraphsContent += customSubgraph;
				subgraphIndex++;
			}
		}
        
		String crossRelationshipContent = '';
		if(!allRelationships.isEmpty())
            {
                for(ERDEntityRelationship crossRelationship : allRelationships)
                {
					crossRelationshipContent += templateEngine.render(TemplateType.RELATIONSHIP,
										new Map<String, String>{
											'from' => crossRelationship.parentObjectName,
											'to' => crossRelationship.childObjectName
										});                    
                }
            }
		
		return templateEngine.render(TemplateType.MAIN,
					new Map<String, String>{
						'content' => subgraphsContent + crossRelationshipContent
					});
	}
	*/
	
	public String generateERD(Map<String,List<String>> groupObjectMap)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		String crossRelationshipContent = '';
		
		list<String> allObjectNames = new list<String>();
		map<String, ERDEntity> objectERDEntityMap = new map<String, ERDEntity>();
		map<String, list<ERDEntityRelationship>> objectChildrenRelationshipMap = new map<String, list<ERDEntityRelationship>>();
		list<ERDEntityRelationship> allObjectChildrenRelationships = new list<ERDEntityRelationship>();
		list<Schema.DescribeSobjectResult> allObjectResults;
		
		if(groupObjectMap != null)
		{
			// Get all object results for the group map
			for(list<String> namesList : groupObjectMap.values())
			{
				allObjectNames.addAll(namesList);
			}
			allObjectResults = Schema.describeSObjects(allObjectNames);
			
			for(String objectName : allObjectNames)
			{
				for(Schema.DescribeSobjectResult objectResult : allObjectResults)
				{
					// For each object
					if(objectResult.getName() == objectName)
					{
						// Add ERDEntity to map
						ERDEntity entity = new ERDEntity();
						entity.objectName = objectName;
						entity.isCustom = objectResult.isCustom();
						objectERDEntityMap.put(objectName,entity);
						
						
						// For all the child relationship of an object
						list<Schema.ChildRelationship> childRelationshipForObject = objectResult.getChildRelationships();
						list<ERDEntityRelationship> entityRleationshipListForObject = new list<ERDEntityRelationship>();
						
						for(Schema.ChildRelationship childRelationship : childRelationshipForObject)
						{
							// Get the child relationship object name
							Schema.Sobjecttype childObjectType = childRelationship.getChildSObject();
							Schema.DescribeSObjectResult childObjectResult = childObjectType.getDescribe();
							String childName = childObjectResult.getName();
							
							// Ensure the child object is in the groupObjectMap, which is specified by user in the UI
							if(ERDUtils.isValidObjectName(childName,allObjectNames))
							{
								// Add ERDEntityRelationship to list of relationsihp for an object
								ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
								entityRelationship.parentObjectName = objectName;
								entityRelationship.childObjectName = childName;
								entityRleationshipListForObject.add(entityRelationship);
							}
						}
						
						// Add list of relationship for an object to the full list
						allObjectChildrenRelationships.addAll(entityRleationshipListForObject);
						// Add list of relationship for an object to the map
						objectChildrenRelationshipMap.put(objectName, entityRleationshipListForObject);
						
						break;
					}
				}
			}
			
			// For each group of objects specified by user in UI
			for(String groupName : groupObjectMap.keySet())
			{
				// Prepare list of entities, list of relationships
				list<ERDEntity> entities = new list<ERDEntity>();
				list<ERDEntityRelationship> entityRelationships = new list<ERDEntityRelationship>();
				list<String> objNames = groupObjectMap.get(groupName);
				
				for(String objName : objNames)
				{
					entities.add(objectERDEntityMap.get(objName));
					entityRelationships.addAll(objectChildrenRelationshipMap.get(objName));
				}
				
				// Generate the subgraph section with group index, groupname, object names for the group, entity list and relationship list
				String groupSubGraph = generateSubgraph(subgraphIndex,groupName,allObjectNames,entities,entityRelationships);
				subgraphsContent += groupSubGraph;
				subgraphIndex++;
			}
			
			// Append cross-group relationship outside of sub graph blocks
			if(!allObjectChildrenRelationships.isEmpty())
	        {
	            for(ERDEntityRelationship crossRelationship : allObjectChildrenRelationships)
	            {
					crossRelationshipContent += templateEngine.render(TemplateType.RELATIONSHIP,
										new Map<String, String>{
											'from' => crossRelationship.parentObjectName,
											'to' => crossRelationship.childObjectName
										});                    
	            }
	        }
		}
        
        // Render ERD graphviz content using template engine
		return templateEngine.render(TemplateType.MAIN,
					new Map<String, String>{
						'content' => subgraphsContent + crossRelationshipContent
					});
	}
	
	
	/*
	public List<Schema.SObjectType> getAllObjectTypes()
	{
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		List<Schema.SObjectType> objectTypes = new List<Schema.SObjectType>(globalDescribe.values());
		return objectTypes;
	}
	*/
	
	private String generateSubgraph(Integer subgraphIndex, String groupName, list<String> allObjectNames, list<ERDEntity> entities, list<ERDEntityRelationship> entityRelationships)
	{
		String entityOutput = '';
		String entityRelationshipOutput = '';
		
		for(ERDEntity entity : entities)
		{
			//if(ERDUtils.isValidObjectName(entity.objectName, allObjectNames))
			//{
				entityOutput += templateEngine.render(TemplateType.ENTITY,
					new Map<String, String>{
						'name' => entity.objectName
					});
			//}
		}
		
		for(ERDEntityRelationship relation : entityRelationships)
		{
			//if(ERDUtils.isValidObjectName(relation.parentObjectName, allObjectNames) 
				//&& ERDUtils.isValidObjectName(relation.childObjectName, allObjectNames))
			//{
				entityRelationshipOutput += templateEngine.render(TemplateType.RELATIONSHIP,
					new Map<String, String>{
						'from' => relation.parentObjectName,
						'to' => relation.childObjectName
					});
			//}
		}
		
		return templateEngine.render(TemplateType.CLUSTER,
					new Map<String, String>{
						'sequence' => ''+subgraphIndex,
						'name' => groupName,
						'content' => entityOutput + entityRelationshipOutput
					});
		
	}
	
	/* THIS VERSION IS DEPRECATED */
	/*
	private String generateSubgraph(
		Integer subgraphIndex, 
		String groupName, 
		List<String> objectNames, 
		List<ERDEntityRelationship> allRelationships) {

		List<ERDEntity> entities = new List<ERDEntity>();
		List<ERDEntityRelationship> entityRelationships = new List<ERDEntityRelationship>();
		
		List<String> objectNamesList = new List<String>(objectNames);
		List<Schema.DescribeSobjectResult> objectResults = Schema.describeSObjects(objectNamesList);
		collectSchemaInfo(objectResults,entities,entityRelationships,allRelationships,objectNamesList);
		
		String entityOutput = '';
		
		for(ERDEntity entity : entities) {
			if(ERDUtils.isValidObjectName(entity.objectName, objectNamesList))
			{
				entityOutput += templateEngine.render(TemplateType.ENTITY,
					new Map<String, String>{
						'name' => entity.objectName
					});
			}
		}
		
		String entityRelationshipOutput = '';
		for(ERDEntityRelationship relation : entityRelationships) {
			if(ERDUtils.isValidObjectName(relation.parentObjectName, objectNamesList) 
				&& ERDUtils.isValidObjectName(relation.childObjectName, objectNamesList))
			{
				entityRelationshipOutput += templateEngine.render(TemplateType.RELATIONSHIP,
					new Map<String, String>{
						'from' => relation.parentObjectName,
						'to' => relation.childObjectName
					});
			}
		}
				
		return templateEngine.render(TemplateType.CLUSTER,
					new Map<String, String>{
						'sequence' => ''+subgraphIndex,
						'name' => groupName,
						'content' => entityOutput + entityRelationshipOutput
					});
	}
	
	
	private void collectSchemaInfo(
		List<Schema.DescribeSObjectResult> objectResults, 
		List<ERDEntity> entities, 
		List<ERDEntityRelationship> entityRelationships, 
		List<ERDEntityRelationship> allRelationships, 
		List<String> objectNames) {
		for(Schema.DescribeSObjectResult objectResult : objectResults) {
			String objectName = objectResult.getName();
			Boolean objectIsCustom = objectResult.isCustom();
		
			// Create ERDEntity Object
			if(!ERDUtils.isEnitityExists(objectName, entities)) {
				ERDEntity entity = new ERDEntity();
				entity.objectName = objectName;
				entity.isCustom = objectIsCustom;
				entities.add(entity);
			}
			
			// Create ERDEntityRelationship and Recursively go through children objects
			// Describe childrelationships
			//if(describeChildCount < 200)
			//{
				describeChildCount++;
				List<Schema.ChildRelationship> childRelationships = objectResult.getChildRelationships();
				//List<Schema.Sobjecttype> childObjectTypes = ERDUtils.getObjectTypesByChildRelationships(childRelationships);
				//List<Schema.DescribeSObjectResult> childObjectResults = ERDUtils.getObjectResultsByObjectTypes(childObjectTypes, objectNames);
				List<Schema.DescribeSObjectResult> childObjectResults = ERDUtils.getObjectResultsByChildRelationships(childRelationships);
				
				// create ERDEntity Relationship
				for(Schema.DescribeSObjectResult childObjectResult : childObjectResults)
				{
					String childObjectName = childObjectResult.getName();
					Boolean childObjectIsCustom = childObjectResult.isCustom();
					
					if(!ERDUtils.isEnitityRelationshipExists(objectName, childObjectName, entityRelationships))
					{
						ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
						entityRelationship.parentObjectName = objectName;
						entityRelationship.childObjectName = childObjectName;
						entityRelationships.add(entityRelationship);
                        allRelationships.add(entityRelationship);
					}
				}
				
				if(!childObjectResults.isEmpty())
				{
					collectSchemaInfo(childObjectResults, entities, entityRelationships, allRelationships, objectNames);
				}
			//}
		}
	}
	*/
	
	
	
	
}