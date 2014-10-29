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
    
    public List<String> allObjectNames {
    	get {
            if(allObjectNames == null) {
                allObjectNames = ERDUtils.getAllObjectNames();
            }
            return allObjectNames;
    	}
    	set;
    }
    public String newGroupName{get;set;}
    public String selectedGroup{get;set;}
    public String groupToDelete{get;set;}
    
    public String currentSetting{
        get {
            if (currentSetting == null) {
                currentSetting = '<New Diagram>';
            }
            return currentSetting;
        }
        set;
    }    
        
    public String newSettingName{get;set;}
    public String selectedSetting{get;set;}
    public String generatedContent{get;set;}

    public String template{get;set;}
    public String fileURL{get;set;}
    
    public String oauthToken{get;set;}
    
        
    private ERDSettingsV3 settings{
    	get {
    		if (settings == null) settings = new ERDSettingsV3(); 
    		return settings;
    	}
    	set;
    }
    
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
        
    public ERDGeneratorController() {
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
    
    public List<ERDGroup> getGroups() {
    	List<ERDGroup> groups = new List<ERDGroup>();
    	for(String g : settings.groupToObjectsToFieldsMap.keySet())
    	{
    		ERDGroup grp = new ERDGroup();
    		grp.groupName = g;
    		grp.selected = settings.includedGroups.contains(g);
    		groups.add(grp);
    	}
    	return groups;
    }
    
    public void addNewGroupWithInput() {
    	if (newGroupName != null)
    		settings.groupToObjectsToFieldsMap.put(newGroupName, new Map<String, List<String>>());
    }
        
    public void deleteERDGroup() {
    	settings.groupToObjectsToFieldsMap.remove(groupToDelete);
    	if(settings.includedGroups.contains(groupToDelete))
    	{
    		settings.includedGroups.remove(groupToDelete);
    	}
    }
        
    public void loadSelectedSetting()
    {
        if(String.isBlank(selectedSetting))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
            return;
        }
        
        currentSetting = selectedSetting;
        
        settings = (ERDSettingsV3) persister.getSettings(selectedSetting);
        
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
        
    }
        
    public void saveSelectedSetting()
    {
        if(String.isBlank(selectedSetting))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
            return;
        }
        
        if(settings.groupToObjectsToFieldsMap.size() == 0)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please add some groups'));
            return;
        }
        
		System.debug('before settings: '+settings);        
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
        
        persister.saveSettings(newSettingName, settings);
        
        selectedSetting = newSettingName;
        currentSetting = selectedSetting;
        
        if(ListUtils.getStringItemIndex(newSettingName,settingNamesList) == -1)
        {
            settingNamesList.add(newSettingName);
        }
    }
    
    // JQuery Selectable / VF Hidden Input Interop
    private String getCSV(List<String> options) {
    	if (options == null) return '';
    	String result = '';
    	for (String o : options) {
    		if (result.length() > 0) {
    		result += ',';
    		}
    		result += o;
    	}
    	return result;
    }
        
    public String getAllObjects() {
    	return getCSV(allObjectNames);
    }
    
    public String getSelectedObjects() {
    	if (settings == null || selectedGroup == null) return null;
    	return getCSV(new List<String>(settings.groupToObjectsToFieldsMap.get(selectedGroup).keySet()));
    }
    
    public void setSelectedObjects(String csv) {
    	if (settings == null || selectedGroup == null) return;
    	Map<String, List<String>> objectToFieldsMap = new Map<String, List<String>>();
    	for(String selectedObj : csv.split(','))
    	{
    		objectToFieldsMap.put(selectedObj, new List<String>());
    	}
    	settings.groupToObjectsToFieldsMap.put(selectedGroup, objectToFieldsMap);
    }
    
    public Boolean getIncludeFields() {
    	return settings.includeFields;
    }
    
    public void setIncludeFields(Boolean include) {
    	settings.includeFields = include;
    }
    
    public Boolean getIsDropboxEnabled() {
    	return new ERDDropboxAPI().areOAuthCredsPresent();
    }
    
    public void generateERD()
    {
        ERDGenerator generator;
        System.debug(LoggingLevel.ERROR,'====>template:' + template);
        System.debug(LoggingLevel.ERROR,'====>fileUrl:' + fileUrl);
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
        	System.debug(LoggingLevel.ERROR,'====>generator:' + generator);
            generatedContent = generator.generateERD(settings);         
            if (oauthToken != null) {
                ERDDropboxAPI api = new ERDDropboxAPI();
                api.oauthToken = oauthToken; 
                System.debug(api.writeFile(currentSetting+'.gv', generatedContent));
            }
        }
    }
    
    public List<SelectOption> getTemplates() {
        List<SelectOption> templates = new List<SelectOption>();
        for (StaticResource sr : [Select s.Name From StaticResource s
						 where s.Description like '#graphviztemplate%']) {
            templates.add(new SelectOption(sr.Name,sr.Name));
        }       
        templates.add(new SelectOption(EXTERNAL_TEMPLATE, '<Use External Template>'));
        return templates;
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