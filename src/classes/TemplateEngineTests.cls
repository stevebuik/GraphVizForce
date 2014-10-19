@isTest(seeAllData=true) // need seeAllData to query the Static Resources. Not best practice but making an exception for this test
private class TemplateEngineTests {

	@IsTest
    static void testAllResourceTemplates() {
    	// check that all supplied templates have expect bind expressions
       	for (StaticResource r : [SELECT Name FROM StaticResource]) {
       		if (r.Name.endsWith('Template')) {
		    	TemplateEngine.TemplateSource src = 
		    		new TemplateEngine.StaticResourceTemplateSource(r.Name);
		    	TemplateEngine engine = new TemplateEngine(src);
				System.assert(engine.templates.get(TemplateType.MAIN).contains('{{content}}'),
					'main template has bind expression for content');       			
				System.assert(engine.templates.get(TemplateType.CLUSTER).contains('{{content}}'),
					'cluster template should have bind expression for content');       			
				System.assert(engine.templates.get(TemplateType.ENTITY).contains('{{name}}'),
					'cluster template should have bind expression for name');       			
				System.assert(engine.templates.get(TemplateType.RELATIONSHIP).contains('{{from}}'),
					'relationship template should have bind expression for from');       			
				System.assert(engine.templates.get(TemplateType.RELATIONSHIP).contains('{{from}}'),
					'relationship template should have bind expression for to');       			
				System.assert(engine.templates.get(TemplateType.RELATIONSHIP).contains('{{from}}'),
					'relationship template should have bind expression for to');       			
				System.assert(engine.templates.get(TemplateType.FIELD).contains('{{name}}'),
					'file template should have bind expression for name');       			
       		}
       }
    }

	@IsTest
    static void testRelationshipTemplate() {
    	
    	TemplateEngine.TemplateSource src = 
    		new TemplateEngine.StaticResourceTemplateSource('DefaultTemplate');
    	TemplateEngine engine = new TemplateEngine(src);
    	
    	String rendered = engine.render(TemplateType.RELATIONSHIP, new Map<String, String>{
    		'from' 	=> 'Contact',
    		'to' 	=> 'Account'
    	});
    	
    	System.assert(rendered.contains('Contact -> Account'), 
    		'Basic relationship should render with entity names and an arrow');
    	    	
    }
}