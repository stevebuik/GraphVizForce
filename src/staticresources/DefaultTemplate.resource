========== MAIN
digraph G {
	size ="8.5,11!";
	graph [rankdir = "LR";]; 
	node [fontsize = "14";]; 
	edge [arrowhead="crow";];
	{{content}}
	}
========== CLUSTER
subgraph cluster_{{sequence}} { label = "{{name}}";
{{content}}}

========== ENTITY
  {{name}} [shape=box, label=<<table cellspacing="0" cellpadding="5" cellborder="0" border="0"><tr><td 
      align="left" port="header" bgcolor="#ffffff"><font align="left" color="#000000" point-size="10">@{{name}}<br
      align="left"/></font><font color="#000000">{{name}}<br align="left"/></font></td></tr></table>>,
      style=dashed]

========== RELATIONSHIP
{{from}} -> {{to}}
========== FIELD
{{name}}
