(function () {
	
	var button = Dropbox.createChooseButton({
		success: function(files) {
				var file = files[0].link;
				$c(globals.fields.fileURL).val(file);
				$110('#dropboxFileSelected').text(file);
		    },
	    linkType: 'direct',
	    multiselect: false,
	    extensions: ['.gv']});
	
	document.getElementById("pickDropboxContainer").appendChild(button);
		
	templateChanged();
		
	$110("#oauth").on("click", function(e) {
		e.preventDefault();
		var url = $110(this).attr("href");
        window.open(url, "oauth", "width=600,height=400");		
	});

}());

function setDropboxToken(token) {
	$c(globals.fields.token).val(token);
	$110("#oauth").css("display", "none");
	$110("#oauthComplete").css("display", "inline-block");
}

function updateObjectsTab() {
	$c(globals.fields.fieldSelectorContainer).css("display", "none");
	refreshTab3();
}

function templateChanged() {
	adjustGeneratorButtons();
	setDownloadURL();
}

function setDownloadURL() {
	var templateSelected = $c(globals.fields.template).val();
	$110("#download").attr("href", globals.templates[templateSelected]);
}

function adjustGeneratorButtons() {
	if ($c(globals.fields.template).val() == 'CalloutTemplate') {
		setTemplateMode('external');
	} else {
		setTemplateMode('resource');	
	}
}

function setTemplateMode(mode) {
	$110.each(['#dropboxFileSelected','#pickDropboxContainer'], function(i, s) {
		$110(s).css('display',mode == 'resource'?'none':'inline-block');
	});
}

//workaround the fact that jquery doesn't like the : characters in visualforce component ids
function $c(componentId) {
	return $110(document.getElementById(componentId));
}

/*********************Javascripts to put Graphviz to web**********************/
function inspect(s) {
	return "<pre>" + s.replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\"/g, "&quot;") + "</pre>"
}
  
function convertERDContentToMarkup(content, format, engine) {
	var result;
	try {
		result = Viz(content, format, engine);
		if (format === "svg")
			return result;
		else
			return inspect(result);
    } catch(e) {
		return inspect(e.toString());
	}
}

function generateERDToWeb(content)
{
	var erdMarkup = convertERDContentToMarkup(content,"svg");
	$c(globals.fields.downloadFile).css("display", "block");
	document.getElementById("diagramContainer").innerHTML = erdMarkup;
}

