({
    handleObjectChange : function(component, event, helper) {
        let object = component.get('v.object');
        console.log('handleObjectChange:', object);
        let availableAttributes = [];
        let selectedAttributes = [];
        object.attributes.forEach(function(attribute){
            attribute.visible = true;
            if(attribute.selected){
                selectedAttributes.push(attribute);
            }
            else{
                availableAttributes.push(attribute);
            }
        });
		
        availableAttributes.sort(helper.compare);
        selectedAttributes.sort(helper.compare);
		        
		component.set('v.availableAttributes', availableAttributes);
		component.set('v.selectedAttributes', selectedAttributes);
        helper.handleFilterAvailable(component, event, helper);
        helper.handleFilterSelected(component, event, helper);
	},
    
	onAddClicked : function(component, event, helper) {
        let attribute = event.getParam('scope');
        attribute.selected = true;
        component.getEvent('onObjectAttributesUpdated').setParams({scope:attribute}).fire();
	},
    
    onRemoveClicked : function(component, event, helper) {
        let attribute = event.getParam('scope');
        attribute.selected = false;
        component.getEvent('onObjectAttributesUpdated').setParams({scope:attribute}).fire();
	},
    
    onSearchAvailable : function(component, event, helper) {
        helper.handleFilterAvailable(component, event, helper);
    },
    
    onSearchSelected : function(component, event, helper) {
        helper.handleFilterSelected(component, event, helper);
    },
})