/*
Name: ERDGeneratorTest
Purpose: 
This class is to test ERDGeneration related class methods

Version		Author			Date		Details				Feature
1.0			Jason Guan		15/06/2014	Initial Creation	
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