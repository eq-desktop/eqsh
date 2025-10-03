pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: mpris
    property var players: Mpris.players.values
    property var activePlayer: mpris.players[mpris.players.length - 1] || null
    property string title: mpris.activePlayer?.trackTitle ?? "Not Playing"
    property string artist: mpris.activePlayer?.trackArtist ?? ""
    property string album: mpris.activePlayer?.trackAlbum ?? ""
    property url thumbnail: mpris.activePlayer?.trackArtUrl ?? ""
    property bool isPlaying: mpris.activePlayer?.isPlaying ?? false
    property int duration: 0
    property int position: 0
    property bool available: false
    function togglePlay() {
        if (mpris.activePlayer) {
            if (mpris.isPlaying) {
                mpris.activePlayer.pause()
            } else {
                mpris.activePlayer.play()
            }
        }
    }
    function next() {
        if (mpris.activePlayer) {
            mpris.activePlayer.next()
        }
    }
    function previous() {
        if (mpris.activePlayer) {
            mpris.activePlayer.previous()
        }
    }

    IpcHandler {
        target: "music"
        function togglePlay() {
            mpris.togglePlay()
        }
        function next() {
            mpris.next()
        }
        function previous() {
            mpris.previous()
        }
        function getData(): object {
            return {
                "title": mpris.title,
                "artist": mpris.artist,
                "album": mpris.album,
                "thumbnail": mpris.thumbnail,
                "isPlaying": mpris.isPlaying,
                "duration": mpris.duration,
                "position": mpris.position
            }
        }
    }
}