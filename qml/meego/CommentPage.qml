// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
import QtWebKit 1.0
MyPage {
    id:commentpage
    property string mysid: ""
    tools:ToolBarLayout{
        id:commentTool
        ToolIcon{
            iconId: "toolbar-back"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                current_page="content"
                web.visible=false
                main.setCssToTheme()//设置css
                if(loading)
                    loading=false
                pageStack.pop()
            }
        }
        ToolIcon{
            id:upButton
            
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/to_up_meego.png":"qrc:/Image/to_up_inverse_meego.png"
            onClicked: {
                flick1.contentY=0
            }
        }
        ToolIcon{
            id: downButton
            iconSource: night_mode?"qrc:/Image/to_down_meego.png":"qrc:/Image/to_down_inverse_meego.png"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                flick1.contentY=web.height-commentpage.height
            }
        }
        ToolIcon{
            iconId: "toolbar-edit"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                comment.show()
            }
        }
    }
    Flickable{
        id:flick1
        anchors.fill: parent
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
                  main.showToolBar=false
            }
            onMovementEnded: {
                main.showToolBar=true
            }
        }
        WebView{
            id:web
            url:"../general/comment.html"
            visible: false
            opacity: night_mode?brilliance_control:1
            settings.javascriptEnabled: true
            settings.minimumFontSize: content_font_size
            onLoadStarted: loading=true
            width: commentpage.width
            onWidthChanged: {
                var temp=web.url
                web.url=""
                web.url=temp
                //如果屏幕方向变了
            }
            function commentFinish(msg)
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
                function commentReply(commentid,floor,lou_zhong_lou)
                {
                    comment.placeholderText="点击回复"+(lou_zhong_lou==0?floor:lou_zhong_lou)+"楼"
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
                web.evaluateJavaScript("initHtml()")//初始化html
            }
            onAlert: {
                utility.consoleLog(message)
            }
        }
    }
    ScrollDecorator {
        id: horizontal
       // __alwaysShowIndicator:false
        flickableItem: flick1
        //anchors { right: flick1.right; top: flick1.top }
    }
    MyComment{
        id:comment
        mysid:commentpage.mysid
        function commentClose(msg)
        {
            web.commentFinish(msg)
        }
    }
    Component.onCompleted: main.setCssToComment()//设置css
}
