// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
Item{
    property alias placeholderText: contentField.placeholderText
    property string parentCommentID: "0"//回复楼中楼时候的id标识
    function commentClose(msg){}
    signal comment_close;
    id:comment
    visible: false
    width: parent.width;
    height: Math.max(toolBarHeight, contentField.height+5);
    Connections{
        target: comment.visible?parent:null
        onHeightChanged:{
            comment.y=parent.height-comment.height
        }
    }
    onHeightChanged: comment.y=parent.height-comment.height
    property string mysid: ""

    property int toolBarHeight: (screen.width < screen.height)
                                ? privateStyle.toolBarHeightPortrait
                                : privateStyle.toolBarHeightLandscape
    property bool isMeShow: true//是否是自己在显示，否则就是系统工具栏在显示
    function show()
    {
        if(!comment.visible){
            forceActiveFocus()
            show_me.start()
        }
    }
    function hide()
    {
        hide_me2.start()
    }
    function close()
    {
        contentField.text=""
        placeholderText="评论"
        parentCommentID="0"
        hide_me.start()
    }


    function post()
    {
        if(contentField.text!=""){
            var url="http://www.ithome.com/ithome/postComment.aspx"
            var data="newsid="+mysid+"&commentNick="+settings.getValue("name","匿名")+"&commentContent="+contentField.text+settings.getValue("signature","----我的小尾巴")
            var other="&parentCommentID="+parentCommentID+"&type=comment&client="+settings.getValue("client","1")+"&device="+settings.getValue("device","RM-821")
            utility.postHttp("POST",url,data+other)
        }
    }
    Timer{
        id:begin
        interval: 200
        onTriggered: show_me.start()
    }

    NumberAnimation on y{
        id:show_me
        duration: 200
        easing.type: Easing.OutQuad
        running: false
        from:parent.height
        to:parent.height-comment.height//-comment.height
        onStarted: {
            comment.visible=true
        }
    }
    NumberAnimation on y{
        id:hide_me
        duration: 200
        easing.type: Easing.Linear
        running: false
        from:parent.height-comment.height
        to:parent.height
        onCompleted: {
            comment_close()
            comment.visible=false
        }
    }
    NumberAnimation on y{
        id:hide_me2
        easing.type: Easing.InOutExpo;
        duration: 200
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

    BorderImage {
        id: background
        anchors.fill: parent
        source:night_mode?"qrc:/Image/toolbar.svg":"qrc:/Image/toolbar_inverse.svg"
        border { left: 20; top: 20; right: 20; bottom: 20 }
    }
    TextArea{
        id:contentField
        //platformInverted: main.platformInverted
        placeholderText: "评论"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.margins: 10

    }
    Keys.onPressed: {
        utility.consoleLog("评论中按下了按键")
        if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return)
        {
            if(contentField.activeFocus){
                post()
            }else
                contentField.forceActiveFocus()
        }else if(event.key == Qt.Key_Context1){
            close()
        }
        event.accepted = true
    }
}
