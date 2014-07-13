// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import QtWebKit 1.0
import com.nokia.symbian 1.0
import "../general"
MyPage{
    id:contentPage
    property string url: ""//html文件的本地路径
    property string myurl: ""//这篇文章的网络地址
    property bool allowDoubleClick:false
    property bool loadImageFinish: false//用了记录是否请求过加载全部图片
    property int contentY: 0//用了记录改变url之前的webview的位置
    property string title: ""
    property string postdate: ""
    property string newssource: ""
    property string newsauthor: ""
    property string me_to_xml: ""//这篇新闻的xml格式的内容
    property int mysid: 0
    tools: CustomToolBarLayout{
        id:contentTool

        ToolButton{
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            //opacity: night_mode?brilliance_control:1
            onClicked: {
                if(loading){
                    cacheContent.cancleDownloadImage()//如果正在加载就取消加载
                    loading=false
                }
                current_page="page"
                web.url=""
                url=""
                web.visible=false
                pageStack.pop()
            }
        }
        ToolButton{
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/edit2.svg":"qrc:/Image/edit.svg"

            onClicked: {
                comment.show()
            }
        }
        ToolButton{
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/comment2.svg":"qrc:/Image/comment.svg"
            onClicked: {
                current_page="comment"
                page.pageStack.push(Qt.resolvedUrl("CommentPage.qml"), {mysid: String(mysid)})
            }

        }
        ToolButton{
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/share2.svg":"qrc:/Image/share.svg"
            //opacity: night_mode?brilliance_control:1
            onClicked: {
                comment.hide()
                myshare.open()
            }
        }
    }
    Connections{
        target: cacheContent
        /*onContent_image:{
            contentY=flick1.contentY
            console.log("content y:"+flick1.contentY)
            url=string
            if(status===PageStatus.Active)
                web.url=string
        }*/
        onImageDownloadFinish:{
            //(const QString id_content,const QString id_image,const QString suffix)
            console.log("Image Download finish")
            //loading=false
            if(id_content==mysid)
            {
                if(allowDoubleClick)
                    web.evaluateJavaScript("document.getElementById(\""+id_image+"\""+").setAttribute(\"src\",\""+id_image+suffix+"\");")//将html中的图片url设置为本地下载的图片
                else{
                    //console.log("Image Download finish")
                    web.evaluateJavaScript("document.getElementById(\""+id_image+"\""+").setAttribute(\"data-url\",\""+id_image+suffix+"\");")//将html中的图片url设置为本地下载的图片
                    //web.evaluateJavaScript("$(\"#"+id_image+"\""+").attr(\"data-url\",\""+id_image+suffix+"\");")//将html中的图片url设置为本地下载的图片
                    web.evaluateJavaScript("refreshImage()")
                }
            }
        }
    }
    QueryDialog {
        id:dialog
        acceptButtonText: "确认"
        rejectButtonText: "取消"
        onAccepted: {
            //utility.launchPlayer(web.videoUrl)
            Qt.openUrlExternally(web.videoUrl)
            dialog.close()
        }
        onRejected: {
            dialog.close()
        }

    }
    function showDialog(name){
        dialog.titleText=name
        dialog.open()
    }
    Flickable{
        id:flick1
        anchors.fill: parent
        maximumFlickVelocity: 3000
        pressDelay:50
        interactive: page.allowMouse
        flickableDirection:Flickable.VerticalFlick
        contentHeight: web.height+title_main.height+60
        NumberAnimation on contentY{ id:flickYto0; from:10;to:0;duration: 100;running: false;onCompleted: web.opacity=night_mode?brilliance_control:1}
        NumberAnimation on contentY{
            id:contnetToHead
            to:0
            duration: 300
            running: false
            easing.type: Easing.OutQuart
        }
        NumberAnimation on contentY{
            id:contnetYrecover
            to:contentPage.contentY
            duration: 100
            running: false
            easing.type: Easing.OutQuart
        }

        Rectangle{
            id:title_main
            clip: true
            color:main.night_mode?"#191919":"#EBEBEB"
            width: parent.width
            height: title_string.height+info_string.height+30
            Text{
                id:title_string
                y:15
                opacity: night_mode?brilliance_control:1
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                text:title
                font.bold: true
                font.pixelSize:24
                wrapMode:Text.WordWrap
                color:main.night_mode?"#f0f0f0":"#282828"

            }
            Text{
                id:info_string
                clip:true
                anchors.top: title_string.bottom
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: mark.left
                anchors.rightMargin: 10
                text:postdate+"    "+newssource+"("+newsauthor+")"
                font.pixelSize:15
                color:main.night_mode?"#969696":"#646464"
            }
            Image{
                id:mark//标记是否收藏
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                source: utility.getFavorite(String(mysid))?"qrc:/Image/icon_grade_middle_star_s.png":"qrc:/Image/icon_grade_middle_star_n.png"
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        var string;
                        //utility.consoleLog("这篇文章被标记的状态："+settings.getValue("mark"+String(newsid),false))
                        if(utility.getFavorite(String(mysid)))
                        {
                            string=utility.deleteMyLikeNews(String(mysid))//取消收藏
                            if(string!="操作失败，请重试")
                            {

                                mark.source="qrc:/Image/icon_grade_middle_star_n.png"
                                if(utility.getFavoriteIsNull()&page.myList.zone=="favorite")
                                {
                                    page.myList.addNewsZone()//如果收藏夹空了就返回到最新资讯
                                }
                            }

                        }else{
                            string=utility.addMyLikeNews(String(mysid),me_to_xml)//加入收藏
                            if(string!="操作失败，请重试")
                            {
                                mark.source="qrc:/Image/icon_grade_middle_star_s.png"
                            }
                        }
                        showBanner(string)//显示返回的信息
                    }
                }
            }
        }

        WebView{
            id:web
            url:""
            anchors.top: title_main.bottom
            property string videoUrl
            onWidthChanged: {
                var temp=web.url
                web.url=""
                web.url=temp
                //setCssToTheme()//如果屏幕放心变了
            }
            opacity: 0
            width: parent.width
            Behavior on opacity{
                NumberAnimation{duration: 300}
            }
            //smooth: true
            settings {
                javascriptEnabled :true
                minimumFontSize: content_font_size
            }
            onAlert:{
                console.log(message)
                //(message)
            }

            Rectangle{
                id:shade
                width: parent.width
                //height: 500
                color: night_mode?"#000000":"#f1f1f1"
                visible: false
            }

            javaScriptWindowObjects: QtObject {
                WebView.windowObjectName: "qml"
                function enlargeImage(src,pos,imageHeight){//此函数用来接收html中img标签的onclick事件并处理，目的是点击图片放大显示
                    //web.evaluateJavaScript("alert($(\"img\").attr(\"my\"))")//
                    if(flick1.interactive)
                    {
                        shade.y=pos
                        //utility.consoleLog("图片高度是："+imageHeight)
                        shade.height=imageHeight
                        shade.visible=true
                        if(loading)
                            main.busyIndicatorHide()//隐藏缓冲圈圈
                        comment.hide()
                        image.imageUrl=utility.cacheImagePrefix+mysid+"/"+src
                        image.opacity=1
                    }
                }
                function openUrl(src){//此函数式为了响应html中的onclick事件，目的是调用系统浏览器打开这个src链接
                    console.log("open url:"+src)
                    Qt.openUrlExternally(src)
                }
                function openVideoUrl(src){//此函数为了响应html中的onclick事件，目的是播放视频
                    console.log("open video url:"+src)
                    if(src==="letv"){
                        showBanner("抱歉，不支持播放此视频")
                    }else{
                        web.videoUrl=src
                        showDialog("确认播放此视频？")
                    }
                }
                function loadImage(url,id,suffix){//此函数为了响应html中的onclick事件，目的是加载这个图片，url是图片的网络地址，id是img标签的id属性(同为图片名字)，suffix是图片的格式
                    //console.log(url+"\n"+id+"\n"+suffix)
                    //if(allowDoubleClick)//判断是否是无图模式，非无图模式不响应这个点击
                    //{
                        //loading=true
                        cacheContent.imageDownload(mysid,url,id,suffix)
                    //}

                    //web.evaluateJavaScript("$(\"#"+id+"\""+").attr(\"src\",\""+id+suffix+"\")")//将html中的图片url设置为本地下载的图片

                }
                function screenHeight()
                {
                    //utility.consoleLog("调用了获取屏幕高度的函数")
                    return contentPage.height-title_main.height
                }
                function getcContentY()
                {
                    //utility.consoleLog("请求获取文章内容的Y坐标")
                    return flick1.contentY
                }

            }


            onUrlChanged: {
                utility.consoleLog("webview url改变："+web.url)
            }
            onLoadFailed: {
                utility.consoleLog("网页加载出错")
            }

            onLoadFinished: {
                if(contentY===0)
                    flickYto0.start()
                loading=false
                contnetYrecover.start()
                if(!allowDoubleClick)
                    web.evaluateJavaScript("refreshImage()")
            }
            onLoadStarted: loading=true//开始加载网页
            onDoubleClick: {
                if(allowDoubleClick)
                {
                    //loading=true
                    utility.imageToShow("contentImage"+String(mysid))
                    //var temp=cacheContent.getContent_image(mysid)
                    //if(temp.indexOf("noImageModel")<0&temp!=="-1")
                        //web.url=temp
                    allowDoubleClick=false
                    web.evaluateJavaScript("refreshImage()")
                }
            }
        }
        onMovementStarted: {
            up.opacity=0
        }
        onMovementEnded: {
            if(flick1.contentY>0)
                up.opacity=1
        }
        Connections{
            target: main.full?flick1:null
            onMovementStarted: {
                //main.showToolBar=false
                comment.hide()
            }
            onMovementEnded: {
                //main.showToolBar=true
                comment.show()
            }
        }
        Connections{
            target: allowDoubleClick?null:flick1
            onMovementEnded: {
                web.evaluateJavaScript("refreshImage()")
            }
        }
    }
    ScrollBar {
        //platformInverted: main.platformInverted
        flickableItem: flick1
        anchors { right: flick1.right; top: flick1.top }
    }
    Image{
        id:up
        opacity: 0
        source: "qrc:/Image/up.svg"
        anchors.right: parent.right
        anchors.bottom: comment.visible?comment.top:parent.bottom
        anchors.margins: 10
        sourceSize.width: 60
        Behavior on opacity{
            NumberAnimation{duration: 300}
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                up.opacity=0
                contnetToHead.start()
            }
        }
    }
    MyImageViewr{
        id:image
        ScrollBar {
            flickableItem: image.myView
            anchors { right: image.right; top: image.top }
        }
        ScrollBar {
            flickableItem: image.myView
            orientation: Qt.Horizontal
            anchors { bottom: image.bottom }
        }
        function close(){
            image.opacity=0
            shade.visible=false
            page.allowMouse=true
            comment.show()
            if(loading)
                main.busyIndicatorShow()//显示缓冲圈圈
        }
    }
    MyShare{
        id:myshare
        function close(){
            comment.show()
            if(loading)
                main.busyIndicatorShow()//显示缓冲圈圈
        }
        function copyContent() {
            var temp=utility.getContent_text(mysid)
            utility.consoleLog(temp)
            if(temp!=="-1")
            {
                utility.setClipboard(title+"\n"+temp)
                showBanner("复制成功了")
            }else{
                showBanner("复制失败")
            }
        }
        function openUrl() {
            console.log("http://wap.ithome.com"+myurl)
            Qt.openUrlExternally("http://wap.ithome.com/html/"+mysid+".htm")
        }
    }
    MyComment{
        id:comment
        mysid:contentPage.mysid
    }
    //Component.onCompleted: utility.consoleLog("新闻内容界面的高度是："+contentPage.height)
    onStatusChanged: {
        if(status===PageStatus.Active&url!="")
        {
            console.log("content url="+url)
            web.url=url
            url=""
        }
    }
}
