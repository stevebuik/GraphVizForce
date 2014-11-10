@isTest 
public with sharing class ERDGeneratorControllerTest
{
	
	@isTest
	static void testSettingsTabWithDefaultDiagram()
	{
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
    	System.debug(LoggingLevel.ERROR, '@@@@@@PageReference is initialised');
    	
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
    	System.debug(LoggingLevel.ERROR, '@@@@@@ERDGeneratorController is initialised');
		controller.ensureDefaultDiagram();
		
		Test.startTest();
        
        	// Test d1 document exists
        	List<Document> docs = [SELECT Id, Body FROM Document WHERE Name = 'Standard Objects' AND FolderId = :controller.persister.folderId];
			System.assertEquals(1, docs.size());
        	
			// Test loading setting d1 
			System.assertEquals('Standard Objects', controller.selectedSetting);
			System.assertEquals('Standard Objects', controller.currentSetting);
			
			// User save current setting d1 after deleted group
			controller.selectedGroup = 'Marketing';
			controller.groupToDelete = controller.selectedGroup;
			controller.deleteERDGroup();
			controller.saveSelectedSetting();
        	//List<ERDEntityGroup> groups = controller.getGroups();
			//System.debug(LoggingLevel.ERROR,'@@@@@@@@@@controller.getGroups():' + groups);
			System.assertEquals(3, controller.erdGroups.size(), 'erd map size should be 3 after Marketing deletion');
			
			// User type in new setting name and save current setting as new
			controller.newSettingName = 'd2';
			controller.saveAsNewSetting();
			System.assertEquals('d2', controller.selectedSetting);
			docs = [SELECT Id, Body FROM Document WHERE Name = 'd2' AND FolderId = :controller.persister.folderId];
			System.assertEquals(1, docs.size());
			
			// User delete selected setting
			controller.deleteSelectedSetting();
			System.assertEquals(null,controller.selectedSetting);
			docs = [SELECT Id, Body FROM Document WHERE Name = 'd2' AND FolderId = :controller.persister.folderId];
			System.assertEquals(0, docs.size());
			
		Test.stopTest();
	}
	
	@isTest
	static void testGroupConfigurationTab()
	{
		ERDPersister persister = new ERDPersister();
        
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
        
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
        
        Test.startTest();
        	
        Test.stopTest();
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