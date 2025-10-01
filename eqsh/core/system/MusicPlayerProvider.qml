pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: mpris
    property var players: Mpris.players.values
    property var activePlayer: mpris.players[mpris.players.length - 1] || null
    property string title: mpris.activePlayer?.trackTitle ?? "--"
    property string artist: mpris.activePlayer?.trackArtist ?? "--"
    property string album: mpris.activePlayer?.trackAlbum ?? "--"
    property url thumbnail: mpris.activePlayer?.trackArtUrl ?? null
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
}