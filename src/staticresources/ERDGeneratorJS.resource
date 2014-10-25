(function () {
	'use strict';
	
	var button = Dropbox.createChooseButton({
		success: function(files) {
				var file = files[0].link;
				$c(globals.fields.fileURL).val(file);
				$('#dropboxFileSelected').text(file);
		    },
	    linkType: 'direct',
	    multiselect: false,
	    extensions: ['.gv']});
	
	document.getElementById("pickDropboxContainer").appendChild(button);
		
	templateChanged();
		
	$("#oauth").on("click", function(e) {
		e.preventDefault();
		var url = $(this).attr("href");
        window.open(url, "oauth", "width=400,height=600");		
	});

}());

function setDropboxToken(token) {
	$c(globals.fields.token).val(token);
}

function templateChanged() {
	adjustGeneratorButtons();
	setDownloadURL();
}

function setDownloadURL() {
	var templateSelected = $c(globals.fields.template).val();
	$("#download").attr("href", globals.templates[templateSelected]);
}

function adjustGeneratorButtons() {
	if ($c(globals.fields.template).val() == 'CalloutTemplate') {
		setTemplateMode('external');
	} else {
		setTemplateMode('resource');	
	}
}

function setTemplateMode(mode) {
	$.each(['#dropboxFileSelected','#pickDropboxContainer'], function(i, s) {
		$(s).css('display',mode == 'resource'?'none':'inline-block');
	});
}

//workaround the fact that jquery doesn't like the : characters in visualforce component ids
function $c(componentId) {
	return $(document.getElementById(componentId));
}
