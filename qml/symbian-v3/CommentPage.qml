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
            function acquireFloor()//获取评论的楼层
            {

            }

            function commentFinish(msg)//回复评论成功之后
            {
                if(msg.indexOf("评论成功") >= 0)
                {
                    var post=new XMLHttpRequest
                    post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
                    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
                    post.onreadystatechange=function()
                            {
                                if(post.readyState===4)
                                {
                                    if(post.status===200)
                                    {
                                        web.evaluateJavaScript('commentFinish('+'\''+post.responseText+'\''+')')
                                    }
                                }
                            }
                    post.send("newsID="+mysid+"&type=comment")
                }
            }

            javaScriptWindowObjects: QtObject{
                WebView.windowObjectName: "qml"
                function mySid()
                {
                    utility.consoleLog("获取了新闻id")
                    return mysid
                }
                function acquireComment(commentid,typeid,postdata)//评论
                {
                    var post=new XMLHttpRequest
                    post.open("POST","http://www.ithome.com/ithome/postComment.aspx")
                    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
                    post.onreadystatechange=function()
                            {
                                if(post.readyState===4)
                                {
                                    if(post.status===200)
                                    {
                                        if(post.responseText.indexOf('您')>-1)
                                            showBanner(post.responseText)
                                        else
                                            web.evaluateJavaScript("reData("+commentid+","+typeid+","+post.responseText+")")
                                    }
                                }
                            }
                    post.send(postdata)
                }
                function commentReply(commentid,floor)
                {
                    utility.consoleLog("点击回复"+floor)
                    comment.placeholderText="点击回复"+floor
                    comment.parentCommentID=commentid
                    comment.show()
                }

                function loadMoreComment(page)
                {
                    utility.consoleLog("增加更多评论")
                    var post=new XMLHttpRequest
                    post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
                    post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
                    post.onreadystatechange=function()
                            {
                                if(post.readyState===4)
                                {
                                    if(post.status===200)
                                    {
                                        //utility.consoleLog("得到的更多评论："+post.responseText)
                                        if(post.responseText==="")
                                            showBanner("下面没有啦")
                                        else web.evaluateJavaScript('addCommentFinish('+'\''+post.responseText+'\''+')')
                                    }
                                }
                            }
                    post.send("newsID="+mysid+"&type=commentpage&page="+page)
                }
            }
            onLoadFinished: {
                //utility.consoleLog("增加更多评论")
                var post=new XMLHttpRequest
                post.open("POST","http://www.ithome.com/ithome/GetAjaxData.aspx")
                post.setRequestHeader("Content-Type","application/x-www-form-urlencoded; charset=UTF-8");
                post.onreadystatechange=function()
                        {
                            if(post.readyState===4)
                            {
                                if(post.status===200)
                                {
                                    //utility.consoleLog("得到的更多评论："+post.responseText)
                                   if(post.responseText!=""){
                                        var string=post.responseText
                                        var count=0
                                        var pos=string.indexOf("class=\"entry\"")
                                        while(pos>=0)
                                        {
                                            count++
                                            pos=string.indexOf("class=\"entry\"",pos+100)
                                        }
                                        if(count>=50)//判断评论是否超过50,用来判断是否要显示“查看更多评论的选项”
                                            web.evaluateJavaScript("document.getElementById(\"commentlist\").innerHTML = unescape('<h3><span class=\"icon2\"></span>评论列表</h3><ul class=\"list\" id=\"LoadArticleReply\"></ul><ul class=\"list\" id=\"ulcommentlist\">"+string+"</ul><div class=\"more_comm\"><a id=\"pagecomment\" href=\"javascript:pagecomment(++commentpage,90);\">查看更多评论 ...</a></div>')");
                                        else
                                            web.evaluateJavaScript("document.getElementById(\"commentlist\").innerHTML = unescape('<h3><span class=\"icon2\"></span>评论列表</h3><ul class=\"list\" id=\"LoadArticleReply\"></ul><ul class=\"list\" id=\"ulcommentlist\">"+string+"</ul>')");
                                    }else{
                                        web.evaluateJavaScript("document.getElementById(\"commentlist\").innerHTML = unescape('<h3><span class=\"icon2\"></span>评论列表</h3>')");
                                        showBanner("还没有人评论，赶快抢沙发")
                                    }

                                    web.visible=true
                                    //flickYto0.start()
                                    loading=false
                                }
                            }
                        }
                post.send("newsID="+mysid+"&type=commentpage&page=1")
            }
            onAlert: {
                utility.consoleLog(message)
            }
            onHeightChanged: {
                if(comment.visible)
                {
                    flick1.contentY=0//如果新增了评论就拉到最上面
                }
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
