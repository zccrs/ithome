// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1
import "../general"
MyPage{
    id:page
    property bool allowMouse: true
    property alias myList: list
    function pushContent()
    {
        pageStack.push(content)
    }
    function open_selection_list()
    {
        main_selection_list.open()
    }
    function loadContent(pageData)
    {
        pageStack.push(Qt.resolvedUrl("Content.qml"),pageData)
    }
    tools: ToolBarLayout{

        ToolIcon{
            opacity: night_mode?brilliance_control:1
            iconSource: night_mode?"qrc:/Image/skin.png":"qrc:/Image/skin_invert.png"
            onClicked: {
                night_mode=!night_mode
                settings.setValue("night_mode",night_mode)
            }
        }
        ToolIcon{
            opacity: night_mode?brilliance_control:1
            iconId: "toolbar-refresh"
            onClicked: {
                list.reModel()
            }
        }
        ToolIcon{
            iconId: "toolbar-search"
            opacity: night_mode?brilliance_control:1
            onClicked: {
                current_page="search"
                if(loading)
                    main.busyIndicatorHide()//隐藏缓冲圈圈
                pageStack.push(Qt.resolvedUrl("Search.qml"))
            }
        }
        ToolIcon{
            iconId: "toolbar-settings"
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
        ScrollDecorator {
            flickableItem:list.myView
            //__alwaysShowIndicator:false
            //anchors { right: list.myView.right; top: list.myView.top }
        }
    }
    MySettings{
        id:setting
    }
    SelectionDialog {
        id: main_selection_list
        titleText: "选择要显示的新闻"
        model: ListModel {
            ListElement { name: "我的收藏" }
            ListElement { name: "最新资讯" }
            ListElement { name: "排行榜" }
            ListElement { name: "WP专区" }
            ListElement { name: "Windows专区" }
            ListElement { name: "IOS专区" }
            ListElement { name: "Android专区" }
            ListElement { name: "手机" }
            ListElement { name: "数码" }
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
                list.addWindowsZone()
                break
            case 5:
                list.addIOSZone()
                break
            case 6:
                list.addAndroidZone()
                break
            case 7:
                list.addPhoneZone()
                break
            case 8:
                list.addDigiZone()
                break
            default:break
            }
        }
    }
}
