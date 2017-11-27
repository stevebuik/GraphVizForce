/**
 * Created by guan on 27/11/17.
 */
({
    doInit : function(component, event, helper){
        //let diagramBody = document.getElementById('erdWeb');
        //console.log('diagramBody', diagramBody);
        //let diagram = Viz("digraph { a -> b; }");
        //document.body.innerHTML += Viz("digraph { a -> b; }");
    },

    handleUserGuideEvent : function(component, event, helper){
        let step = event.getParam('scope');
        let showPreview = component.get('v.showPreview');
        component.set('v.showPreview', showPreview || step == 'step3');
    },
})