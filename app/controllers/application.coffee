`import Ember from 'ember'`

ApplicationController = Ember.Controller.extend(

	selectedItem: null

	selectedItemUrl: 'http://it-ebooks.info/'

	selectedDatasourceType: null

	datasourceTypeSelections: [
		Ember.Object.create( {title: 'Cloud'} )
		Ember.Object.create( {title: 'Mockup'} )
	]

	blockToLoad: null

	aboutModalButtons: [
		Ember.Object.create( {title: 'Close', clicked:"cancelAbout", dismiss: 'modal'} )
	]

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
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="join_datasource" id="1" x="16" y="5"><mutation items="4"></mutation><field name="DESCRIPTION">My Favourite Topics</field><value name="ADD0"><block type="it-ebooks_datasource" id="2"><field name="SEARCH_STRING">HTML5</field></block></value><value name="ADD1"><block type="it-ebooks_datasource" id="3"><field name="SEARCH_STRING">Java</field></block></value><value name="ADD2"><block type="it-ebooks_datasource" id="4"><field name="SEARCH_STRING">CoffeeScript</field></block></value><value name="ADD3"><block type="it-ebooks_datasource" id="5"><field name="SEARCH_STRING">Scala</field></block></value></block></xml>')

		load_Example2: ->
			@set('blockToLoad', null)
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="join_datasource" id="1" x="16" y="5"><mutation items="3"></mutation><field name="DESCRIPTION">Web</field><value name="ADD0"><block type="it-ebooks_datasource" id="2"><field name="SEARCH_STRING">REST</field></block></value><value name="ADD1"><block type="it-ebooks_datasource" id="3"><field name="SEARCH_STRING">Single Page</field></block></value><value name="ADD2"><block type="join_datasource" id="4"><mutation items="2"></mutation><field name="DESCRIPTION">Language</field><value name="ADD0"><block type="it-ebooks_datasource" id="5"><field name="SEARCH_STRING">CoffeeScript</field></block></value><value name="ADD1"><block type="it-ebooks_datasource" id="6"><field name="SEARCH_STRING">HTML5</field></block></value></block></value></block></xml>')

		load_Example3: ->
			@set('blockToLoad', null)
			@set('blockToLoad', '<xml xmlns="http://www.w3.org/1999/xhtml"><block type="join_datasource" id="1" x="16" y="5"><mutation items="2"></mutation><field name="DESCRIPTION">Web Know-How</field><value name="ADD0"><block type="join_datasource" id="2"><mutation items="2"></mutation><field name="DESCRIPTION">Markup</field><value name="ADD0"><block type="it-ebooks_datasource" id="3"><field name="SEARCH_STRING">HTML5</field></block></value></block></value><value name="ADD1"><block type="join_datasource" id="4"><mutation items="2"></mutation><field name="DESCRIPTION">Styling</field><value name="ADD0"><block type="it-ebooks_datasource" id="5"><field name="SEARCH_STRING">CSS</field></block></value></block></value></block></xml>')

		showAbout: ->
			Bootstrap.ModalManager.show('aboutModal')

		cancelAbout: ->
			Bootstrap.NM.push('About Modal was cancelled', 'info')

	# -------------------------
	# --- Declare Observers ---
	# -------------------------

	selectedEbookChanged: ( ->

		if @selectedDatasourceType.title == 'Cloud'

			url = 'http://it-ebooks.info/search/?q=' + @selectedItem.isbn + '&type=isbn'
			@set('selectedItemUrl', url)

	).observes('selectedItem')

)

`export default ApplicationController`
