public class TemplateEngine {
	
	public interface TemplateSource {
		String getMain();
		String getGroup();
		String getEntity();
		String getField();
		String getRelationship();
	}

	public static final String BINDINGS = '\\{\\{([^}]*)\\}\\}';

	private final TemplateSource source;

	private final Map<TemplateType, String> templateStrings;

	public TemplateEngine(TemplateSource source) {
		templateStrings = new Map<TemplateType, String>{
			TemplateType.MAIN => source.getMain(),
			TemplateType.CLUSTER => source.getGroup(),
			TemplateType.ENTITY => source.getEntity(),
			TemplateType.RELATIONSHIP => source.getRelationship(),
			TemplateType.FIELD => source.getField()
		};
	}

	public List<String> getBindExpressions(String template) {		
        Pattern p = Pattern.compile(BINDINGS);
        Matcher m = p.matcher(template);
        List<String> results = new List<String>();
        while (m.find()) {
        	results.add(m.group());
        }
        return results;
    }

    public String applyBindings(String template, Map<String, String> data) {
    	List<String> binds = getBindExpressions(template);
		for (String bind : binds) {
			String key = bind.substring(2, bind.length()-2);
			String val = data.get(key);
		    template = template.replace(bind, val==null?'':val);
		}
		return template;
    }

    public String render(TemplateType template, Map<String, String> data) {
    	return applyBindings(templateStrings.get(template), data);
    }

    public class StaticResourceTemplateSource implements TemplateSource {

    	private final List<String> extracted = new List<String>();

    	public StaticResourceTemplateSource(String resourceName) {
    		List<StaticResource> resources = [select id, name, body from StaticResource
				where name = :resourceName];
			if (resources.size() == 1) {
				String templateStrings = resources.get(0).body.toString();
				List<String> templates = templateStrings.split('==========');
				System.debug(templates.size());
				for(String t : templates) {
					if (t.length() > 0) {
						extracted.add(t.substringAfter('\n'));
					}
				}
			} else {
				throw new ApplicationException('Resource not found: '+resourceName);
			}
    	}

 		public String getMain() {
 			return extracted.get(0);
 		}
		public String getGroup() {
 			return extracted.get(1);
 		}
		public String getEntity() {
 			return extracted.get(2);
 		}		   	
		public String getField() {
 			return extracted.get(3);
 		}		   	
 		public String getRelationship() {
 			return extracted.get(4);
 		}		   	
    }

}