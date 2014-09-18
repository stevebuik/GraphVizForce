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

    public class StaticTemplateSource implements TemplateSource {
 		public String getMain() {
 			return 'digraph G { splines=ortho; graph [rankdir = "LR";]; node [fontsize = "14";shape = "record";]; edge [arrowhead="crow";];\n {{content}}\n}\n';
 		}
		public String getGroup() {
			return '\nsubgraph cluster_{{sequence}} { label = "{{name}}"; \n{{content}}}\n';
 		}
		public String getEntity() {
 			return '{{name}} [label = " {{name}} "];\n';
 		}		   	
		public String getField() {
 			return '{{name}}';
 		}		   	
 		public String getRelationship() {
 			return '{{from}} -> {{to}}\n';
 		}		   	
    }
}