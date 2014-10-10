/**
* @description ERDGeneratorController
* This is the controller for visualforce page ERDGeneratorPage
* @date 21/09/2014
*/

public class ERDGeneratorController
{
	public static final String GROUP_STANDARD = 'Standard';
    public static final String GROUP_CUSTOM = 'Custom';
    public static final String FOLDER_ERD_SETTINGS = 'ERD Settings';
	
    public String newGroupName{get;set;}
    public String selectedGroup{get;set;}
    
    public String currentSetting{
    	get {
    		if (currentSetting == null) {
    			currentSetting = '<New Diagram>';
    		}
    		return currentSetting;
    	}
    	set;}
    public String newSettingName{get;set;}
    public String selectedSetting{get;set;}
    public String generatedContent{get;set;}
    
    public list<ERDGroup> ERDGroupList{get;set;}
    public list<ERDEntity> selectedObjectList{get;set;}
    
    public List<String> selected { get; set; }
    public List<String> unselected { get; set; }
    
    private map<String,list<String>> selectedGroupObjectMap{get;set;}
    
    private ERDPersister persister;
    
    
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
    
    public list<SelectOption> settingSelectOptions
    {
    	get
    	{
            list<SelectOption> options = new list<SelectOption>();
            list<String> settingNames;
            
            if(persister != null)
            {
            	settingNames = persister.getDiagramNameList();
            }
            
            if(settingNames != null)
    		{
    			settingNames.sort();
    			for(String setting : settingNames)
    			{
					SelectOption option = new SelectOption(setting,setting);
					options.add(option);
    			}
    		}
            
            return options;
    	}
    }
    
    public map<String,list<String>> filteredSelectedGroupObjectMap
    {
    	get
    	{
    		map<String,list<String>> filteredMap = new map<String,list<String>>();
    		for(String grp : selectedGroupObjectMap.keySet())
    		{
    			for(ERDGroup erdGroup : ERDGroupList)
    			{
    				if(erdGroup.groupName == grp && erdGroup.selected == true)
    				{
    					filteredMap.put(grp,selectedGroupObjectMap.get(grp));
    				}
    			}
    		}
    		
    		return filteredMap;
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
    	    	
    	ERDGroup standardGroup = createERDGroup(ERDGeneratorController.GROUP_STANDARD,true);
    	ERDGroup customGroup = createERDGroup(ERDGeneratorController.GROUP_CUSTOM,true);
    	
        ERDGroupList.add(customGroup);
        ERDGroupList.add(standardGroup);
        
        selectedGroup = customGroup.groupName;
        
        selectedGroupObjectMap = new map<String,list<String>>();
        
        initERDPersister();
    }
    
    private void initERDPersister()
    {
    	persister = new ERDPersister(FOLDER_ERD_SETTINGS);
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
    
    public void loadSelectedSetting()
    {
    	if(String.isBlank(selectedSetting))
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
    		return;
    	}
    	
    	currentSetting = selectedSetting;
    	
    	// Apply map to selectedGroupObjectMap
    	selectedGroupObjectMap = persister.getDiagram(selectedSetting);
    	
    	// Apply map to ERDGroupList
    	ERDGroupList = new list<ERDGroup>();
    	list<String> groups = new list<String>(selectedGroupObjectMap.keySet());
    	
    	if(!groups.isEmpty())
    	{
	    	groups.sort();
	    	for(String grp : groups)
	    	{
	    		ERDGroup erdGroup = createERDGroup(grp,true);
		        ERDGroupList.add(erdGroup);
	    	}
	    	
	    	selectedGroup = ERDGroupList[0].groupName;
    	}
    	else
    	{
    		selectedGroup = null;
    	}
    }
    
    public void saveSelectedSetting()
    {
    	if(String.isBlank(selectedSetting))
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
    		return;
    	}
    	
    	if(filteredSelectedGroupObjectMap.size() == 0)
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please add objects to some groups'));
    		return;
    	}
    	
    	persister.saveDiagram(selectedSetting, filteredSelectedGroupObjectMap);
    	
    	currentSetting = selectedSetting;
    }
    
    public void saveAsNewSetting()
    {
    	if(String.isBlank(newSettingName))
    	{
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter setting name'));
    		return;
    	}
    	
    	persister.saveDiagram(newSettingName, filteredSelectedGroupObjectMap);
    	
    	currentSetting = selectedSetting;
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
        
        if(!selected.isEmpty() && !String.isBlank(selectedGroup))
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
        
        if(!unselected.isEmpty() && !String.isBlank(selectedGroup))
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
    
    public void generateERD()
    {
        ERDGenerator generator = new ERDGenerator();
		generatedContent = generator.generateERD(filteredSelectedGroupObjectMap);
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