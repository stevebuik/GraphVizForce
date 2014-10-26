@isTest
public with sharing class ERDPersisterTests {

    public static final String FOLDER_ERD_SETTINGS = 'ERD Settings';

	@isTest
	private static void testUpgrade() {
		ERDPersister persister = new ERDPersister(FOLDER_ERD_SETTINGS);
		
		Map<String,List<String>> v0 = new Map<String,List<String>>{
			'Sales' => new List<String>{'Account', 'Contact'},
			'Marketing' => new List<String>{'Lead', 'Campaign'}
		};
		
		String v0Persisted = JSON.serialize(v0); 
		
		ERDSettingsV1 v1 = (ERDSettingsV1) persister.upgrade(1, v0Persisted); 		
		System.assertEquals(v0, v1.groups, 'groups should upgrade from v0 -> v1');

		ERDSettingsV2 v2 = (ERDSettingsV2) persister.upgrade(2, JSON.serialize(v1)); 		
		System.assertEquals(v0, v2.groups, 'groups should upgrade from v1 -> v2');
		System.assertEquals(false, v2.includeFields, 'fields should have correct default');

	}

	@isTest 
	private static void testRoundTrip() {

		String name1 = 'd1'; 

		ERDPersister persister = new ERDPersister(FOLDER_ERD_SETTINGS);

		Map<String,List<String>> v0 = new Map<String,List<String>>{
			'Sales' => new List<String>{'Account', 'Contact'},
			'Marketing' => new List<String>{'Lead', 'Campaign'}
			};
			
		// create fake non-versioned persisted settings		
		insert new Document(Name = name1,
			FolderId = persister.folderId,
			Body = Blob.valueOf(JSON.serialize(v0)));
	
		ERDSettingsV2 v2Retrieved = (ERDSettingsV2) persister.getSettings(name1);		
		System.assertEquals(v0, v2Retrieved.groups,
			'Groups survive the upgrade and are copied into the latest version');
		
		v2Retrieved.groups.get('Sales').add('Opportunity');
		v2Retrieved.includeFields = true;
		
		persister.saveSettings(name1, v2Retrieved);

		ERDSettingsV2 v2RetrievedAgain = (ERDSettingsV2) persister.getSettings(name1);		
		System.assertEquals(v2Retrieved.groups, v2RetrievedAgain.groups,
			'An updated diagram retrieved later matches the original');
		System.assertEquals(v2Retrieved.includeFields, v2RetrievedAgain.includeFields,
			'An updated diagram retrieved later matches the original');
		
	}
}