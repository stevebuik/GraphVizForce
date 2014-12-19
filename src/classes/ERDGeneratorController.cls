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
    public static final String DEFAULT_DIAGRAM_NAME = 'Default Diagram';
    
    public List<ERDEntityGroup> erdGroups{get;set;}
    public String newGroupName{get;set;}
    public String selectedGroup{get;set;}
    public String groupToDelete{get;set;}
    
    public String newSettingName{get;set;}
    public String selectedSetting{get;set;}
    public String generatedContent{get;set;}

    public String template{get;set;}
    public String fileURL{get;set;}
    
    public String selectedSingleObject{get;set;}
    
    @TestVisible private ERDPersister persister;
    @TestVisible private ERDSettingProcessor processor;
    @TestVisible private ERDInspector inspector;
    private List<String> settingNamesList;
    
    public String currentSetting{
        get {
            if (currentSetting == null) {
                currentSetting = '<New Diagram>';
            }
            return currentSetting;
        }
        set;
    }    
    
    public List<String> allObjectNames {
    	get {
            if(allObjectNames == null) {
                allObjectNames = ERDUtils.getAllObjectNames();
            }
            return allObjectNames;
    	}
    	set;
    }
    
    @TestVisible
    private ERDSettingsV3 settings{
    	get {
    		if (settings == null) settings = new ERDSettingsV3(); 
    		return settings;
    	}
    	set;
    }
    
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
    	System.debug(LoggingLevel.ERROR, '@@@@@@ERDGeneratorController constructor is called');
        processor = new ERDSettingProcessor();
        inspector = new ERDInspector();
        initERDPersister();
	}
	
	/***********Initialisation************/
    private void initERDPersister() {
    	
        persister = new ERDPersister();
        
        // Load first setting if setting List is not empty
        settingNamesList = persister.getSettingsNameList();
    }
    
    // if no diagrams exist i.e. new user, then seed one from a static resource
    public PageReference ensureDefaultDiagram() {
    	System.debug(LoggingLevel.ERROR,'@@@@@ensureDefaultDiagram is called');
    	if (settingNamesList.size() == 0) {
    		System.debug(LoggingLevel.ERROR,'@@@@@settingNamesList is empty');
    		selectedSetting = DEFAULT_DIAGRAM_NAME;
    		currentSetting = selectedSetting;
    		settings = (ERDSettingsV3) persister.getDefaultSettings();  
	        persister.saveSettings(selectedSetting, settings);
	        initUI();
	        PageReference ref = Page.ERDGeneratorPage;
	        ref.setRedirect(true);
	        return ref;
    	} else {
    		System.debug(LoggingLevel.ERROR,'@@@@@settingNamesList is not empty');
    		settingNamesList.sort();
            selectedSetting = settingNamesList[0];
            currentSetting = selectedSetting;            
            loadSelectedSetting();
            initUI();
	    	return null;
    	}
    }
    
    private void initUI()
    {
    	// Get ERD Entity Groups
        erdGroups = ERDUtils.getERDEntityGroups(settings.groupToObjectsToFieldsMap.keySet(),settings.includedGroups);
        
        // Reset UI persistency
        selectedGroup = null;
        selectedSingleObject = null;
    }
    
    /********Getter Setter Methods********/
    public Boolean getIncludeFields() {
    	return settings.includeFields;
    }
    
    public void setIncludeFields(Boolean include) {
    	settings.includeFields = include;
    }
    
    public Boolean getIncludeStandardUserLookup(){
    	return settings.includeStandardUserLookup;
    }
    
    public void setIncludeStandardUserLookup(Boolean include){
    	settings.includeStandardUserLookup = include;
    }
    
    public List<String> getAllSelectedObjects()
    {
    	List<String> sorted = new List<String>();
    	if(settings != null) {sorted = new List<String>(processor.retrieveAllObjectsForGroups(settings));}
    	sorted.sort();
    	return sorted;
    }
    
    public String getObjectsForSelectedGroup()
    {
    	if(selectedGroup == null || String.isBlank(selectedGroup)) return '';
    	return getCSV(inspector.getAvailableObjectsForGroup(selectedGroup,allObjectNames,settings.groupToObjectsToFieldsMap));
    }
    
    public String getSelectedObjects() {
    	if (settings == null || selectedGroup == null || settings.groupToObjectsToFieldsMap.get(selectedGroup) == null) return null;
    	return getCSV(new List<String>(settings.groupToObjectsToFieldsMap.get(selectedGroup).keySet()));
    }
    
    public void setSelectedObjects(String csv) {
    	
    	if (settings == null || selectedGroup == null) return;
    	processor.setSelectedObjectsToGroup(settings, csv, selectedGroup);
    }
    
    public String getAllFieldsForSelectedObject()
    {
    	if(selectedSingleObject == null || String.isBlank(selectedSingleObject)) return '';
    	List<String> fieldNames = new List<String>();
    	fieldNames = inspector.getFieldNamesByObjectName(selectedSingleObject);
    	return getCSV(fieldNames);
    }
    
    public String getSelectedObjectFields()
    {
    	if(settings == null || selectedSingleObject == null || String.isBlank(selectedSingleObject)) return null;
    	return getCSV(processor.retrieveFieldsForObject(settings, selectedSingleObject));
    }
    
    /** 
    * @description This is the problematic setter:
    * Problem: When select object in selectlist, selctedsingleobject is updated immediately when this setter is called, csv passed into this method is still the old set of fields, that gets updated into the new selected single object
    * Solution: in UI, use table with edit button instead of selectlist
    */
    public void setSelectedObjectFields(String csv)
    {
    	if (settings == null || selectedSingleObject == null || String.isBlank(selectedSingleObject)) return;
    	processor.setSelectedFieldsToObject(settings, csv, selectedSingleObject);
    }
    
       
    /********UI Interactive Methods********/
    public void loadSelectedSetting()
    {
        if(String.isBlank(selectedSetting))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
            return;
        }
        
        // Update currentSetting
        currentSetting = selectedSetting;
        settings = (ERDSettingsV3) persister.getSettings(selectedSetting);
        
        initUI();
    }
    
    public PageReference refreshObjectFieldSelection()
    {
    	System.debug(LoggingLevel.ERROR, '@@@@@@refreshObjectFieldSelection is called');
    	updateERDGroupSelection();
    	selectedSingleObject = null;
    	return null;
    }
    
    public void updateERDGroupSelection()
    {
    	processor.setERDGroupSelection(settings,erdGroups);
    }
    
    public void addNewGroupWithInput() {
    	if (newGroupName == null || erdGroups == null) {return;}
    	
    	ERDEntityGroup newGroup = new ERDEntityGroup(newGroupName,true);
    	erdGroups.add(newGroup);
    	
    	processor.addNewERDGroup(settings,newGroupName);
    }
    
    public void deleteERDGroup() {
    	if(erdGroups != null)
    	{
    		for(Integer i=0;i<erdGroups.size();i++)
    		{
    			if(erdGroups[i].groupName == groupToDelete)
    			{
    				erdGroups.remove(i);
    				break;
    			}
    		}
    	}
    	
    	processor.deleteERDGroup(settings,groupToDelete);
    	
    	// Reset UI Persistency
    	if(groupToDelete == selectedGroup) {selectedGroup = null;}
    }
    
    public void deleteSelectedSetting()
    {
        if(String.isBlank(selectedSetting))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select a setting'));
            return;
        }
        
        Integer index = ERDListUtils.getStringItemIndex(selectedSetting,settingNamesList);
        
        if(index != -1)
        {
            settingNamesList.remove(index);
            persister.deleteSettings(selectedSetting);
        }
        
        // Reset UI Persistency
        selectedSetting = null;
        currentSetting = null;
        selectedGroup = null;
        selectedSingleObject = null;
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
        
        updateERDGroupSelection();
        
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
        if(ERDListUtils.getStringItemIndex(newSettingName,settingNamesList) == -1)
        {
            settingNamesList.add(newSettingName);
        }
        
        selectedSetting = newSettingName;
        currentSetting = selectedSetting;
    }
    
    public void generateERD()
    {
    	updateERDGroupSelection();
    	
        ERDGenerator generator;
        if (template == EXTERNAL_TEMPLATE) {   
            if (fileUrl == null || fileUrl == '') {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please choose an external file'));
            } else {    
                generator = new ERDGenerator(new ERDTemplateEngine.CalloutTemplateSource(fileUrl));
            }           
        } else {
            generator = new ERDGenerator(template);         
        }
        if (generator != null) {
            generatedContent = generator.generateERD(settings);         
        }
    }
    
    public PageReference download() {    	
    	return Page.ERDDownloader;
    }
    
    /********Template Related Methods********/
    
    public List<SelectOption> getTemplates() {
        List<SelectOption> templates = new List<SelectOption>();
        for (StaticResource sr : [Select s.Name From StaticResource s
						 where s.Description like '#graphviztemplate%']) {
            templates.add(new SelectOption(sr.Name,sr.Name));
        }       
        templates.add(new SelectOption(EXTERNAL_TEMPLATE, '<Use External Template>'));
        return templates;
    }
        
    
    /********Local Methods********/
    // JQuery Selectable / VF Hidden Input Interop
    private String getCSV(List<String> options) {
    	System.debug(LoggingLevel.ERROR, '@@@@getCSV:' + options);
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
    
}