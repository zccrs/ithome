// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0

ListView {
    id:listview
    interactive: allowMouse
    cacheBuffer: 0
    highlightMoveDuration: 300
    height: parent.height-y
    clip: sysIsSymbian_v3?false:true//必须开启，不然夜间模式的时候因为状态栏有透明度会将其显示出来
    model: listmodel
    delegate: Component{
        Loader{
            width: parent.width
            source: loaderSource
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
                                 "m_text":"",
                                 "loaderSource": "MyLiseComponent.qml"
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
