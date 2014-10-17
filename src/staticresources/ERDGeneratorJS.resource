(function () {
	'use strict';
	
	var button = Dropbox.createChooseButton({
		success: function(files) {
				var file = files[0].link;
				$c(globals.fileURL).val(file);
				$('#dropboxFileSelected').text(file);
		    },
	    linkType: 'direct',
	    multiselect: false,
	    extensions: ['.gv']});
	
	document.getElementById("pickDropboxContainer").appendChild(button);
	
	adjustTemplateMode();

}());

function adjustTemplateMode() {
	if ($c(globals.template).val() == 'CalloutTemplate') {
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
