========== MAIN
digraph G {
	graph [rankdir=LR,nodesep=1.0]; 
	node  [shape=plaintext,fontsize=14]; 
	edge  [arrowhead=crow];
	{{content}}
}
========== CLUSTER

subgraph cluster_{{sequence}} { label = "{{name}}";
	style="rounded, filled";
	fillcolor={{color}};
	node [style=filled,color=white];

{{content}}
	}

========== ENTITY

{{name}} [label=<<table border="0" cellborder="1" cellspacing="0" color="#808080" port="{{name}}">
			<tr><td bgcolor="gray" colspan="2">{{name}}</td></tr>
		{{fields}}
		</table>>]

========== MD_RELATIONSHIP
	edge [style=solid]
	{{from}} -> {{to}} 
	
========== LOOKUP_RELATIONSHIP
	edge [style=dashed]
	{{from}} -> {{to}}
	
========== FIELD
	<tr><td>{{name}}</td><td>{{fieldType}}</td></tr>
