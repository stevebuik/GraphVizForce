/**
* @description ERDGeneratorController
* This is the controller for visualforce page ERDGeneratorPage
* @author Zhiren Guan
* @date 21/09/2014
*/

public class ERDGeneratorController
{
	public static final String GROUP_STANDARD = 'Standard';
    public static final String GROUP_CUSTOM = 'Custom';
    public static final list<String> AVAILABLE_OBJECTS = new List<String>{'Salary__c',
    													'Job_Application__c',
    													'Offer__c',
    													'Review__c',
    													'Candidate_Snapshot__c',
    													'Programming_Language__c',
    													'Position_Programming_Language__c',
    													'Zip_Code__c',
    													'Job_Posting_Site__c',
    													'Job_Posting__c',
    													'Interviewer__c',
    													'Position__c',
    													'Search_Config__c',
    													'Candidate__c',
    													'Position_Approval_Matrix__c',
    													'Error_Log__c'
    													};
	
    public String newGroupName{get;set;}
    
    public list<ERDGroup> ERDGroupList{get;set;}
    
    public list<ERDEntity> selectedObjectList{get;set;}
    public String selectedGroup{get;set;}
    
    //private Set<String> unSelectedNames;
    //private Set<String> selectedNames;
    
    private map<String,list<String>> unSelectedGroupObjectMap{get;set;}
    private map<String,list<String>> selectedGroupObjectMap{get;set;}
    
    public List<String> selected { get; set; }
    public List<String> unselected { get; set; }
    
    public String generatedContent{get;set;}
    
    public list<SelectOption> groupSelectOptions//{get;set;}
    {
    	get
    	{
            List<SelectOption> options = new List<SelectOption>();
            
            if(ERDGroupList != null)
    		{
    			for(ERDGroup gp : ERDGroupList)
    			{
    				if(gp.selected)
    				{
    					SelectOption option = new SelectOption(gp.groupName,gp.groupName);
    					options.add(option);
    				}
    			}
    		}
            
            return options;
    	}
    }
    
    
	public ERDGeneratorController()
    {
    	init();
    }
    
    /**
    * @description Initialise visualforce page
    */
    private void init()
    {
    	if(ERDGroupList == null)
    	{
    		ERDGroupList = new list<ERDGroup>();
    	}
    	
    	/*
    	if(groupSelectOptions == null)
    	{
    		groupSelectOptions = new list<SelectOption>();
    	}
    	*/
    	
    	ERDGroup standardGroup = createERDGroup(ERDGeneratorController.GROUP_STANDARD,false);
    	ERDGroup customGroup = createERDGroup(ERDGeneratorController.GROUP_CUSTOM,true);
    	
        ERDGroupList.add(standardGroup);
        ERDGroupList.add(customGroup);
        
        unSelectedGroupObjectMap = new map<String,list<String>>();
        selectedGroupObjectMap = new map<String,list<String>>();
    }
    
    public void addNewGroupWithInput()
    {
    	if(String.isNotBlank(newGroupName))
    	{
    		addERDGroup(newGroupName);
    	}
    	
    	//return null;
    }
    
    public ERDGroup addERDGroup(String groupName)
    {
        if(ERDGroupList == null)
        {
        	ERDGroupList = new list<ERDGroup>();
        }
        
        ERDGroup newGroup = createERDGroup(groupName,true);
        ERDGroupList.add(newGroup);
        
        return newGroup;
    }
    
    /**
    * Multi Picklist
    */
    public List<SelectOption> selectedOptions
    { 
        get
        {
        	list<String> sorted = new list<String>();
        	
        	if(selectedGroupObjectMap.containsKey(selectedGroup))
        	{
        		sorted = selectedGroupObjectMap.get(selectedGroup);
        	}
        	else
        	{
        		selectedGroupObjectMap.put(selectedGroup,sorted);
        	}
        	
            sorted.sort();
            List<SelectOption> options = new List<SelectOption>();
            for (String s: sorted)
            {
                options.add(new SelectOption(s, s));
            }
            return options;
        }
    }
    
    public List<SelectOption> unSelectedOptions
    { 
        get
        {
        	List<SelectOption> options = new List<SelectOption>();
        	Set<String> unSelectedObjects = new Set<String>(AVAILABLE_OBJECTS);
        	Set<String> groupNameSet = selectedGroupObjectMap.keySet();
            
        	for(String groupName : groupNameSet)
        	{
        		list<String> groupObjects = selectedGroupObjectMap.get(groupName);
        		for(String groupObjName : groupObjects)
        		{
        			unSelectedObjects.remove(groupObjName);
        		}
        	}
        	
        	for(String objName : unSelectedObjects)
        	{
            	options.add(new SelectOption(objName, objName));
            }
            return options;
        }
    }


    public void doSelect()
    {
    	/*
        for (String s: selected)
        {
            selectedNames.add(s);
            unselectedNames.remove(s);
        }
        */
        
        if(!selected.isEmpty())
        {
	        list<String> selectedNames = new list<String>();
	        
	        if(selectedGroupObjectMap.containsKey(selectedGroup))
	    	{
	    		selectedNames = selectedGroupObjectMap.get(selectedGroup);
	    	}
	    	else
	    	{
	    		selectedGroupObjectMap.put(selectedGroup,selectedNames);
	    	}
	        
	        for(String s: selected)
	        {
	        	selectedNames.add(s);
	        }
        }
    }

    public void doUnSelect()
    {
    	/*
        for (String s: unselected)
        {
            unSelectedNames.add(s);
            selectedNames.remove(s);
        }
        */
        
        if(!unselected.isEmpty())
        {
	        Set<String> selectedNames;
	        
	        if(selectedGroupObjectMap.containsKey(selectedGroup))
	    	{
	    		selectedNames = new Set<String>(selectedGroupObjectMap.get(selectedGroup));
	    	}
	        
	        if(selectedNames != null)
			{
		        for(String s: unselected)
		        {
		        	selectedNames.remove(s);
		        }
			}
			
			selectedGroupObjectMap.put(selectedGroup,new list<String>(selectedNames));
        }
    }
    
    /* TODO: Generate Content only for selected groups, currently picking up unselected groups */
    public void generateERD()
    {
        ERDGenerator generator = new ERDGenerator();
		generatedContent = generator.generateERD(selectedGroupObjectMap);
    }
    
    
    public static ERDGroup createERDGroup(String groupName, Boolean selected)
    {
    	ERDGroup newGroup = new ERDGroup();
    	newGroup.groupName = groupName;
        newGroup.selected = selected;
        
        return newGroup;
    }
    
    /**
    * @description Group inner class for front end
    */
    public class ERDGroup
    {
    	public String groupName {get;set;}
    	public Boolean selected {get;set;}
    }
    
}