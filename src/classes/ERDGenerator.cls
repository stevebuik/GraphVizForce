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
	
	public String generateERD(Map<String,List<String>> groupObjectMap)
	{
		ERDInterpreter interpreter = new ERDInterpreter();
		
		List<String> objectNameList = interpreter.getObjectNameList(groupObjectMap);
		Map<String,Schema.DescribeSobjectResult> objectNameSObjectResultMap = interpreter.getObjectNameSObjectResultMap(objectNameList);
		
		Map<String, ERDEntity> objectERDEntityMap = new Map<String, ERDEntity>();
		Map<String, List<ERDEntityRelationship>> objectChildRelationshipMap = new Map<String, List<ERDEntityRelationship>>();
		List<ERDEntityRelationship> allObjectRelationshipList = new List<ERDEntityRelationship>();
		
		interpreter.setupERDMaps(objectNameList,
								objectNameSObjectResultMap,
								objectERDEntityMap,
								objectChildRelationshipMap,
								allObjectRelationshipList
								);
								
		String subgraphContent = interpreter.interpretSubgraphContent(templateEngine, 
																	groupObjectMap,
																	objectERDEntityMap,
																	objectChildRelationshipMap
																	);
		String crossGroupRelationshipContent = interpreter.interpretCrossGroupRelationshipContent(templateEngine, allObjectRelationshipList);
		
		return interpreter.renderERDGraphvizContent(templateEngine, subgraphContent, crossGroupRelationshipContent);
		
	}
	
	/*
	public String generateERD(Map<String,List<String>> groupObjectMap){
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		String crossRelationshipContent = '';
		
		List<String> allObjectNames = new List<String>();
		Map<String, ERDEntity> objectERDEntityMap = new Map<String, ERDEntity>();
		Map<String, List<ERDEntityRelationship>> objectChildrenRelationshipMap = new Map<String, List<ERDEntityRelationship>>();
		List<ERDEntityRelationship> allObjectChildrenRelationships = new List<ERDEntityRelationship>();
		List<Schema.DescribeSobjectResult> allObjectResults;
		
		if(groupObjectMap != null){
			// Get all object results for the group Map
			for(List<String> namesList : groupObjectMap.values()){
				allObjectNames.addAll(namesList);
			}
			allObjectResults = Schema.describeSObjects(allObjectNames);
			
			for(String objectName : allObjectNames){
				for(Schema.DescribeSobjectResult objectResult : allObjectResults){
					// For each object
					if(objectResult.getName() == objectName){
						// Add ERDEntity to Map
						ERDEntity entity = new ERDEntity();
						entity.objectName = objectName;
						entity.isCustom = objectResult.isCustom();
						objectERDEntityMap.put(objectName,entity);
						
						
						// For all the child relationship of an object
						List<Schema.ChildRelationship> childRelationshipForObject = objectResult.getChildRelationships();
						List<ERDEntityRelationship> entityRleationshipListForObject = new List<ERDEntityRelationship>();
						
						for(Schema.ChildRelationship childRelationship : childRelationshipForObject){
							// Get the child relationship object name
							Schema.Sobjecttype childObjectType = childRelationship.getChildSObject();
							Schema.DescribeSObjectResult childObjectResult = childObjectType.getDescribe();
							String childName = childObjectResult.getName();
							
							// Ensure the child object is in the groupObjectMap, which is specified by user in the UI
							if(ERDUtils.isValidObjectName(childName,allObjectNames)){
								// Add ERDEntityRelationship to List of relationsihp for an object
								ERDEntityRelationship entityRelationship = new ERDEntityRelationship();
								entityRelationship.parentObjectName = objectName;
								entityRelationship.childObjectName = childName;
								entityRleationshipListForObject.add(entityRelationship);
							}
						}
						
						// Add List of relationship for an object to the full List
						allObjectChildrenRelationships.addAll(entityRleationshipListForObject);
						// Add List of relationship for an object to the Map
						objectChildrenRelationshipMap.put(objectName, entityRleationshipListForObject);
						
						break;
					}
				}
			}
			
			// For each group of objects specified by user in UI
			for(String groupName : groupObjectMap.keySet()){
				// Prepare List of entities, List of relationships
				List<ERDEntity> entities = new List<ERDEntity>();
				List<ERDEntityRelationship> entityRelationships = new List<ERDEntityRelationship>();
				List<String> objNames = groupObjectMap.get(groupName);
				
				for(String objName : objNames){
					entities.add(objectERDEntityMap.get(objName));
					entityRelationships.addAll(objectChildrenRelationshipMap.get(objName));
				}
				
				// Generate the subgraph section with group index, groupname, object names for the group, entity List and relationship List
				String groupSubGraph = generateSubgraph(subgraphIndex,groupName,allObjectNames,entities,entityRelationships);
				subgraphsContent += groupSubGraph;
				subgraphIndex++;
			}
			
			// Append cross-group relationship outside of sub graph blocks
			if(!allObjectChildrenRelationships.isEmpty()){
	            for(ERDEntityRelationship crossRelationship : allObjectChildrenRelationships){
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
	
	private String generateSubgraph(
		Integer subgraphIndex, 
		String groupName, 
		List<String> allObjectNames, 
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
		
		for(ERDEntityRelationship relation : entityRelationships){
			entityRelationshipOutput += templateEngine.render(TemplateType.RELATIONSHIP,
				new Map<String, String>{
					'from' => relation.parentObjectName,
					'to' => relation.childObjectName
				});
		}
		
		return templateEngine.render(TemplateType.CLUSTER,
					new Map<String, String>{
						'sequence' => ''+subgraphIndex,
						'name' => groupName,
						'content' => entityOutput + entityRelationshipOutput
					});
		
	}
	*/
}