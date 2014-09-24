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
	
	public String generateERD(Map<String,List<String>> groupObjectMap)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		List<ERDEntityRelationship> allRelationships = new List<ERDEntityRelationship>();
		
		if(groupObjectMap != null)
		{
			for(String groupName : groupObjectMap.keySet())
			{
				List<String> objNames = groupObjectMap.get(groupName);
				String standardSubgraph = generateSubgraph(subgraphIndex,groupName,objNames,allRelationships);
				subgraphsContent += standardSubgraph;
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

	private List<Schema.SObjectType> getObjectTypes()
	{
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		List<Schema.SObjectType> objectTypes = new List<Schema.SObjectType>(globalDescribe.values());
		return objectTypes;
	}
	
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
			if(describeChildCount < 100)
			{
				describeChildCount++;
				List<Schema.ChildRelationship> childRelationships = objectResult.getChildRelationships();
				List<Schema.Sobjecttype> childObjectTypes = ERDUtils.getObjectTypesByChildRelationships(childRelationships);
				List<Schema.DescribeSObjectResult> childObjectResults = ERDUtils.getObjectResultsByObjectTypes(childObjectTypes, objectNames);
				
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
				
				collectSchemaInfo(childObjectResults, entities, entityRelationships, allRelationships, objectNames);
			}
		}
	}
	
	
	
	
}