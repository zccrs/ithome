// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
//import XmlListModel 1.0
AddXmlModel{
    id:addonemodel
    property int poss: -1;
    property string verifyKey:"";
    signal close
    function addone(m_pos,key){
        verifyKey=key
        poss=m_pos
        var temp=utility.outQueue()
        //console.log("addone model sid is:"+temp)
        if(temp!="null")
        {
            addonemodel.source="http://www.ithome.com/rss/"+temp+".xml"
            reload()
        }
        else {
            close()
        }
    }
    onStatusChanged: {
        if(status==XmlListModel.Ready&&count>0)
        {
            //cacheContent.saveTitle(addonemodel.get(0).newsid,addonemodel.get(0).title)
            //cacheContent.saveContent(addonemodel.get(0).newsid,addonemodel.get(0).detail)
            //console.log(addonemodel.get(0).detail+"\n")
            if(verifyKey!=zone) return
            if(poss===-1){
                listmodel.append({
                             "title":addonemodel.get(0).title,
                             "m_url":addonemodel.get(0).m_url,
                             "image":addonemodel.get(0).image,
                             "description":addonemodel.get(0).description,
                             "detail":addonemodel.get(0).detail,
                             "newsid":addonemodel.get(0).newsid,
                             "hitcount":addonemodel.get(0).hitcount,
                             "commentcount":addonemodel.get(0).commentcount,
                             "postdate":addonemodel.get(0).postdate,
                             "newssource":addonemodel.get(0).newssource,
                             "newsauthor":addonemodel.get(0).newsauthor,
                             "isHighlight":false,
                             "m_text":"",
                             "loaderSource": "MyLiseComponent.qml"
                            })
            }else{
                listmodel.insert(pos,{
                             "title":addonemodel.get(0).title,
                             "m_url":addonemodel.get(0).m_url,
                             "image":addonemodel.get(0).image,
                             "description":addonemodel.get(0).description,
                             "detail":addonemodel.get(0).detail,
                             "newsid":addonemodel.get(0).newsid,
                             "hitcount":addonemodel.get(0).hitcount,
                             "commentcount":addonemodel.get(0).commentcount,
                             "postdate":addonemodel.get(0).postdate,
                             "newssource":addonemodel.get(0).newssource,
                             "newsauthor":addonemodel.get(0).newsauthor,
                             "isHighlight":false,
                             "m_text":""
                            })
            }
            if(Number(addonemodel.get(0).newsid)>maxnewsidData)
                maxnewsidData=Number(addonemodel.get(0).newsid)
            if(Number(addonemodel.get(0).newsid)<minnewsidData)
                minnewsidData=Number(addonemodel.get(0).newsid)
            addone(poss,verifyKey)
        }
    }
}
