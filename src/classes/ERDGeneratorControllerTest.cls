@isTest
public with sharing class ERDGeneratorControllerTest
{
	private static final String FOLDER_ERD_SETTINGS = 'ERD Settings';
	
	@isTest
	static void testERDGeneratorWithSavedDiagrams()
	{
		// Initiate diagram
		String diagramName = 'd1';
		ERDPersister persister = new ERDPersister(FOLDER_ERD_SETTINGS);
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
			// Test Tab 1
			System.assertEquals('d1', controller.selectedSetting);
			
			// User type in new setting name and save current setting as new
			controller.newSettingName = 'd2';
			controller.saveAsNewSetting();
			System.assertEquals('d2', controller.selectedSetting);
			List<Document> docs = [select Id, Body from Document where Name = 'd2' and FolderId = :FOLDER_ERD_SETTINGS];
			
			// User delete selected setting
			controller.deleteSelectedSetting();
			System.assertEquals(null,controller.selectedSetting);
			docs = [select Id, Body from Document where Name = 'd2' and FolderId = :FOLDER_ERD_SETTINGS];
			System.assertEquals(0, docs.size());
		Test.stopTest();
	}
	
	/*
	@isTest
	static void testERDGeneratorWithoutSavedDiagrams()
	{
	 
		
	}
	*/
}