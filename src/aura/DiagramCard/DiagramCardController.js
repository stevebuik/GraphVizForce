/**
 * Created by guan on 29/11/17.
 */
({
    onViewDiagram : function(component, event, helper){
        component.getEvent('onViewDiagram').setParams({scope:component.get('v.diagram')}).fire();
    }
})