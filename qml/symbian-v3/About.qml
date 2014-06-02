// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import QtWebKit 1.0
MyPage{
    id:aboutPage
    property color text_color: night_mode?"#f0f0f0":"#282828"
    property real text_opacity: night_mode?brilliance_control:1

    tools: CustomToolBarLayout{
        ToolButton{
            id:backButton
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            onClicked: {
                current_page="setting"
                pageStack.pop()
            }
        }
    }
    Flickable{
        id:aboutFlick
        anchors.fill: parent
        maximumFlickVelocity: 3000
        pressDelay:200
        flickableDirection:Flickable.VerticalFlick
        contentHeight: myhtml.height
        opacity: text_opacity
        Behavior on contentY{
            NumberAnimation{
                duration: 300
                easing.type: Easing.OutQuart
            }
        }
        WebView{
            id:myhtml
            width: parent.width
            onWidthChanged: {
                var temp=myhtml.url
                myhtml.url=""
                myhtml.url=temp
            }
            settings.minimumFontSize: content_font_size
            anchors.verticalCenter: parent.verticalCenter
            url:"../general/about.html"
            javaScriptWindowObjects: QtObject {
                WebView.windowObjectName: "qml"
                function openUrl(src){
                    Qt.openUrlExternally(src)
                }
            }
        }
    }
    Keys.onPressed: {
        //utility.consoleLog("按下的按键是："+event.key)
        switch(event.key)
        {
        case Qt.Key_Down:
        {
            aboutFlick.contentY=Math.min(aboutFlick.contentY+10,aboutFlick.contentHeight-aboutPage.height)
            break;
        }
        case Qt.Key_Up:
            aboutFlick.contentY=Math.max(aboutFlick.contentY-10,0)
            break;
        case Qt.Key_Right:
            aboutFlick.contentY=Math.min(aboutFlick.contentY+aboutPage.height,aboutFlick.contentHeight-aboutPage.height)
            break;
        case Qt.Key_Left:
            aboutFlick.contentY=Math.max(aboutFlick.contentY-aboutPage.height,0)
            break;
        case Qt.Key_4:
            aboutFlick.contentY=Math.min(aboutFlick.contentY+aboutPage.height,aboutFlick.contentHeight-aboutPage.height)
            break;
        case Qt.Key_1:
            aboutFlick.contentY=Math.max(aboutFlick.contentY-aboutPage.height,0)
            break;
        case Qt.Key_2:
            aboutFlick.contentY=0
            break;
        case Qt.Key_8:
            aboutFlick.contentY=aboutFlick.contentHeight-aboutFlick.height
            break;
        case Qt.Key_Context1:
            backButton.clicked()
            break
        default:break;
        }
    }
    onStatusChanged: {
        if(status==PageStatus.Active)
        {
            labelTxt="关于"
        }
    }

}
