/**
 * Created by guan on 27/11/17.
 */
({
    doInit : function(component, event, helper){
        let userGuideCompleted = localStorage.getItem('userGuideCompleted');
        window.showUserGuide = !userGuideCompleted;
        console.log('@@@@ showUserGuide:', showUserGuide);

        /* Setup all objects */
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

        objects.sort(helper.compare);
        component.set('v.allObjects', objects);

        /* Setup Diagram List */
        let groups = [{label:'First Group', value:'First Group', entities:[]}];
        let diagrams = [{label:'Sample Diagram', value:'Sample Diagram', visible:true, groups:groups}];
        component.set('v.diagrams', diagrams);
    },

    /** List View Functions **/
    onSearchDiagrams : function(component, event, helper) {
        let diagrams = component.get('v.diagrams');
        let term = component.get('v.searchTerm').toLowerCase();
        diagrams.forEach(function(diagram){
            diagram.visible = (term == '' || diagram.label.toLowerCase().indexOf(term) != -1);
        });
        component.set('v.diagrams', diagrams);
    },

    gotoDiagramDetail : function(component, event, helper){
        component.set('v.currentState', 'DETAIL');
        component.find('diagramConfigurator').find('sourcePanel').find('objectPanel').set('v.searchTerm', '');
        let diagram = event.getParam('scope');
        component.set('v.selectedDiagram', diagram);
        helper.initialiseObjects(component, event, helper);
        component.find('diagramConfigurator').find('targetPanel').set('v.currentState', 'GROUPS');
    },

    onObjectClicked : function(component, event, helper) {
        let obj = event.getParam('scope');
        component.find('diagramConfigurator').find('targetPanel').set('v.currentState', 'ATTRIBUTES');
        component.set('v.selectedObject', obj);
    },

    onAddNewDiagram : function(component, event, helper){
        helper.handleAddDiagram(component, event, helper);
    },

    onRemoveDiagram : function(component, event, helper){
       let diagrams = component.get('v.diagrams');
       let diagramToRemove = event.getParam('scope');
       diagrams.forEach(function (diagram) {
           if(diagram.value == diagramToRemove.value){
               let index = diagrams.findIndex((x) => x.value === diagramToRemove.value);
               diagrams.splice(index, 1);
               component.set('v.diagrams', diagrams);
               return;
           }
       });
    },

    onBackToList : function(component, event, helper){
        component.set('v.currentState', 'LIST');
    },

    /** Detail View functions **/
    onAddGroup : function(component, event, helper) {
        let selectedDiagram = component.get('v.selectedDiagram');
        let groupName = event.getParam('scope');
        let group = {label:groupName, value:groupName, entities:[]};
        selectedDiagram.groups.push(group);
        selectedDiagram.groups.sort(helper.compare);
        component.set('v.selectedDiagram', selectedDiagram);
    },

    onRemoveGroup : function(component, event, helper) {
        let group = event.getParam('scope');
        let selectedDiagram = component.get('v.selectedDiagram');
        let objects = component.get('v.objects');
        selectedDiagram.groups.forEach(function (targetGroup) {
            if(targetGroup.value == group.value){
                targetGroup.entities.forEach(function (targetObject) {
                    objects.push(targetObject);
                });
                let index = selectedDiagram.groups.findIndex((x) => x.value === targetGroup.value);
                selectedDiagram.groups.splice(index, 1);
                objects.sort(helper.compare);
                selectedDiagram.groups.sort(helper.compare);
                component.set('v.objects', objects);
                component.set('v.selectedDiagram', selectedDiagram);
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
        helper.addObjectToGroup(component, helper, objectToAdd, groupValue);
    },

    onDragObjectToGroup : function(component, event, helper){
        let objects = component.get('v.objects');
        let scope = event.getParam('scope');
        let groupValue = scope.group;
        let index = objects.findIndex((x) => x.value === scope.object);
        let objectToAdd = objects[index];
        helper.addObjectToGroup(component, helper, objectToAdd, groupValue);
    },

    /**
    * @description:	Remove the object from target panel and add it back to source panel
    */
    onTargetPanelRemoveObject : function(component, event, helper){
        let obj = event.getParam('scope');
        let selectedDiagram = component.get('v.selectedDiagram');
        let objects = component.get('v.objects');

        selectedDiagram.groups.forEach(function (group) {
            group.entities.forEach(function (targetObject) {
                if(targetObject.value == obj.value){
                    let index = group.entities.findIndex((x) => x.value === targetObject.value);
                    group.entities.splice(index, 1);
                    objects.push(targetObject);
                    objects.sort(helper.compare);
                    component.set('v.selectedDiagram', selectedDiagram);
                    component.set('v.objects', objects);
                    return;
                }
            });
        });
    },

    onObjectAttributesUpdated : function(component, event, helper){
        let attribute = event.getParam('scope');
        let selectedDiagram = component.get('v.selectedDiagram');
        let objects = component.get('v.objects');
        let selectedObject = component.get('v.selectedObject');

        // Find target object in groups and propagate attribute changes
        selectedDiagram.groups.forEach(function (group) {
            group.entities.forEach(function (targetObject) {
                if(targetObject.value == selectedObject.value){
                    targetObject.attributes.forEach(function (targetAttribute) {
                        if(targetAttribute.value == attribute.value){
                            targetAttribute.selected = attribute.selected;
                            component.set('v.selectedDiagram', selectedDiagram);
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

    onEditGroupName : function(component, event, helper) {
        let scope = event.getParam('scope');
        let newGroupName = scope.newValue;
        let selectedDiagram = component.get('v.selectedDiagram');
        let updateIndex = selectedDiagram.groups.findIndex((x) => x.value === scope.oldValue);

        let exists = false;
        selectedDiagram.groups.forEach(function (group){
            if(group.label == newGroupName){
                exists = true;
                return;
            }
        });

        if(exists){
            component.find('notifLib').showToast({
                "title": "Info",
                "message": 'This group name "'+ newGroupName +'" already exists.'
            });
        }
        else{
            selectedDiagram.groups[updateIndex].label = selectedDiagram.groups[updateIndex].value = scope.newValue;
            component.set('v.selectedDiagram', selectedDiagram);
        }
    },

    onDiagramChanged : function(component, event, helper) {
        helper.onSaveDiagram(component, event, helper);
    },

    onCloneDiagram : function(component, event, helper) {
        helper.onCloneDiagram(component, event, helper);
    },
})
