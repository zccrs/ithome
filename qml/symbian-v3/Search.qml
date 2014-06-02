// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0
MyPage{
    id:root
    focus:true
    function close()
    {
        if(online){
            if(so.searchText!=""){
                Qt.openUrlExternally("https://www.google.com.hk/search?q=www.ithome.com"+so.searchText)
                so.searchTextInputFocus=false
                so.closeSoftwareInputPanel()
                so.searchText=""
            }
        }else{
            showBanner("亲，还没联网呢")
        }
    }
    tools: CustomToolBarLayout{
        id:searchTool
        ToolButton{
            id:backButton
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            onClicked: {
                current_page="page"
                so.searchText=""
                so.searchTextInputFocus=false
                so.closeSoftwareInputPanel()
                if(loading)
                    main.busyIndicatorShow()//显示缓冲圈圈
                pageStack.pop()
            }
        }
        ToolButton{
            //platformInverted: main.platformInverted
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/search2.svg":"qrc:/Image/search.svg"
            //opacity: night_mode?brilliance_control:1
            onClicked: close()
        }
    }
    MySearchBox{
        id:so
        placeHolderText: "请输入内容搜索"
        //platformInverted: main.platformInverted
    }
    Keys.onPressed: {
        if(event.key === Qt.Key_Context1)
            backButton.clicked()
        else if(event.key === Qt.Key_Select||event.key === Qt.Key_Enter||event.key === Qt.Key_Return){
            if(so.activeFocus)
                close()
            else
                so.forceActiveFocus()
        }
        event.accepted = true
    }

    onStatusChanged: {
        if(status==PageStatus.Active)
        {
            labelTxt="搜索"
        }
    }
}
//
