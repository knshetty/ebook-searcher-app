`import Ember from 'ember'`

JoinDatasourceController = Ember.Controller.extend(

	# Dependency injection
	needs: ['application']

	# -------------------------
	# --- Declare Observers ---
	# -------------------------
	selectedBookChanged: ( ->

		@set('controllers.application.selectedItem', @selectedModelItem)

	).observes('selectedModelItem')

)

`export default JoinDatasourceController`
