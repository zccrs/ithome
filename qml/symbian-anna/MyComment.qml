// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
Item{
    property alias placeholderText: contentField.placeholderText
    property alias text: contentField.text
    property string parentCommentID: "0"//回复楼中楼时候的id标识
    function commentClose(msg){}
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
        if(contentField.activeFocus)
        {
            contentField.focus=false
            contentField.closeSoftwareInputPanel()
        }
        contentField.text=""
        placeholderText="请输入评论内容"
        parentCommentID="0"
        hide_me.start()
    }


    function post()
    {
        if(contentField.text!=""){
            var url="http://www.ithome.com/ithome/postComment.aspx"
            var data="newsid="+mysid+"&commentNick="+settings.getValue("name","匿名")+"&commentContent="+contentField.text+settings.getValue("signature","----我的小尾巴")
            var other="&parentCommentID="+parentCommentID+"&type=comment"//&client="+settings.getValue("client","1")+"&device="+settings.getValue("device","RM-821")
            utility.postHttp(url,data+other)
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
            comment.visible=false
            main.showToolBar=true
            parent.forceActiveFocus()
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
        source: night_mode?"qrc:/Image/toolbar.svg":privateStyle.imagePath("qtg_fr_toolbar", main.platformInverted)
        //Component.onCompleted: utility.consoleLog("工具栏的背景图是:"+source)
        border { left: 20; top: 20; right: 20; bottom: 20 }
    }
    ToolButton{
        id:back
        anchors.left: parent.left
        anchors.leftMargin: parent.width===640?20:0
        anchors.bottom: parent.bottom
        //anchors.bottomMargin: parent.width===640?5:0
        //anchors.verticalCenter: parent.verticalCenter
        opacity: night_mode?brilliance_control:1
        platformInverted: main.platformInverted
        iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
        onClicked: {
            close()
        }
    }
    TextArea{
        id:contentField
        platformInverted: main.platformInverted
        placeholderText: "请输入评论内容"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: message_send.left
        anchors.left: back.right
        anchors.margins: 10

    }
    ToolButton{
        id:message_send
        opacity: night_mode?brilliance_control:1
        anchors.right: parent.right
        anchors.rightMargin: parent.width===640?20:0
        anchors.bottom: parent.bottom
        //anchors.bottomMargin:parent.width===640?5:0
        //anchors.verticalCenter: parent.verticalCenter
        platformInverted: main.platformInverted
        iconSource: night_mode?"qrc:/Image/message_send.svg":"qrc:/Image/message_send_inverted.svg"
        onClicked: {
            post()
        }
    }
    function keysPress()
    {
        if(contentField.activeFocus){
            if(contentField.text!="")
                post()
            else
                parent.forceActiveFocus()
        }else
            contentField.forceActiveFocus()
    }
}
