`import Ember from 'ember'`

BlocklyBasicComponent = Ember.Component.extend(
	
	tagName: 'div'

	classNames: ['ember-blockly']
	
	workspace: null
	
	allBlocks_Initial: null
	
	blockVisuals: Ember.A([])
	selectedBlockVisual: null
	
	
	didInsertElement: ->
		self = @
		
		# --------------------------
		# --- Initialise Blockly ---
		# --------------------------
		# Create a blockly-editor with toolbox
		@workspace = Blockly.inject(
						'blocklyDiv',
						{media: 'media/',
						toolbox: self.$('.blocky-basic-toolbox').get(0)})
		
		# Setup Workspace's parent (i.e. ember-component class)
		@workspace._parent = @
		
		
		# ----------------------------
		# --- Handle Custom Blocks ---
		# ----------------------------
		# Add Custom Blocks
		@addCustomBlockWithCodeGenerator_Itebooks_Datasource(@)
		@addCustomBlockWithCodeGenerator_Join_Datasource(@)
		
		
		# ---------------------------------
		# --- Populate Workspace Editor ---
		# ---------------------------------
		# Configuration initial blocks in the editor
		xml_text = @get('blockToLoad')
		if xml_text
			xml = Blockly.Xml.textToDom(xml_text)
			Blockly.Xml.domToWorkspace(@workspace, xml)
		
		###		
		Blockly.Xml.domToWorkspace(
			@workspace, 
			self.$('.blocky-basic-initial-blocks9').get(0))
		###	
		
		# ----------------------------
		# --- Setup Event-Handlers ---
		# ----------------------------
		# Add Event-Handler: For each block in the Workspace
		@allBlocks_Initial = Blockly.mainWorkspace.getAllBlocks()
		for block in @allBlocks_Initial
			Blockly.bindEvent_(block.getSvgRoot(), 
							   'mouseup', 
							   block, 
							   @blockOnClick)
			
			# Get all Block-Visuals as ember objects
			@blockVisuals.pushObject(Ember.Object.create({block:block}))
      
		# Add Event-Handler: For newly-added/removed 
		# blocks to the Workspace
		@workspace.addChangeListener(@workspaceOnModification)

	
	
	# ---------------------
	# --- Action Events ---
	# ---------------------
	actions:
		run: ->
			console.log '--- Clicked: Run Button ---'
			
			# Generate JavaScript code
			window.LoopTrap = 1000
			Blockly.JavaScript.INFINITE_LOOP_TRAP = 'if (--window.LoopTrap == 0) throw "Infinite loop.";\n'
			code = Blockly.JavaScript.workspaceToCode(@workspace)
			Blockly.JavaScript.INFINITE_LOOP_TRAP = null
			
			# Run JavaScript code
			try
				eval(code)
			catch error
				alert error
				
			
		show_Code: ->
			console.log '--- Clicked: ShowCode Button ---'

			# Generate JavaScript code and display it.
			Blockly.JavaScript.INFINITE_LOOP_TRAP = null
			code = Blockly.JavaScript.workspaceToCode(@workspace)
			alert(code)
			
		show_WorkspaceAsXml: ->
			console.log '--- Clicked: ShowWorkspace Button ---'

			# Generate XML from blocks on the workspace and display it.
			xml = Blockly.Xml.workspaceToDom(@workspace)
			xml_text = Blockly.Xml.domToText(xml)
			console.log xml_text
			alert(xml_text)
	
	
	# -------------------------------
	# --- Declare Local Functions ---
	# -------------------------------
	# Response Event: On block selection
	blockOnClick: ->
		# Avoiding event propagation to other stacked/connected blocks
		if Blockly.selected.id == @.id
			parent = Blockly.mainWorkspace._parent
			selectedItem = parent.blockVisuals.
							findBy('block.id', Blockly.selected.id)
			
			selectedItem.block._outputModel = Ember.A([])
			selectedItem.block._isChildernRouteLoaded = false
			
			parent.set('selectedBlockVisual', selectedItem)
	
	# Response Event: On Workspace modification, such as 
	# addition/removal of blocks
	workspaceOnModification: ->
		allBlocks_Latest = Blockly.mainWorkspace.getAllBlocks()
		parent = Blockly.mainWorkspace._parent
		
		# On-changes to the number of blocks present in Workspace
		if allBlocks_Latest.length == parent.allBlocks_Initial.length
			return
		
		# On-addition of a new block to Workspace
		else if allBlocks_Latest.length > parent.allBlocks_Initial.length
			newBlock = Blockly.selected
			Blockly.bindEvent_(newBlock.getSvgRoot(), 
							   'mouseup', 
							   newBlock, 
							   parent.blockOnClick)
			parent.allBlocks_Initial.push(newBlock)
			
			# Block-Visual: Add new item
			parent.blockVisuals.pushObject(
				Ember.Object.create({block:newBlock}))
		
		# On-removal of a block from Workspace
		else if allBlocks_Latest.length < parent.allBlocks_Initial.length
			for id in parent.allBlocks_Initial.getEach('id')
				if !allBlocks_Latest.findBy('id', id)
					# Block-Visual: Remove an item
					deletedBlock = parent.allBlocks_Initial.
												findBy('id', id)
					parent.blockVisuals.removeObject(
						parent.blockVisuals.
							findBy('block.id', deletedBlock.id))
					parent.set('selectedBlockVisual', null)
			parent.allBlocks_Initial = allBlocks_Latest
		
	# -----------------------------------------------
	# --- Declare Custom Blocks + Code Generators ---
	# -----------------------------------------------
	################################
	# 'It-ebooks - Datasource' Block
	################################
	addCustomBlockWithCodeGenerator_Itebooks_Datasource: (context)-> 
		# Custom-block declaration
		# v0.2 Block Factory URL => https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#ky4fee
		# v0.1 Block Factory URL => https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#kkjtrt
		Blockly.Blocks['it-ebooks_datasource'] = {
			init: ->
				@appendDummyInput()
					.appendField(new Blockly.FieldImage("media/icons/ebook_icon.png", 30, 30, "ebook_icon"))
					.appendField("IT eBooks - Datasource")
				@appendDummyInput()
					.setAlign(Blockly.ALIGN_RIGHT)
					.appendField("Title / Author Search:")
					.appendField(new Blockly.FieldTextInput("HTML5"), "SEARCH_STRING")
				@setOutput(true)
				@setColour(290)
				@setTooltip('Search eBooks on http://it-ebooks.info')
				@setHelpUrl('')
		}
		
		# Code-generator: JavaScript 
		Blockly.JavaScript['it-ebooks_datasource'] = (block) ->
			text_search_string = block.getFieldValue('SEARCH_STRING')
			theUrl = "http://it-ebooks-api.info/v1/search/restful"
			code = "var xmlHttp = new XMLHttpRequest();" +
				   "xmlHttp.open( 'GET', 'http://it-ebooks-api.info/v1/search/restful', false );" +
				   "xmlHttp.send( null );" +
				   "var response = xmlHttp.responseText;"
			# TODO: Change ORDER_NONE to the correct strength.
			return [code, Blockly.JavaScript.ORDER_NONE];
			
	###########################
	# 'Join - Datasource' Block
	###########################
	addCustomBlockWithCodeGenerator_Join_Datasource: (context)-> 
		# Custom-block declaration
		# Source: https://github.com/google/blockly/blob/e3009310713209e80acc58a49d677d69f80d7b70/blocks/text.js @ line 69 (i.e. Blockly.Blocks['text_join'])
		Blockly.Blocks['join_datasource'] = {
			# Block for creating a string made up of any number of elements of any type.
			init: ->
				@itemCount_ = 2
				@updateShape_()
				@setOutput(true, 'String')
				@setMutator(new Blockly.Mutator(['text_create_join_item']))
				@setColour(290)
				@setTooltip('Combine several datasources output together')
				@setHelpUrl('')
			
			###
			# Create XML to represent number of text inputs.
			# @return {Element} XML storage element.
			# @this Blockly.Block
			###
			mutationToDom: ->
				container = document.createElement('mutation')
				container.setAttribute('items', @itemCount_)
				return container
			
			###
			# Parse XML to restore the text inputs.
			# @param {!Element} xmlElement XML storage element.
			# @this Blockly.Block
			###
			domToMutation: (xmlElement) ->
				@itemCount_ = parseInt(xmlElement.getAttribute('items'), 10)
				@updateShape_()
			
			###
			# Populate the mutator's dialog with this block's components.
			# @param {!Blockly.Workspace} workspace Mutator's workspace.
			# @return {!Blockly.Block} Root block in mutator.
			# @this Blockly.Block
			###
			decompose: (workspace) ->
				containerBlock = Blockly.Block.obtain(workspace, 'text_create_join_container')
				containerBlock.initSvg()
				connection = containerBlock.getInput('STACK').connection
				for num in [0..@itemCount_-1]
					itemBlock = Blockly.Block.obtain(workspace, 'text_create_join_item')
					itemBlock.initSvg()
					connection.connect(itemBlock.previousConnection)
					connection = itemBlock.nextConnection
				return containerBlock
				
			###
			# Reconfigure this block based on the mutator dialog's components.
			# @param {!Blockly.Block} containerBlock Root block in mutator.
			# @this Blockly.Block
			###
			compose: (containerBlock) ->
				itemBlock = containerBlock.getInputTargetBlock('STACK')
				
				# Count number of inputs.
				connections = []
				i = 0
				while itemBlock
					connections[i] = itemBlock.valueConnection_
					itemBlock = itemBlock.nextConnection && itemBlock.nextConnection.targetBlock()
					i++
				@itemCount_ = i
				@updateShape_()
				
				# Reconnect any child blocks.
				for num in [0..@itemCount_-1]
					if connections[num]
						@getInput('ADD' + num).connection.connect(connections[num])
			
			###
			# Store pointers to any connected child blocks.
			# @param {!Blockly.Block} containerBlock Root block in mutator.
			# @this Blockly.Block
			###
			saveConnections: (containerBlock) ->
				itemBlock = containerBlock.getInputTargetBlock('STACK')
				i = 0
				while itemBlock
				  input = @getInput('ADD' + i)
				  itemBlock.valueConnection_ = input && input.connection.targetConnection
				  itemBlock = itemBlock.nextConnection && itemBlock.nextConnection.targetBlock()
				  i++
			
			###
			# Modify this block to have the correct number of inputs.
			# @private
			# @this Blockly.Block
			###
			updateShape_: ->
				# Delete everything.
				if @getInput('EMPTY')
					@removeInput('EMPTY')
				else
					i = 0
					while @getInput('ADD' + i)
						@removeInput('ADD' + i)
						i++
				
				# Rebuild block.
				if @itemCount_ == 0
					@appendDummyInput('EMPTY')
						.appendField(@newQuote_(true))
						.appendField(@newQuote_(false))
				else
					for num in [0..@itemCount_-1]
						input = @appendValueInput('ADD' + num)
						if num == 0
							input.appendField('Join - Datasource')
		}
		

	# -------------------------
	# --- Declare Observers ---
	# -------------------------
	blockVisualsContentChanged: ( ->
		if @selectedBlockVisual
			blockToSelect = @allBlocks_Initial.findBy('id', 
								@selectedBlockVisual.block.id)
			blockToSelect.select()
			@get('currentController').transitionToRoute(
					blockToSelect.type, @selectedBlockVisual.block.id)
		else
			@get('currentController').transitionToRoute('index')
	).observes('selectedBlockVisual')

	blockToLoadChanged: (->
		# Clear all blocks from the editor
		Blockly.mainWorkspace.clear()
		
		# Get blocks to be loaded
		xml_text = @get('currentController.blockToLoad')

		# Load blocks & add event-handlers
		if xml_text
			xml = Blockly.Xml.textToDom(xml_text)
			Blockly.Xml.domToWorkspace(@workspace, xml)
		
			# ----------------------------
			# --- Setup Event-Handlers ---
			# ----------------------------
			# Add Event-Handler: For each block in the Workspace
			@allBlocks_Initial = Blockly.mainWorkspace.getAllBlocks()
			for block in @allBlocks_Initial
				Blockly.bindEvent_(block.getSvgRoot(), 
								   'mouseup', 
								   block, 
								   @blockOnClick)
			
				# Get all Block-Visuals as ember objects
				@blockVisuals.pushObject(Ember.Object.create({block:block}))		
	).observes('currentController.blockToLoad')
)

`export default BlocklyBasicComponent`
