// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
Item{
    id:comment
    property alias placeholderText: contentField.placeholderText
    property string parentCommentID: "0"//回复楼中楼时候的id标识
    function commentClose(msg){}
    visible: false
    width: parent.width;

    height: contentField.height+13//Math.max()

    Connections{
        target: comment.visible?parent:null
        onHeightChanged:{
            comment.y=parent.height-comment.height
        }
    }
    onHeightChanged: comment.y=parent.height-comment.height
    property string mysid: ""
    property bool isMeShow: false//是否是自己在显示，否则就是系统工具栏在显示
    function show()
    {
        if(main.showToolBar)
        {
            isMeShow=true
            main.showToolBar=false
            begin.start()
        }else if(!comment.visible){
            if(isMeShow)
            {
                show_me.start()
            }else{
                isMeShow=false
                main.showToolBar=true
            }
        }
    }
    function hide()
    {
        if(main.showToolBar)
            main.showToolBar=false
        else
            hide_me2.start()
    }

    function close()
    {

        isMeShow=false
        if(contentField.focus)
        {
            contentField.focus=false
            contentField.platformCloseSoftwareInputPanel()
        }
        contentField.text=""
        placeholderText="请输入评论内容"
        parentCommentID="0"
        hide_me.start()
    }
    function post()
    {
        if(contentField.text!=""){
            loading=true
            var url="http://www.ithome.com/ithome/postComment.aspx"
            var data="newsid="+mysid+"&commentNick="+settings.getValue("name","匿名")+"&commentContent="+contentField.text+settings.getValue("signature","----我的小尾巴")
            var other="&parentCommentID="+parentCommentID+"&type=comment&client="+settings.getValue("client","1")+"&device="+settings.getValue("device","RM-821")
            utility.postHttp(url,data+other,settings.getValue("userCookie","ASP.NET_SessionId=000000000000000000000000"))
        }
    }
    Timer{
        id:begin
        interval:  toolBarStyle.visibilityTransitionDuration
        onTriggered: show_me.start()
    }

    NumberAnimation on y{
        id:show_me
        running: false
        from:parent.height
        to:parent.height-comment.height
        easing.type: Easing.InOutExpo;
        duration: toolBarStyle.visibilityTransitionDuration
        onStarted: comment.visible=true
    }
    NumberAnimation on y{
        id:hide_me
        easing.type: Easing.InOutExpo;
        duration: toolBarStyle.visibilityTransitionDuration
        running: false
        from:parent.height-comment.height
        to:parent.height
        onCompleted: {
            comment.visible=false
            main.showToolBar=true
        }
    }
    NumberAnimation on y{
        id:hide_me2
        easing.type: Easing.InOutExpo;
        duration: toolBarStyle.visibilityTransitionDuration
        running: false
        from:parent.height-comment.height
        to:parent.height
        onCompleted: {
            comment.visible=false
        }
    }
    Connections{
        target: utility
        onPostOk:{
            loading=false
            showBanner(returnData)
            if(returnData==="评论成功")
            {
                commentClose(returnData)
                close()
            }
        }
    }
    Image {
        anchors.top : background.top
        anchors.right: background.left
        anchors.bottom : background.bottom
        source: "image://theme/meegotouch-menu-shadow-left"
    }
    Image {
        anchors.bottom : background.top
        anchors.left: background.left
        anchors.right : background.right
        source: "image://theme/meegotouch-menu-shadow-top"
    }
    Image {
        anchors.top : background.top
        anchors.left: background.right
        anchors.bottom : background.bottom
        source: "image://theme/meegotouch-menu-shadow-right"
    }
    Image {
        anchors.top : background.bottom
        anchors.left: background.left
        anchors.right : background.right
        source: "image://theme/meegotouch-menu-shadow-bottom"
    }
    BorderImage {
        id: background
        ToolBarStyle { id: toolBarStyle; }
        anchors.fill: parent;
        border.left: 10
        border.right: 10
        border.top: 10
        border.bottom: 10
        source: toolBarStyle.background;
    }
    ToolIcon{
        id:back
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        opacity: night_mode?brilliance_control:1
        iconId: "toolbar-back";
        onClicked: {
            close()
        }
    }
    TextArea{
        id:contentField
        placeholderText: "请输入评论内容"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: message_send.left
        anchors.left: back.right
    }
    ToolIcon{
        id:message_send
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        opacity: night_mode?brilliance_control:1
        iconId: "toolbar-send-chat"
        onClicked: {
            post()
        }
    }
}
