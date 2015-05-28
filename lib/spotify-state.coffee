dbus = require 'dbus-native'
{Emitter} = require 'event-kit'

module.exports =
  class SpotifyState
    PROPERTY_CHANGED = '{"path":"/org/mpris/MediaPlayer2","interface":"org.\
      freedesktop.DBus.Properties","member":"PropertiesChanged"}'

    constructor: ->
      @emitter = new Emitter
      @_sessionBus = dbus.sessionBus()
      @running = false
      @playing = false
      @updateRunning()
      setInterval(@updateRunning, 5000)

    onDidChange: (callback) ->
      @emitter.on 'did-change', callback

    destroy: ->
      # 'Unsubscribe' from DBus
      @_sessionBus.removeMatch("type='signal',member='PropertiesChanged'")
      @_sessionBus.signals.removeListener(PROPERTY_CHANGED, @updateData)

    updateRunning: (updateAfter = true) =>
      @_sessionBus.getService('org.mpris.MediaPlayer2.spotify').getInterface(
        '/org/mpris/MediaPlayer2', 'org.freedesktop.DBus.Properties',
        (err, @_DBusInterface) =>
          if err?
            # Spotify isn't running
            @running = false
            @emitter.emit 'did-change'
            return
          @running = true
          if updateAfter
            @updateMetadata()
            @updatePlaying()
          unless @_sessionBus.signals._events[PROPERTY_CHANGED]?
            @_DBusInterface.on('PropertiesChanged', @updateData)
      )

    updateData: (err, data) =>
      property = data[0][0]
      if property is 'PlaybackStatus'
        @parsePlaybackStatus data[0][1]
      else if property is 'Metadata'
        @parseMetadata data[0][1]

    updateMetadata: ->
      unless @running
        return
      @_DBusInterface.Get 'org.mpris.MediaPlayer2.Player', 'Metadata',
        (err, data) =>
          if err?
            atom.notifications.addError "Couldn't get Spotify Metadata: #{err}"
            return
          @parseMetadata data

    updatePlaying: ->
      unless @running
        return
      @_DBusInterface.Get 'org.mpris.MediaPlayer2.Player', 'PlaybackStatus',
        (err, data) =>
          if err?
            atom.notifications.addError "Couldn't get Spotify playback status:\
              #{err}"
            return
          @parsePlaybackStatus data

    parseMetadata: (data) ->
      if data[1][0].length == 0
        # Looks like Spotify isn't running
        @updateRunning false
        return
      for [key, val] in data[1][0]
        switch key
          when 'mpris:artUrl' then @artURL = val[1][0]
          when 'mpris:length' then @length = val[1][0]
          when 'mpris:trackid' then @trackID = val[1][0]
          when 'xesam:album' then @album = val[1][0]
          when 'xesam:artist' then @artist = val[1][0]
          when 'xesam:autoRating' then @autoRating = val[1][0]
          when 'xesam:contentCreated' then @created = val[1][0]
          when 'xesam:discNumber' then @discNumber = val[1][0]
          when 'xesam:title' then @title = val[1][0]
          when 'xesam:trackNumber' then @trackNumber = val[1][0]
          when 'xesam:url' then @url = val[1][0]

      @emitter.emit 'did-change'

    parsePlaybackStatus: (data) ->
      if data[1][0].length == 0
        # Looks like Spotify isn't running
        @updateRunning false
        return
      @playing = data[1][0] is 'Playing'

      @emitter.emit 'did-change'

    _callMediaPlayer: (member) ->
      @_sessionBus.invoke({
        destination: 'org.mpris.MediaPlayer2.spotify'
        path: '/org/mpris/MediaPlayer2'
        interface: 'org.mpris.MediaPlayer2.Player'
        member: member
      })

    next: ->
      @_callMediaPlayer 'Next'

    previous: ->
      @_callMediaPlayer 'Previous'

    togglePlay: ->
      @_callMediaPlayer 'PlayPause'
