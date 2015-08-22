`import Ember from 'ember'`

BlocklyBasicComponent = Ember.Component.extend(

	tagName: 'div'

	classNames: ['ember-blockly']

	blocklyEditor: null

	allBlocks_VisualType_InWorkspace: null

	allBlocks_EmberObjType_FromWorkspace: Ember.A([])

	selectedBlock_EmberObjType: null

	# --------------------------------
	# --- Component Initialisation ---
	# --------------------------------
	didInsertElement: ->

		self = @

		# -----------------------------------------------------
		# Inject Custom Blocks
		# -----------------------------------------------------
		# Create & inject custom visual-blocks into the toolbox
		# Note! Toolbox contains: Categories
		# -----------------------------------------------------
		# 'Itebooks' visual-block: Create & inject a custom visual-block
		# to be the toolbox category called 'Datasource'
		@addCustomVisualBlockItebooksBlock_DatasourceCategory(@)

		# 'Join' visual-block: Create & inject a custom visual-block
		# to be the toolbox category called 'Datasource'
		@addCustomVisualBlockJoinBlock_DatasourceCategory(@)

		# ----------------------------------------------------------
		# Initialise Blockly-Editor
		# Note! A blockly-editor is composed of: Toolbox + Workspace
		# ----------------------------------------------------------
		# Instantiate blockly-editor
		@blocklyEditor = Blockly.inject('blocklyDiv', {
											media: 'media/',
											toolbox: self.$('.blocky-basic-toolbox').get(0)
										 })

		# Assign ember-context to blockly-editor
		@blocklyEditor._emberContext = @

		# ------------------
		# Populate Workspace
		# ------------------
		# Approach 1: Populate workspace with predefined visual-block
		# composition: Handle predefinition of TEXT type that containing XML
		xml_text = @get('blockToLoad')
		if xml_text
			xml = Blockly.Xml.textToDom(xml_text)
			Blockly.Xml.domToWorkspace(@blocklyEditor, xml)

		###
		# Approach 2: Populate workspace with predefined visual-block composition:
		# Handle predefinition of DOM element type that containing XML
		Blockly.Xml.domToWorkspace(
			@blocklyEditor, self.$('.blocky-basic-initial-blocks1').get(0)
		)
		###

		# --------------------
		# Setup Event-Handlers
		# --------------------
		# ----------------------------------------------------------------------
		# 1. Assign event-handler for mouse-interactions with visual-blocks
		# 2. Build an ember-object-type collection to house visual-block objects
		# ----------------------------------------------------------------------
		@allBlocks_VisualType_InWorkspace = Blockly.mainWorkspace.getAllBlocks()
		for visualBlock in @allBlocks_VisualType_InWorkspace

			# Assign mouse-interaction event-handler for
			# each visual-block found in the workspace
			Blockly.bindEvent_(
				visualBlock.getSvgRoot(), 'mouseup', visualBlock, @blockOnClick
			)

			# Build-up an ember-object-type collection from
			# all visual-blocks found in the workspace
			@allBlocks_EmberObjType_FromWorkspace.pushObject(
				Ember.Object.create( {block: visualBlock} )
			)

    # -----------------------------------------------------
		# Assign event-handler for reacting to addition/removal
		# of visual-blocks to/from the workspace
    # -----------------------------------------------------
		@blocklyEditor.addChangeListener(@workspaceOnChange)


	# ---------------------
	# --- Action Events ---
	# ---------------------
	actions:
		run: ->

			# ------------------------
			# Generate JavaScript code
			# ------------------------
			window.LoopTrap = 1000
			Blockly.JavaScript.INFINITE_LOOP_TRAP = 'if (--window.LoopTrap == 0) throw "Infinite loop.";\n'
			code = Blockly.JavaScript.workspaceToCode(@blocklyEditor)
			Blockly.JavaScript.INFINITE_LOOP_TRAP = null

			# -----------------------
			# Execute JavaScript code
			# -----------------------
			try
				eval(code)
			catch error
				alert error

		show_JSCode: ->

			# --------------------------------------------
			# Generate JavaScript code in-order to display
			# --------------------------------------------
			Blockly.JavaScript.INFINITE_LOOP_TRAP = null
			code = Blockly.JavaScript.workspaceToCode(@blocklyEditor)
			alert(code)

		show_WorkspaceAsXml: ->

			# ------------------------------------------
			# Generate XML from visual-block composition
			# present within the workspace & display
			# ------------------------------------------
			xml = Blockly.Xml.workspaceToDom(@blocklyEditor)
			xml_text = Blockly.Xml.domToText(xml)
			console.log xml_text
			alert(xml_text)

		clearWorkspace: ->

			# Clear all visual-blocks from workspace & purge
			# all items from ember-object-type collection
			@clearWorkspaceContents()


	# -------------------------------
	# --- Declare Local Functions ---
	# -------------------------------
	# ------------------------------------------------
	# Respond-To-Event: On visual-block being selected
	# ------------------------------------------------
	blockOnClick: ->

		# ------------------------------------
		# Initialise & set selected-block item
		# ------------------------------------
		# Act only on the selected visual-block
		if Blockly.selected.id == @id

			# ---------------------------------------------------------
			# Get selected block item from ember-object-type collection
			# ---------------------------------------------------------
			editorEmberContext = Blockly.mainWorkspace._emberContext
			selectedItem = editorEmberContext.allBlocks_EmberObjType_FromWorkspace.
											findBy('block.id', Blockly.selected.id)

			# -------------------------------------------------------
			# Initialise the selected block item of ember-object-type
			# -------------------------------------------------------
			selectedItem.block._outputModel = Ember.A([])
			selectedItem.block._isChildernRouteLoaded = false

			# ------------------------------------------------
			# Set the selected block item of ember-object-type
			# ------------------------------------------------
			editorEmberContext.set('selectedBlock_EmberObjType', selectedItem)

	# -----------------------------------------------------------------------
	# Respond-To-Event: On add/removal of visual-blocks to/from the workspace
	# -----------------------------------------------------------------------
	workspaceOnChange: ->

		allVisualBlocks_Latest = Blockly.mainWorkspace.getAllBlocks()
		editorEmberContext = Blockly.mainWorkspace._emberContext

		# ----------------------------------------
		# Scenario 1: When number of visual-blocks
		# in the workspace remains unchange
		# ----------------------------------------
		if allVisualBlocks_Latest.length == editorEmberContext.allBlocks_VisualType_InWorkspace.length
			# Do nothing
			return

		# ----------------------------------------------------------
		# Scenario 2: On addition of a visual-block to the workspace
		# ----------------------------------------------------------
		else if allVisualBlocks_Latest.length > editorEmberContext.allBlocks_VisualType_InWorkspace.length

			addedVisualBlock = Blockly.selected

			# Assign mouse-interaction event-handler for the newly added visual-block
			Blockly.bindEvent_(addedVisualBlock.getSvgRoot(), 'mouseup',
				addedVisualBlock, editorEmberContext.blockOnClick)

			# Keep account of newly added visual-block entries into the workspace
			editorEmberContext.allBlocks_VisualType_InWorkspace.push(addedVisualBlock)

			# Create & add a new block entry to the ember-object-type collection
			editorEmberContext.allBlocks_EmberObjType_FromWorkspace.pushObject(
				Ember.Object.create( {block: addedVisualBlock} )
			)

		# -----------------------------------------------------------
		# Scenario 3: On-removal of a visual-block from the workspace
		# -----------------------------------------------------------
		else if allVisualBlocks_Latest.length < editorEmberContext.allBlocks_VisualType_InWorkspace.length

			for id in editorEmberContext.allBlocks_VisualType_InWorkspace.getEach('id')

				if !allVisualBlocks_Latest.findBy('id', id)

					# ---------------------------------------------------------
					# Purge visual-blocks from the ember-object-type collection
					# ---------------------------------------------------------
					deletedBlock = editorEmberContext.allBlocks_VisualType_InWorkspace.
													findBy('id', id)
					editorEmberContext.allBlocks_EmberObjType_FromWorkspace.removeObject(
						editorEmberContext.allBlocks_EmberObjType_FromWorkspace.
							findBy('block.id', deletedBlock.id)
					)

					# -----------------------------------------------------
					# Re-initialise the selected block of ember-object-type
					# -----------------------------------------------------
					editorEmberContext.set('selectedBlock_EmberObjType', null)

			# Keep account of all the latest visual-blocks within the workspace
			editorEmberContext.allBlocks_VisualType_InWorkspace = allVisualBlocks_Latest

	# -----------------------------------------------
	# Clear all visual-blocks from workspace & purge
	# all items from ember-object-type collection
	# -----------------------------------------------
	clearWorkspaceContents: ->

		# Clear all visual-blocks from workspace
		Blockly.mainWorkspace.clear()

		# Clear ember-object-type collection
		@allBlocks_EmberObjType_FromWorkspace.clear()


	# ---------------------------------------------------------
	# --- Declare custom visual-blocks with code generators ---
	# ---------------------------------------------------------

	#-----------------------------------------------------------------------------
	# Custom Visual-Block: 1
	#-----------------------------------------------------------------------------
	# Name: 						It-ebooks
	# Target-Category: 	Datasource
	# Block Factory URL:
	# 									v0.2 >> https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#ky4fee
	# 									v0.1 >> https://blockly-demo.appspot.com/static/demos/blockfactory/index.html#kkjtrt
	#-----------------------------------------------------------------------------
	addCustomVisualBlockItebooksBlock_DatasourceCategory: (context)->

		# --------------------------------------------------------------------------
		# Declare custom visual-block: It-eBooks
		# --------------------------------------------------------------------------
		# Block Functionality:	To make RESTful search-query request to IT-ebooks API
		# Input Type: 					- None -
		# Output Type:					Array
		# --------------------------------------------------------------------------
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
				@setColour(290) # 290 = Purple colour
				@setTooltip('Search eBooks on http://it-ebooks.info')
				@setHelpUrl('')

		}

		# --------------------------
		# Code-generator: JavaScript
		# --------------------------
		Blockly.JavaScript['it-ebooks_datasource'] = (block) ->

			text_search_string = block.getFieldValue('SEARCH_STRING')
			theUrl = "http://it-ebooks-api.info/v1/search/restful"
			code = "var xmlHttp = new XMLHttpRequest();" +
							"xmlHttp.open( 'GET', 'http://it-ebooks-api.info/v1/search/restful', false );" +
							"xmlHttp.send( null );" +
							"var response = xmlHttp.responseText;"
			# TODO: Change ORDER_NONE to the correct strength.
			return [code, Blockly.JavaScript.ORDER_NONE]

	#-----------------------------------------------------------------------------
	# Custom Visual-Block: 2
	#-----------------------------------------------------------------------------
	# Name: 						Join
	# Target-Category: 	Datasource
	# Source: 					https://github.com/google/blockly/blob/e3009310713209e80acc58a49d677d69f80d7b70/blocks/text.js starting from line 69 (i.e. Blockly.Blocks['text_join'])
	#-----------------------------------------------------------------------------
	addCustomVisualBlockJoinBlock_DatasourceCategory: (context)->

		# -----------------------------------------------------
		# Declare custom visual-block: Join
		# -----------------------------------------------------
		# Block Functionality:	Aggregate outputs of mulitple
		#												datasource-blocks of array type
		# Input Type:						Array
		# Output Type:					Array
		# -----------------------------------------------------
		Blockly.Blocks['join_datasource'] = {

			init: ->

				@itemCount_ = 2
				@updateShape_()
				@setOutput(true, 'Array')
				@setMutator(new Blockly.Mutator(['text_create_join_item']))
				@setColour(290) # 290 = Purple colour
				@setTooltip('Aggregate several datasources output together')
				@setHelpUrl('')

			# ----------------------------------------------
			# Create XML to represent number of array inputs
			# ----------------------------------------------
			# @return {Element} XML storage element
			# @this Blockly.Block
			# ----------------------------------------------
			mutationToDom: ->

				container = document.createElement('mutation')
				container.setAttribute('items', @itemCount_)
				return container

			# ------------------------------------------------
			# Parse XML to restore the array inputs
			# ------------------------------------------------
			# @param {!Element} xmlElement XML storage element
			# @this Blockly.Block
			# ------------------------------------------------
			domToMutation: (xmlElement) ->

				@itemCount_ = parseInt(xmlElement.getAttribute('items'), 10)
				@updateShape_()

			# ----------------------------------------------------------
			# Populate the mutator's dialog with this block's components
			# ----------------------------------------------------------
			# @param {!Blockly.Workspace} Mutator's workspace.
			# @return {!Blockly.Block} Root block in mutator.
			# @this Blockly.Block
			# ----------------------------------------------------------
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

			# ---------------------------------------------------------------
			# Reconfigure this block based on the mutator dialog's components
			# ---------------------------------------------------------------
			# @param {!Blockly.Block} containerBlock is Root block in mutator
			# @this Blockly.Block
			# ---------------------------------------------------------------
			compose: (containerBlock) ->

				itemBlock = containerBlock.getInputTargetBlock('STACK')

				# ----------------------
				# Count number of inputs
				# ----------------------
				connections = []
				i = 0
				while itemBlock
					connections[i] = itemBlock.valueConnection_
					itemBlock = itemBlock.nextConnection && itemBlock.nextConnection.targetBlock()
					i++
				@itemCount_ = i
				@updateShape_()

				# --------------------------
				# Reconnect any child blocks
				# --------------------------
				for num in [0..@itemCount_-1]
					if connections[num]
						@getInput('ADD' + num).connection.connect(connections[num])

			# ---------------------------------------------------------------
			# Store pointers to any connected child blocks
			# ---------------------------------------------------------------
			# @param {!Blockly.Block} containerBlock is Root block in mutator
			# @this Blockly.Block
			# ---------------------------------------------------------------
			saveConnections: (containerBlock) ->

				itemBlock = containerBlock.getInputTargetBlock('STACK')
				i = 0
				while itemBlock
				  input = @getInput('ADD' + i)
				  itemBlock.valueConnection_ = input && input.connection.targetConnection
				  itemBlock = itemBlock.nextConnection && itemBlock.nextConnection.targetBlock()
				  i++

			# ------------------------------------------------------
			# Modify this block to have the correct number of inputs
			# ------------------------------------------------------
			# @private
			# @this Blockly.Block
			# ------------------------------------------------------
			updateShape_: ->

				# -----------------
				# Delete everything
				# -----------------
				if @getInput('EMPTY')
					@removeInput('EMPTY')
				else
					i = 0
					while @getInput('ADD' + i)
						@removeInput('ADD' + i)
						i++

				# -------------
				# Rebuild block
				# -------------
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
	selectedBlock_EmberObjectType_Changed: ( ->

		# ----------------------------------------------------------
		# On selecting a visual-block, transtion to respective route
		# ----------------------------------------------------------
		if @selectedBlock_EmberObjType
			blockToSelect = @allBlocks_VisualType_InWorkspace.
												findBy('id', @selectedBlock_EmberObjType.block.id)
			blockToSelect.select()
			@get('currentController').transitionToRoute(blockToSelect.type,
				@selectedBlock_EmberObjType.block.id)
		# -------------------------------------
		# By default, transition to index route
		# -------------------------------------
		else
			@get('currentController').transitionToRoute('index')

	).observes('selectedBlock_EmberObjType')

	predefinedVisualBlockToLoad_Changed: (->

		# Clear all visual-blocks from workspace & purge
		# all items from ember-object-type collection
		@clearWorkspaceContents()

		# Get predefined visual-block-composition to-be loaded to the workspace
		xml_text = @get('currentController.blockToLoad')

		# --------------------------------------------------------------------------
		# 1. Load to workspace the predefined visual-block-composition
		# 2. Add event-handlers to visual-blocks found in workspace
		# 3. Add visual-blocks from workspace as entry to ember-object-type
		# 	 collection
		# --------------------------------------------------------------------------
		# Load predefined visual-block-composition to the workspace
		if xml_text
			xml = Blockly.Xml.textToDom(xml_text)
			Blockly.Xml.domToWorkspace(@blocklyEditor, xml)

			@allBlocks_VisualType_InWorkspace = Blockly.mainWorkspace.getAllBlocks()
			for visualBlock in @allBlocks_VisualType_InWorkspace

				# Assign mouse-interaction event-handler for
				# each visual-block found in the workspace
				Blockly.bindEvent_(visualBlock.getSvgRoot(), 'mouseup', visualBlock,
					@blockOnClick)

				# Create & add a new blocks entry to the ember-object-type collection
				@allBlocks_EmberObjType_FromWorkspace.pushObject(
					Ember.Object.create( {block: visualBlock} )
				)

	).observes('currentController.blockToLoad')

)

`export default BlocklyBasicComponent`
