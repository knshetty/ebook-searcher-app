`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  # --------------------------------------------
  # Public routes
  # --------------------------------------------
  @route 'it-ebooks_datasource', { path: '/it-ebooks_datasource/:block_id' }
  @route 'join_datasource', { path: '/join_datasource/:block_id' }
  @route 'google-books_datasource', { path: '/google-books_datasource/:block_id' }

`export default Router`
