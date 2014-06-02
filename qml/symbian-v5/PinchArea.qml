// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
Item {
    width: row.width
    height: row.height
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 80
    anchors.horizontalCenter: parent.horizontalCenter
    //property alias maxScale:sli.maximumValue
    property real maxScale: 3
    property real minScale: 0.5

    property real imageScale: 1
    onImageScaleChanged: sli.value=imageScale
    signal pinchFinished
    signal large
    signal diminish
    signal changedImageScale(real value)

    Rectangle{
        id:rect
        anchors.fill: parent
        opacity: 0.5
        radius: 18
    }

    Row{
        id:row
        anchors.centerIn: parent
        height: Math.max(sli.height,save.height,zoom_in.height,zoom_out.height)
        Image{
            id:zoom_out
            anchors.verticalCenter: parent.verticalCenter
            source: "qrc:/Image/shadow.png"
            sourceSize.width:50
            Image{
                anchors.centerIn: parent
                source: "qrc:/Image/qgn_indi_browser_tb_zoom_out.svg"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        diminish()
                    }
                }
            }
        }

        RewriteSlider {
            id:sli
            width:200
            value: imageScale
            anchors.verticalCenter: parent.verticalCenter
            maximumValue:maxScale
            minimumValue:minScale
            onValueChanged:{
                changedImageScale(value)
            }
         }
        Image{
            id:zoom_in
            source: "qrc:/Image/shadow.png"
            sourceSize.width:50
            anchors.verticalCenter: parent.verticalCenter
            Image{
                anchors.centerIn: parent
                source: "qrc:/Image/qgn_indi_browser_tb_zoom_in.svg"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        large()
                    }
                }
            }
        }
        Image{
            id:save
            source: "qrc:/Image/shadow.png"
            sourceSize.width:50
            anchors.verticalCenter: parent.verticalCenter
            Image{
                anchors.centerIn: parent
                source: "qrc:/Image/save.svg"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        var log=utility.saveImageToLocality(imageUrl);
                        utility.consoleLog("图片保存地址"+log)
                        main.showBanner(log)
                    }
                }
            }
        }
    }
}
