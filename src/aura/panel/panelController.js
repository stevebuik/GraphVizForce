({
	onToggle : function(component, event, helper) {
		component.set('v.collapsed', !component.get('v.collapsed'));
	},
    
    onRemove : function(component, event, helper) {
		component.getEvent("onRemovePanel").setParams({action:'REMOVE'}).fire();
	},

	onEditMode : function(component, event, helper) {
        component.set('v.isEditMode', true);
    },

    onEditCompleted : function(component, event, helper) {
        component.set('v.isEditMode', false);
        component.getEvent("onEditPanelTitle").setParams({scope:component.get('v.title')}).fire();
    },
})