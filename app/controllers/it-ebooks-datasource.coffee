`import Ember from 'ember'`

ItEbooksDatasourceController = Ember.Controller.extend(

	# Dependency injection
	needs: ['application']

	# -------------------------
	# --- Declare Observers ---
	# -------------------------
	selectedEbookChanged: ( ->

		@set('controllers.application.selectedItem', @selectedEbook)

	).observes('selectedEbook')

)

`export default ItEbooksDatasourceController`
