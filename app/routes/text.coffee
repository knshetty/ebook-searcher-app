`import Ember from 'ember'`

TextRoute = Ember.Route.extend(

	setupController: (controller, model) ->
		# Purge unsaved data
		#model.rollback()

		# Source Model from parent-route
		controller.set('model', model)
)

`export default TextRoute`
