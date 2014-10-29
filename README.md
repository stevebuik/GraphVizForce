Graphviz Force
========

An Entity Relationship Diagram generator in Graphviz format for Salesforce.com

<a href="https://githubsfdeploy.herokuapp.com/app/githubdeploy/stevebuik/GraphVizForce" target="deploy">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

###Getting Started

To run the generator, navigate to the ERD Generator tab. You may need to make the tab visible in your Profile.

You can configure which objects are included in the diagram by creating *Groups* in the *Configure Groups* tab.

Then just click the *Generate* button and you will see the generated content. 
This content needs to be saved to a file on your computer with a .gv extension. 
Then you can open the file using [Graphviz](http://www.graphviz.org) and export to a pdf or image file if required.

If you don't want to manually save the .gv file then you can enabled the *Generate to Dropbox* feature by:

1. Go to https://www.dropbox.com/developers/apps and click *Create App*
2. Choose these options 
    - Dropbox API app
    - Files and datastores
    - Yes My app only needs access to files it creates.
3. Enter any App Name
4. Enter https://c.ap1.visual.force.com/apex/erdoauth into the *Redirect URIs* filed and click add. 
Note that you need to change the ap1 in the url to be your Salesforce server name
5. In Salesforce Setup, go to *Develop/Custom Settings* and click on the *manage* link for ERD
6. Add a setting named *DropboxClientKey* with a value copied from the *App key* in your Dropbox API App 
7. Add a setting named *DropboxClientSecret* with a value copied from the *App secret* in your Dropbox API App 
8. Go back to the ERD Generator tab and you will now see a *Generate to Dropbox* link in the generate section. 
If you click this link and re-generate you should see a file being saved to your Dropbox folder.

###Templates

Diagrams are generated using a template system. Templates are *Static Resources* that have a description starting with #graphviztemplate. 
You can also use a template that is in a public Dropbox folder. The file must have a .gv extension. 
This is useful when changing templates because you can edit the file locally and Dropbox will automatically save it to the cloud.
If you are a developer you can use Eclipse or any other meta-data editor to create/edit Static Resources instead of using Dropbox.

This means you can create custom templates if you want or you can just use the basic included template(s).
If you create a nice template, please send us a sample - we'd like to include it for everyone to use. 

For more info on Graphviz syntax see http://www.graphviz.org/Documentation/dotguide.pdf

The easiest way to play with templates is to generate a diagram and open it in Graphviz. 
Then edit the .gv in any editor and Graphviz will automatically refresh. Once you are happy with the design, apply the changes to your template and re-generate.

###Motivation

This tool was not possible using Apex until the Summer 14 Release when Salesforce removed the limits on describes.

We built it to enable anyone to generate ERD Diagrams and to share what we've learned building tools like this. 

The code is split into modules to make it easier to understand for developers. 
There are a few techniques used in the code which you can copy and learn from:

- Dropbox File Chooser without OAuth [ERDGeneratorJS](https://github.com/stevebuik/GraphVizForce/blob/master/src/staticresources/ERDGeneratorJS.resource)
- Dropbox File Writer with OAuth [ERDDropboxAPI](https://github.com/stevebuik/GraphVizForce/blob/master/src/classes/ERDDropboxAPI.cls)
- Template generation from any data [TemplateEngine](https://github.com/stevebuik/GraphVizForce/blob/master/src/classes/TemplateEngine.cls)
- JQuery-UI widgets wrapped in a Visualforce Component [JQuerySelectable](https://github.com/stevebuik/GraphVizForce/blob/master/src/components/JQuerySelectable.component)
- Automatically upgraded saved Settings [ERDPersister](https://github.com/stevebuik/GraphVizForce/blob/master/src/classes/ERDPersister.cls) 

Look at the tests to learn how to use these classes.

###Roadmap

We welcome contributions from the community. If you want to add a feature, connect with one of us to ensure that someone else is not already doing it and then send us a pull request.

Here are some ideas that we are working on now
- Field Chooser for each object
- SFDC1 Tablet UI for the Generator Tab

Here are features that we need help with
- xdot renderer & [canviz](https://code.google.com/p/canviz/) previewer
- More Templates
- Lightning Component for the JQuery Selectable
- Displaying types with Fields
- Connecting Relationships to the correct Field using dot *ports*
- Displaying relationship types (Master Detail vs Lookup)
- Displaying relationship names

Note: we need help with the xdot render service. If you know Heroku well enough to get a buildpack working with the Graphviz dot CLI tool, we'd really appreciate your help.
  
### Contributors

Jason Guan [Github](https://github.com/jasong327) [LinkedIn](https://www.linkedin.com/pub/jason-guan/39/3a9/346) [Website](http://cyberlemons.com/)

Steve Buikhuizen [@stevebuik](https://twitter.com/stevebuik) [Github](https://github.com/stevebuik) [LinkedIn](https://www.linkedin.com/in/stevebuikhuizen) [Google+](https://plus.google.com/+SteveBuikhuizen)