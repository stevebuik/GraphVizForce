public with sharing class ERDEntityGroup {
	public String groupName {get;set;}
    public Boolean selected {get;set;}
    
    public ERDEntityGroup(String grpName, Boolean isSelected)
    {
    	this.groupName = grpName;
    	this.selected = isSelected;
    }
}