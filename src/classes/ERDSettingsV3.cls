public class ERDSettingsV3 implements ERDPersister.Versionable {
	
	// this field should always be present. It is used to hydrate/upgrade automatically
	public Integer version = 3;
	public Integer getVersion() { return version; }
	
	// any other fields persisted are here
	public Map<String,Map<String,List<String>>> groupToObjectsToFieldsMap {get;set;}
	public List<String> includedGroups {get;set;}
	public Boolean includeFields {get;set;}
	
	public void upgrade(ERDPersister.Versionable old) {
		// old version is always the current - 1
		ERDSettingsV2 v2 = (ERDSettingsV2) old; 
		
		// copy shared data
		Map<String, List<String>> v2Map = v2.groups;
		Map<String,Map<String,List<String>>> v3Map = new Map<String,Map<String,List<String>>>();
		for(String groupName : v2Map.keySet())
		{
			Map<String,List<String>> objectToFieldsMap = new Map<String,List<String>>();
			
			for(String objectName : v2Map.get(groupName))
			{
				objectToFieldsMap.put(objectName, new List<String>());
			}
			v3Map.put(groupName,objectToFieldsMap);
		}
		groupToObjectsToFieldsMap = v3Map;
		
		// set sensible defaults for new data
		includeFields = v2.includeFields; 
		includedGroups = new List<String>(v2.groups.keySet());
	}

}