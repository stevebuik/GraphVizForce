({
	doInit : function(component, event, helper) {
        
        let objectNames = ['Account', 'Site', 'Task', 'Contract', 'ContractContactRole', 'Event', 'OpportunityCompetitor', 'OpportunityContactRole', 'OpportunityLineItem', 'PartnerRole', 'Pricebook', 'Contact', 'Lead', 'Case', 'User', 'Opportunity', 'Order', 'Product', 'Asset', 'Solution', 'AccountContactRole', 'Activity', 'Campaign', 'CampaignMember', 'CaseContactRole', 'ContentVersion'];
        let attributeArray = [{label:'Id', value:'Id', selected:true}, {label:'Name', value:'Name', selected:true}, {label:'Owner', value:'Owner', selected:true}, {label:'CreatedBy', value:'CreatedBy', selected:true}, {label:'Description', value:'Description', selected:false}, {label:'LastModifiedBy', value:'LastModifiedBy', selected:false}, {label:'Phone', value:'Phone', selected:false}, {label:'ShippingAddress', value:'ShippingAddress', selected:false}, {label:'Type', value:'Type', selected:false}, {label:'MobilePhone', value:'MobilePhone', selected:false}, {label:'Email', value:'Email', selected:false}, {label:'Website', value:'Website', selected:false}];
        for(var i=0;i<100;i++){
            attributeArray.push({label:'Z Attribute Name' + i, value:'ZAttributeValue' + i, selected:false});   
        }
        for(var i=0;i<attributeArray.length;i++){
            attributeArray[i].visible = true;
        }
        attributeArray.sort(helper.compare);
        
        let objects = [];
        let groupIndex = 0;
        for(var i=0;i<objectNames.length;i++){
            let objectName = objectNames[i];
            let groupName = 'Group'
            objects.push({label:objectName, value:objectName, visible:false, attributes:JSON.parse(JSON.stringify(attributeArray))});
        }
        
        for(var i=0;i<200;i++){
            objects.push({label:'Z Object Name' + i, value:'ZObjectValue' + i, visible:false, attributes:JSON.parse(JSON.stringify(attributeArray))});
        }

        let groups = [{label:'First Group', value:'First Group', entities:[]}];

        objects.sort(helper.compare);
        groups.sort(helper.compare);
        component.set('v.objects', objects);
        component.set('v.groups', groups);
        
	},
    
    /*
    onTargetPanelObjectClicked : function(component, event, helper) {
        component.find('sourcePanel').find('objectPanel').getEvent('onObjectClicked').setParams(event.getParams()).fire();
    },
    */
    
    onAddGroup : function(component, event, helper) {
        let groups = component.get('v.groups');
        let groupName = helper.generateUniqueGroupName(helper, groups, event.getParam('scope'));
        let group = {label:groupName, value:groupName, entities:[]};
        groups.push(group);
        groups.sort(helper.compare);
        component.set('v.groups', groups);
    },
    
    onRemoveGroup : function(component, event, helper) {
        let group = event.getParam('scope');
        let groups = component.get('v.groups');
        let objects = component.get('v.objects');
        groups.forEach(function (targetGroup) {
            if(targetGroup.value == group.value){
                targetGroup.entities.forEach(function (targetObject) {
                    objects.push(targetObject);
                });
                let index = groups.findIndex((x) => x.value === targetGroup.value);
                groups.splice(index, 1);
                objects.sort(helper.compare);
                groups.sort(helper.compare);
                component.set('v.objects', objects);
                component.set('v.groups', groups);
                return;
            }
        });
    },
    
    onAddObject : function(component, event, helper) {
        component.set('v.showAddGroup', true);
        component.set('v.objectToAdd', event.getParam('scope'));
    },
    
    onAddObjectToGroupClicked : function(component, event, helper){
        component.set('v.showAddGroup', false);
        
        let objectToAdd = component.get('v.objectToAdd');
        let groupValue = event.getSource().get('v.value');
        console.log('onAddObjectToGroupClicked > objectToAdd:', objectToAdd);
        console.log('onAddObjectToGroupClicked > groupValue:', groupValue);
        helper.addObjectToGroup(component, helper, objectToAdd, groupValue);
    },
    
    onDragObjectToGroup : function(component, event, helper){
        console.log('handle onDragObjectToGroup');
        let scope = event.getParam('scope');
        let objectToAdd = scope.object;
        let groupValue = scope.group;
        console.log('onDragObjectToGroup > object:', objectToAdd);
        console.log('onDragObjectToGroup > group:', groupValue);
        helper.addObjectToGroup(component, helper, objectToAdd, groupValue);
    },
    
    /**
    * @description:	Remove the object from target panel and add it back to source panel
    */
    onTargetPanelRemoveObject : function(component, event, helper){
        let obj = event.getParam('scope');
		let groups = component.get('v.groups');
		let objects = component.get('v.objects');
        
        groups.forEach(function (group) {
            group.entities.forEach(function (targetObject) {
                if(targetObject.value == obj.value){
                    let index = group.entities.findIndex((x) => x.value === targetObject.value);
                    group.entities.splice(index, 1);
                    objects.push(targetObject);
                    objects.sort(helper.compare);
                    component.set('v.groups', groups);
                    component.set('v.objects', objects);
                    return;
                }
            });
        });
    },
    
    onObjectAttributesUpdated : function(component, event, helper){
        let attribute = event.getParam('scope');
		let groups = component.get('v.groups');
		let objects = component.get('v.objects');
        let selectedObject = component.get('v.selectedObject');
		
        // Find target object in groups and propagate attribute changes
		groups.forEach(function (group) {
            group.entities.forEach(function (targetObject) {
                if(targetObject.value == selectedObject.value){
                    targetObject.attributes.forEach(function (targetAttribute) {
                        if(targetAttribute.value == attribute.value){
                            targetAttribute.selected = attribute.selected;
                            component.set('v.groups', groups);
                            component.set('v.selectedObject', targetObject);
                            return;
                        }
                    });
                }
            });
        });
        
        // Find target object in objects and propagate attribute changes
        objects.forEach(function (targetObject) {
            if(targetObject.value == selectedObject.value){
                targetObject.attributes.forEach(function (targetAttribute) {
                    if(targetAttribute.value == attribute.value){
                        targetAttribute.selected = attribute.selected;
                        component.set('v.objects', objects);
                        component.set('v.selectedObject', targetObject);
                        return;
                    }
                });
            }
        });
    },
    
    onObjectClicked : function(component, event, helper) {
        let obj = event.getParam('scope');
        console.log('onObjectClicked:', obj);
        component.find('targetPanel').set('v.currentState', 'ATTRIBUTES');
        component.set('v.selectedObject', obj);
    },

    onEditGroupName : function(component, event, helper) {
        console.log('onEditGroupName');
        let newGroup = event.getParam('scope');
        let groups = component.get('v.groups');
        let groupName = helper.generateUniqueGroupName(helper, groups, newGroup.label);
        console.log('groupName:', groupName);

        groups.forEach(function (group) {
            if(group.value == newGroup.value){
                group.label = group.value = groupName;
                component.set('v.groups', groups);
                return;
            }
        });
    },
    
})