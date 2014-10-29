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
		ERDInterpreter interpreter = new ERDInterpreter();
		Boolean includeFields = settings.includeFields;
		
		// This is temporary, to prepare groupObjectMap for existing generator logic
		// TODO: modify generator to take the selectedGroupToObjectsToFieldsMap
		Map<String,List<String>> groupObjectMap = new Map<String,List<String>>();
		for(String grp : settings.groupToObjectsToFieldsMap.keySet())
		{
			groupObjectMap.put(grp, new List<String>(settings.groupToObjectsToFieldsMap.get(grp).keySet()));
		}
		
		System.debug(LoggingLevel.ERROR, '====>groupObjectMap:' + groupObjectMap);
		
		List<String> objectNameList = interpreter.getObjectNameList(groupObjectMap);
		Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap = interpreter.getObjectNameSObjectResultMap(objectNameList);
		
		Map<String, ERDEntity> objectERDEntityMap = new Map<String, ERDEntity>();
		List<ERDEntityRelationship> allObjectRelationshipList = new List<ERDEntityRelationship>();
		
		interpreter.setupERDMaps(objectNameList,
								objectNameSObjectResultMap,
								objectERDEntityMap,
								allObjectRelationshipList
								);
								
		String subgraphContent = generateSubgraphContent(groupObjectMap,
														objectERDEntityMap,
														includeFields
														);
		String crossGroupRelationshipContent = generateCrossGroupRelationshipContent(allObjectRelationshipList);
		
		System.debug(LoggingLevel.ERROR, '====>subgraphContent:' + subgraphContent);
		System.debug(LoggingLevel.ERROR, '====>crossGroupRelationshipContent:' + crossGroupRelationshipContent);
		return renderERDGraphvizContent(subgraphContent, crossGroupRelationshipContent);
	}
	
	/*
	public String generateERD(Map<String,List<String>> groupObjectMap, Boolean includeFields)
	{
		ERDInterpreter interpreter = new ERDInterpreter();
		
		List<String> objectNameList = interpreter.getObjectNameList(groupObjectMap);
		Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap = interpreter.getObjectNameSObjectResultMap(objectNameList);
		
		Map<String, ERDEntity> objectERDEntityMap = new Map<String, ERDEntity>();
		//Map<String, List<ERDEntityRelationship>> objectChildRelationshipMap = new Map<String, List<ERDEntityRelationship>>();
		List<ERDEntityRelationship> allObjectRelationshipList = new List<ERDEntityRelationship>();
		
		interpreter.setupERDMaps(objectNameList,
								objectNameSObjectResultMap,
								objectERDEntityMap,
								//objectChildRelationshipMap,
								allObjectRelationshipList
								);
								
		String subgraphContent = generateSubgraphContent(groupObjectMap,
														objectERDEntityMap,
														//objectChildRelationshipMap,
														includeFields
														);
		String crossGroupRelationshipContent = generateCrossGroupRelationshipContent(allObjectRelationshipList);
		
		return renderERDGraphvizContent(subgraphContent, crossGroupRelationshipContent);
		
	}
	*/
	
	private String generateSubgraphContent(Map<String,List<String>> groupObjectMap,
											Map<String, ERDEntity> objectERDEntityMap, 
											//Map<String, List<ERDEntityRelationship>> objectChildRelationshipMap,
											Boolean includeFields
											)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		
		Set<String> groupNameSet = groupObjectMap.keySet();
		
		// For each group of objects specified by user in UI
		for(String groupName : groupNameSet){
			// Prepare List of entities, List of relationships
			List<ERDEntity> entities = new List<ERDEntity>();
			//List<ERDEntityRelationship> entityRelationships = new List<ERDEntityRelationship>();
			List<String> objNamesInGroup = groupObjectMap.get(groupName);
			
			for(String objName : objNamesInGroup){
				entities.add(objectERDEntityMap.get(objName));
				//entityRelationships.addAll(objectChildRelationshipMap.get(objName));
			}
			
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
		//List<ERDEntityRelationship> entityRelationships
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