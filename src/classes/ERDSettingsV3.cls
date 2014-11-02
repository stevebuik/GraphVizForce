public class ERDSettingsV3 implements ERDPersister.Versionable {
	
	// this field should always be present. It is used to hydrate/upgrade automatically
	public Integer version = 3;
	public Integer getVersion() { return version; }
	
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
	public Boolean includeFields {get;set;}
	
	public Map<String,Map<String,List<String>>> selectedGroupToObjectsToFieldsMap
	{
		get
		{
			Map<String,Map<String,List<String>>> returnMap = new Map<String,Map<String,List<String>>>();
			if(groupToObjectsToFieldsMap != null)
			{
				for(String grp : groupToObjectsToFieldsMap.keySet())
				{
					if(includedGroups.contains(grp))
					{
						returnMap.put(grp, groupToObjectsToFieldsMap.get(grp));
					}
				}
			}
			
			return returnMap;
		}
	}
	
	public Set<String> objectNameSet
	{
		get
		{
			Set<String> objectNameSet = new Set<String>();
			
			for(Map<String,List<String>> objectToFieldsMap : this.selectedGroupToObjectsToFieldsMap.values())
			{
				objectNameSet.addAll(objectToFieldsMap.keySet());
			}
			
			return objectNameSet;
		}
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