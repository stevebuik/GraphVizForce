/**
* @description ERDGeneratorController
* This is the controller for visualforce page ERDGeneratorPage
* @date 21/09/2014
*/

public class ERDGeneratorController
{
    public static final String EXTERNAL_TEMPLATE = 'CalloutTemplate';
    
    public static final String GROUP_STANDARD = 'Standard';
    public static final String GROUP_CUSTOM = 'Custom';
    public static final String FOLDER_ERD_SETTINGS = 'ERD Settings';
    
    public List<String> allObjectNames{get;set;}
    public String newGroupName{get;set;}
    public String selectedGroup{get;set;}
    public String groupToDelete{get;set;}
    public Boolean includeFields{get;set;}
    
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

    public String template{get;set;}
    public String fileURL{get;set;}
    
    public String oauthToken{get;set;}
    
    public List<ERDGroup> ERDGroupList{get;set;}
    public List<ERDEntity> selectedObjectList{get;set;}
    
    public List<String> selected { get; set; }
    public List<String> unselected { get; set; }
    
    private ERDSettingsV2 settings{get;set;}
    
    private ERDPersister persister;
    private List<String> settingNamesList;
    
    public List<SelectOption> settingSelectOptions
    {
        get
        {
            List<SelectOption> options = new List<SelectOption>();
            
            if(settingNamesList != null && !settingNamesList.isEmpty())
            {
                settingNamesList.sort();
                for(String setting : settingNamesList)
                {
                    SelectOption option = new SelectOption(setting,setting);
                    options.add(option);
                }
            }
            
            return options;
        }
    }
    
    public Map<String,List<String>> filteredSelectedGroupObjectMap
    {
        get
        {
            Map<String,List<String>> filteredMap = new Map<String,List<String>>();
            for(String grp : settings.groups.keySet())
            {
                for(ERDGroup erdGroup : ERDGroupList)
                {
                    if(erdGroup.groupName == grp && erdGroup.selected == true)
                    {
                        filteredMap.put(grp,settings.groups.get(grp));
                    }
                }
            }
            
            return filteredMap;
        }
    }
    
    public ERDGeneratorController() {
        if(ERDGroupList == null)
        {
            ERDGroupList = new List<ERDGroup>();
        }
                
        ERDGroup standardGroup = createERDGroup(ERDGeneratorController.GROUP_STANDARD,true);
        ERDGroup customGroup = createERDGroup(ERDGeneratorController.GROUP_CUSTOM,true);
        
        ERDGroupList.add(customGroup);
        ERDGroupList.add(standardGroup);
        
        selectedGroup = customGroup.groupName;
                
        initERDPersister();    
    }
        
    private void initERDPersister() {
    	
        persister = new ERDPersister(FOLDER_ERD_SETTINGS);
        
        // Load first setting if setting List is not empty
        settingNamesList = persister.getSettingsNameList();
        if(!settingNamesList.isEmpty())
        {
            settingNamesList.sort();
            selectedSetting = settingNamesList[0];
            currentSetting = selectedSetting;
            
            loadSelectedSetting();
        }
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
            ERDGroupList = new List<ERDGroup>();
        }
        
        ERDGroup newGroup = createERDGroup(groupName,true);
        ERDGroupList.add(newGroup);
        
        return newGroup;
    }
    
    public void deleteERDGroup()
    {
        Integer index = getERDGroupIndex(groupToDelete, ERDGroupList);
        if(index != -1)
        {
            ERDGroupList.remove(index);
            settings.groups.remove(selectedGroup);
            selectedGroup = null;
        }
    }
    
    private Integer getERDGroupIndex(String groupName, List<ERDGroup> groups)
    {
        if(groups != null)
        {
            for(Integer i=0;i<groups.size();i++)
            {
                ERDGroup grp = groups[i];
                if(grp.groupName == groupName)
                {
                    return i;
                }
            }
        }
        
        return -1;
    }
    
    public void loadSelectedSetting()
    {
        if(String.isBlank(selectedSetting))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
            return;
        }
        
        currentSetting = selectedSetting;
        
        // Apply Map to selectedGroupObjectMap
        settings = (ERDSettingsV2) persister.getSettings(selectedSetting);
        
        // Apply Map to ERDGroupList
        ERDGroupList = new List<ERDGroup>();
        List<String> groups = new List<String>(settings.groups.keySet());
        
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
    
    public void deleteSelectedSetting()
    {
        if(String.isBlank(selectedSetting))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
            return;
        }
        
        Integer index = ListUtils.getStringItemIndex(selectedSetting,settingNamesList);
        
        if(index != -1)
        {
            settingNamesList.remove(index);
            persister.deleteSettings(selectedSetting);
        }
        
        selectedSetting = null;
        currentSetting = null;
        selectedGroup = null;
        ERDGroupList = null;
        
        
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
        
        settings.groups = filteredSelectedGroupObjectMap;
        persister.saveSettings(selectedSetting, settings);
        
        currentSetting = selectedSetting;
    }
    
    public void saveAsNewSetting()
    {
        if(String.isBlank(newSettingName))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter setting name'));
            return;
        }
        
        settings.groups = filteredSelectedGroupObjectMap;
        persister.saveSettings(newSettingName, settings);
        
        selectedSetting = newSettingName;
        currentSetting = selectedSetting;
        
        if(ListUtils.getStringItemIndex(newSettingName,settingNamesList) == -1)
        {
            settingNamesList.add(newSettingName);
        }
    }
    
    /**
    * Multi PickList
    */
    public List<SelectOption> selectedOptions
    { 
        get
        {
            List<String> sorted = new List<String>();
            
            if(settings.groups.containsKey(selectedGroup))
            {
                sorted = settings.groups.get(selectedGroup);
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
            if(allObjectNames == null)
            {
                allObjectNames = ERDUtils.getAllObjectNames();
            }
            
            List<SelectOption> options = new List<SelectOption>();
            Set<String> unSelectedObjects = new Set<String>(allObjectNames);
            Set<String> groupNameSet = settings.groups.keySet();
            
            for(String groupName : groupNameSet)
            {
                List<String> groupObjects = settings.groups.get(groupName);
                for(String groupObjName : groupObjects)
                {
                    unSelectedObjects.remove(groupObjName);
                }
            }
            
            List<String> sorted = new List<String>(unSelectedObjects);
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
            List<String> selectedNames = new List<String>();
            
            if(settings.groups.containsKey(selectedGroup))
            {
                selectedNames = settings.groups.get(selectedGroup);
            }
            else
            {
                settings.groups.put(selectedGroup,selectedNames);
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
            
            if(settings.groups.containsKey(selectedGroup))
            {
                selectedNames = new Set<String>(settings.groups.get(selectedGroup));
            }
            
            if(selectedNames != null)
            {
                for(String s: unselected)
                {
                    selectedNames.remove(s);
                }
            }
            
            settings.groups.put(selectedGroup,new List<String>(selectedNames));
        }
    }
    
    public void generateERD()
    {
        ERDGenerator generator;
        if (template == EXTERNAL_TEMPLATE) {   
            if (fileUrl == null || fileUrl == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please choose an external file'));
            } else {    
                generator = new ERDGenerator(new TemplateEngine.CalloutTemplateSource(fileUrl));
            }           
        } else {
            generator = new ERDGenerator(template);         
        }
        if (generator != null) {
            generatedContent = generator.generateERD(filteredSelectedGroupObjectMap,includeFields);         
            if (oauthToken != null) {
                ERDDropboxAPI api = new ERDDropboxAPI();
                api.oauthToken = oauthToken; 
                System.debug(api.writeFile(currentSetting+'.gv', generatedContent));
            }
        }
    }
    
    public List<SelectOption> getTemplates() {
        List<SelectOption> templates = new List<SelectOption>();
        for (String t : new List<String>{'DefaultTemplate'}) {
            templates.add(new SelectOption(t,t));
        }       
        templates.add(new SelectOption(EXTERNAL_TEMPLATE, '<Use External Template>'));
        return templates;
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