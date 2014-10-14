public with sharing class ERDPersister {

	private Id folderId;

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
	
	public list<String> getDiagramNameList()
	{
		list<String> diagramList = new list<String>();
		
		if(folderId != null)
		{
			List<Document> ds = [SELECT Id, Name FROM Document 
									WHERE folderId = :folderId];
			
			if(!ds.isEmpty())
			{
				for(Document doc : ds)
				{
					diagramList.add(doc.Name);
				}
			}
		}
		
		return diagramList;
	}

	public Map<String,List<String>> getDiagram(String name) {
		List<Document> ds = [select Id, Body from Document 
			where Name = :name 
			and FolderId = :folderId];
			
		if (ds.size() == 0) {
			return null;
		} else if (ds.size() == 1) {
			String groupString = ds.get(0).Body.toString();
			Map<String,List<String>> result = new Map<String,List<String>>();
			Map<String,Object> parsed = (Map<String,Object>) JSON.deserializeUntyped(groupString);
			for (String groupName : parsed.keySet()) {
				List<Object> entities = (List<Object>) parsed.get(groupName);	
				List<String> entityStrings = new List<String>();	
				for (Object entity : entities) {
					entityStrings.add((String)entity);
				}
				result.put(groupName, entityStrings);
			}
			return result;
		} else {
			throw new ApplicationException('Too many documents found: '+name);
		}
	}

	public void saveDiagram(String name, Map<String,List<String>> groups) {
		
		List<Document> ds = [select Id from Document 
			where Name = :name 
			and FolderId = :folderId];

		String body = JSON.serialize(groups);			
			
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
	
	public void deleteDiagram(String name)
	{
		list<Document> ds = [select Id from Document 
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