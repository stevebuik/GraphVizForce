@isTest(seeAllData=true) // need seeAllData to query the Static Resources. Not best practice but making an exception for this test
private class TemplateEngineTests {
	
	private static void checkTemplateContains(TemplateEngine engine, TemplateType templateType, String bind) {
		System.assert(engine.templates.get(templateType).contains('{{'+bind+'}}'),
			templateType+' template has bind expression for '+bind);       			
	}

	@IsTest
    static void testAllResourceTemplates() {
    	// check that all supplied templates have expect bind expressions
       	for (StaticResource r : [SELECT Name FROM StaticResource]) {
       		if (r.Name.endsWith('Template')) {
		    	TemplateEngine.TemplateSource src = 
		    		new TemplateEngine.StaticResourceTemplateSource(r.Name);
		    	TemplateEngine engine = new TemplateEngine(src);
		    	checkTemplateContains(engine, TemplateType.MAIN, 'content');       			
		    	checkTemplateContains(engine, TemplateType.ENTITY, 'name');       			
		    	checkTemplateContains(engine, TemplateType.CLUSTER, 'content');       			
		    	checkTemplateContains(engine, TemplateType.RELATIONSHIP, 'from');       			
		    	checkTemplateContains(engine, TemplateType.RELATIONSHIP, 'to');       			
		    	checkTemplateContains(engine, TemplateType.FIELD, 'name');       			
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