/*
Name: ERDGeneratorTest
Purpose: 
This class is to test ERDGeneration related class methods

*/

@isTest
private with sharing class ERDGeneratorTest
{
	@isTest
	static void ERDGeneratorTests()
	{
		ERDGenerator generator = new ERDGenerator();
		String erdOutput = generator.generateERD(null,null);
		System.assert(erdOutput != '');
	}
}

/*

To run the generator, use the following in execute anonymous

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

*/