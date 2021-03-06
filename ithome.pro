# Add more folders to ship with the application, here
TARGET = ithome
VERSION = 1.2.2

QT += network webkit xml
CONFIG += mobility
MOBILITY += systeminfo

folder_01.source = qml/meego
folder_01.target = qml
folder_02.source = qml/symbian-anna
folder_02.target = qml
folder_03.source = qml/general
folder_03.target = qml
folder_04.source = qml/symbian-v3#如果是s60v3就改成symbian-v3，是v5就是symbian-v5
folder_04.target = qml
DEPLOYMENTFOLDERS = folder_03



simulator {
    message(simulator build)
    DEPLOYMENTFOLDERS += folder_01 folder_02 folder_04
    RESOURCES += \
        symbian.qrc
}

contains(MEEGO_EDITION, harmattan){
    message(harmattan build)
    DEPLOYMENTFOLDERS += folder_01
    DEFINES += Q_OS_HARMATTAN

    splash.files = Image/MeeGo.png
    splash.path = /opt/ithome/data

    iconsvg.files += $${TARGET}meego.svg
    iconsvg.path = /usr/share/themes/base/meegotouch/$${TARGET}



    export(splash.files)
    export(splash.path)


    export(iconsvg.files)
    export(iconsvg.path)
    INSTALLS += splash iconsvg

    RESOURCES +=

}


# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:{
    contains(S60_VERSION, 5.0){
        message(symbian s60v3 build)
        DEFINES += Q_OS_S60V3#如果是s60v3就改成Q_OS_S60V3，是v5就是Q_OS_S60V5
        INCLUDEPATH += $$[QT_INSTALL_PREFIX]/epoc32/include/middleware
        INCLUDEPATH += $$[QT_INSTALL_PREFIX]/include/Qt
        DEPLOYMENTFOLDERS += folder_04
    }else{
        message(symbian anna build)
        DEPLOYMENTFOLDERS += folder_02
    }
    DEPLOYMENTFOLDERS += folder_03
    TARGET.UID3 = 0xE274BCB6
    TARGET.CAPABILITY += NetworkServices
    RESOURCES += symbian.qrc
}



# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable

# Add dependency to Symbian components
#CONFIG += qt-components

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    #src/myimage.cpp \
    src/settings.cpp \
    src/utility.cpp \
    src/threaddownloadimage.cpp \
    src/myxmllistmodel.cpp \
    src/cache.cpp \
    src/mynetworkaccessmanagerfactory.cpp

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/symbian-v3/* \
    qml/symbian-v5/* \
    qml/meego/* \
    qml/symbian-v5/UserCenter.qml \
    qml/symbian-v5/TitleAndTextField.qml \
    qml/symbian-v5/RetrievePassword.qml \
    qml/symbian-v5/RegisterAccount.qml \
    qml/symbian-v5/LoginPage.qml \
    qml/symbian-v5/SetUserPassword.qml \
    qml/meego/UserCenter.qml \
    qml/meego/TitleAndTextField.qml \
    qml/meego/SetUserPassword.qml \
    qml/meego/RetrievePassword.qml \
    qml/meego/RegisterAccount.qml \
    qml/meego/LoginPage.qml \
    qml/symbian-v3/UserCenter.qml \
    qml/symbian-v3/TitleAndTextField.qml \
    qml/symbian-v3/SetUserPassword.qml \
    qml/symbian-v3/RetrievePassword.qml \
    qml/symbian-v3/RegisterAccount.qml \
    qml/symbian-v3/MyRadioButton.qml \
    qml/symbian-v3/LoginPage.qml \
    qml/meego/UIConstants.js \
    ithome_harmattan.desktop

RESOURCES += \
    general.qrc \
    meego.qrc

HEADERS += \
    #src/myimage.h \
    src/settings.h \
    src/utility.h \
    src/threaddownloadimage.h \
    src/myxmllistmodel.h \
    src/cache.h \
    src/mynetworkaccessmanagerfactory.h
