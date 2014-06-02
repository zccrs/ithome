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
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/to_up_meego.png":"qrc:/Image/to_up_inverse_meego.png"
            onClicked: {
                flick1.contentY=0
            }
        }
        ToolIcon{

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
                                        //utility.consoleLog(post.responseText)
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
                function acquireComment(commentid,typeid,postdata)
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
                    comment.placeholderText="点击回复"+floor
                    comment.parentCommentID=commentid
                    comment.show()
                }

                function loadMoreComment(page)
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
                                        utility.consoleLog(post.responseText)
                                        if(post.responseText==="")
                                            showBanner("下面没有啦")
                                        else
                                            web.evaluateJavaScript('addCommentFinish('+'\''+post.responseText+'\''+')')
                                    }
                                }
                            }
                    post.send("newsID="+mysid+"&type=commentpage&page="+page)
                }
            }
            onLoadFinished: {
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
                    flick1.contentY=0//如果新增了评论就拉到最前
                }
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
