({
	onObjectClicked : function(component, event, helper) {
		component.getEvent('onObjectClicked').setParams(event.getParams()).fire();
	},
    
    onRemoveObject : function(component, event, helper){
		component.getEvent('onRemoveObject').setParams(event.getParams()).fire();
    },
    
    onAddGroup : function(component, event, helper){
        component.getEvent('onAddGroup').setParams({scope:component.get('v.newGroupName')}).fire();
    },
    
    onDragEnter : function(component, e, helper){
        if(e.target.nodeType == 1) {
			e.preventDefault();
            let target = helper.closest(e.target, '.slds-box');
            target.classList.add("drag-enter");
        }
    },
    
    onDragLeave : function(component, e, helper){
        if(e.target.nodeType == 1) {
            e.preventDefault();
            e.target.classList.remove("drag-enter");
        }
    },

    onDragOver : function(component, e, helper){
        if(e.target.nodeType == 1) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'copy';
            e.stopPropagation();
        }
    },
    
    onDrop : function(component, e, helper){
        if(e.target.nodeType == 1) {
            e.preventDefault();
            e.target.classList.remove("drag-enter");
			let value = JSON.parse(e.dataTransfer.getData("value"));
            console.log('onDrop > value:', value);
            let dropTarget = helper.closest(e.target, '.dropTarget');
            let group = dropTarget.getAttribute('data-group');
            console.log('onDrop > group:', group);
            component.getEvent('onDragObjectToGroup').setParams({scope:{group:group, object:value}}).fire();
        }
    },
})