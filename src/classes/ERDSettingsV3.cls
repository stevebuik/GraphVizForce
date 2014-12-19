public class ERDSettingsV3 implements ERDPersister.Versionable {
	
	// this field should always be present. It is used to hydrate/upgrade automatically
	public Integer version = 3;
	public Integer getVersion() { return version; }
	public Boolean includeFields {get;set;}
	public Boolean includeStandardUserLookup {get;set;}
	//public Set<String> objectNameSet;
	
	// any other fields persisted are here
	public Map<String,Map<String,List<String>>> groupToObjectsToFieldsMap
	{
		get {
			if (groupToObjectsToFieldsMap == null) groupToObjectsToFieldsMap = new Map<String,Map<String,List<String>>>();
			return groupToObjectsToFieldsMap; 
		}
		set;
	}
	public Set<String> includedGroups 
	{
		get {
			if (includedGroups == null) includedGroups = new Set<String>();
			return includedGroups; 
		}
		set;
	}
	
	public void upgrade(ERDPersister.Versionable old) {
		// old version is always the current - 1
		ERDSettingsV2 v2 = (ERDSettingsV2) old; 
		
		// copy shared data
		Map<String, List<String>> v2Map = v2.groups;
		Map<String,Map<String,List<String>>> v3Map = new Map<String,Map<String,List<String>>>();
		Set<String> v3IncludedGroups = new Set<String>();
		
		if(v2Map != null)
		{
			for(String groupName : v2Map.keySet())
			{
				Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>>();
				
				for(String objectName : v2Map.get(groupName))
				{
					objectToFieldsMap.put(objectName, new List<String>());
				}
				v3Map.put(groupName,objectToFieldsMap);
			}
			
			v3IncludedGroups = v2Map.keySet();
		}
		
		groupToObjectsToFieldsMap = v3Map;
		includedGroups = v3IncludedGroups;
		
		// set sensible defaults for new data
		includeFields = v2.includeFields; 
	}

}