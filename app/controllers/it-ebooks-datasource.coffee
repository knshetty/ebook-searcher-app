`import Ember from 'ember'`

ItEbooksDatasourceController = Ember.Controller.extend(

	# Dependency injection
	needs: ['application']

	# -------------------------
	# --- Declare Observers ---
	# -------------------------
	selectedBookChanged: ( ->

		@set('controllers.application.selectedItem', @selectedbook)

	).observes('selectedbook')

)

`export default ItEbooksDatasourceController`
