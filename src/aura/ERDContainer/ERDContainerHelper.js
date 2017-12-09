/**
 * Created by guan on 30/11/17.
 */
({
    compare : function(a,b) {
        if (a.label < b.label)
            return -1;
        if (a.label > b.label)
            return 1;
        return 0;
    },

    initialiseObjects : function(component, event, helper){
        let allObjects = component.get('v.allObjects');
        let selectedDiagram = component.get('v.selectedDiagram');
        let displayAllObjects = component.get('v.displayAllObjects');
        let objects = [];
        allObjects.forEach(function (obj) {
            let exists = false;
            selectedDiagram.groups.forEach(function (group) {
                group.entities.forEach(function (selectedObj){
                    if(obj.value == selectedObj.value){
                        console.log('found');
                        exists = true;
                        return;
                    }
                });
                if(exists) return;
            });
            if(!exists){
                obj.visible = displayAllObjects;
                objects.push(JSON.parse(JSON.stringify(obj)));
            }
        });

        objects.sort(helper.compare);
        component.set('v.objects', objects);
    },

    isObjectInGroup : function(obj, groups){
        groups.forEach(function (group) {
            group.entities.forEach(function (selectedObj){
                if(obj.value == selectedObj.value){
                    return true;
                }
            });
        });
        return false;
    },

    addObjectToGroup : function(component, helper, objectToAdd, groupValue){
        let objects = component.get('v.objects');
        let selectedDiagram = component.get('v.selectedDiagram');
        let groups = selectedDiagram.groups;
        console.log('addObjectToGroup > groupValue:', groupValue);
        let groupRemoved = false;
        let groupAdded = false;

        // Remove object from object list
        for(var i=0;i<objects.length;i++){
            let targetObject = objects[i];
            if(targetObject.value == objectToAdd.value){
                objects.splice(i, 1);
                groupRemoved = true;
                break;
            }
        }

        // Add object to group AND Remove object from current group
        for(var i=0;i<groups.length;i++){
            if(groupRemoved && groupAdded) break;

            let group = groups[i];

            group.entities.forEach(function (entity) {
                if(entity.value == objectToAdd.value){
                    let index = group.entities.findIndex((x) => x.value === entity.value);
                    if(index != -1){
                        group.entities.splice(index, 1);
                        groupRemoved = true;
                    }
                }
            });

            if(group.value == groupValue){
                group.entities.push(objectToAdd);
                group.entities.sort(helper.compare);
                groupAdded = true;
            }

        }

        selectedDiagram.groups = groups;
        component.set('v.objects', objects);
        component.set('v.selectedDiagram', selectedDiagram);
    },

    /*
    generateUniqueGroupName : function(helper, groups, newGroupName){
        let nameList = [];
        groups.forEach(function(group){
            nameList.push({label:group.label, value:group.value});
        });
        let newName = helper.generateUniqueName(helper, nameList, newGroupName);
        return newName;
    },

    generateUniqueDiagramName : function(helper, diagrams, newDiagramName){
         let nameList = [];
         diagrams.forEach(function(diagram){
             nameList.push({label:diagram.label, value:diagram.value});
         });
         let newName = helper.generateUniqueName(helper, nameList, newDiagramName);
         return newName;
     },

    generateUniqueName : function(helper, nameList, targetName){
        nameList.forEach(function(name){
            // Go through each existing name, check if new name matches existing name
            if(targetName == name.label){
                if()
                targetName = helper.generateUniqueName(helper, nameList, targetName + ' (1)');
            }
        });
        return targetName;
    },
    */

    onSaveDiagram : function(component, event, helper) {
        let diagrams = component.get('v.diagrams');
        let selectedDiagram = component.get('v.selectedDiagram');
        diagrams.forEach(function (diagram){
           if(diagram.value == selectedDiagram.value){
               let index = diagrams.findIndex((x) => x.value === diagram.value);
               diagrams[index] = selectedDiagram;
               component.set('v.diagrams', diagrams);
               return;
           }
        });
    },

    onCloneDiagram : function(component, event, helper) {

        helper.onSaveDiagram(component, event, helper);

        let diagrams = component.get('v.diagrams');
        let selectedDiagram = component.get('v.selectedDiagram');
        let diagramName = selectedDiagram.label + ' (1)';
        let newDiagram = {label:diagramName, value:diagramName, visible:true, groups:selectedDiagram.groups};
        diagrams.push(newDiagram);
        diagrams.sort(helper.compare);
        component.set('v.diagrams', diagrams);
        component.set('v.selectedDiagram', newDiagram);
        helper.initialiseObjects(component, event, helper);

        component.find('notifLib').showToast({
            "title": "Info",
            "message": 'A new diagram ' + diagramName + ' has been cloned successfully.'
        });
    },
})