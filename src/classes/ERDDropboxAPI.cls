public class ERDDropboxAPI {

	public String key {get;set;}
	public String secret {get;set;}
	public String oauthToken {get;set;}
	
	public List<String> errorMessages{
		get {
			if (errorMessages == null) {
				errorMessages = new List<String>();
			}
			return errorMessages; 
		}
		set;
	}

	public ERDDropboxAPI() {
    	ERD__c oauthKey = ERD__c.getInstance('DropboxClientKey');
    	ERD__c oauthSecret = ERD__c.getInstance('DropboxClientSecret');
    	if (oauthKey == null || oauthSecret == null) {
    		if (oauthKey == null) {
	    		errorMessages.add('"DropboxClientKey" setting not present.');
    		}
    		if (oauthSecret == null) {
	    		errorMessages.add('"DropboxClientSecret" setting not present.');
    		}
    		errorMessages.add('Please configure a Dropbox application first.');
    		errorMessages.add('See help for more info.');
    	} else {
			this.key = oauthKey.Value__c;
			this.secret = oauthSecret.Value__c;
    	}
	}
	
	public Boolean isCallbackRequest() {
		return !ApexPages.currentPage().getParameters().containsKey('start');
	}
	
	public String getCallbackURL() {
		return 'https://'+System.URL.getSalesforceBaseUrl().getHost()+Page.ERDOauth.getURL();
	}
	
	public void updateTokenFromCode() {
		String code = ApexPages.currentPage().getParameters().get('code');
		if (code != null) {
			Http http = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint('https://api.dropbox.com/1/oauth2/token'); 
			req.setMethod('POST');
			req.setBody('code=' + code + '&grant_type=authorization_code&client_id='+key+'&client_secret='+secret+'&redirect_uri='+getCallbackURL());
			req.setHeader('Content-Type','application/x-www-form-urlencoded');
			String response = http.send(req).getBody();
			Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
			oauthToken = (String) responseMap.get('access_token');
		}
	}
	
	public String getAuthoriseURL() {
		String url = 'https://www.dropbox.com/1/oauth2/authorize';
		url += '?client_id='+key;
		url += '&response_type=code';
		url += '&redirect_uri='+getCallbackURL();
		return url;
	}
	
	public String writeFile(String file, String contents) {
		String filePathEncoded = EncodingUtil.urlEncode(file, 'UTF-8');
		String putFileURL = 'https://api-content.dropbox.com/1/files_put/auto/'+filePathEncoded;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(putFileURL);
		request.setMethod('PUT');
		request.setBody(contents);
		request.setHeader('Authorization', 'Bearer ' + oauthToken);
		HttpResponse response = http.send(request);
		return response.toString();
	}

}