public with sharing class ERDSettingProcessor
{
	public Set<String> retrieveAllObjectsForGroups(ERDSettingsv3 settings)
	{
		Set<String> objectNameSet = new Set<String>();
		
		for(String grp : settings.groupToObjectsToFieldsMap.keySet())
		{
			if(settings.includedGroups.contains(grp))
			{
				objectNameSet.addAll(settings.groupToObjectsToFieldsMap.get(grp).keySet());
			}
		}
		
		return objectNameSet;
	}
	
	public void setSelectedObjectsToGroup(ERDSettingsV3 settings, String csv, String selectedGroup)
	{
		Map<String, List<String>> objectToFieldsMap = settings.groupToObjectsToFieldsMap.get(selectedGroup);
    	if(objectToFieldsMap == null) {objectToFieldsMap = new Map<String, List<String>>();}
    	
    	Map<String, List<String>> newObjectToFieldsMap = new Map<String,List<String>>();
    	
    	for(String selectedObj : csv.split(','))
    	{
    		if(!String.isBlank(selectedObj))
    		{
	    		List<String> selectedObjectList = new List<String>();
	    		if(objectToFieldsMap.keySet().contains(selectedObj))
	    		{
	    			selectedObjectList = objectToFieldsMap.get(selectedObj);
	    		}
	    		newObjectToFieldsMap.put(selectedObj, selectedObjectList);
    		}
    	}
    	settings.groupToObjectsToFieldsMap.put(selectedGroup, newObjectToFieldsMap);
	}
	
	public List<String> retrieveFieldsForObject(ERDSettingsV3 settings, String selectedSingleObject)
	{
		for(Map<String, List<String>> objectToFieldsMap : settings.groupToObjectsToFieldsMap.values())
    	{
    		for(String obj : objectToFieldsMap.keySet())
    		{
    			if(obj == selectedSingleObject)
    			{
    				return objectToFieldsMap.get(obj);
	    		}
    		}
    	}
    	return null;
	}
	
	public void setSelectedFieldsToObject(ERDSettingsV3 settings, String csv, String selectedSingleObject)
	{
		for(Map<String, List<String>> objectToFieldsMap : settings.groupToObjectsToFieldsMap.values())
    	{
    		for(String obj : objectToFieldsMap.keySet())
    		{
    			if(obj == selectedSingleObject)
    			{
	    			Set<String> newFieldsList = new Set<String>();
    				for(String selectedField : csv.split(','))
			    	{
			    		if(!String.isBlank(selectedField))
			    		{
			    			newFieldsList.add(selectedField);
			    		}
			    	}
	    			objectToFieldsMap.put(obj,new List<String>(newFieldsList));
	    			return;
	    		}
    		}
    	}
	}
	
	public void setERDGroupSelection(ERDSettingsV3 settings, List<ERDEntityGroup> erdGroups)
	{
		Set<String> includedGroups = new Set<String>();
    	if(erdGroups != null)
    	{
    		for(ERDEntityGroup grp : erdGroups)
    		{
    			if(grp.selected)
    			{
    				includedGroups.add(grp.groupName);
    			}
    		}
    	}
    	settings.includedGroups = includedGroups;
	}
	
	public void addNewERDGroup(ERDSettingsV3 settings, String newGroupName)
	{
		settings.groupToObjectsToFieldsMap.put(newGroupName, new Map<String, List<String>>());
    	settings.includedGroups.add(newGroupName);
	}
	
	public void deleteERDGroup(ERDSettingsV3 settings, String groupToDelete)
	{
    	settings.groupToObjectsToFieldsMap.remove(groupToDelete);
    	if(settings.includedGroups.contains(groupToDelete)) {settings.includedGroups.remove(groupToDelete);}
	}
}