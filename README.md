# spotify-linux package

A package adding Spotify integration for Linux.

Heavily inspired by [jakemarsh/atom-spotify](https://github.com/jakemarsh/atom-spotify).

![](https://raw.githubusercontent.com/jazzpi/spotify-linux/master/spotify-linux.png)

Displays the currently playing song in the status bar. You can format the
string however you like (you can use HTML!), with these placeholders:

 - `%p`: Whether or not the current song is playing. Displays a play/pause icon
 - `%c`: Image of the cover art
 - `%l`: Length of the song
 - `%A`: Album
 - `%a`: Artist
 - `%r`: Auto-Rating provided by Spotify
 - `%y`: Year of publishing
 - `%d`: Disc number
 - `%t`: Title
 - `%n`: Track number

Default keybindings are like this:

 - `ctrl-alt-shift-right`: Next song
 - `ctrl-alt-shift-left`: Previous song
 - `ctrl-alt-shift-space`: Play/Pause
