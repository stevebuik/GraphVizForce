@isTest(SeeAllData = true)
public with sharing class ERDGeneratorControllerTest
{
	//private static final String FOLDER_ERD_SETTINGS = 'ERD_Settings';
	
	@isTest
	static void testSettingsTabWithSavedDiagrams()
	{
		// Initiate diagram
		String diagramName = 'd1';
		ERDPersister persister = new ERDPersister();
		Map<String,Map<String,List<String>>> erdMap = new Map<String,Map<String,List<String>>>{
				'Sales' => new Map<String, List<String>>
							{
								'Account' => new List<String>{'Name'},
								'Contact' => new List<String>(),
								'Opportunity' => new List<String>()
							},
				'Marketing' => new Map<String, List<String>>
							{
								'Lead' => new List<String>(),
								'Campaign' => new List<String>()
							}
			};
		
		// create fake non-versioned persisted settings		
		insert new Document(Name = diagramName,
			FolderId = persister.folderId,
			Body = Blob.valueOf(JSON.serialize(erdMap)));
        
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
        
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
		
		Test.startTest();
        
        	// Test d1 document exists
        	List<Document> docs = [SELECT Id, Body FROM Document WHERE Name = 'd1' AND FolderId = :persister.folderId];
			System.assertEquals(1, docs.size());
        	
			// Test loading setting d1 
			System.assertEquals('d1', controller.selectedSetting);
			System.assertEquals('d1', controller.currentSetting);
			
			// User save current setting d1 after deleted group
			controller.selectedGroup = 'Marketing';
			controller.groupToDelete = controller.selectedGroup;
			controller.deleteERDGroup();
			controller.saveSelectedSetting();
        	List<ERDEntityGroup> groups = controller.getGroups();
			System.debug(LoggingLevel.ERROR,'@@@@@@@@@@controller.getGroups():' + groups);
			System.assertEquals(1, groups.size(), 'erd map size should be 1 after group deletion');
			
			// User type in new setting name and save current setting as new
			controller.newSettingName = 'd2';
			controller.saveAsNewSetting();
			System.assertEquals('d2', controller.selectedSetting);
			docs = [SELECT Id, Body FROM Document WHERE Name = 'd2' AND FolderId = :persister.folderId];
			System.assertEquals(1, docs.size());
			
			// User delete selected setting
			controller.deleteSelectedSetting();
			System.assertEquals(null,controller.selectedSetting);
			docs = [SELECT Id, Body FROM Document WHERE Name = 'd2' AND FolderId = :persister.folderId];
			System.assertEquals(0, docs.size());
			
		Test.stopTest();
	}
	
	@isTest
	static void testSettingsTabWithoutSavedDiagrams()
	{
		
	}
	
	@isTest
	static void testGroupConfigurationTab()
	{
		
	}
	
	@isTest
	static void testObjectConfigurationTab()
	{
		
	}
	
	@isTest
	static void testOptionsTab()
	{
		
	}
	
	@isTest
	static void testERDContentGeneration()
	{
		
	}
}