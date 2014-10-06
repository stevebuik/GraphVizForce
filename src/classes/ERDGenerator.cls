/*
Name: ERDGenerator
Purpose: generate an ERD that Graphviz can understand
*/

public with sharing class ERDGenerator
{
	private Integer describeChildCount = 0;

	private TemplateEngine.StaticResourceTemplateSource templateSource = new TemplateEngine.StaticResourceTemplateSource('DefaultTemplate');
	//private TemplateEngine.CalloutTemplateSource templateSource = new TemplateEngine.CalloutTemplateSource('https://dl.dropboxusercontent.com/u/1270824/erd-templates/default.txt');
	
	private TemplateEngine templateEngine = new TemplateEngine(templateSource);
	
	public String generateERD(Map<String,List<String>> groupObjectMap){
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		String crossRelationshipContent = '';
		
		List<String> allObjectNames = new list<String>();
		Map<String, ERDEntity> objectERDEntityMap = new map<String, ERDEntity>();
		Map<String, list<ERDEntityRelationship>> objectChildrenRelationshipMap = new map<String, list<ERDEntityRelationship>>();
		List<ERDEntityRelationship> allObjectChildrenRelationships = new list<ERDEntityRelationship>();
		List<Schema.DescribeSobjectResult> allObjectResults;
		
		if(groupObjectMap != null){
			// Get all object results for the group map
			for(list<String> namesList : groupObjectMap.values()){
				allObjectNames.addAll(namesList);
			}
			allObjectResults = Schema.describeSObjects(allObjectNames);
			
			for(String objectName : allObjectNames){
				for(Schema.DescribeSobjectResult objectResult : allObjectResults){
					// For each object
					if(objectResult.getName() == objectName){
						// Add ERDEntity to map
						ERDEntity entity = new ERDEntity();
						entity.objectName = objectName;
						entity.isCustom = objectResult.isCustom();
						objectERDEntityMap.put(objectName,entity);
						
						
						// For all the child relationship of an object
						list<Schema.ChildRelationship> childRelationshipForObject = objectResult.getChildRelationships();
						list<ERDEntityRelationship> entityRleationshipListForObject = new list<ERDEntityRelationship>();
						
						for(Schema.ChildRelationship childRelationship : childRelationshipForObject){
							// Get the child relationship object name
							Schema.Sobjecttype childObjectType = childRelationship.getChildSObject();
							Schema.DescribeSObjectResult childObjectResult = childObjectType.getDescribe();
							String childName = childObjectResult.getName();
							
							// Ensure the child object is in the groupObjectMap, which is specified by user in the UI
							if(ERDUtils.isValidObjectName(childName,allObjectNames)){
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
			for(String groupName : groupObjectMap.keySet()){
				// Prepare list of entities, list of relationships
				list<ERDEntity> entities = new list<ERDEntity>();
				list<ERDEntityRelationship> entityRelationships = new list<ERDEntityRelationship>();
				list<String> objNames = groupObjectMap.get(groupName);
				
				for(String objName : objNames){
					entities.add(objectERDEntityMap.get(objName));
					entityRelationships.addAll(objectChildrenRelationshipMap.get(objName));
				}
				
				// Generate the subgraph section with group index, groupname, object names for the group, entity list and relationship list
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
		list<ERDEntityRelationship> entityRelationships){

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
		
}