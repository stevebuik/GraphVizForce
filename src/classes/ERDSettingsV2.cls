public class ERDSettingsV2 implements ERDPersister.Versionable {
	
	// this field should always be present. It is used to hydrate/upgrade automatically
	public Integer version = 2;
	public Integer getVersion() { return version; }
	
	// any other fields persisted are here
	public Map<String,List<String>> groups {
		get {
			if (groups == null) groups = new Map<String,List<String>>();
			return groups; 
		}
		set;
	}
	public Boolean includeFields {get;set;}
	
	public void upgrade(ERDPersister.Versionable old) {
		// old version is always the current - 1
		ERDSettingsV1 v1 = (ERDSettingsV1) old; 
		
		// copy shared data
		groups = v1.groups;
		
		// set sensible defaults for new data
		includeFields = false; 
	}

}