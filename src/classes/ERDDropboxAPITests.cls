@isTest
private class ERDDropboxAPITests {

	private static final String FAKE_OAUTH_TOKEN = 'foobar';

	@IsTest
    static void writeFile() {
    	Test.setMock(HttpCalloutMock.class, new MockDropboxFileWriteService());
    	ERDDropboxAPI api = new ERDDropboxAPI();
    	String response = api.writeFile('fakefile.txt','<some>fake generated content<some>');  
    	System.assert(response.contains('200'), 
    		'The response from Dropbox contained http OK');
    }

	public class MockDropboxFileWriteService implements HttpCalloutMock {
	    public HTTPResponse respond(HTTPRequest req) {
	        System.assert(req.getEndpoint().startsWith(ERDDropboxAPI.DROPBOX_CONTENT_ENDPOINT),
	        	'correct Dropbox endpoint is called for file write');
	        System.assertEquals('PUT', req.getMethod(),
	        	'file write is always a PUT to allow large files to be written');
	        
	        // Create a fake write confirmation response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"success": true}');
	        res.setStatusCode(200);
	        return res;
	    }
	}

	@IsTest
    static void tokenCallback() {
    	Test.setMock(HttpCalloutMock.class, new MockDropboxTokenService());
    	ERDDropboxAPI api = new ERDDropboxAPI();
        ApexPages.currentPage().getParameters().put('code', 'abc123');
    	api.updateTokenFromCode();    	
    	System.assertEquals(FAKE_OAUTH_TOKEN, api.oauthToken, 
    		'The code is correctly read from the url and translated into a token');
    }

	public class MockDropboxTokenService implements HttpCalloutMock {
	    public HTTPResponse respond(HTTPRequest req) {
	        System.assertEquals(ERDDropboxAPI.DROPBOX_TOKEN_ENDPOINT, req.getEndpoint(),
	        	'correct Dropbox endpoint is called for token exchange');
	        System.assertEquals('POST', req.getMethod(),
	        	'token exchange is always a POST for max security');
	        
	        // Create a fake token response
	        HttpResponse res = new HttpResponse();
	        res.setHeader('Content-Type', 'application/json');
	        res.setBody('{"access_token":"'+FAKE_OAUTH_TOKEN+'"}');
	        res.setStatusCode(200);
	        return res;
	    }
	}

	@IsTest
    static void oauthCallbackURL() {
    	ERDDropboxAPI api = new ERDDropboxAPI();
    	String url = api.getCallbackURL();    	
    	System.assert(url.endsWith(Page.ERDOauth.getUrl()), 
    		'The callback url is the oauth VF page');
    }

	@IsTest
    static void authoriseURL() {
    	ERDDropboxAPI api = new ERDDropboxAPI();
    	String url = api.getAuthoriseURL();    	
    	System.assert(url.startsWith(ERDDropboxAPI.DROPBOX_AUTH_ENDPOINT), 
    		'The initial oauth dance url is uses the correct dropbox oauth url');
    }

	@IsTest
    static void oauthDanceStartDetection() {
    	ERDDropboxAPI api = new ERDDropboxAPI();    	
    	System.assertEquals(true, api.isCallbackRequest(), 
    		'Normal http requests are considered callbacks');
    	
        ApexPages.currentPage().getParameters().put('start', '1');
    	System.assertEquals(false, api.isCallbackRequest(), 
    		'Start http requests are detected based on the start param');
    }
    
	@IsTest
    static void credentialsPresenceCheck() {
    	ERDDropboxAPI api = new ERDDropboxAPI();    	
    	System.assertEquals(false, api.areOAuthCredsPresent(), 
    		'Not present with no settings');
    	
    	ERD__c appKey = new ERD__c(Name = 'DropboxClientKey', Value__c = 'xxxx');
    	insert appKey;     	
    	api = new ERDDropboxAPI();    	
    	System.assertEquals(false, api.areOAuthCredsPresent(), 
    		'Not present with key only');
    	
    	ERD__c appSecret = new ERD__c(Name = 'DropboxClientSecret', Value__c = 'xxxx');
    	insert appSecret;     	
    	api = new ERDDropboxAPI();    	
    	System.assertEquals(true, api.areOAuthCredsPresent(), 
    		'Present with both settings');
    	
    }
}