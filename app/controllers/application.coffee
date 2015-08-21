`import Ember from 'ember'`

ApplicationController = Ember.Controller.extend(

	selectedItem: null

	selectedDatasourceType: null

	datasourceTypes: [
		Ember.Object.create({title: 'Cloud'})
		Ember.Object.create({title: 'Mockup'})
	]

	blockToLoad: null

	# ---------------------
	# --- Action Events ---
	# ---------------------
	actions:
		goTo_IndexPage: ->
			@transitionToRoute('index')

		load_Example0: ->
			@set('blockToLoad', null)
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="it-ebooks_datasource" id="1" x="16" y="5"><field name="SEARCH_STRING">HTML5</field></block></xml>')

		load_Example1: ->
			@set('blockToLoad', null)
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="join_datasource" id="1" x="16" y="5"><mutation items="4"></mutation><value name="ADD0"><block type="it-ebooks_datasource" id="2"><field name="SEARCH_STRING">HTML5</field></block></value><value name="ADD1"><block type="it-ebooks_datasource" id="3"><field name="SEARCH_STRING">Java</field></block></value><value name="ADD2"><block type="it-ebooks_datasource" id="4"><field name="SEARCH_STRING">CoffeeScript</field></block></value><value name="ADD3"><block type="it-ebooks_datasource" id="5"><field name="SEARCH_STRING">Scala</field></block></value></block></xml>')

		load_Example2: ->
			@set('blockToLoad', null)
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="join_datasource" id="1" x="16" y="5"><mutation items="3"></mutation><value name="ADD0"><block type="it-ebooks_datasource" id="2"><field name="SEARCH_STRING">REST</field></block></value><value name="ADD1"><block type="it-ebooks_datasource" id="3"><field name="SEARCH_STRING">Single Page</field></block></value><value name="ADD2"><block type="join_datasource" id="4"><mutation items="2"></mutation><value name="ADD0"><block type="it-ebooks_datasource" id="5"><field name="SEARCH_STRING">CoffeeScript</field></block></value><value name="ADD1"><block type="it-ebooks_datasource" id="6"><field name="SEARCH_STRING">HTML5</field></block></value></block></value></block></xml>')

		load_Example3: ->
			@set('blockToLoad', null)
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="join_datasource" id="1" x="16" y="5"><mutation items="2"></mutation><value name="ADD0"><block type="join_datasource" id="2"><mutation items="2"></mutation><value name="ADD0"><block type="it-ebooks_datasource" id="3"><field name="SEARCH_STRING">HTML5</field></block></value></block></value><value name="ADD1"><block type="join_datasource" id="4"><mutation items="2"></mutation><value name="ADD0"><block type="it-ebooks_datasource" id="5"><field name="SEARCH_STRING">CSS</field></block></value></block></value></block></xml>')

)

`export default ApplicationController`
