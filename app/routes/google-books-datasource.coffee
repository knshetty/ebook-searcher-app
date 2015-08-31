`import Ember from 'ember'`

# ------------------------
# --- Declare Promises ---
# ------------------------
# --------------------------------------------------------
# Mockup REST Call: Google Books API as the resource
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
						isbn:'None',
						infolink:'https://books.google.fi/'
					} ))

				resolve(eBooks)

		), 500)

	)


GoogleBooksDatasourceRoute = Ember.Route.extend(

	# --------------------------------
	# --- Declare Public Variables ---
	# --------------------------------
	# Initialise RESTful resource [Note! Options are: (a) Cloud, (b) Mockup]
	restfulResourceType: { title: 'Cloud' }

	# ---------------------------------
	# --- Declare Private Variables ---
	# ---------------------------------
	# Initialise total number of eBooks found
	_totalNumOfAvailableEbooks: 0

	beforeModel: (transition) ->

		# -------------------------
		# Get RESTful resource type
		# -------------------------
		applicationController = transition.handlerInfos.
															findBy('name', 'application').handler.controller
		if applicationController.get('selectedDatasourceType') != undefined

			@restfulResourceType = applicationController.get('selectedDatasourceType')

		# Get parameter passed in the route url
		params = @paramsFor(transition.targetName)

		# ----------------
		# Get visual-block
		# ----------------
		block = Blockly.Block.getById(params.block_id, Blockly.selected.workspace)
		@_block = block

		# Setup ember context
		block._emberContext = @

		# ------------------------
		# Set RESTful resource URL
		# ------------------------
		@_searchString = block.getFieldValue('SEARCH_STRING')
		@_url = 'https://www.googleapis.com/books/v1/volumes?q='+@_searchString

	model: (params) ->

		# ---------------------------
		# Build model: Mockup fixture
		# ---------------------------
		if @restfulResourceType.title == 'Mockup'

			# Initialise total number of eBooks found
			@set('_totalNumOfAvailableEbooks', 0)

			# ------------------
			# Invoke mockup call
			# ------------------
			self = @
			numOfeBooksToMockup = 10
			dataset = Ember.A([])
			mockupRESTCall_SearcheBooks_Async(dataset, numOfeBooksToMockup, self._searchString).then( (data) ->

				# --------------------------------
				# Set total number of eBooks found
				# --------------------------------
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

				if response.items != undefined

					response.items.map((eBook)->

						eBooks.pushObject(Ember.Object.create( {
							title:eBook.volumeInfo.title,
							id:eBook.volumeInfo.id,
							description:eBook.volumeInfo.description,
							image:eBook.volumeInfo.imageLinks.thumbnail,
							subtitle:'None',
							isbn:eBook.volumeInfo.industryIdentifiers[0].identifier,
							infolink:eBook.volumeInfo.infoLink
						} ))

					)

				# --------------------------------
				# Set total number of eBooks found
				# --------------------------------
				self.set('_totalNumOfAvailableEbooks', parseInt(response.totalItems))
				self._block._totalAvailable = parseInt(response.totalItems)

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

`export default GoogleBooksDatasourceRoute`
