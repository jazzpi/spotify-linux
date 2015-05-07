{CompositeDisposable} = require 'atom'
SpotifyView = require './spotify-view'
SpotifyState = require './spotify-state'

module.exports =
  config:
    songFormat:
      title: 'Song format'
      description: 'See README.md for placeholders'
      type: 'string'
      default: '%p %a - %t'
    position:
      title: 'Position'
      type: 'string'
      default: 'right'
      enum: ['right', 'left']

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @state = new SpotifyState

    @subscriptions.add atom.commands.add 'atom-workspace',
      'spotify-linux:next': => @next()

      'spotify-linux:previous': => @previous()

      'spotify-linux:toggle-play': => @togglePlay()

    atom.packages.onDidActivateInitialPackages =>
      @view = new SpotifyView @state, document.querySelector('status-bar')
      @view.update()
      @subscriptions.add @state.onDidChange =>
        @view.update()

  deactivate: ->
    @subscriptions.dispose()

  next: ->
    @state.next()

  previous: ->
    @state.previous()

  togglePlay: ->
    @state.togglePlay()

  provideSpotify: ->
    {
      next: =>
        @next()
      previous: =>
        @previous()
      togglePlay: =>
        @togglePlay()
      spotifyState: =>
        @state
    }
