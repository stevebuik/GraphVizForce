/*
Name: ERDGenerator
Purpose: 
This class is to generate content that Graphviz can understand and turn it into ERD

// Create Standard Object Name List
List<String> salesObjects = new List<String>{'Account',
    										'AccountContactRole',
    										'Asset',
    										'Campaign',
    										'CampaignMember',
    										'Case',
    										'CaseStatus',
    										'Contact',
    										'Contract',
    										'ContractContactRole',
    										'Lead',
    										'LeadStatus',
    										'Opportunity',
    										'OpportunityCompetitor',
    										'OpportunityContactRole',
    										'Order',
    										'Partner',
    										'PartnerRole',
    										'Quote'
    										};
List<String> profileObjects = new List<String>{'FieldPermissions',
    											'ObjectPermissions',
    											'PermissionSet',
    											'PermissionSetAssignment',
    											'Profile',
    											'SetupEntityAccess',
    											'User',
    											'UserLicense'
    											};

// Create Standard Group Map
Map<String,List<String>> standardMap = new Map<String,List<String>>();
standardMap.put('Sales',salesObjects);
standardMap.put('ProfilePermission',profileObjects);

// Create Custom Group Map
List<String> recruitmentCustomObjects = new List<String>{'Salary__c',
    													'Job_Application__c',
    													'Offer__c',
    													'Review__c',
    													'Candidate_Snapshot__c',
    													'Programming_Language__c',
    													'Position_Programming_Language__c',
    													'Zip_Code__c',
    													'Job_Posting_Site__c',
    													'Job_Posting__c',
    													'Interviewer__c',
    													'Position__c',
    													'Search_Config__c',
    													'Candidate__c',
    													'Position_Approval_Matrix__c',
    													'Error_Log__c'
    													};
Map<String,List<String>> customMap = new Map<String,List<String>>();
customMap.put('Recruitment',recruitmentCustomObjects);

// Generate ERD Graphviz content
ERDGenerator generator = new ERDGenerator();
String content = generator.generateERD(standardMap,customMap);
System.debug(content);

Version		Author			Date		Details				Feature
1.0			Jason Guan		13/06/2014	Initial Creation	
*/
public with sharing class ERDGenerator
{
	private Boolean isLimited = true;		// current limit is 100, false indicates limit is removed
	private Integer describeChildCount = 0;
	private String erdTemplateStart = 'digraph G { splines=ortho; graph [rankdir = "LR";]; node [fontsize = "14";shape = "record";]; edge [arrowhead="crow";];\r';
	
	public String generateERD(Map<String,List<String>> standardGroupingMap, Map<String,List<String>> customGroupingMap)
	{
		String subgraphsContent = '';
		Integer subgraphIndex = 0;
		List<ERDEntityRelationship> allRelationships = new List<ERDEntityRelationship>();
		String crossRelationshipContent = '';
		
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
        
		if(!allRelationships.isEmpty())
            {
                for(ERDEntityRelationship crossRelationship : allRelationships)
                {
                    crossRelationshipContent += crossRelationship.parentObjectName + ' -> ' + crossRelationship.childObjectName + ';\r';
                }
            }
		
		return erdTemplateStart + subgraphsContent + crossRelationshipContent + '}';
	}
	/*
	public String generateCustomObjectERD()
	{
		List<ERDEntity> entities = new List<ERDEntity>();
		List<ERDEntityRelationship> entityRelationships = new List<ERDEntityRelationship>();
		List<Schema.SObjectType> allObjectTypes = getObjectTypes();
		
		// Get the top level object results
		List<Schema.DescribeSObjectResult> objectResults = ERDUtils.getCustomObjectResultsByObjectTypes(allObjectTypes);
		
		List<String> objectNames = new List<String>();
		for(Schema.DescribeSObjectResult objResult : objectResults)
		{
			objectNames.add(objResult.getName());
		}
		
		// Collection entities and entity relationships recursively
		collectSchemaInfo(objectResults,entities,entityRelationships,objectNames);
		
		// Generate ERD Content for custom objects
		String entityOutput = '';
		String entityRelationshipOutput = '';
		
		for(ERDEntity entity : entities)
		{
			if(ERDUtils.isValidObjectName(entity.objectName, objectNames))
			{
				String entityString = entity.objectName + ' [label = " ' + entity.objectName + ' "];\r';
				entityOutput += entityString;
			}
		}
		
		for(ERDEntityRelationship relation : entityRelationships)
		{
			if(ERDUtils.isValidObjectName(relation.parentObjectName, objectNames) && ERDUtils.isValidObjectName(relation.childObjectName, objectNames))
			{
				String relationString = relation.parentObjectName + ' -> ' + relation.childObjectName + ';\r';
				entityRelationshipOutput += relationString;
			}
		}
		
		return erdTemplateStart + entityOutput + entityRelationshipOutput + '}';
		
	}
	*/
	/*
	public String generateERDByGroups(List<String> groups)
	{
		String subgraphs = '';
		Integer subgraphIndex = 0;
		Map<String,List<String>> groupMap = new Map<String,List<String>>();
		
		for(List<Standard_Data_Model__c> dataModels : [SELECT Group__c, Name 
														FROM Standard_Data_Model__c 
														WHERE Group__c IN :groups])
		{
			System.debug(dataModels.size());
		    for(Standard_Data_Model__c model : dataModels)
		    {
		    	if(groupMap.containsKey(model.Group__c))
		    	{
		    		groupMap.get(model.Group__c).add(model.Name);
		    	}
		    	else
		    	{
		    		groupMap.put(model.Group__c,new List<String>{model.Name});
		    	}
		    }
		}
		
		for(String groupName : groupMap.keySet())
		{
			String subgraph = generateSubgraph(subgraphIndex,groupName,groupMap.get(groupName));
			subgraphs += subgraph;
			subgraphIndex++;
		}
		
		
		return erdTemplateStart + subgraphs + '}';
	}
	*/
	
	private List<Schema.SObjectType> getObjectTypes()
	{
		Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
		List<Schema.SObjectType> objectTypes = new List<Schema.SObjectType>(globalDescribe.values());
		return objectTypes;
	}
	
	private String generateSubgraph(Integer subgraphIndex, String groupName, List<String> objectNames, List<ERDEntityRelationship> allRelationships)
	{
		List<ERDEntity> entities = new List<ERDEntity>();
		List<ERDEntityRelationship> entityRelationships = new List<ERDEntityRelationship>();
		
		List<String> objectNamesList = new List<String>(objectNames);
		List<Schema.DescribeSobjectResult> objectResults = Schema.describeSObjects(objectNamesList);
		collectSchemaInfo(objectResults,entities,entityRelationships,allRelationships,objectNamesList);
		
		String subgraph = '';
		String entityOutput = '';
		String entityRelationshipOutput = '';
		
		for(ERDEntity entity : entities)
		{
			if(ERDUtils.isValidObjectName(entity.objectName, objectNamesList))
			{
				String entityString = entity.objectName + ' [label = " ' + entity.objectName + ' "];\r';
				entityOutput += entityString;
			}
		}
		
		for(ERDEntityRelationship relation : entityRelationships)
		{
			if(ERDUtils.isValidObjectName(relation.parentObjectName, objectNamesList) && ERDUtils.isValidObjectName(relation.childObjectName, objectNamesList))
			{
				String relationString = relation.parentObjectName + ' -> ' + relation.childObjectName + ';\r';
				entityRelationshipOutput += relationString;
			}
		}
		
		subgraph = 'subgraph cluster_' + subgraphIndex + ' { label = "' + groupName + '"; \r' + entityOutput + entityRelationshipOutput + ' } \r';
		
		return subgraph;
	}
	
	private void collectSchemaInfo(List<Schema.DescribeSObjectResult> objectResults, List<ERDEntity> entities, List<ERDEntityRelationship> entityRelationships, List<ERDEntityRelationship> allRelationships, List<String> objectNames)
	{
		for(Schema.DescribeSObjectResult objectResult : objectResults)
		{
			String objectName = objectResult.getName();
			Boolean objectIsCustom = objectResult.isCustom();
		
			// Create ERDEntity Object
			if(!ERDUtils.isEnitityExists(objectName, entities))
			{
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
				
				// Recursively collect schema info for child object result
				if(!isLimited)
				{
					collectSchemaInfo(childObjectResults, entities, entityRelationships, allRelationships, objectNames);
				}
			}
		}
	}
	
	
	
	
}