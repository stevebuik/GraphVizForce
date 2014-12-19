public class ERDTemplateEngine {
    
    public interface TemplateSource {
        String getTemplate();
    }

    public static final String BINDINGS = '\\{\\{([^}]*)\\}\\}';

    public final Map<ERDTemplateType, String> templates;

    public ERDTemplateEngine(TemplateSource source) {

        List<String> templateSplit = source.getTemplate().split('==========');
        List<String> extracted = new List<String>();
        for(String t : templateSplit) {
            if (t.length() > 0) {
                extracted.add(t.substringAfter('\n'));
            }
        }

        templates = new Map<ERDTemplateType, String>{
            ERDTemplateType.MAIN => extracted.get(0),
            ERDTemplateType.CLUSTER => extracted.get(1),
            ERDTemplateType.ENTITY => extracted.get(2),
            ERDTemplateType.MD_RELATIONSHIP => extracted.get(3),
            ERDTemplateType.LOOKUP_RELATIONSHIP => extracted.get(4),
            ERDTemplateType.FIELD => extracted.get(5)
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
        System.debug(LoggingLevel.ERROR, '====> template:' + template);
        List<String> binds = getBindExpressions(template);
        System.debug(LoggingLevel.ERROR, '====> binds:' + binds);
        for (String bind : binds) {
            String key = bind.substring(2, bind.length()-2);
            String val = data.get(key);
            System.debug(LoggingLevel.ERROR, '====> key:' + key);
            System.debug(LoggingLevel.ERROR, '====> val:' + val);
            template = template.replace(bind, val==null?'':val);
        }
        return template;
    }

    public String render(ERDTemplateType template, Map<String, String> data) {
        
        System.debug(LoggingLevel.ERROR, '====> template type:' + template);
        System.debug(LoggingLevel.ERROR, '====> data:' + data);
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
        	if (resourceName == null) {
                throw new ERDException('Resource name not present');
        	}
            this.resourceName = resourceName;
        }

        public String getTemplate() {

            List<StaticResource> resources = [select id, name, body from StaticResource
                where name = :resourceName];
            if (resources.size() == 1) {
                return resources.get(0).body.toString();
            } else {
                throw new ERDException('Resource not found: '+resourceName);
            }
        }
    }

}