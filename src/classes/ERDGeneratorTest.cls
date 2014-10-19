@isTest
private with sharing class ERDGeneratorTest
{
	@isTest
	static void ERDGeneratorTests()
	{
		ERDGenerator generator = new ERDGenerator('DefaultTemplate'); 
		
		Map<String,List<String>> basicEntitiesWithValidAPINames = new Map<String,List<String>>{
			'Standard' => new List<String>{'Account', 'Contact'}
		};
		
		Map<String,List<String>> basicEntitiesWithInvalidAPINames = new Map<String,List<String>>{
			'Standard' => new List<String>{'account', 'contact'}
		};
		
		Test.startTest();
			String validERDOutput = generator.generateERD(basicEntitiesWithValidAPINames);
			String invalidERDOutput = generator.generateERD(basicEntitiesWithInvalidAPINames);
		Test.stopTest();
		
		System.assertNotEquals(-1, validERDOutput.indexOf('->'), 
			'There should be at least one relationship between the two entities');
		
		System.assertEquals(-1, validERDOutput.indexOf('->'), 
			'There should be NO relationship between the two entities because they have invalid API names');
	}
}