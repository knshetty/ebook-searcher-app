`import Ember from 'ember'`
`import config from './config/environment'`

Router = Ember.Router.extend
  location: config.locationType

Router.map ->
  # --------------------------------------------
  # Public routes
  # --------------------------------------------
  @route 'text_print', { path: '/text_print/:block' }
  @route 'text', { path: '/text/:block' }
  @route 'it-ebooks_datasource', { path: '/it-ebooks_datasource/:block_id' }
  @route 'join_datasource', { path: '/join_datasource/:block_id' }

`export default Router`
