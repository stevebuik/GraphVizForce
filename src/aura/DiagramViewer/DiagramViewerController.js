/**
 * Created by guan on 27/11/17.
 */
({
    doInit : function(component, event, helper){



    },

    handleUserGuideEvent : function(component, event, helper){

        let step = event.getParam('scope');
        if(step == 'step3'){
            let format = 'svg';
            let content = 'digraph  {a -> b}';
            let erdMarkup = Viz(content, format);
            document.getElementById("graph").innerHTML = erdMarkup;
        }

    },
})