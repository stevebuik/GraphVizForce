({
    onAddObject : function(component, event, helper) {
        component.getEvent('onAddObject').setParams(event.getParams()).fire();
    },
    
    onObjectClicked : function(component, event, helper) {
        component.getEvent('onObjectClicked').setParams(event.getParams()).fire();
    },
    
    onSearchObject : function(component, event, helper) {
        let objects = component.get('v.objects');
        let term = component.get('v.searchTerm').toLowerCase();
        objects.forEach(function(object){
            object.visible = (term == '' || object.label.toLowerCase().indexOf(term) != -1);
        });
        component.set('v.objects', objects);
    },
    
})