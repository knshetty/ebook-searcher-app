# eBooks Searcher App

Here's an interactive eBook search tool [i.e. a Single-Page web application(SPA)], intended to be a technical example on how-to combine below technologies:

* [Ember.js](http://emberjs.com/) a SPA framework
* [Blockly](https://developers.google.com/blockly/) a visual programming editor library
* [IT-eBooks API](http://it-ebooks-api.info/) an open RESTful webservice to access eBooks information
	
### What can one do with this app?

* Search eBooks across multiple RESTful-resources
* Compose-&-Combine search queries & their results using Visual-Blocks
* Provides a set of interactive Visual-Blocks, where a mouse-click on a given Visual-Block produce's instant results.

### Ember.js highlights:

* Wraps the entire Blockly editor as an Ember component
* Each block is assigned a detected route
* Auto route-transitions are used for childern-block traversals

### Blockly hightlights:

* Custom blocks
	
### IT-eBooks API highlights:

* Only a single type of request is made to RESTful API, which is of type '/search/{query}'. Here the response is a paged result i.e. each page result is capped to 10 items.

## Prerequisites

You will need the following things properly installed on your computer.

* [Git](http://git-scm.com/)
* [Node.js](http://nodejs.org/) (with NPM) and [Bower](http://bower.io/)

## Installation

* `git clone https://github.com/knshetty/ebook-searcher-app.git` this repository
* change into the new directory
* `npm install`
* `bower install`

## Running / Development

* `ember server`
* Visit your app at [http://localhost:4200/ebook-searcher-app/](http://localhost:4200/ebook-searcher-app/).

### Code Generators

Make use of the many generators for code, try `ember help generate` for more details

### Building

* `ember build` (development)
* `ember build --environment production` (production)

## How-To-BootStrap this ember-cli project from scratch:

### 0. Create a basic ember-cli project:

	$ ember new ebook-searcher-app
	$ cd ebook-searcher-app/
	$ npm install && bower install
		
### 1. Install dependencies that help in build management:

	$ npm install --save-dev broccoli-merge-trees
	$ npm install --save-dev broccoli-static-compiler
	$ npm install ember-cli-coffeescript@0.10.0 --save-dev
	$ npm cache clean
	$ npm install
			
### 2. Install app specific dependencies:

	$ bower install bootstrap --save
	$ bower install ember-addons.bs_for_ember --save
	$ bower install openhab-blockly --save
			
### 3. Setup project-build environment

	Configure the file "Brocfile.js" for the build with following depedencies:
		i. "Bootstrap3" UI framework's dependencies
		ii. "Bootstrap-for-ember" dependencies
		iii. "Blockly" dependencies
		iv. "Index" page dependencies
		
### 4. Conduct a basic smoke test

	$ ember server
	Visit the running app at http://0.0.0.0:4200/

## Further Reading / Useful Links

* [ember.js](http://emberjs.com/)
* [ember-cli](http://www.ember-cli.com/)
* Development Browser Extensions
  * [ember inspector for chrome](https://chrome.google.com/webstore/detail/ember-inspector/bmdblncegkenkacieihfhpjfppoconhi)
  * [ember inspector for firefox](https://addons.mozilla.org/en-US/firefox/addon/ember-inspector/)

