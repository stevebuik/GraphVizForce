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
        console.log('@@@@ initialiseObjects called');
        let allObjects = component.get('v.allObjects');
        let diagram = component.get('v.selectedDiagram');
        let objects = [];
        allObjects.forEach(function (obj) {
            let objectInGroup = helper.isObjectInGroup(obj, diagram.groups);
            console.log('@@@@ objectInGroup', objectInGroup);
            if(!objectInGroup){
                objects.push(obj);
            }
        });

        objects.sort(helper.compare);
        component.set('v.objects', objects);
        console.log('@@@@ initialised objects:', objects.length);
    },

    isObjectInGroup : function(obj, groups){
        groups.forEach(function (group) {
            group.entities.forEach(function (selectedObj){
                console.log('@@@@ obj', obj);
                console.log('@@@@ selectedObj', selectedObj);
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

    generateUniqueGroupName : function(helper, groups, groupName){
        let nameList = [];
        groups.forEach(function(group){
            nameList.push(group.label);
        });
        let newName = helper.generateUniqueName(helper, nameList, groupName);
        return newName;
    },

    generateUniqueDiagramName : function(helper, diagrams, diagramName){
         let nameList = [];
         diagrams.forEach(function(diagram){
             nameList.push(diagram.label);
         });
         let newName = helper.generateUniqueName(helper, nameList, diagramName);
         return newName;
     },

    generateUniqueName : function(helper, nameList, targetName){
        nameList.forEach(function(name){
            console.log('existing name:', name);
            if(name == targetName){
                console.log('matches name');
                targetName = helper.generateUniqueName(helper, nameList, targetName + ' (1)');
            }
        });
        return targetName;
    },

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
        let diagramName = helper.generateUniqueDiagramName(helper, diagrams, selectedDiagram.label);
        let newDiagram = {label:diagramName, value:diagramName, visible:true, groups:selectedDiagram.groups};
        diagrams.push(newDiagram);
        diagrams.sort(helper.compare);
        component.set('v.diagrams', diagrams);
        component.set('v.selectedDiagram', newDiagram);
        helper.initialiseObjects(component, event, helper);
        alert('A new diagram ' + diagramName + ' has been cloned successfully.');
    },
})