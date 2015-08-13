`import Ember from 'ember'`

# ------------------------
# --- Declare Promises ---
# ------------------------
# Mockup =>> REST Call: Mock a search result for books from itebooks.com
mockupRESTCall_SearchBooks_Async = (books, numOfBooksToMockup, searchString) ->

	return new Ember.RSVP.Promise((resolve) ->

		Ember.run.later(books, ( ->

				for i in [1..numOfBooksToMockup]
					books.pushObject(Ember.Object.create({
						title:'Title: '+searchString+'_Book'+i, 
						id:i,
						description:'None',
						image:'None',
						subtitle:'None',
						isbn:'None'
					}))
				resolve(books)

		), 500)

	)


ItEbooksDatasourceRoute = Ember.Route.extend(

	# Initialise RESTful resource
	datasourceType: {title: 'Cloud'} # Alternative >> Cloud, Mockup
	
	# Initialise Total-Number-of-Books available
	_totalNumOfAvailableBooks: 0

	beforeModel: (transition) ->

		# Get the datasource type as the RESTful resource
		applicationController = transition.handlerInfos.findBy('name', 'application').handler.controller
		if applicationController.get('selectedDatasourceType') != undefined
			@datasourceType = applicationController.get('selectedDatasourceType')

		# Get parameters passed with the route
		params = @paramsFor(transition.targetName)

		# Get block
		block = Blockly.Block.getById(params.block_id, Blockly.selected.workspace)
		@_block = block
		
		# Setup Ember-Context to the selected block
		block._emberContext = @

		# Set URL (i.e. datasource resource)
		@_searchString = block.getFieldValue('SEARCH_STRING')
		@_url = 'http://it-ebooks-api.info/v1/search/'+@_searchString+'/page/1'
	
	model: (params) ->

		# ---------------------------
		# Build model: Mockup Fixture
		# ---------------------------
		if @datasourceType.title == 'Mockup'

			# Initialise Total-Number-of-Books generated
			@set('_totalNumOfAvailableBooks', 0)

			# -------------------------------			
			# Invoke Mockup >> Mock REST Call
			# -------------------------------
			self = @
			numOfBooksToMockup = 10
			dataset = Ember.A([])
			mockupRESTCall_SearchBooks_Async(dataset, numOfBooksToMockup, self._searchString).then( (data) ->

				# Set Total-Number-of-Books generated
				self.set('_totalNumOfAvailableBooks', data.length)
				self._block._totalAvailable = data.length

				# Populate block's output			
				self._block._outputModel = data

				# Return model
				return data

			)

		# -----------------
		# Extract model: REST
		# -----------------
		else if @datasourceType.title == 'Cloud'
			
			# Initialise Total-Number-of-Books found
			@set('_totalNumOfAvailableBooks', 0)

			# Initialise an empty array to hold books
			books = Ember.A([])

			# --------------------------------------------
			# REST Call >> To search books on itebooks.com
			# --------------------------------------------
			self = @
			Ember.$.getJSON(@_url).then( (response) ->

				if response.Books != undefined

					response.Books.map((book)->

						books.pushObject(Ember.Object.create({
							title:book.Title,
							id:book.ID,
							description:book.Description,
							image:book.Image,
							subtitle:book.SubTitle,
							isbn:book.isbn
						}))

					)

				# Set Total-Number-of-Books found
				self.set('_totalNumOfAvailableBooks', parseInt(response.Total))
				self._block._totalAvailable = parseInt(response.Total)

				# Populate block's output			
				self._block._outputModel = books
			
				# Return model			
				return books
			)
	
	setupController: (controller, model) ->

		# Set block
		controller.set('block', @_block)

		# Set model
		controller.set('model', model)

		# Select a book
		if model.length > 0
			controller.set('selectedbook', model[0])

		# Set total number of availabe books
		controller.set('totalAvailable', @_totalNumOfAvailableBooks)
			
		# Set pagenated-count
		pagenatedCountVsTotal = controller.model.length + ' / ' + @_totalNumOfAvailableBooks
		controller.set('pagenatedCountVsTotal', pagenatedCountVsTotal)

)

`export default ItEbooksDatasourceRoute`
