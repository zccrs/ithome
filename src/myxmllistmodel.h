#ifndef DOWNLOAD_H
#define DOWNLOAD_H

#include <QObject>
#include <QtNetwork>
class Download : public QObject
{
    Q_OBJECT
public:
    explicit Download(QObject *parent = 0);
private:
    ~Download();
    QPointer<QNetworkAccessManager> manager;
    QPointer<QNetworkReply> reply;
signals:
    void downloadFinished(QNetworkReply*);
public slots:
    void startDownload(const QUrl url);//开始下载
    void stopDownload();//停止获取网络数据
};

#endif // DOWNLOAD_H

#ifndef MYXMLROLE_H
#define MYXMLROLE_H

#include <QObject>
#include <QDeclarativeItem>
#include <QString>

class MyXmlRole : public QDeclarativeItem
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)//设置要解析的标签
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)//设置创建储存标签内容的qml属性
    Q_PROPERTY(bool isKey READ isKey WRITE setIsKey NOTIFY isKeyChanged)//设置这个属性是否为重要的

public:
    explicit MyXmlRole(QDeclarativeItem *parent = 0);

    QString m_query;                       //
    void setQuery(const QString new_query);////设置要解析的标签
    const QString query();                 //

    QString m_name;                        //
    void setName(const QString new_query); ////设置创建储存标签内容的qml属性
    const QString name();                  //

    bool m_isKey;                          //设置这个属性是否为重要的
    const bool isKey();                    //
    void setIsKey(const bool new_isKey);   //
private:

signals:
    void queryChanged();
    void nameChanged();
    void isKeyChanged();
public slots:

};

#endif // MYXMLROLE_H




#ifndef MYXMLLISTMODEL_H
#define MYXMLLISTMODEL_H

#include <QDomDocument>
#include <QDomElement>
#include <QDomNodeList>
#include <QDomNode>
#include <QObject>
#include <QDeclarativeItem>
#include <QFile>
#include <QString>
#include <QObjectList>
#include <QStringList>
#include <QList>
#include <QDeclarativeEngine>
#include <QDeclarativeContext>
#include <QDeclarativeComponent>
#include <QThread>
#include <QPointer>

class MyXmlListModel : public QDeclarativeItem , public QDomDocument
{
    Q_OBJECT
    Q_PROPERTY(Status status READ status WRITE setStatus NOTIFY statusChanged)//我的状态
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)//xml文件路径
    //Q_PROPERTY(QString xml READ xml WRITE setXml NOTIFY xmlChanged)//xml数据
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)//设置从哪个标签开始
    Q_PROPERTY(int count READ count NOTIFY countChanged)//获取到的标签的个数
    Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)//是否在创建完毕就获取

    Q_ENUMS(Status)
public:
    explicit MyXmlListModel(QDeclarativeItem *parent = 0);
    ~MyXmlListModel();

    enum Status{
        Null,//没有设置xml的数据模型
        Ready,//解析完成
        Loading,//加载中
        Error//出错啦
    };

private:
    QPointer<Download> download;
    QPointer<QThread> mythread;

    Status m_status;                      //
    const Status status();                ////记录我的状态
    void setStatus(const Status new_status); //

    QString m_xml;                      //
    //const QString xml();                ////xml文件路径
    //void setXml(const QString new_xml); //

    QUrl m_source;                     //
    const QUrl source();               ////xml数据
    void setSource(QUrl new_source);   //

    QString m_query;                       //
    void setQuery(const QString new_query);////设置从哪个标签开始解析
    const QString query();                 //

    int m_count;                           //
    void setCount(const int new_count);    ////获取到的标签的个数
    const int count();                     //

    bool m_running;                         //
    void setRunning(const bool new_running);////是否在创建完毕就获取
    const bool running();                   //

    QString errorInfo;                     //储存出错信息

    QStringList prefixTags;//记录query中的分解出来的要解析的标签的父标签
    QStringList propertyName;//记录标签内容要存到的属性的名称
    QStringList tagsList;//记录要解析的标签
    QStringList tagsType;//记录要储存的标签内容的变量类型

    QObjectList objList;//记录解析出来的标签的qml

    void componentComplete();//重写的函数，在qml创建完毕后调用
    void analyze();//调用这个函数进行xml数据分析
    void creationObj(QStringList m_tagsType, QStringList m_tagsName, QStringList m_tagsContent);//一个是属性名称。一个是属性数据类型,一个是属性内容
    void saveQml(QDomElement *tag, int depth=0);//将分析到的数据存到qml

    QPointer<QDeclarativeComponent> component;//用了动态创建qml
    QPointer<QDeclarativeEngine> engine;///////
signals:
    void downloadData(const QUrl url);
    void stopDownload();//停止从网络下载数据
    //void xmlChanged();
    void sourceChanged();
    void queryChanged();
    void statusChanged();
    void countChanged();
    void runningChanged();

    void error(const QString message);

    void deleteQml();//发送信号delete掉动态创建的qml
public slots:
    void replyFinished(QNetworkReply*);
    void reload();//重新解析信息
    const QString errorString();//返回出错信息，为了兼容系统的qml xmlListModel，我这里改为了信号error(const QString message);
    QObject* get(const int index);//获取储存第index个xml标签的qml的id
};

#endif // MYXMLLISTMODEL_H
