import QtQuick
import QtQuick.Window
import QtMultimedia

Item {
    readonly property real s: Screen.height / 768
    anchors.fill: parent

    MediaPlayer {
        id: mediaplayer
        source: "bg.mp4"
        autoPlay: true
        loops: MediaPlayer.Infinite
        audioOutput: audioOut
        AudioOutput { id: audioOut; volume: 0 }
        videoOutput: videoOutput
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}

