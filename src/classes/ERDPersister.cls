public with sharing class ERDPersister {
	
	public static final Integer CURRENT_VERSION = 3;
	
	public interface Versionable {
		Integer getVersion();
		void upgrade(Versionable old);
	}

	public Id folderId;

	public ERDPersister(String folderName) {
		List<Folder> fs = [select Id from Folder 
			where Name = :folderName
			and Type = 'Document'];	
		if (fs.size() == 0) {
			throw new ApplicationException('Folder not found: '+folderName);
		} else if (fs.size() == 1) {
			this.folderId = fs.get(0).Id;
		} else {
			throw new ApplicationException('Too many folders found: '+folderName);
		}
	}
	
	public List<String> getSettingsNameList()
	{
		List<String> diagramList = new List<String>();		
		if(folderId != null) {
			List<Document> ds = [SELECT Id, Name FROM Document WHERE folderId = :folderId];
			
			if(!ds.isEmpty()) {
				for(Document doc : ds) {
					diagramList.add(doc.Name);
				}
			}
		}		
		return diagramList;
	}
	
	public Versionable getSettings(String name)
	{
		return getSettingsByNameVersion(name,CURRENT_VERSION);
	}
	
	public Versionable getSettings(String name, Integer version)
	{
		return getSettingsByNameVersion(name,version);
	}
	
	/* returns the settings upgraded to the latest version expected by the code base.
	This provides a way for existing settings to be automatically upgraded when they are read */
	private Versionable getSettingsByNameVersion(String name, Integer version) {
		List<Document> ds = [select Id, Body from Document 
			where Name = :name 
			and FolderId = :folderId];
			
		if (ds.size() == 0) {
			return null;
		} else if (ds.size() == 1) {
			String settingJSON = ds.get(0).Body.toString();
			Versionable v = upgrade(version, settingJSON);
			return v;
		} else {
			throw new ApplicationException('Too many documents found: '+name);
		}	
	}
	
	// separated for testability
	public Versionable upgrade(Integer targetVersion, String persisted) {
		Map<String, Object> persistedMap = (Map<String, Object>) JSON.deserializeUntyped(persisted);
		Integer persistedVersion = (Integer) persistedMap.get('version');
		
		if (persistedVersion == null) {// prior to versionable, only the groups were saved
			
			Versionable setting;
			
			if(persistedMap != null && !persistedMap.isEmpty())
			{
				if(persistedMap.values()[0] instanceof List<String>)
				{
					ERDSettingsV1 v1 = new ERDSettingsV1();		
					v1.groups = new Map<String,List<String>>();
					for (String g : persistedMap.keySet()) {
						v1.groups.put(g, new List<String>());
						List<Object> objects = (List<Object>) persistedMap.get(g);
						for (Object o : objects) {
							v1.groups.get(g).add((String) o);
						}
					}
					
					setting = v1;
				}
				else
				{
					ERDSettingsV3 v3 = new ERDSettingsV3();		
					v3.groupToObjectsToFieldsMap = new Map<String,Map<String,List<String>>>();
					for(String g : persistedMap.keySet())
					{
						v3.groupToObjectsToFieldsMap.put(g, new Map<String, List<String>>());
						Map<String,Object> objectToFieldsMap = (Map<String,Object>)persistedMap.get(g);
						
						for(String objectName : objectToFieldsMap.keySet())
						{
							v3.groupToObjectsToFieldsMap.get(g).put(objectName, new List<String>());
							
							List<Object> objects = (List<Object>) objectToFieldsMap.get(objectName);
							for (Object o : objects)
							{
								v3.groupToObjectsToFieldsMap.get(g).get(objectName).add((String) o);
							}
							objectToFieldsMap.put(objectName, new List<String>());
						}
					}
					
					setting = v3;
				}
			}
			
			
			return upgrade(targetVersion, setting); 	
		} else {
			Type persistedType = Type.forName('ERDSettingsV'+persistedVersion);
			Versionable hydrated = (Versionable) JSON.deserialize(persisted, persistedType);
			return upgrade(targetVersion, hydrated);
		}
	}
	
	public Versionable upgrade(Integer targetVersion, Versionable oldVersion) {
		Versionable latest = oldVersion;
		while (latest.getVersion() < targetVersion) {
			Type upgradedType = Type.forName('ERDSettingsV'+(latest.getVersion()+1));
			Versionable nextVersion = (Versionable) upgradedType.newInstance();
			nextVersion.upgrade(latest);
			latest = nextVersion;		
		}
		return latest;
	}

	public void saveSettings(String name, Versionable settings) {
		
		List<Document> ds = [select Id from Document 
			where Name = :name 
			and FolderId = :folderId];

		String body = JSON.serialize(settings);			
			
		if (ds.size() == 0) {
			Document d = new Document(
				Name = name,
				FolderId = folderId,
				Body = Blob.valueOf(body)
			);
			insert d;
		} else if (ds.size() == 1) {
			Document d = ds.get(0);
			d.Body = Blob.valueOf(body);
			update d;
		} else {
			throw new ApplicationException('Too many Documents found: '+name);			
		}

	}
	
	public void deleteSettings(String name)
	{
		List<Document> ds = [select Id from Document 
			where Name = :name 
			and FolderId = :folderId];
			
		if(ds.size() == 1)
		{
			Document d = ds.get(0);
			delete d;
		}
		else
		{
			throw new ApplicationException('Document does not exist: ' + name);
		}
	}


}