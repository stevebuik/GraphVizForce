@isTest
private with sharing class ERDGeneratorTest
{
	@isTest
	static void ERDGeneratorTests()
	{
		ERDGenerator generator = new ERDGenerator('DefaultTemplate'); 
		
		Map<String,List<String>> basicEntities = new Map<String,List<String>>{
			'Standard' => new List<String>{'account', 'contact'}
		};
		String erdOutput = generator.generateERD(basicEntities);
		
		System.debug(erdOutput);
		
		System.assertNotEquals(-1, erdOutput.indexOf('->'), 
			'There should be at least one relationship between the two entities');
	}
}