({
    /*
	handleGroupChanged : function(component, helper) {
        
        var dropZones = document.querySelectorAll('[data-drop-effect]');
        [].forEach.call(dropZones, function(elt){
            elt.addEventListener('dragenter', function(e){helper.onDragEnter(component, helper, e);});
            elt.addEventListener('dragleave', function(e){helper.onDragLeave(component, helper, e);});
            elt.addEventListener('dragover', helper.onDragOver);
            elt.addEventListener('drop', function(e){helper.onDrop(component, helper, e);});
        });
	},
    
    onDragEnter : function(component, helper, e){
        if(e.target.nodeType == 1) {
			e.preventDefault();
            let target = helper.closest(e.target, '.slds-box');
            target.classList.add("drag-enter");
        }
    },
    
    onDragLeave : function(component, helper, e){
        if(e.target.nodeType == 1) {
            e.preventDefault();
            e.target.classList.remove("drag-enter");
        }
    },

    onDragOver : function(component, helper, e){
        if(e.target.nodeType == 1) {
            e.preventDefault();
            e.dataTransfer.dropEffect = 'copy';
            e.stopPropagation();
        }
    },
    
    onDrop : function(component, helper, e){
        if(e.target.nodeType == 1) {
            e.preventDefault();
            e.target.classList.remove("drag-enter");
			let value = JSON.parse(e.dataTransfer.getData("value"));
            let dropTarget = helper.closest(e.target, '.dropTarget');
            let group = dropTarget.getAttribute('data-group');
            console.log('onDrop group:', group);
            component.getEvent('onDragObjectToGroup').setParams({scope:{group:group, object:value}}).fire();
        }
    },
    */
	
    // Find the closest parent by selector
    closest : function(el, selector) {
        var matchesFn;
    
        // find vendor prefix
        ['matches','webkitMatchesSelector','mozMatchesSelector','msMatchesSelector','oMatchesSelector'].some(function(fn) {
            if (typeof document.body[fn] == 'function') {
                matchesFn = fn;
                return true;
            }
            return false;
        })
    
        var parent;
    
        // traverse parents
        while (el) {
            parent = el.parentElement;
            if (parent && parent[matchesFn](selector)) {
                return parent;
            }
            el = parent;
        }
    
        return null;
    }
})