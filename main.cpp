#include <QtGui/QApplication>
#include <QSplashScreen>
#include <QPixmap>
#include <QString>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>

#include <QWebSettings>
#include "qmlapplicationviewer.h"
#include "src/mynetworkaccessmanagerfactory.h"
#include "src/cache.h"
#include "src/settings.h"
#include "src/utility.h"
//#include "src/myxmllistmodel.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));
    //qDebug()<<QString::fromUtf8("主线程地址是：")<<QThread::currentThread();
#if defined(Q_OS_SYMBIAN)||defined(Q_WS_SIMULATOR)
    QPixmap pixmap(":/Image/Symbian.png");
    QSplashScreen *splash = new QSplashScreen(pixmap);
    splash->show();
    splash->raise();
#endif

#if defined(Q_WS_SIMULATOR)
    QNetworkProxy proxy;
    proxy.setType(QNetworkProxy::HttpProxy);
    proxy.setHostName("localhost");
    proxy.setPort(8888);
    QNetworkProxy::setApplicationProxy(proxy);
#endif
    //int width=QApplication::desktop()->width();
    //int height=QApplication::desktop()->height();
    app->setApplicationName (QString::fromUtf8("IT之家"));
    app->setOrganizationName ("Stars");
    app->setApplicationVersion ("1.1.5");
    Settings *setting=new Settings;
    Utility *unility=new Utility;
    Cache *cacheContent=new Cache(setting);
    //qmlRegisterType<MyXmlListModel>("myXmlListModel",1,0,"MyXmlListModel");
    //qmlRegisterType<MyXmlRole>("myXmlListModel", 1, 0, "MyXmlRole");

    QmlApplicationViewer viewer;
    
    MyNetworkAccessManagerFactory *network = new MyNetworkAccessManagerFactory();
    viewer.engine()->setNetworkAccessManagerFactory(network);
    
    viewer.rootContext ()->setContextProperty ("cacheContent",cacheContent);
    viewer.rootContext()->setContextProperty("settings",setting);
    viewer.rootContext()->setContextProperty("utility",unility);
    
    QWebSettings::globalSettings ()->setAttribute (QWebSettings::LocalContentCanAccessRemoteUrls,true);
    QWebSettings::globalSettings ()->setAttribute (QWebSettings::SpatialNavigationEnabled,true);
    QWebSettings::globalSettings ()->setAttribute (QWebSettings::SpatialNavigationEnabled, true);
#if defined(Q_OS_SYMBIAN)||defined(Q_WS_SIMULATOR)
#if defined(Q_OS_S60V5)//判断qt的版本
    viewer.setMainQmlFile(QLatin1String("qml/symbian-v5/main.qml"));
    if(setting->getValue("night_mode",false).toBool())
        unility->setCss("./qml/symbian-v5/theme_black.css",viewer.width()-20);//设置默认的css
    else
        unility->setCss("./qml/symbian-v5/theme_white.css",viewer.width()-20);
#elif defined(Q_OS_S60V3)
    viewer.setMainQmlFile(QLatin1String("qml/symbian-v3/main.qml"));
    if(setting->getValue("night_mode",false).toBool())
        unility->setCss("./qml/symbian-v3/theme_black.css",viewer.width()-20);//设置默认的css
    else
        unility->setCss("./qml/symbian-v3/theme_white.css",viewer.width()-20);
#else
    viewer.setMainQmlFile(QLatin1String("qml/symbian-anna/main.qml"));
    if(setting->getValue("night_mode",false).toBool())
        unility->setCss("./qml/symbian-anna/theme_black.css",viewer.width()-20);//设置默认的css
    else
        unility->setCss("./qml/symbian-anna/theme_white.css",viewer.width()-20);
#endif

    viewer.showExpanded();
    splash->finish(&viewer);
    splash->deleteLater();
#elif defined(Q_OS_HARMATTAN)
    viewer.setMainQmlFile(QLatin1String("qml/meego/main.qml"));
    if(setting->getValue("night_mode",false).toBool())
        unility->setCss("/opt/ithome/qml/meego/theme_black.css",460);//设置默认的css
    else
        unility->setCss("/opt/ithome/qml/meego/theme_white.css",460);
    viewer.showExpanded();
#else
    viewer.setMainQmlFile(QLatin1String("qml/symbian-v5/main.qml"));
    viewer.show();
#endif
    return app->exec();
}
