// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.symbian 1.1
import "../general"
MyPage{
    id:page

    property bool isQuit: false
    property alias myList: list
    property bool allowMouse: true


    function open_selection_list()
    {
        main_selection_list.open()
    }
    function loadContent(pageData)
    {
        pageStack.push(Qt.resolvedUrl("Content.qml"),pageData)
    }

    Timer{
        id:judgeQuit
        interval: 2000
        onTriggered: isQuit=false
    }

    tools: CustomToolBarLayout{
        id:mainTool

        ToolButton{
            id:backButton
            platformInverted: main.platformInverted
            iconSource: night_mode?"qrc:/Image/back2.svg":"qrc:/Image/back.svg"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                if(isQuit){
                    Qt.quit()
                }
                else{
                    main.showBanner("再按一次退出")
                    isQuit=true
                    judgeQuit.start()
                }
            }
        }
        ToolButton{
            id:refreshButton
            platformInverted: main.platformInverted
            iconSource: night_mode?"qrc:/Image/refresh2.svg":"qrc:/Image/refresh.svg"
            opacity: night_mode?brilliance_control:1
            onClicked: list.reModel()
        }
        ToolButton{
            id:searchButton
            platformInverted: main.platformInverted
            iconSource: night_mode?"qrc:/Image/search2.svg":"qrc:/Image/search.svg"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                current_page="search"
                if(loading)
                    main.busyIndicatorHide()//隐藏缓冲圈圈
                list.addListViewCount=0//将新增新闻的数量置为0
                pageStack.push(Qt.resolvedUrl("Search.qml"))
            }
        }
        ToolButton{
            id:settingButton
            platformInverted: main.platformInverted
            iconSource: night_mode?"qrc:/Image/setting2.svg":"qrc:/Image/setting.svg"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                current_page="setting"
                if(loading)
                    main.busyIndicatorHide()//隐藏缓冲圈圈
                pageStack.push(setting)
            }
        }
    }
    MainList{
        id:list
        ScrollBar{
            flickableItem:list.myView
            platformInverted: main.platformInverted
            anchors { right: list.myView.right; top: list.myView.top }
        }
        onButtonPress: {
            switch(keysid)
            {
            case Qt.Key_Backspace:
                if(main.showToolBar)
                    backButton.clicked()
                break
            default:
            {
                switch(mykeys.isButtonClick(keysid))
                {
                case mykeys.button1:
                    backButton.clicked()
                    break
                case mykeys.button2:
                    refreshButton.clicked()
                    break
                case mykeys.button3:
                    searchButton.clicked()
                    break
                case mykeys.button4:
                    settingButton.clicked()
                    break
                default:break
                }
                break;
            }
            }
        }
    }

    MySettings{
        id:setting
    }
    SelectionDialog {
        id: main_selection_list
        platformInverted: main.platformInverted
        titleText: "选择要显示的新闻"
        model: ListModel {
            ListElement { name: "我的收藏" }
            ListElement { name: "最新资讯" }
            ListElement { name: "排行榜" }
            ListElement { name: "WP专区" }
            ListElement { name: "WIN8专区" }
            ListElement { name: "IOS专区" }
            ListElement { name: "Android专区" }
        }
        //onPrivateClicked: console.log("PrivateClicked")
        onAccepted: {
            switch(selectedIndex){
            case 0:
                list.addFavoriteZone()
                break
            case 1:
                list.addNewsZone()
                break
            case 2:
                list.addRankZone()
                break
            case 3:
                list.addWPZone()
                break
            case 4:
                list.addWIN8Zone()
                break
            case 5:
                list.addIOSZone()
                break
            case 6:
                list.addAndroidZone()
                break
            default:break
            }
        }
        onStatusChanged: {
            //utility.consoleLog("SelectionDialog现在的状态是："+status+" "+DialogStatus.Closed)
            if(status===DialogStatus.Closed)
                page.forceActiveFocus()
        }
    }
    onFocusChanged: {
        if(focus)
            list.forceActiveFocus()
    }
}
