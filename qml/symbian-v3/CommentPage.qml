// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
import QtWebKit 1.0
MyPage {
    id:commentpage
    property string mysid: ""
    tools: CustomToolBarLayout{
        id:commentTool
        ToolButton{
            id:backButton
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            //opacity: night_mode?brilliance_control:1
            onClicked: {
                current_page="content"
                web.visible=false
                setCssToTheme()//刷新css
                if(loading)
                    loading=false
                pageStack.pop()
            }
        }
        ToolButton{
            id:upButton
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/to_up_symbian.svg":"qrc:/Image/to_up_inverse_symbian.svg"
            onClicked: {
                flick1.contentY=0
            }
        }
        ToolButton{
            id:downButton
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/to_down_symbian.svg":"qrc:/Image/to_down_inverse_symbian.svg"
            //opacity: night_mode?brilliance_control:1
            onClicked: {
                flick1.contentY=web.height-commentpage.height
            }
        }
        ToolButton{
            id:editButton
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/edit2.svg":"qrc:/Image/edit.svg"
            //opacity: night_mode?brilliance_control:1
            onClicked: {
                comment.show()
            }
        }
    }

    Flickable{
        id:flick1
        width: parent.width
        height:parent.height-comment.height
        maximumFlickVelocity: 3000
        pressDelay:50
        flickableDirection:Flickable.VerticalFlick
        contentHeight: web.height
        contentWidth: web.width
        //NumberAnimation on contentY{ id:flickYto0; from:10;to:0;duration: 100;running: false}
        Behavior on contentY{
            NumberAnimation{
                duration: 300
                easing.type: Easing.OutQuart
            }
        }
        Connections{
            target: full?flick1:null
            onMovementStarted: {
                comment.hide()
            }
            onMovementEnded: {
                comment.show()
            }
        }
        WebView{
            id:web
            //y:-300
            visible: false
            //smooth: true
            url:"comment.html"
            settings.javascriptEnabled: true
            opacity: night_mode?brilliance_control:1
            settings.minimumFontSize: content_font_size
            onLoadStarted: loading=true
            width: commentpage.width
            onWidthChanged: {
                var temp=web.url
                web.url=""
                web.url=temp
                //如果屏幕方向变了
            }
            function commentFinish(msg)//回复评论成功之后
            {
                evaluateJavaScript('commentFinish('+'\''+msg+'\''+','+'\''+comment.parentCommentID+'\''+')')
            }

            javaScriptWindowObjects: QtObject{
                WebView.windowObjectName: "qml"
                function mySid()
                {
                    utility.consoleLog("html索取了新闻id")
                    return mysid
                }
                function commentReply(commentid,nickname,lou)
                {
                    if(nickname!="") {
                        comment.text = "回复#" + lou + " " + utility.fromUtf8(nickname) + ": "
                    } else {
                        comment.placeholderText = "点击回复"
                    }

                    comment.parentCommentID=commentid
                    comment.show()
                }
                function showAlert(message)
                {
                    utility.consoleLog(message)
                    showBanner(message)
                }
                function initHtmlFinisd()//初始化Html完成之后
                {
                    web.visible=true
                    //flickYto0.start()
                    loading=false
                    //utility.consoleLog(web.html)
                }
                function commentToEnd()//将评论拉到最后
                {
                    downButton.clicked()
                }
            }
            onLoadFinished: {
                utility.consoleLog( "加载评论成功" )
                web.evaluateJavaScript("initHtml()")//初始化html
            }
            onAlert: {
                utility.consoleLog(message)
            }
        }

    }
    ScrollBar {
        //platformInverted: main.platformInverted
        flickableItem: flick1
        anchors { right: flick1.right; top: flick1.top }
    }
    MyComment{
        id:comment
        mysid:commentpage.mysid
        function commentClose(msg)
        {
            web.commentFinish(msg)
        }
    }
    Keys.onPressed: {
        //utility.consoleLog("按下的按键是："+event.key)
        switch(event.key)
        {
        case Qt.Key_Down:
            flick1.contentY=Math.min(flick1.contentY+10,flick1.contentHeight-flick1.height)
            break;
        case Qt.Key_Up:
            flick1.contentY=Math.max(flick1.contentY-10,0)
            break;
        case Qt.Key_Right:
            flick1.contentY=Math.min(flick1.contentY+flick1.height,flick1.contentHeight-flick1.height)
            break;
        case Qt.Key_Left:
            flick1.contentY=Math.max(flick1.contentY-flick1.height,0)
            break;
        case Qt.Key_4:
            flick1.contentY=Math.min(flick1.contentY+flick1.height,flick1.contentHeight-flick1.height)
            break;
        case Qt.Key_1:
            flick1.contentY=Math.max(flick1.contentY-flick1.height,0)
            break;
        case Qt.Key_2:
            flick1.contentY=0
            break;
        case Qt.Key_8:
            flick1.contentY=flick1.contentHeight-flick1.height
            break;
        case Qt.Key_Context1:
            backButton.clicked()
            break
        default:{
            if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return){
                comment.show()
                event.accepted = true
            }
            break;
        }
        }
    }
    onStatusChanged: {
        if(status==PageStatus.Active)
        {
            labelTxt="评论"
        }
    }
    Component.onCompleted: main.setCssToComment()//设置css
}
