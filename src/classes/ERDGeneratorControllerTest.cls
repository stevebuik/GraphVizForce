<apex:page controller="ERDGeneratorController" action="{!ensureDefaultDiagram}">

	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.js" 
		type="text/javascript"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.js" 
		type="text/javascript"></script>
    <script type="text/javascript" src="https://www.dropbox.com/static/api/2/dropins.js" 
    	id="dropboxjs" data-app-key="1nasijgpqxbicyu"></script>
    <script type="text/javascript">    
		// need separate jquery because of the apex:tabpanel
		// see http://salesforce.stackexchange.com/questions/21207/tab-panel-error
		var $110 = jQuery.noConflict( false );
    	var globals = {
    		fields: {
    			fileURL:  "{!$Component.generatorForm.generatorBlock.fileURL}",
    			token:	  "{!$Component.generatorForm.generatorBlock.oauthToken}",
    			template: "{!$Component.generatorForm.generatorBlock.template}"
    		},
    		templates: {
    			"DefaultTemplate" : "{!$Resource.DefaultTemplate}"
    		}
    	};
	</script>

	<style type="text/css">
        .textInput {width: 100%;}
	    .pbTitle {white-space: nowrap}
	    #titleContainer {margin: 5px 0px;}
	    #helpLink {
	    	float: right;
	    	margin: 0 10px 0 0;
	    }	    
	    #generatorTitle {margin-left: 22px; font-size:1.5em;}
	    .activeTab {
	    	font-size: 1.2em;
	    	background-color: #027c6f; 
	    	color:white !important; 
	    	background-image:none
	    }
    	.inactiveTab {
    		cursor: pointer;
	    	font-size: 1.2em;
    		background-color: lightgrey; 
	    	color:#555555 !important; 
    		background-image:none
    	}
    	.btnSave {
    		margin: 0 10px 0 20px !important;
    	}
	    .throbber {
	    	padding-left: 20px;
	    	margin: 0 10px; 
	    	font-size: 1.1em;
	    	color: #888;
	    	background: #66FF33 url("{!$Resource.WorkingImage}") no-repeat;}
	    #generatingLabel {
	    	margin: 5px 5px;
	    }
	    #generateContainer {
	    	margin: 10px 0 0 0;
	    }
	    #generateContainer > * {
	    	float:left;
	    	margin: 0 5px 2px 0;
	    }
	    #oauthComplete {
	    	display:none;
	    }
	    #dropboxFileSelected {
	    	padding: 2px 0 0 0;
	    	font-weight: bold;
	    }
	    #download {
	    	float: right;
	    }
	    .tabLeftOne {
    		min-height: 300px;
	    	width: 500px;
	    }
	    .tabLeftTwo {
    		min-height: 300px;
	    	width: 800px;
	    }
	    #groupsLeft {
    		min-height: 300px;
	    	width: 300px;
	    	float:left;
	    	margin: 0 20px 0 0;
	    }
	    #groupsRight {
	    	float:left;
	    }
	    .editorBlockTitle {
			color: #000;
			font-size: 1.3em;	    
			margin: 1em 0 0 1em;
			display: block;		
			float: left;
		}
	    .editorBlockHint {
			color: #000;
			font-size: 1.1em;	    
			margin: 1em 1em 0 0;
			display: inline-block;
			float: right;		
		}
	    .tabPageBlock
	    {
	    	height:400px;
	    }
	    .scrollableLeft
        {
        	height:240px;
        	overflow:scroll;
        }
	    .configHint {
	    	margin: 0 0 0 20px;
	    }
	    #generator {
	    	padding: 10px 0 0 0;
	    }
	    #generator h2 {
	    	font-size: 1.2em;
	    }
	    .generatedHint {
	    	font-size: 1.5em;
	    	margin: 2em 3em;
	    	display: block;
	    }
	    .clearfix {clear: both;}
    </style>
	<link rel="stylesheet" href="//code.jquery.com/ui/1.11.2/themes/smoothness/jquery-ui.css"></link>
    
    <apex:outputPanel id="messages">
   		<apex:messages />
   	</apex:outputPanel>
    
    <apex:form id="generatorForm">
    	<apex:pageBlock id="generatorBlock">
     		<apex:facet name="header">
    			<apex:outputPanel id="title">
    				<div id="titleContainer">
	    				<h2 id="generatorTitle">Diagram: {!currentSetting}</h2>
                    	<apex:commandButton styleClass="btnSave" value="Save" 
                    		action="{!saveSelectedSetting}" rerender="messages,title" 
                    		status="working" style="width:40px;">
                    	</apex:commandButton>
	    				<apex:actionStatus id="working">
	    					<apex:facet name="start">
	    						<span id="workingLabel" class="throbber">Working..</span>
	    					</apex:facet>
	    				</apex:actionStatus>
	    				<a id="helpLink" target="help" href="https://github.com/stevebuik/GraphVizForce">Help</a>
    				</div>
    			</apex:outputPanel>
    		</apex:facet>
    		
    		<apex:tabPanel switchType="client" id="tabPanel" selectedTab="tab1"
    			tabClass="activeTab" inactiveTabClass="inactiveTab">
    			<apex:tab label="Choose/Create Diagram" id="tab1" name="tab1">
    				<div class="tabLeftOne">
					    <apex:pageBlock id="blockSetting">
		                	<apex:pageBlockSection columns="3">
		                		
		                		<apex:outputText value="Choose a Diagram" />
		                		<apex:selectList id="settingPicklist" value="{!selectedSetting}" 
		                			size="1" style="width:150px;">
						            <apex:actionSupport event="onchange" action="{!loadSelectedSetting}" rerender="blockSetting,blockGroup,blockSelection,blockSingleObjectSelection,blockFieldSelection,blockIncludeFields,title" status="working" />
						            <apex:selectOptions value="{!settingSelectOptions}"/>
						        </apex:selectList>
		                    	<apex:commandButton id="btnDeleteSetting" value="Delete Diagram" 
		                    		action="{!deleteSelectedSetting}" rerender="blockSetting,blockGroup,blockSelection,blockSingleObjectSelection,blockFieldSelection,blockIncludeFields,title" 
		                    		status="working">
		                    	</apex:commandButton>
		                    	
		                		<apex:outputText value="Create a new Diagram" />
		                		<apex:inputText html-placeholder="Enter New Diagram Name" id="inpSettingName" styleClass="textInput" value="{!newSettingName}" />
		                    	<apex:commandButton id="btnSaveNewSetting" value="Save As" 
		                    		action="{!saveAsNewSetting}" rerender="messages,settingPicklist,title" status="working">
		                    		<apex:param value="{!newSettingName}"/>
		                    	</apex:commandButton>
		                    	
		                	</apex:pageBlockSection>
		                </apex:pageBlock>
					</div>
    			</apex:tab>
    			
    			<apex:tab label="Configure Groups" id="tab2" name="tab2">
    				<div id="groupsLeft">
		                <apex:pageBlock title="Groups" id="blockGroup">
		                	<apex:pageBlockSection >
		                    	<apex:inputText html-placeholder="Enter Group Name" id="inpGroupName" styleClass="textInput" value="{!newGroupName}" />
		                    	<apex:commandButton id="btnCreateGroup" value="Add" 
		                    		action="{!addNewGroupWithInput}" rerender="messages,groupTable" status="working">
		                    	</apex:commandButton>
		                	</apex:pageBlockSection>
                            <div class="scrollableLeft">
                            	<!-- <apex:actionFunction name="updateGroupSelection">
                            		<apex:param name
                            	</apex:actionFunction> -->
                                <apex:pageBlockTable id="groupTable" value="{!erdGroups}" var="group">
                                    <apex:column headerValue="Select Groups">
                                        <apex:inputCheckbox id="groupCheckBox" value="{!group.selected}">
                                        </apex:inputCheckbox>
                                        <apex:outputLabel value="{!group.groupName}" for="groupCheckBox" />
                                    </apex:column>
                                    <apex:column headerValue="Edit" width="30">
                                        <apex:commandButton id="editGroupButton" value="Edit >>" rerender="blockSelection,blockSingleObjectSelection,blockFieldSelection" status="working">
                                            <apex:param assignTo="{!selectedGroup}" value="{!group.groupName}" name="selectedERDGroup"/>
                                        </apex:commandButton>
                                    </apex:column>
                                    <apex:column headerValue="Delete" width="30">
                                        <apex:commandButton id="deleteGroupButton" value="Delete" action="{!deleteERDGroup}" rerender="blockGroup,blockSelection,blockSingleObjectSelection,blockFieldSelection" status="working">
                                            <apex:param assignTo="{!groupToDelete}" value="{!group.groupName}" name="ERDGroupToDelete"/>
                                        </apex:commandButton>
                                    </apex:column>
                                </apex:pageBlockTable>
                            </div>
		                </apex:pageBlock>
			      	</div>
			      	   
    				<div id="groupsRight">
		                <apex:outputPanel id="blockSelection">
							<div id="objectsForSelectedGroup" style="display:none;">{!objectsForSelectedGroup}</div>
							<apex:inputHidden id="selectedObjects" value="{!selectedObjects}">
							</apex:inputHidden>
			                <apex:pageBlock rendered="{!NOT(ISNULL(selectedGroup))}">
			                	<apex:facet name="header">
			                		<h2 class="editorBlockTitle">Group: {!selectedGroup}</h2>
			                		<span class="editorBlockHint">Hold down <strong>Ctrl/Cmd</strong> to Select Multiple Objects</span>
			                		<div class="clearfix"></div>
			                	</apex:facet>
								<c:JQuerySelectable selectableId="objectSelector" 
									optionsFieldId="objectsForSelectedGroup" 
									selectedFieldId="{!$Component.selectedObjects}"/> 
		                	</apex:pageBlock>
		                </apex:outputPanel>
					</div>		                	
		        </apex:tab>
		        
		        <apex:actionFunction name="refreshTab3" action="{!refreshObjectFieldSelection}" reRender="blockSingleObjectSelection,blockFieldSelection" oncomplete="debugger;" status="working" />
		        <apex:tab label="Configure Objects" id="tab3" name="tab3" ontabenter="document.getElementById('!{$Component.refreshButton}').click();">
		        	
		        	<div style="width:100%">
		        		<apex:commandButton value="Refresh2" onclick="refreshTab3();return false;" oncomplete="debugger;" reRender="blockSingleObjectSelection,blockFieldSelection" status="working" />
		        	
		        		<apex:commandButton id="refreshButton" value="Refresh" action="{!refreshObjectFieldSelection}" oncomplete="debugger;" reRender="blockSingleObjectSelection,blockFieldSelection" status="working" />
		        	</div>
		        	
					<div id="groupsLeft">
						<apex:pageBlock id="blockSingleObjectSelection" title="Select Object to Edit">
                            <div class="scrollableLeft">
                                <apex:pageBlockTable id="objectTable" value="{!allSelectedObjects}" var="selectedObj">
                                    <apex:column headerValue="Object Name">
                                        <apex:outputLabel value="{!selectedObj}" />
                                    </apex:column>
                                    <apex:column headerValue="Edit" width="30">
                                        <apex:commandButton id="editObjectButton" value="Edit >>" rerender="blockFieldSelection" status="working">
                                            <apex:param assignTo="{!selectedSingleObject}" value="{!selectedObj}" name="selectedSingleObjecToEditFields"/>
                                        </apex:commandButton>
                                    </apex:column>
                                </apex:pageBlockTable>
                            </div>
						</apex:pageBlock>
					</div>
					
    				<div id="groupsRight">
		                <apex:outputPanel id="blockFieldSelection">
							<div id="allFieldsForSelectedObject" style="display:none;">{!allFieldsForSelectedObject}</div>
							<apex:inputHidden id="selectedObjectFields" value="{!selectedObjectFields}"/>
			                <apex:pageBlock rendered="{!NOT(ISNULL(selectedSingleObject))}">
			                	<apex:facet name="header">
			                		<h2 class="editorBlockTitle">Object: {!selectedSingleObject}</h2>
			                		<span class="editorBlockHint">Hold down <strong>Ctrl/Cmd</strong> to Select Multiple Fields</span>
			                		<div class="clearfix"></div>
			                	</apex:facet>
								<c:JQuerySelectable selectableId="fieldSelector" 
									optionsFieldId="allFieldsForSelectedObject" 
									selectedFieldId="{!$Component.selectedObjectFields}"/> 
		                	</apex:pageBlock>
		                </apex:outputPanel>
					</div>	
		         	
		        </apex:tab>
    			<apex:tab label="Options" id="tab4" name="tab4">
	            	<div class="tabLeftOne">
			            <apex:pageBlock id="blockIncludeFields">
				            <apex:inputCheckbox id="fieldsCheckbox" value="{!includeFields}" />
						    <apex:outputLabel value="Include Fields" for="fieldsCheckbox" />
						    <span class="configHint">Show fields in the diagram. Does not affect your field selections.</span>
				        </apex:pageBlock>
					</div>
    			</apex:tab>
		        
    		</apex:tabPanel>
    		
            <div id="generator">
				<h2>ERD Content</h2>
			    <div id="generateContainer">
		    		<apex:commandButton value="Generate" action="{!generateERD}" 
		    			rerender="messages,generated" status="generating"/>
		    		<span id="templateLabel">Template:</span>
			    	<apex:selectList id="template" size="1" value="{!template}" 
			    		onChange="templateChanged();">
			    		<apex:selectOptions value="{!templates}"/>
			    	</apex:selectList>
			    	<span id="dropboxFileSelected"></span>
			    	<span id="pickDropboxContainer"></span>
		    		<apex:inputHidden id="fileURL" value="{!fileURL}" />
		    		<apex:outputPanel rendered="{!isDropboxEnabled}">
				    	<a id="oauth" href="{!$Page.ERDOAuth}?start=true">Generate to Dropbox</a>
				    	<span id="oauthComplete">Dropbox Generation Enabled</span>
			    		<apex:inputHidden id="oauthToken" value="{!oauthToken}" />
		    		</apex:outputPanel>
			    	<a id="download" target="download">Download Template</a>
			    </div>
			    <div style="clear: both;"></div>
			    <div>
				    <apex:actionStatus id="generating">
	   					<apex:facet name="start">
	   						<div id="generatingLabel" class="throbber">Generating..</div>
	   					</apex:facet>
	   				</apex:actionStatus>			    
	   			</div>
	   			<apex:outputPanel id="generated">
	               	<apex:inputTextarea value="{!generatedContent}" 
	               		rendered="{!LEN(generatedContent) != 0}" rows="20" style="width:100%;" />
	               	<apex:outputPanel styleClass="generatedHint" rendered="{!LEN(generatedContent) == 0}">
	               		When you click the "Generate" button, Graphviz code will appear here. Cut/Paste this code to Graphviz to see it as a diagram.
	               	</apex:outputPanel>
               	</apex:outputPanel>
            </div>
        </apex:pageBlock>
    </apex:form>

    <script type="text/javascript" src="{!$Resource.ERDGeneratorJS}"></script>

</apex:page>