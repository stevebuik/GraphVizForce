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
            //let content = 'digraph {a -> b}';
            //let content = "digraph \n" +
            //"{a -> b} \n";

            let content = 'digraph G { \n'+
                               'node [shape=plaintext, fontsize=12]; \n'+
                               'edge  [arrowhead=crow]; \n'+
                               'a [label=<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0"> \n'+
                                '                      <TR><TD PORT="c" BGCOLOR="gray">Object 1</TD></TR> \n'+
                                '                      <TR><TD PORT="d">second</TD></TR> \n'+
                                '                      <TR><TD PORT="e">third</TD></TR> \n'+
                                '         </TABLE>>]; \n'+
                               'b [label=<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0"> \n'+
                               '                       <TR><TD PORT="c" BGCOLOR="gray">Object 2</TD></TR> \n'+
                               '                       <TR><TD PORT="d">second</TD></TR> \n'+
                               '                       <TR><TD PORT="e">third</TD></TR> \n'+
                               '          </TABLE>>]; \n'+
                               'a:c -> b:c; \n'+
                           '}';

            console.log('@@@@ content after:', content);

            let erdMarkup = Viz(content, format);
            document.getElementById("graph").innerHTML = erdMarkup;
        }

    },

})