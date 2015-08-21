`import Ember from 'ember'`

JoinDatasourceRoute = Ember.Route.extend(

	_totalAvailable_ChildOutputItems: 0

	beforeModel: (transition) ->

		# Get parameter passed with the route url
		params = @paramsFor(transition.targetName)

		# Get Block
		@block = Blockly.Block.getById(params.block_id, Blockly.selected.workspace)

		# Set Ember-Context
		@block._emberContext = @

		# ------------------------------------------
		# Get all the childern-block's outputs
		# Note! Transitioning to a child-block route
		# will automatically load it's outputs
		# ------------------------------------------
		if @block.childBlocks_.length > 0

			if !@block._isChildernRouteLoaded

				# Flag descendant-block is loading it's route
				@block._isChildernRouteLoaded = true

				# --------------------------
				# Purge child-block's output
				# --------------------------
				for childBlock in @block.childBlocks_

					delete childBlock._outputModel

				# ----------------------------------
				# Fire a child-block route at-a-time
				# ----------------------------------
				for childBlock in @block.childBlocks_

					@routeToChildBlockAndReturnBackThisRoute(childBlock, @)
					break

			else
				# ----------------------------------
				# Fire a child-block route at-a-time
				# ----------------------------------
				for childBlock in @block.childBlocks_

					if !childBlock._outputModel

						@routeToChildBlockAndReturnBackThisRoute(childBlock, @)
						break

	model: (params) ->

		# Initialise an empty model
		aggregatedModels = Ember.A([])

		# Initialise total number of available child-output items
		@set('_totalAvailable_ChildOutputItems', 0)

		# -----------------------------------------
		# 1. Aggregate all childern-block's outputs
		# 2. Compute 'totalAvailable' property
		# -----------------------------------------
		for childBlock in @block.childBlocks_

			if childBlock._outputModel

				# Aggregation: Enter each child-block's output into a single collection
				aggregatedModels.pushObjects(childBlock._outputModel)

				# Compute total number of available child-block's output items
				total = childBlock._totalAvailable + @_totalAvailable_ChildOutputItems
				@set('_totalAvailable_ChildOutputItems', total)

				# Set this totalAvailable property
				@block._totalAvailable = total

		# Set this block's output
		@block._outputModel = aggregatedModels

		return aggregatedModels

	setupController: (controller, model) ->

		# Set block
		controller.set('block', @block)

		# Set Ember-Model
		controller.set('model', model)

		# -----------------------------
		# Select an item with the model
		# -----------------------------
		if model.length > 0

			controller.set('selectedModelItem', model[0])

		# Set total number of available child-block's outputs
		controller.set('totalAvailable', @_totalAvailable_ChildOutputItems)

		# -------------------
		# Set pagenated-count
		# -------------------
		pagenatedCountVsTotal = controller.model.length +
														' / ' +
														@_totalAvailable_ChildOutputItems
		controller.set('pagenatedCountVsTotal', pagenatedCountVsTotal)

		# Flag descendant-block's outputs have been loaded & aggregated
		@block._isChildernRouteLoaded = false

		# --------------------------
		# Route back to parent-block
		# --------------------------
		if @block.id != Blockly.selected.id

			if @block.parentBlock_ != null

				controller.transitionToRoute(
					@block.parentBlock_.type, @block.parentBlock_.id
				)

	# -------------------------------
	# --- Declare Local Functions ---
	# -------------------------------
	routeToChildBlockAndReturnBackThisRoute: (childBlock, self)->

		# -----------------------------------------
		# Initialise a promise to route child-block
		# -----------------------------------------
		new Ember.RSVP.Promise((resolve)->

			Ember.run(->

				self.transitionTo(childBlock.type, childBlock.id).then( ->

					# Route back to this-block
					resolve(self.transitionTo(self.block.type, self.block.id))

				)

			)

		)

)

`export default JoinDatasourceRoute`
