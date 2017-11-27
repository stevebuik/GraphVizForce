({
	onRemovePanel : function(component, event, helper) {
        var r = confirm("Do you want to remove this group?");
        if (r == true) {
            console.log('event', event);
        	component.getEvent('onRemoveGroup').setParams({scope:component.get('v.group')}).fire();
        }
	},

	onEditPanelTitle : function(component, event, helper) {
	    let group = component.get('v.group');
	    let newTitle = event.getParam('scope');
	    console.log('onEditPanelTitle:', group.label);
	    console.log('onEditPanelTitle:', group.value);
	    console.log('onEditPanelTitle:', newTitle);
	    if(group.value != newTitle){
            component.getEvent('onEditGroupName').setParams({scope:group}).fire();
        }
    },
})