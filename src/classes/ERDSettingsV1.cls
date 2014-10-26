public class ERDSettingsV1 implements ERDPersister.Versionable {

	// this field should always be present. It is used to hydrate/upgrade automatically
	public Integer version = 1;
	public Integer getVersion() { return version; }
	
	// any other fields persisted are here
	public Map<String,List<String>> groups {get;set;}
	
	public void upgrade(ERDPersister.Versionable old) {
		// this upgrade is handled by the persister
	}
	
}