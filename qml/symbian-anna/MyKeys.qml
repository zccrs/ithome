// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1

QtObject{
    property int button1: 1
    property int button2: 2
    property int button3: 3
    property int button4: 4
    function isButtonClick(keyid)
    {
        utility.consoleLog(keyid)
        switch(keyid)
        {
        case Qt.Key_1:
            if(main.showToolBar)
                return button1
            else return -1
        case Qt.Key_R:
            if(main.showToolBar)
                return button1
            else return -1
        case Qt.Key_4:
            if(main.showToolBar)
                return button1
            else return -1
        case Qt.Key_F:
            if(main.showToolBar)
                return button1
            else return -1
        case Qt.Key_7:
            if(main.showToolBar)
                return button1
            else return -1
        case Qt.Key_V:
            if(main.showToolBar)
                return button2
            else return -1
        case Qt.Key_2:
            if(main.showToolBar)
                return button2
            else return -1
        case Qt.Key_T:
            if(main.showToolBar)
                return button2
            else return -1
        case Qt.Key_5:
            if(main.showToolBar)
                return button2
            else return -1
        case Qt.Key_G:
            if(main.showToolBar)
                return button2
            else return -1;
        case Qt.Key_8:
            if(main.showToolBar)
                return button2
            else return -1
        case Qt.Key_B:
            if(main.showToolBar)
                return button2
            else return -1
        case Qt.Key_3:
            if(main.showToolBar)
                return button3
            else return -1
        case Qt.Key_Y:
            if(main.showToolBar)
                return button3
            else return -1
        case Qt.Key_6:
            if(main.showToolBar)
                return button3
            else return -1
        case Qt.Key_H:
            if(main.showToolBar)
                return button3
            else return -1;
        case Qt.Key_9:
            if(main.showToolBar)
                return button3
            else return -1
        case Qt.Key_N:
            if(main.showToolBar)
                return button3
            else return -1
        case Qt.Key_Asterisk:
            if(main.showToolBar)
                return button4
            else return -1
        case Qt.Key_U:
            if(main.showToolBar)
                return button4
            else return -1
        case Qt.Key_NumberSign:
            if(main.showToolBar)
                return button4
            else return -1
        case Qt.Key_J:
            if(main.showToolBar)
                return button4
            else return -1;
        case Qt.Key_0:
            if(main.showToolBar)
                return button4
            else return -1
        case Qt.Key_M:
            if(main.showToolBar)
                return button4
            else return -1
        default:
            return -1;
        }
    }
}
