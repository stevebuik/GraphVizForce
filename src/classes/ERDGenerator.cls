/*
Name: ERDGenerator
Purpose: generate an ERD that Graphviz can understand
*/

public with sharing class ERDGenerator
{
	private Integer describeChildCount = 0;
	
	private ERDTemplateEngine templateEngine;
	
	public ERDGenerator(String resourceName) {
		this(new ERDTemplateEngine.StaticResourceTemplateSource(resourceName));	
	}

	public ERDGenerator(ERDTemplateEngine.TemplateSource source) {
		templateEngine = new ERDTemplateEngine(source);
	}
	
	public String generateERD(ERDSettingsV3 settings)
	{
		ERDInspector inspector = new ERDInspector();
		ERDSettingProcessor processor = new ERDSettingProcessor();
		Boolean includeFields = settings.includeFields;
		Map<String,Map<String,List<String>>> erdMap = new Map<String,Map<String,List<String>>>();
		Set<String> allSelectedObjects = processor.retrieveAllObjectsForGroups(settings);
		List<ERDEntityRelationship> allObjectRelationshipList = new List<ERDEntityRelationship>();
		Map<String, List<ERDEntity>> groupToERDEntityListMap = new Map<String, List<ERDEntity>>(); 
		
		for(String grp : settings.groupToObjectsToFieldsMap.keySet())
		{
			if(settings.includedGroups.contains(grp))
			{
				erdMap.put(grp,settings.groupToObjectsToFieldsMap.get(grp));
			}
		}
		
		inspector.inspectERDSchema(allSelectedObjects,
								erdMap,
								groupToERDEntityListMap,
								allObjectRelationshipList
								);
								
		String subgraphContent = generateSubgraphContent(groupToERDEntityListMap, includeFields);
		String crossGroupRelationshipContent = generateCrossGroupRelationshipContent(allObjectRelationshipList);
		
		return renderERDGraphvizContent(subgraphContent, crossGroupRelationshipContent);
	}
	
	private static final List<String> COLORS = new List<String> {
		'powderblue','olivedrab3','peachpuff','orange','lightsalmon4','indianred2'
		,'mediumpurple','tomato2','orchid','wheat','palegreen','darkslateblue' 
	};
	
	private String generateSubgraphContent(Map<String, List<ERDEntity>> groupToERDEntityListMap,
											Boolean includeFields) {
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		
		Set<String> groupNameSet = groupToERDEntityListMap.keySet();
		
		// For each group of objects specified by user in UI
		for(String groupName : groupNameSet){
			// Prepare List of entities, List of relationships
			List<ERDEntity> entities = groupToERDEntityListMap.get(groupName);
			
			// Generate the subgraph section with group index, groupname, object names for the group, entity List and relationship List
			String groupSubGraph = generateSubgraph(
				subgraphIndex,
				groupName,
				COLORS.get(subgraphIndex), 
				entities,
				includeFields);
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
				crossGroupRelationshipContent += templateEngine.render(ERDTemplateType.RELATIONSHIP,
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
		return templateEngine.render(ERDTemplateType.MAIN,
					new Map<String, String>{
						'content' => subgraphContent + crossGroupRelationshipContent
					});
	}
	
	private String generateFields(List<String> entityFields)
	{
		String entityFieldsOutput = '';
		
		for(String fieldName : entityFields)
		{
			entityFieldsOutput += templateEngine.render(ERDTemplateType.FIELD,
				new Map<String, String>{
					'name' => fieldName
				});
		}
		
		return entityFieldsOutput;
	}
	
	private String generateSubgraph(
		Integer subgraphIndex, 
		String groupName, 
		String colour,
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
			
			entityOutput += templateEngine.render(ERDTemplateType.ENTITY,
				new Map<String, String>{
					'name' => entity.objectName,
					'fields' => entityFieldsOutput
				});
		}
				
		return templateEngine.render(ERDTemplateType.CLUSTER,
					new Map<String, String>{
						'sequence' => ''+subgraphIndex,
						'color' => colour,
						'name' => groupName,
						'content' => entityOutput + entityRelationshipOutput
					});
		
	}
	
}