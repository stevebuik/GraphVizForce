({
	onToggle : function(component, event, helper) {
		component.set('v.collapsed', !component.get('v.collapsed'));
	},
    
    onRemove : function(component, event, helper) {
		component.getEvent("onRemovePanel").setParams({action:'REMOVE'}).fire();
	}
})