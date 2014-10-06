@isTest
private with sharing class ERDGeneratorTest
{
	@isTest
	static void ERDGeneratorTests()
	{
		ERDGenerator generator = new ERDGenerator();
		String erdOutput = generator.generateERD(null);
		System.assert(erdOutput != '');
	}
}
