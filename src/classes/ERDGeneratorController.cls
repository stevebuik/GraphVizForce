/**
* @description ERDGeneratorController
* This is the controller for visualforce page ERDGeneratorPage
* @date 21/09/2014
*/

public class ERDGeneratorController
{
	public static final String GROUP_STANDARD = 'Standard';
    public static final String GROUP_CUSTOM = 'Custom';
	
    public String newGroupName{get;set;}
    
    public list<ERDGroup> ERDGroupList{get;set;}
    
    public list<ERDEntity> selectedObjectList{get;set;}
    public String selectedGroup{get;set;}
    
    private map<String,list<String>> unSelectedGroupObjectMap{get;set;}
    private map<String,list<String>> selectedGroupObjectMap{get;set;}
    
    public List<String> selected { get; set; }
    public List<String> unselected { get; set; }
    
    public String generatedContent{get;set;}
    
    public list<SelectOption> groupSelectOptions
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
        	list<String> objectNames = ERDUtils.getAllObjectNames();
        	Set<String> unSelectedObjects = new Set<String>(objectNames);
        	Set<String> groupNameSet = selectedGroupObjectMap.keySet();
            
        	for(String groupName : groupNameSet)
        	{
        		list<String> groupObjects = selectedGroupObjectMap.get(groupName);
        		for(String groupObjName : groupObjects)
        		{
        			unSelectedObjects.remove(groupObjName);
        		}
        	}
        	
        	list<String> sorted = new list<String>(unSelectedObjects);
        	sorted.sort();
        	
        	for(String objName : sorted)
        	{
            	options.add(new SelectOption(objName, objName));
            }
            
            return options;
        }
    }


    public void doSelect()
    {
        
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