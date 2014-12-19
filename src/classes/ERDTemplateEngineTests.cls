@isTest(seeAllData=true) // need seeAllData to query the Static Resources. Not best practice but making an exception for this test
private class ERDTemplateEngineTests {
    
    private static void checkTemplateContains(ERDTemplateEngine engine, ERDTemplateType templateType, String bind) {
        System.assert(engine.templates.get(templateType).contains('{{'+bind+'}}'),
            templateType+' template has bind expression for '+bind);                
    }

    @IsTest
    static void testAllResourceTemplates() {
        // check that all supplied templates have expect bind expressions
        for (StaticResource r : [SELECT Name FROM StaticResource]) {
            if (r.Name.endsWith('Template')) {
                ERDTemplateEngine.TemplateSource src = 
                    new ERDTemplateEngine.StaticResourceTemplateSource(r.Name);
                ERDTemplateEngine engine = new ERDTemplateEngine(src);
                checkTemplateContains(engine, ERDTemplateType.MAIN, 'content');                 
                checkTemplateContains(engine, ERDTemplateType.ENTITY, 'name');                  
                checkTemplateContains(engine, ERDTemplateType.CLUSTER, 'content');                  
                checkTemplateContains(engine, ERDTemplateType.MD_RELATIONSHIP, 'from');                  
                checkTemplateContains(engine, ERDTemplateType.MD_RELATIONSHIP, 'to');                  
                checkTemplateContains(engine, ERDTemplateType.LOOKUP_RELATIONSHIP, 'from');                
                checkTemplateContains(engine, ERDTemplateType.LOOKUP_RELATIONSHIP, 'to');                  
                checkTemplateContains(engine, ERDTemplateType.FIELD, 'name');                   
            }
       }
    }

    @IsTest
    static void testRelationshipTemplate() {
        
        ERDTemplateEngine.TemplateSource src = 
            new ERDTemplateEngine.StaticResourceTemplateSource('DefaultTemplate');
        ERDTemplateEngine engine = new ERDTemplateEngine(src);
        
        String rendered = engine.render(ERDTemplateType.MD_RELATIONSHIP, new Map<String, String>{
            'from'  => 'Contact',
            'to'    => 'Account'
        });
        
        
        System.assert(rendered.contains('Contact -> Account'), 
            'Basic relationship should render with entity names and an arrow');
        
        rendered = engine.render(ERDTemplateType.LOOKUP_RELATIONSHIP, new Map<String, String>{
            'from'  => 'Contact',
            'to'    => 'Account'
        });
        
        System.assert(rendered.contains('Contact -> Account'), 
            'Basic relationship should render with entity names and an arrow');
                
    }
}