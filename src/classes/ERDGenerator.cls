/*
Name: ERDGenerator
Purpose: generate an ERD that Graphviz can understand
*/

public with sharing class ERDGenerator
{
	private Integer describeChildCount = 0;
	
	private TemplateEngine templateEngine;
	
	public ERDGenerator(String resourceName) {
		this(new TemplateEngine.StaticResourceTemplateSource(resourceName));	
	}

	public ERDGenerator(TemplateEngine.TemplateSource source) {
		templateEngine = new TemplateEngine(source);
	}
	
	public String generateERD(ERDSettingsV3 settings)
	{
		ERDInspector inspector = new ERDInspector();
		Boolean includeFields = settings.includeFields;
		Map<String,Map<String,List<String>>> erdMap = settings.selectedGroupToObjectsToFieldsMap;
		Set<String> objectNameSet = settings.objectNameSet;
		
		List<ERDEntityRelationship> allObjectRelationshipList = new List<ERDEntityRelationship>();
		Map<String, List<ERDEntity>> groupToERDEntityListMap = new Map<String, List<ERDEntity>>(); 
		
		inspector.inspectERDSchema(objectNameSet,
								erdMap,
								groupToERDEntityListMap,
								allObjectRelationshipList
								);
								
		String subgraphContent = generateSubgraphContent(groupToERDEntityListMap, includeFields);
		String crossGroupRelationshipContent = generateCrossGroupRelationshipContent(allObjectRelationshipList);
		
		return renderERDGraphvizContent(subgraphContent, crossGroupRelationshipContent);
	}
	
	private String generateSubgraphContent(Map<String, List<ERDEntity>> groupToERDEntityListMap,
											Boolean includeFields)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		
		Set<String> groupNameSet = groupToERDEntityListMap.keySet();
		
		// For each group of objects specified by user in UI
		for(String groupName : groupNameSet){
			// Prepare List of entities, List of relationships
			List<ERDEntity> entities = groupToERDEntityListMap.get(groupName);
			
			// Generate the subgraph section with group index, groupname, object names for the group, entity List and relationship List
			String groupSubGraph = generateSubgraph(subgraphIndex,groupName,entities,includeFields);
			subgraphsContent += groupSubGraph;
			subgraphIndex++;
		}
		
		return subgraphsContent;
	}
	
	private String generateCrossGroupRelationshipContent(List<ERDEntityRelationship> allObjectRelationshipList)
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
	
	private String renderERDGraphvizContent(String subgraphContent, String crossGroupRelationshipContent)
	{
		// Render ERD graphviz content using template engine
		return templateEngine.render(TemplateType.MAIN,
					new Map<String, String>{
						'content' => subgraphContent + crossGroupRelationshipContent
					});
	}
	
	private String generateFields(List<String> entityFields)
	{
		String entityFieldsOutput = '';
		
		for(String fieldName : entityFields)
		{
			entityFieldsOutput += templateEngine.render(TemplateType.FIELD,
				new Map<String, String>{
					'name' => fieldName
				});
		}
		
		return entityFieldsOutput;
	}
	
	private String generateSubgraph(
		Integer subgraphIndex, 
		String groupName, 
		List<ERDEntity> entities,
		Boolean includeFields
		){

		String entityOutput = '';
		String entityRelationshipOutput = '';
		String entityFieldsOutput = '';
		
		for(ERDEntity entity : entities){
			
			if(includeFields) {
				entityFieldsOutput = generateFields(entity.fieldNameList);
			} else {
				entityFieldsOutput = '';
			}
			
			entityOutput += templateEngine.render(TemplateType.ENTITY,
				new Map<String, String>{
					'name' => entity.objectName,
					'fields' => entityFieldsOutput
				});
		}
				
		return templateEngine.render(TemplateType.CLUSTER,
					new Map<String, String>{
						'sequence' => ''+subgraphIndex,
						'name' => groupName,
						'content' => entityOutput + entityRelationshipOutput
					});
		
	}
	
}