// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.0
import com.nokia.symbian 1.0

Item{
    anchors.fill: parent
    Image{
        id: ithome_image
        source: "qrc:/Image/ithome.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
    }
    TextField{
        id:input_oldpassword
        placeholderText: "旧密码"
        anchors.top: ithome_image.bottom
        anchors.topMargin: 20
       
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_newpassword
        KeyNavigation.up: input_re_newpassword
        KeyNavigation.tab: input_newpassword
    }
    TextField{
        id:input_newpassword
        placeholderText: "新密码"
        anchors.top: input_oldpassword.bottom
        anchors.topMargin: 10
    
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_re_newpassword
        KeyNavigation.up: input_oldpassword
        KeyNavigation.tab: input_re_newpassword
    }
    TextField{
        id:input_re_newpassword
        placeholderText: "重复新密码"
        anchors.top: input_newpassword.bottom
        anchors.topMargin: 10
        
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width*0.8
        KeyNavigation.down: input_oldpassword
        KeyNavigation.up: input_newpassword
        KeyNavigation.tab: input_oldpassword
    }
    MyButton{
        id: register_button
        enabled: input_oldpassword.text!=""&input_newpassword.text!=""&input_re_newpassword.text!=""
        text: "确        认"
        font.pixelSize: 18
        anchors.top: input_re_newpassword.bottom
        anchors.topMargin: 20
        
        width: parent.width*0.6
        
        anchors.horizontalCenter: parent.horizontalCenter
        
        onClicked: {
            var url = "http://i.ruanmei.com/PostModifyUserInfo.aspx"
            var data = 
                    "nickName="+settings.getValue("UserNick","")+
                    "&oldpwd="+input_oldpassword.text+
                    "&newpwd="+input_newpassword.text+
                    "&newpwd2="+input_re_newpassword.text+
                    "&type=modify";
            if( input_newpassword.text==input_re_newpassword.text )
                utility.setUserData( data,url )
            else
                showBanner("两次输入新密码不一致")
        }
    }
}
