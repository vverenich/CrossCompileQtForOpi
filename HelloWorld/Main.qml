import QtQuick
import QtQuick.Controls
import QtQml
import QtQuick.Controls.Material

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    color: "#333333"

    Material.theme: Material.Dark
    Material.accent: Material.DeepOrange

    Column {
        id: columnTest

        anchors.centerIn: parent

        Button {
            id: buttonTest

            text: "Test button"

            onClicked: {
                console.log("Test button is clicked")
            }
        }

        Slider {
            id: sliderTest
        }
    }
}
