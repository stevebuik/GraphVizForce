========== MAIN
digraph G {
	splines=ortho; 
	graph [rankdir = "LR";]; 
	node [fontsize = "14";shape = "record";]; 
	edge [arrowhead="crow";];
	{{content}}
	}
========== CLUSTER
subgraph cluster_{{sequence}} { label = "{{name}}";
{{content}}}

========== ENTITY
{{name}} [label = " {{name}} "];
========== FIELD
{{name}}
========== RELATIONSHIP
{{from}} -> {{to}}
