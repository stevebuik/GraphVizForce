public class TemplateEngine {
	
	public interface TemplateSource {
		String getTemplate();
	}

	public static final String BINDINGS = '\\{\\{([^}]*)\\}\\}';

	private final Map<TemplateType, String> templates;

	public TemplateEngine(TemplateSource source) {

		List<String> templateSplit = source.getTemplate().split('==========');
		List<String> extracted = new List<String>();
		for(String t : templateSplit) {
			if (t.length() > 0) {
				extracted.add(t.substringAfter('\n'));
			}
		}

		templates = new Map<TemplateType, String>{
			TemplateType.MAIN => extracted.get(0),
			TemplateType.CLUSTER => extracted.get(1),
			TemplateType.ENTITY => extracted.get(2),
			TemplateType.RELATIONSHIP => extracted.get(3),
			TemplateType.FIELD => extracted.get(4)
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
    	return applyBindings(templates.get(template), data);
    }

    public class CalloutTemplateSource implements TemplateSource {
    	private final String url;
    	public CalloutTemplateSource(String url) {
    		this.url = url;
    	}
		public String getTemplate() {
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setEndpoint(url);
			request.setMethod('GET');
			HttpResponse response = http.send(request);
			return response.getBody();
		}
    }

    public class StaticResourceTemplateSource implements TemplateSource {

    	private final String resourceName;

    	public StaticResourceTemplateSource(String resourceName) {
    		this.resourceName = resourceName;
    	}

		public String getTemplate() {

			List<StaticResource> resources = [select id, name, body from StaticResource
				where name = :resourceName];
			if (resources.size() == 1) {
				return resources.get(0).body.toString();
			} else {
				throw new ApplicationException('Resource not found: '+resourceName);
			}
		}
    }

}