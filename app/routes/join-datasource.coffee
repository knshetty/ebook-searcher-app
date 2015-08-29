`import Ember from 'ember'`

JoinDatasourceRoute = Ember.Route.extend(

	# ---------------------------------
	# --- Declare Private Variables ---
	# ---------------------------------
	_totalAvailable_ChildOutputItems: 0

	beforeModel: (transition) ->

		# Get parameter passed in the route url
		params = @paramsFor(transition.targetName)

		# Get visual-block
		@block = Blockly.Block.getById(params.block_id, Blockly.selected.workspace)

		# Set ember context
		@block._emberContext = @

		# ------------------------------------------
		# Get all the childern-block's outputs
		# Note! Transitioning to a child-block route
		# will automatically load it's outputs
		# ------------------------------------------
		if @block.childBlocks_.length > 0

			if !@block._isChildernRouteLoaded

				# Flagging descendant-block is loading it's route
				@block._isChildernRouteLoaded = true

				# --------------------------
				# Purge child-block's output
				# --------------------------
				for childBlock in @block.childBlocks_

					delete childBlock._outputModel

				# ---------------------------------------
				# Fire childern-block route one at-a-time
				# ---------------------------------------
				for childBlock in @block.childBlocks_

					@routeToChildBlockAndReturnBackThisRoute(childBlock, @)
					break

			else
				# ---------------------------------------
				# Fire childern-block route one at-a-time
				# ---------------------------------------
				for childBlock in @block.childBlocks_

					if !childBlock._outputModel

						@routeToChildBlockAndReturnBackThisRoute(childBlock, @)
						break

	model: (params) ->

		# Initialise model
		aggregatedModels = Ember.A([])

		# Initialise total number of available child-output items count
		@set('_totalAvailable_ChildOutputItems', 0)

		# -----------------------------------------
		# 1. Aggregate all childern-block's outputs
		# 2. Compute total number of available items count
		# -----------------------------------------
		for childBlock in @block.childBlocks_

			if childBlock._outputModel

				# Aggregation: Enter each child-block's output into a single collection
				aggregatedModels.pushObjects(childBlock._outputModel)

				# ---------------------------------------
				# Compute total number of available items
				# count within the child-block's output
				# ---------------------------------------
				total = childBlock._totalAvailable + @_totalAvailable_ChildOutputItems
				@set('_totalAvailable_ChildOutputItems', total)

				# Set total number of available items count property
				@block._totalAvailable = total

		# Set this block's output
		@block._outputModel = aggregatedModels

		return aggregatedModels

	setupController: (controller, model) ->

		# Set visual-block
		controller.set('block', @block)

		# Set ember model
		controller.set('model', model)

		# -------------------------------
		# Select an item within the model
		# -------------------------------
		if model.length > 0

			controller.set('selectedModelItem', model[0])

		# Set the total number of available items count
		controller.set('totalAvailable', @_totalAvailable_ChildOutputItems)

		# -------------------
		# Set pagenated-count
		# -------------------
		pagenatedCountVsTotal = controller.model.length +
														' / ' +
														@_totalAvailable_ChildOutputItems
		controller.set('pagenatedCountVsTotal', pagenatedCountVsTotal)

		# Flagging descendant-block's outputs have been loaded & aggregated
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
	routeToChildBlockAndReturnBackThisRoute: (childBlock, self) ->

		# -----------------------------------------
		# Initialise a promise to route child-block
		# -----------------------------------------
		new Ember.RSVP.Promise((resolve) ->

			Ember.run( ->

				self.transitionTo(childBlock.type, childBlock.id).then( ->

					# Route back to this-block
					resolve(self.transitionTo(self.block.type, self.block.id))

				)

			)

		)

)

`export default JoinDatasourceRoute`
