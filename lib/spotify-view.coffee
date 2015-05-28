module.exports =
  class SpotifyView extends HTMLElement

    constructor: (@state, @statusBar) ->
      @element = document.createElement 'div'
      @element.id = 'status-bar-spotify-linux'
      @element.classList.add 'inline-block'
      if atom.config.get('spotify-linux.position') is 'right'
        @statusBar.addRightTile(item: @element, priority: 100)
      else
        @statusBar.addLeftTile(item: @element, priority: 100)

    update: ->
      unless @state.running
        @element.classList.add 'hidden'
        return
      else
        @element.classList.remove 'hidden'
      placeholders =
        p: if @state.playing then '<span class="icono-play"></span>' else
          '<span class="icono-pause"></span>'
        c: "<img src='#{@state.artURL}'>"
        l: @state.length
        A: @state.album
        a: @state.artist
        r: @state.autoRating
        y: @state.created[...4]
        d: @state.discNumber
        t: @state.title
        n: @state.tracknumber
      fmt = atom.config.get('spotify-linux.songFormat')
      @element.innerHTML = fmt.replace /([^%]|^)%([a-zA-Z])/g,
        (match, g1, g2) ->
          return g1 + placeholders[g2]

    destroy: ->
      @element.destroy()
