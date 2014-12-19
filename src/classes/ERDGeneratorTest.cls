@isTest
private with sharing class ERDGeneratorTest
{
	/*
	@isTest
	static void testThatTemplatesGenerateExpectedOutput() {
		
		ERDGenerator generator = new ERDGenerator('DefaultTemplate'); 
		
		Map<String,List<String>> basicEntitiesWithValidAPINames = new Map<String,List<String>>{
			'Standard' => new List<String>{'Account', 'Contact'}
		};
		
		Map<String,List<String>> basicEntitiesWithInvalidAPINames = new Map<String,List<String>>{
			'Standard' => new List<String>{'account', 'contact'}
		};
		
		Test.startTest();
			String validERDOutput = generator.generateERD(basicEntitiesWithValidAPINames,false);
			String invalidERDOutput = generator.generateERD(basicEntitiesWithInvalidAPINames,false);
		Test.stopTest();
		
		System.assertNotEquals(-1, validERDOutput.indexOf('->'), 
			'There should be at least one relationship between the two entities');
		
		System.assertEquals(-1, invalidERDOutput.indexOf('->'), 
			'There should be NO relationship between the two entities because they have invalid API names');
	}*/
	
	@isTest
	static void testThatTemplatesGenerateExpectedOutput()
	{
		ERDGenerator generator = new ERDGenerator('DefaultTemplate'); 
		
		ERDSettingsV3 settings = new ERDSettingsV3();
		settings.groupToObjectsToFieldsMap = new Map<String,Map<String,List<String>>>{
			'Standard' => new Map<String,List<String>>{
				'Account' => new List<String>(),
				'Contact' => new List<String>()
			}
		};
		settings.includedGroups = new Set<String>{'Standard'};
		settings.includeFields = true;
		settings.includeStandardUserLookup = false;
		
		Test.startTest();
			String erdOutput = generator.generateERD(settings);
		Test.stopTest();
		
		System.assertNotEquals(-1, erdOutput.indexOf('->'), 
			'There should be at least one relationship between the two entities');
	}
	
	@isTest
	static void testThatTemplatesGenerateNoRelationshipWithInvalidAPINames()
	{
		ERDGenerator generator = new ERDGenerator('DefaultTemplate'); 
		
		ERDSettingsV3 settings = new ERDSettingsV3();
		settings.groupToObjectsToFieldsMap = new Map<String,Map<String,List<String>>>{
			'Standard' => new Map<String,List<String>>{
				'account' => new List<String>(),
				'contact' => new List<String>()
			}
		};
		settings.includedGroups = new Set<String>{'Standard'};
		settings.includeFields = true;
		settings.includeStandardUserLookup = false;
		
		Test.startTest();
			String erdOutput = generator.generateERD(settings);
		Test.stopTest();
		
		System.assertEquals(-1, erdOutput.indexOf('->'), 
			'There should be NO relationship between the two entities because they have invalid API names');
	}
}