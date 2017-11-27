({
	compare : function(a,b) {
        if (a.label < b.label)
            return -1;
        if (a.label > b.label)
            return 1;
        return 0;
    },
    
    generateUniqueGroupName : function(helper, groups, groupName){
        for(var i=0;i<groups.length;i++){
            let group = groups[i];
            if(group.label == groupName && group.value == groupName){
                return helper.generateUniqueGroupName(helper, groups, groupName + ' (1)');
            }
        }
        return groupName;
    },
    
    addObjectToGroup : function(component, helper, objectToAdd, groupValue){
        let objects = component.get('v.objects');
        let groups = component.get('v.groups');
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
        
        component.set('v.objects', objects);
        component.set('v.groups', groups);
    },
    
})