// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0

ListView {
    id:listview
    property alias pull_down_visible: pull_down.visible
    interactive: allowMouse
    highlightMoveDuration: 300
    height: parent.height-y
    clip: sysIsSymbian_v3?false:true//必须开启，不然夜间模式的时候因为状态栏有透明度会将其显示出来
    model: listmodel
    delegate: Component{
        Loader{
            width: parent.width
            source: index == 0?"SlideNewsView.qml":"MyLiseComponent.qml"
            //Component.onCompleted: utility.consoleLog("index是："+index+" "+source)
        }
    }
    maximumFlickVelocity: 2800
    width: parent.width

    Component {
        id: highlightBar
        Rectangle {
            width: listview.width
            height: 100
            color: night_mode? "#00ffee":"#00CCFF"
            z:2
            opacity: 0.2
            radius: 10
            y: listview.currentItem.y;
            Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
        }
    }
    highlight: (deviceName==="RM-609"||(deviceName==="Simulator Product Name"&width===640))||sysIsSymbian_v3?highlightBar:null
    property bool loadSwitch: true

    function addmodel(){
        if(!loading)
        {
            if(zone==="rank"){
                return
            }else{
                //isRunning=true
                for(var i=0;i<addxmlmodel.count;++i){
                    /*if(isPause){
                        count=i
                        return
                    }*/
                    //console.log("add2 sid:"+addxmlmodel.get(i).newsid)
                    //cacheContent.saveTitle(addxmlmodel.get(i).newsid,addxmlmodel.get(i).title)
                    //cacheContent.saveContent(addxmlmodel.get(i).newsid,addxmlmodel.get(i).detail)
                    listmodel.append({
                                 "title":addxmlmodel.get(i).title,
                                 "m_url":addxmlmodel.get(i).m_url,
                                 "image":addxmlmodel.get(i).image,
                                 "description":addxmlmodel.get(i).description,
                                 "detail":addxmlmodel.get(i).detail,
                                 "newsid":addxmlmodel.get(i).newsid,
                                 "hitcount":addxmlmodel.get(i).hitcount,
                                 "commentcount":addxmlmodel.get(i).commentcount,
                                 "postdate":addxmlmodel.get(i).postdate,
                                 "newssource":addxmlmodel.get(i).newssource,
                                 "newsauthor":addxmlmodel.get(i).newsauthor,
                                 "isHighlight":false,
                                 "m_text":""
                                })
                }
                //isRunning=false
                if(Number(addxmlmodel.get(addxmlmodel.count-1).newsid)<minnewsidData)
                {
                    minnewsidData=Number(addxmlmodel.get(addxmlmodel.count-1).newsid)

                }
                if(!loading)
                {
                    addxmlmodel.source="http://www.ithome.com/rss/"+zone+"lessthan_"+String(minnewsidData)+".xml"
                    addxmlmodel.query="/rss/channel/item"
                    addxmlmodel.reload()
                }
            }

        }
    }
    Item{
        id:pull_down
        visible: zone!="favorite"?true:false
        width: loadImage.width+loadData.width
        anchors.horizontalCenter: parent.horizontalCenter
        y:-contentY-20-pull_down.height
        Image{
            id:loadImage
            opacity: night_mode?brilliance_control:1
            source:main.night_mode? "qrc:/Image/pull_down.svg":"qrc:/Image/pull_down_inverse.svg"
            anchors.verticalCenter: parent.verticalCenter
            Behavior on rotation{
                NumberAnimation{duration: 100}
            }
        }
        Text {
            id: loadData
            text: "下拉刷新"
            color: main.night_mode?"#f0f0f0":"#282828"
            font.pixelSize: main.sysIsSymbian?20:22
            anchors.left: loadImage.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            opacity: 0.5//night_mode?brilliance_control:
        }
        NumberAnimation on y{
            id:pull_down_to_homeing
            duration: 000
            to:-50
            running: false
        }
    }

    onContentYChanged: {
        if(contentY<-10&zone!="favorite")
        {
            //pull_down.y=-contentY-20-pull_down.height
            if(listview.contentY<-80)
            {
                if(loadImage.rotation===0){
                    loadImage.rotation=180
                    loadData.text="松手刷新"
                }
            }else if(loadImage.rotation===180){
                loadImage.rotation=0
                loadData.text="下拉刷新"
                if(!loading)
                {
                    reModel()
                }
            }
        }
    }
    onCurrentIndexChanged: {
        if(sysIsSymbian_v3&currentIndex===count-1)
        {
            addmodel()
        }
    }

    onMovementEnded: {
        if((listview.contentY>=listview.contentHeight-parent.height)&!loading&zone!="favorite"){
            addmodel()
        }
    }
    onAtYBeginningChanged: loadSwitch=!loadSwitch
 }
