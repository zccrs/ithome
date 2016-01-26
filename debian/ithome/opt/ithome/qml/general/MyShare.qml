// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0

Item{
    function close(){}
    function copyContent(){}
    function openUrl(){}
    property int imageSize: Math.min(width/4,96)
    anchors.fill: parent
    opacity: 0
    onActiveFocusChanged: {
        utility.consoleLog("分享界面的focus:"+activeFocus)
    }

    function open()
    {
        comment.hide()
        opacity=1
        if(loading)
            main.busyIndicatorHide()//隐藏缓冲圈圈
    }

    function shareUrl(to,key)
    {
        hide()
        var string1="http://s.share.baidu.com/?click=1&url=http://www.ithome.com"+myurl
        var string2="&uid=0&to="+to+"&type=text&pic=&title="+title
        var string3="&key="+key+"&desc=&comment=&relateUid=&searchPic=0&sign=on&l=18hrfu3j718hrfu4if18hrfub95&linkid=hs7148kvhp0&firstime=1393550178804"
        Qt.openUrlExternally(string1+string2+string3)
    }
    function hide()
    {
        hide_me.start()
    }

    NumberAnimation on opacity{
        id:hide_me
        duration: 100
        running: false
        from:1
        to:0
        onCompleted: close()
    }

    Rectangle{
        anchors.fill: parent
        color: "black"
        opacity: 0.8
    }
    Behavior on opacity{
        NumberAnimation{duration: 100}
    }
    MouseArea{
        anchors.fill: parent
        onClicked: hide()
    }
    Grid{
        columns: 3
        rows:2
        spacing: sysIsSymbian?30:40
        anchors.centerIn: parent
        Image{
            id:sina_weibo
            sourceSize.height:imageSize
            source: "qrc:/Image/shadow.png"
            smooth: true
            Image{

                sourceSize.height:imageSize
                source: "qrc:/Image/Sina_Weibo.svg"
                smooth: true
                anchors.left: parent.left
                y:-5
                MouseArea{
                    id: image1
                    anchors.fill: parent
                    onClicked: {
                        shareUrl("tsina","1369706960")
                    }
                }
            }
            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                width: parent.width*2/3
                height: 20
                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                    radius: 8
                }
                Text{
                    anchors.centerIn: parent
                    text:"新浪微博"
                    font.pixelSize: sysIsSymbian?10:12
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Image{
            id:tencent_weibo
            sourceSize.height:imageSize

            source: "qrc:/Image/shadow.png"
            smooth: true
            Image{

                sourceSize.height:imageSize
                source: "qrc:/Image/tencent_Weibo.svg"
                smooth: true
                anchors.left: parent.left
                y:-5
                MouseArea{
                    id: image2
                    anchors.fill: parent
                    onClicked: {
                        shareUrl("tqq","801077952")
                    }
                }
            }
            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                width: parent.width*2/3
                height: 20
                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                    radius: 8
                }
                Text{
                    anchors.centerIn: parent
                    text:"腾讯微博"
                    font.pixelSize: sysIsSymbian?10:12
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Image{
            id:qzone
            sourceSize.height:imageSize

            source: "qrc:/Image/shadow.png"
            smooth: true

            Image{

                sourceSize.height:imageSize
                source: "qrc:/Image/Qzone.svg"
                smooth: true
                anchors.left: parent.left
                y:-5
                MouseArea{
                    id: image3
                    anchors.fill: parent
                    onClicked: {
                        shareUrl("qzone","")
                    }
                }
            }
            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                width: parent.width*2/3
                height: 20
                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                    radius: 8
                }
                Text{
                    anchors.centerIn: parent
                    text:"QQ空间"
                    font.pixelSize: sysIsSymbian?10:12
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Image{
            id:tieba
            sourceSize.height:imageSize

            source: "qrc:/Image/shadow.png"
            smooth: true

            Image{

                sourceSize.height:imageSize
                source: "qrc:/Image/tieba.svg"
                smooth: true
                anchors.left: parent.left
                y:-5
                MouseArea{
                    id: image4
                    anchors.fill: parent
                    onClicked: {
                        if(!online){
                            showBanner("还没联网哦")
                            return
                        }
                        var string1="http://tieba.baidu.com/f/commit/share/openShareApi?url=http://www.ithome.com"+myurl
                        var string2="&title="+title+"&desc=&comment="
                        hide()
                        copyContent()
                        Qt.openUrlExternally(string1+string2)
                    }
                }
            }
            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                width: parent.width*2/3
                height: 20
                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                    radius: 8
                }
                Text{
                    anchors.centerIn: parent
                    text:"百度贴吧"
                    font.pixelSize: sysIsSymbian?10:12
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Image{
            id:browser
            sourceSize.height: imageSize
            source: "qrc:/Image/shadow.png"
            smooth: true

            y:parent.height/2+15
            Image{

                sourceSize.height:imageSize
                source: "qrc:/Image/Browser.svg"
                smooth: true
                anchors.left: parent.left
                y:-5
                MouseArea
                {
                    id: image5
                    anchors.fill: parent
                    onClicked: {
                        hide()
                        openUrl()
                    }
                }
            }
            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                width: parent.width*2/3
                height: 20
                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                    radius: 8
                }
                Text{
                    anchors.centerIn: parent
                    text:"浏览器"
                    font.pixelSize: sysIsSymbian?10:12
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        Image{
            id:copy
            sourceSize.height:imageSize
            source: "qrc:/Image/shadow.png"
            smooth: true

            Image{

                sourceSize.height:imageSize
                source: "qrc:/Image/Copy.svg"
                smooth: true
                anchors.left: parent.left
                y:-5
                MouseArea{
                    id: image6
                    anchors.fill: parent
                    onClicked: {
                        hide()
                        copyContent()
                    }
                }
            }
            Item{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                width: parent.width*2/3
                height: 20
                Rectangle{
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.7
                    radius: 8
                }
                Text{
                    anchors.centerIn: parent
                    text:"复制全文"
                    font.pixelSize: sysIsSymbian?10:12
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    Keys.onPressed: {
        switch(event.key)
        {
        case Qt.Key_1:
            image1.clicked(0)
            break;
        case Qt.Key_2:
            image2.clicked(0)
            break;
        case Qt.Key_3:
            image3.clicked(0)
            break;
        case Qt.Key_4:
            image4.clicked(0)
            break;
        case Qt.Key_5:
            image5.clicked(0)
            break;
        case Qt.Key_6:
            image6.clicked(0)
            break;
        case Qt.Key_Context1:
            hide()
            break
        default:{
            if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return){
                hide()
            }
            break;
        }
        }
        event.accepted=true
    }
}
