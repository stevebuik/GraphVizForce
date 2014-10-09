@isTest
public with sharing class ERDPersisterTests {

	@isTest
	private static void testRoundTrip() {

		String name1 = 'd1'; 

		ERDPersister persister = new ERDPersister('ER Diagrams');

		Map<String,List<String>> diagram1 = new Map<String,List<String>>{
			'Sales' => new List<String>{'Account', 'Contact'},
			'Marketing' => new List<String>{'Lead', 'Campaign'}
			};
	
		persister.saveDiagram(name1, diagram1);

		Map<String,List<String>> diagram1Retrieved = persister.getDiagram(name1);		
		System.assertEquals(diagram1, diagram1Retrieved);
		
		diagram1.get('Sales').add('Opportunity');
		
		persister.saveDiagram(name1, diagram1);

		diagram1Retrieved = persister.getDiagram(name1);		
		System.assertEquals(diagram1, diagram1Retrieved);
		
	}

}