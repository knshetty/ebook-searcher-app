`import Ember from 'ember'`

# ------------------------
# --- Declare Promises ---
# ------------------------
# --------------------------------------------------------
# Mockup REST Call: ITeBooks Open API as the resource
# --------------------------------------------------------
# Mock eBook search result that returns an array-of-eBooks
# --------------------------------------------------------
mockupRESTCall_SearcheBooks_Async = (eBooks, numOfeBooksToMockup, searchString) ->

	return new Ember.RSVP.Promise((resolve) ->

		Ember.run.later(eBooks, ( ->

				for i in [1..numOfeBooksToMockup]

					eBooks.pushObject(Ember.Object.create( {
						title:'Title: '+searchString+'_Book'+i,
						id:i,
						description:'None',
						image:'None',
						subtitle:'None',
						isbn:'None'
					} ))

				resolve(eBooks)

		), 500)

	)


ItEbooksDatasourceRoute = Ember.Route.extend(

	# Initialise RESTful resource
	# Note! Alternatives are: (a) Cloud, (b) Mockup
	restfulResourceType: {title: 'Cloud'}

	# Initialise total number of eBooks available
	_totalNumOfAvailableEbooks: 0

	beforeModel: (transition) ->

		# -------------------------
		# Get RESTful resource type
		# -------------------------
		applicationController = transition.handlerInfos.
															findBy('name', 'application').handler.controller
		if applicationController.get('selectedDatasourceType') != undefined

			@restfulResourceType = applicationController.get('selectedDatasourceType')

		# Get parameters passed with the route
		params = @paramsFor(transition.targetName)

		# ---------
		# Get Block
		# ---------
		block = Blockly.Block.getById(params.block_id, Blockly.selected.workspace)
		@_block = block

		# Setup Ember-Context
		block._emberContext = @

		# ------------------------
		# Set RESTful resource URL
		# ------------------------
		@_searchString = block.getFieldValue('SEARCH_STRING')
		@_url = 'http://it-ebooks-api.info/v1/search/'+@_searchString+'/page/1'

	model: (params) ->

		# ---------------------------
		# Build model: Mockup fixture
		# ---------------------------
		if @restfulResourceType.title == 'Mockup'

			# Initialise total number of eBooks generated
			@set('_totalNumOfAvailableEbooks', 0)

			# ------------------
			# Invoke mockup call
			# ------------------
			self = @
			numOfeBooksToMockup = 10
			dataset = Ember.A([])
			mockupRESTCall_SearcheBooks_Async(dataset, numOfeBooksToMockup, self._searchString).then( (data) ->

				# ------------------------------------
				# Set total number of eBooks generated
				# ------------------------------------
				self.set('_totalNumOfAvailableEbooks', data.length)
				self._block._totalAvailable = data.length

				# Populate block's output
				self._block._outputModel = data

				# Return model
				return data

			)

		# -----------------
		# Build model: REST
		# -----------------
		else if @restfulResourceType.title == 'Cloud'

			# Initialise total number of eBooks found
			@set('_totalNumOfAvailableEbooks', 0)

			# Initialise an empty array to hold eBooks
			eBooks = Ember.A([])

			# ---------------------------------------------------------
			# Invoke RESTful call to search eBooks on ITeBooks Open API
			# ---------------------------------------------------------
			self = @
			Ember.$.getJSON(@_url).then( (response) ->

				if response.Books != undefined

					response.Books.map((eBook)->

						eBooks.pushObject(Ember.Object.create( {
							title:eBook.Title,
							id:eBook.ID,
							description:eBook.Description,
							image:eBook.Image,
							subtitle:eBook.SubTitle,
							isbn:eBook.isbn
						} ))

					)

				# --------------------------------
				# Set total number of eBooks found
				# --------------------------------
				self.set('_totalNumOfAvailableEbooks', parseInt(response.Total))
				self._block._totalAvailable = parseInt(response.Total)

				# Populate block's output
				self._block._outputModel = eBooks

				# Return model
				return eBooks
			)

	setupController: (controller, model) ->

		# Set block
		controller.set('block', @_block)

		# Set model
		controller.set('model', model)

		# --------------
		# Select a eBook
		# --------------
		if model.length > 0

			controller.set('selectedEbook', model[0])

		# Set total number of availabe eBooks
		controller.set('totalAvailable', @_totalNumOfAvailableEbooks)

		# -------------------
		# Set pagenated-count
		# -------------------
		pagenatedCountVsTotal = controller.model.length +
		 												' / ' +
														@_totalNumOfAvailableEbooks
		controller.set('pagenatedCountVsTotal', pagenatedCountVsTotal)

)

`export default ItEbooksDatasourceRoute`
