`import Ember from 'ember'`

GoogleBooksDatasourceController = Ember.Controller.extend(

	# Dependency injection
	needs: ['application']

	# -------------------------
	# --- Declare Observers ---
	# -------------------------
	selectedEbookChanged: ( ->

		@set('controllers.application.selectedItem', @selectedEbook)

	).observes('selectedEbook')

)

`export default GoogleBooksDatasourceController`
