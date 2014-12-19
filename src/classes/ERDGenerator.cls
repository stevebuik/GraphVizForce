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
		Boolean includeStandardUserLookup = settings.includeStandardUserLookup;
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
		String crossGroupRelationshipContent = generateCrossGroupRelationshipContent(allObjectRelationshipList, includeStandardUserLookup);
		
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
	
	private String generateCrossGroupRelationshipContent(List<ERDEntityRelationship> allObjectRelationshipList, Boolean includeStandardUserLookup)
	{
		String crossGroupRelationshipContent = '';
		
		if(!allObjectRelationshipList.isEmpty())
		{
            for(ERDEntityRelationship crossRelationship : allObjectRelationshipList){
            	
            	if(includeStandardUserLookup || !ERDUtils.isStandardUserLookupRelationship(crossRelationship))
            	{
            		ERDTemplateType templateType = (crossRelationship.isCascadeDelete?ERDTemplateType.MD_Relationship:ERDTemplateType.LOOKUP_RELATIONSHIP);
            		crossGroupRelationshipContent += templateEngine.render(templateType,
									new Map<String, String>{
										'from' => crossRelationship.parentObjectName,
										'to' => crossRelationship.childObjectName
									});    
            	}      
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
	
	private String generateFields(List<ERDEntityField> entityFields)
	{
		String entityFieldsOutput = '';
		
		for(ERDEntityField entityField : entityFields)
		{
			System.debug(LoggingLevel.ERROR, '@@@@@@@@@@@@@@@entityField.fieldType:' + entityField.fieldType);
			entityFieldsOutput += templateEngine.render(ERDTemplateType.FIELD,
				new Map<String, String>{
					'name' => entityField.fieldName,
					'fieldType' => entityField.fieldType
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
				entityFieldsOutput = generateFields(entity.fieldList);
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