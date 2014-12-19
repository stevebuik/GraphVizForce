@isTest 
public with sharing class ERDGeneratorControllerTest
{
	
	@isTest
	static void testSettingsWithDefaultDiagram()
	{
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
    	System.debug(LoggingLevel.ERROR, '@@@@@@PageReference is initialised');
    	
		Test.startTest();
        	
        	/* Test controller without saved diagram */
        	// Instantiate a new controller with all parameters in the page
	      	ERDGeneratorController controller;
	        controller = new ERDGeneratorController();
	    	System.debug(LoggingLevel.ERROR, '@@@@@@ERDGeneratorController is initialised');
			controller.ensureDefaultDiagram();
        
        	// Test d1 document exists
        	List<Document> docs = [SELECT Id, Body FROM Document WHERE Name = :ERDGeneratorController.DEFAULT_DIAGRAM_NAME AND FolderId = :controller.persister.folderId];
			System.assertEquals(1, docs.size());
        	
			// Test loading setting d1 
			System.assertEquals(ERDGeneratorController.DEFAULT_DIAGRAM_NAME, controller.selectedSetting);
			System.assertEquals(ERDGeneratorController.DEFAULT_DIAGRAM_NAME, controller.currentSetting);
			
			/* Test controller with saved diagram */
			// Load page with saved diagram "Standard Objects"
			controller = new ERDGeneratorController();
			controller.ensureDefaultDiagram();
			
			// Test controller UI methods
			System.assertEquals(1,controller.settingSelectOptions.size());
			
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
	static void testGroupConfiguration()
	{
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
    	
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
		controller.ensureDefaultDiagram();
        
        Test.startTest();
        	// User unselect a group
        	controller.erdGroups[0].selected = false;
        	controller.saveSelectedSetting();
        	System.assertEquals(3, controller.settings.includedGroups.size());
        	
        	// User select a group
        	controller.erdGroups[0].selected = true;
        	controller.saveSelectedSetting();
        	System.assertEquals(4, controller.settings.includedGroups.size());
        	
        	// User add a new group
        	controller.newGroupName = 'New Group';
        	controller.addNewGroupWithInput();
        	controller.saveSelectedSetting();
        	System.assertEquals(5, controller.settings.includedGroups.size());
        	
        	// User delete a group
        	controller.groupToDelete = 'New Group';
        	controller.deleteERDGroup();
        	controller.saveSelectedSetting();
        	System.assertEquals(4, controller.settings.includedGroups.size());
        	
        	// User press edit button on a group
        	controller.selectedGroup = 'Common';
        	String selectedObjectsForGroup = controller.getSelectedObjects();
        	System.assertEquals('Contact,Account', selectedObjectsForGroup);
        	String objectsForSelectedGroup = controller.getObjectsForSelectedGroup();
        	System.assertEquals(true, objectsForSelectedGroup.contains('Contact'));
        	
        	// User add objects to a group
        	controller.setSelectedObjects('Contact,Account,Lead');
        	controller.saveSelectedSetting();
        	selectedObjectsForGroup = controller.getSelectedObjects();
        	System.assertEquals('Contact,Account,Lead',selectedObjectsForGroup);
        	
        	// User remove objects from a group
        	controller.setSelectedObjects('Contact,Account');
        	controller.saveSelectedSetting();
        	selectedObjectsForGroup = controller.getSelectedObjects();
        	System.assertEquals('Contact,Account',selectedObjectsForGroup);
        	
        Test.stopTest();
	}
	
	
	@isTest
	static void testObjectConfiguration()
	{
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
    	
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
		controller.ensureDefaultDiagram();
        
        // User press edit button on a group
    	controller.selectedGroup = 'Common';
    	String selectedObjectsForGroup = controller.getSelectedObjects();
    	System.assertEquals('Contact,Account', selectedObjectsForGroup);
    	
    	// User add objects to a group
    	controller.setSelectedObjects('Contact,Account,Lead');
    	selectedObjectsForGroup = controller.getSelectedObjects();
    	System.assertEquals('Contact,Account,Lead',selectedObjectsForGroup);
        
        Test.startTest();
        	
        	// User switch to step 3 - object > fields section
        	controller.refreshObjectFieldSelection();
        	Set<String> allSelectedObjects = new Set<String>(controller.getAllSelectedObjects());
        	System.assertEquals(true,allSelectedObjects.contains('Lead'));
        	
        	// User press edit button on an object
        	controller.selectedSingleObject = 'Contact';
        	String allFieldsForSelectedObject = controller.getAllFieldsForSelectedObject();
        	String selectedObjectFields = controller.getSelectedObjectFields();
        	System.assertEquals(true,allFieldsForSelectedObject.contains('FirstName'));
        	System.assertEquals(true,selectedObjectFields.contains('FirstName'));
        	System.assertEquals(false,selectedObjectFields.contains('Email'));
        	
        	// User add fields to an object
        	controller.setSelectedObjectFields('Jigsaw,Languages__c,FirstName,LastName,Email');
        	controller.saveSelectedSetting();
        	selectedObjectFields = controller.getSelectedObjectFields();
        	System.assertEquals(true,selectedObjectFields.contains('Email'));
        	
        	// User remove fields from an object
        	controller.setSelectedObjectFields('Jigsaw,Languages__c,FirstName,LastName');
        	controller.saveSelectedSetting();
        	selectedObjectFields = controller.getSelectedObjectFields();
        	System.assertEquals(false,selectedObjectFields.contains('Email'));
        	
        Test.stopTest();
	}
	
	
	@isTest
	static void testSettingOptions()
	{
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
    	
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
		controller.ensureDefaultDiagram();
        
        Test.startTest();
        	
        	// Test include fields with default diagram
        	Boolean includeFields = controller.getIncludeFields();
        	Boolean includeStandardUserLookup = controller.getIncludeStandardUserLookup();
        	System.assertEquals(true,includeFields);
        	
        	// User diselect include fields checkbox
        	controller.setIncludeFields(false);
        	includeFields = controller.getIncludeFields();
        	controller.saveSelectedSetting();
        	System.assertEquals(false,includeFields);
        	
        	// User select include standard user lookup
        	controller.setIncludeStandardUserLookup(true);
        	includeStandardUserLookup = controller.getIncludeStandardUserLookup();
        	controller.saveSelectedSetting();
        	System.assertEquals(true,includeStandardUserLookup);
        	
        Test.stopTest();
	}
	
	@isTest
	static void testERDContentGeneration()
	{
		// Initiate page reference
		PageReference pageRef = Page.ERDGeneratorPage;
        Test.setCurrentPage(pageRef);
    	
        // Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
		controller.ensureDefaultDiagram();
        
        Test.startTest();
        	
        	// Test templates list:
        	List<SelectOption> templates = controller.getTemplates();
        	System.assertEquals(2, templates.size());
        	
        	// User press generate button
        	controller.template = 'DefaultTemplate';
        	controller.generateERD();
        	System.assertEquals(true,controller.generatedContent.contains('graph [rankdir=LR,nodesep=1.0];'));
        	System.assertEquals(true,controller.generatedContent.contains('label = "Common"'));
        	System.assertEquals(true,controller.generatedContent.contains('Account -> Account'));
        	System.assertEquals(true,controller.generatedContent.contains('Account [label='));
        Test.stopTest();
	}
	
	@isTest
	static void testERDPersisterMethods()
	{
		// Instantiate a new controller with all parameters in the page
      	ERDGeneratorController controller;
        controller = new ERDGeneratorController();
		
		Test.startTest();
		
			// On controller initialisation in new org, no settings available
			List<String> settingNames = controller.persister.getSettingsNameList();
			System.assertEquals(0,settingNames.size());
			
			// Controller initialise with DefaultDiagram
			controller.ensureDefaultDiagram();
			settingNames = controller.persister.getSettingsNameList();
			System.assertEquals(1,settingNames.size());
			
			// Controller load settings
			controller.loadSelectedSetting();
			System.assertEquals(4,controller.erdGroups.size());
			
		Test.stopTest();
	}
}