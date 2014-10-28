public with sharing class ERDOauthController {

	ERDDropboxAPI api = new ERDDropboxAPI();    

    public PageReference oauthPageLoaded() {    		
    	if (api.isCallbackRequest()) {
    		api.updateTokenFromCode();
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'callback'));    			
    		return null;
    	} else if (api.areOAuthCredsPresent()) {
    		return new PageReference(api.getAuthoriseURL());
    	} else {
    		for (String e : api.errorMessages) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e));    			
    		}
    		return null;
    	}
    }
    
    public String getToken() {
    	return api.oauthToken;
    }
    
    public Boolean getIsCallbackRequest() {
    	return api.isCallbackRequest();    	    	
    }	

}