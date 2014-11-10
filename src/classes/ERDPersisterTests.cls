@isTest
public with sharing class ERDPersisterTests {


	@isTest
	private static void testUpgrade() {
		ERDPersister persister = new ERDPersister();
		
		Map<String,List<String>> v0 = new Map<String,List<String>>{
			'Sales' => new List<String>{'Account', 'Contact'},
			'Marketing' => new List<String>{'Lead', 'Campaign'}
		};
		
		String v0Persisted = JSON.serialize(v0); 
		
		Test.startTest();
			// Test upgrade to v1
			ERDSettingsV1 v1 = (ERDSettingsV1) persister.upgrade(1, v0Persisted); 		
			System.assertEquals(v0, v1.groups, 'groups should upgrade from v0 -> v1');
			
			// Test upgrade to v2
			ERDSettingsV2 v2 = (ERDSettingsV2) persister.upgrade(2, JSON.serialize(v1)); 		
			System.assertEquals(v0, v2.groups, 'groups should upgrade from v1 -> v2');
			System.assertEquals(false, v2.includeFields, 'fields should have correct default');
			
			// Test upgrade to v3
			Map<String,Map<String,List<String>>> v3Map = new Map<String,Map<String,List<String>>>{
				'Sales' => new Map<String, List<String>>
							{
								'Account' => new List<String>(),
								'Contact' => new List<String>()
							},
				'Marketing' => new Map<String, List<String>>
							{
								'Lead' => new List<String>(),
								'Campaign' => new List<String>()
							}
			};
			Set<String> v3IncludedGroups = v2.groups.keySet();
			ERDSettingsv3 v3 = (ERDSettingsV3) persister.upgrade(3, JSON.serialize(v2));
		Test.stopTest();
			
		System.assertEquals(v3Map, v3.groupToObjectsToFieldsMap, 'groupToObjectsToFieldsMap should be constructed from v2.groups');
		System.assertEquals(v3IncludedGroups, v3.includedGroups, 'includedGroups should contains all groups from v2');
		System.assertEquals(false, v3.includeFields, 'fields should have correct default');
	}

	@isTest 
	private static void testRoundTrip() {

		String name1 = 'd1'; 

		ERDPersister persister = new ERDPersister();

		Map<String,List<String>> v0 = new Map<String,List<String>>{
			'Sales' => new List<String>{'Account', 'Contact'},
			'Marketing' => new List<String>{'Lead', 'Campaign'}
			};
			
		// create fake non-versioned persisted settings		
		insert new Document(Name = name1,
			FolderId = persister.folderId,
			Body = Blob.valueOf(JSON.serialize(v0)));
	
		// Test ERDSettingsV2
		Test.startTest();
			ERDSettingsV2 v2Retrieved = (ERDSettingsV2) persister.getSettings(name1,2);		
			System.assertEquals(v0, v2Retrieved.groups,
				'Groups survive the upgrade and are copied into the latest version');
			
			v2Retrieved.groups.get('Sales').add('Opportunity');
			v2Retrieved.includeFields = true;
			
			persister.saveSettings(name1, v2Retrieved);
	
			ERDSettingsV2 v2RetrievedAgain = (ERDSettingsV2) persister.getSettings(name1,2);		
			System.assertEquals(v2Retrieved.groups, v2RetrievedAgain.groups,
				'An updated diagram retrieved later matches the original');
			System.assertEquals(v2Retrieved.includeFields, v2RetrievedAgain.includeFields,
				'An updated diagram retrieved later matches the original');
			
			
			// Test ERDSettingsV3
			Map<String,Map<String,List<String>>> v3MapToTest = new Map<String,Map<String,List<String>>>{
				'Sales' => new Map<String, List<String>>
							{
								'Account' => new List<String>(),
								'Contact' => new List<String>(),
								'Opportunity' => new List<String>()
							},
				'Marketing' => new Map<String, List<String>>
							{
								'Lead' => new List<String>(),
								'Campaign' => new List<String>()
							}
			};
			
			ERDSettingsV3 v3Retrieved = (ERDSettingsV3) persister.getSettings(name1);
			System.assertEquals(v3MapToTest, v3Retrieved.groupToObjectsToFieldsMap,'Groups survive the upgrade and are copied into the latest version');
			v3Retrieved.groupToObjectsToFieldsMap.put('Finance', new Map<String, List<String>>());
			v3Retrieved.groupToObjectsToFieldsMap.get('Sales').put('Opportunity',new List<String>());
			v3Retrieved.groupToObjectsToFieldsMap.get('Sales').get('Account').add('Name');
			v3Retrieved.includedGroups = new Set<String>();
			v3Retrieved.includedGroups.add('Finance');
			v3Retrieved.includeFields = true;
			
			persister.saveSettings(name1, v3Retrieved);
			
			ERDSettingsV3 v3RetrievedAgain = (ERDSettingsV3) persister.getSettings(name1);
			System.assertEquals(v3Retrieved.groupToObjectsToFieldsMap, v3RetrievedAgain.groupToObjectsToFieldsMap, 'An updated diagram retrieved later matches the original');
			System.assertEquals(v3Retrieved.includedGroups, v3RetrievedAgain.includedGroups, 'An updated diagram retrieved later matches the original');
			System.assertEquals(v3Retrieved.includeFields, v3RetrievedAgain.includeFields, 'An updated diagram retrieved later matches the original');
			
		Test.stopTest();
	}
}