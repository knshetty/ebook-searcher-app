`import Ember from 'ember'`

JoinDatasourceRoute = Ember.Route.extend(

	_totalAvailable_ChildOutputItems: 0

	beforeModel: (transition) ->

		# Get passed-parameters with route
		params = @paramsFor(transition.targetName)
		
		# Get Block
		@block = Blockly.Block.getById(params.block_id, Blockly.selected.workspace)

		# Set Ember-Context
		@block._emberContext = @
		
		# -------------------------------------------------------------
		# Route the Childern-Blocks inorder to initialise there outputs
		# -------------------------------------------------------------
		if @block.childBlocks_.length > 0

			if !@block._isChildernRouteLoaded
		
				# Flag Descendant-Blocks are loading their routes
				@block._isChildernRouteLoaded = true

				for childBlock in @block.childBlocks_
					# Purge Child-Block's output
					delete childBlock._outputModel

				# Fire a single Child-Block route			
				for childBlock in @block.childBlocks_
					@routeToChildBlockAndRouteToThisBack(childBlock, @)
					break
		
			else 
				# Fire a single Child-Block route at-a-time
				for childBlock in @block.childBlocks_

					if !childBlock._outputModel
						@routeToChildBlockAndRouteToThisBack(childBlock, @)
						break

	model: (params) ->

		# Initialise an empty model
		aggregatedModels = Ember.A([])

		# Initialise Total-Available-ChildOutput-Items
		@set('_totalAvailable_ChildOutputItems', 0)

		# Obtain all Childern-Blocks output for aggregation		
		for childBlock in @block.childBlocks_			
			if childBlock._outputModel
				# Aggregate Child-Output
				aggregatedModels.pushObjects(childBlock._outputModel)
				
				# Aggregate Total-Available Child-Output-Items
				total = childBlock._totalAvailable + @_totalAvailable_ChildOutputItems
				@set('_totalAvailable_ChildOutputItems', total)
				@block._totalAvailable = total
		
		# Set this block's output
		@block._outputModel = aggregatedModels

		return aggregatedModels

	setupController: (controller, model) ->

		# Set block
		controller.set('block', @block)

		# Set Model
		controller.set('model', model)

		# Select a book
		if model.length > 0
			controller.set('selectedbook', model[0])

		# Set total number of availabe Child-Output
		controller.set('totalAvailable', @_totalAvailable_ChildOutputItems)
			
		# Set pagenated-count
		pagenatedCountVsTotal = controller.model.length + ' / ' + @_totalAvailable_ChildOutputItems
		controller.set('pagenatedCountVsTotal', pagenatedCountVsTotal)

		# Flag Descendant-Blocks outputs have been loaded & aggregated
		@block._isChildernRouteLoaded = false
		
		# Route back to Parent-Block
		if @block.id != Blockly.selected.id

			if @block.parentBlock_ != null
				controller.transitionToRoute(@block.parentBlock_.type, @block.parentBlock_.id) 

	# -------------------------------
	# --- Declare Local Functions ---
	# -------------------------------
	routeToChildBlockAndRouteToThisBack: (childBlock, self)->

		# Fire-up a promise to route Child-Block
		new Ember.RSVP.Promise((resolve)->
			Ember.run(-> 
				self.transitionTo(childBlock.type, childBlock.id).then( ->
					# Route back to this-Block
					resolve(self.transitionTo(self.block.type, self.block.id))
				)
			)
		)
)

`export default JoinDatasourceRoute`
