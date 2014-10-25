#include "myxmllistmodel.h"

Download::Download(QObject *parent) :
    QObject(parent)
{
}
void Download::startDownload(const QUrl url)
{
    if(manager.isNull())
    {
        manager = new QNetworkAccessManager(this);
        connect(manager, SIGNAL(finished(QNetworkReply*)),this, SIGNAL(downloadFinished(QNetworkReply*)));
    }
    manager->get(QNetworkRequest(url));
}

void Download::stopDownload()
{
    if(!reply.isNull())
    {
        QString::fromUtf8("停止了之前的网络请求");
        reply->abort();//停止请求这个数据
    }
}

Download::~Download()
{
    manager->deleteLater();
}


MyXmlRole::MyXmlRole(QDeclarativeItem *parent) :
    QDeclarativeItem(parent)
{
    m_query="";
    m_isKey=false;
    m_name="";
}
const QString MyXmlRole::query()
{
    return m_query;
}
void MyXmlRole::setQuery(const QString new_query)
{
    if(new_query!=m_query)
    {
        m_query=new_query;
        emit queryChanged();
    }
}

const QString MyXmlRole::name()
{
    return m_name;
}
void MyXmlRole::setName(const QString new_name)
{
    if(new_name!=m_name)
    {
        m_name=new_name;
        emit nameChanged();
    }
}

const bool MyXmlRole::isKey()
{
    return m_isKey;
}

void MyXmlRole::setIsKey(const bool new_isKey)
{
    if(m_isKey!=new_isKey)
    {
        m_isKey=new_isKey;
        emit isKeyChanged();
    }
}


MyXmlListModel::MyXmlListModel(QDeclarativeItem *parent) :
    QDeclarativeItem(parent), QDomDocument()
{
    m_status=MyXmlListModel::Null;//初始化状态
    m_xml="";
    m_source="";
    m_query="";
    m_count=0;
    errorInfo="";
    m_running=false;

    engine = new QDeclarativeEngine(this);
    component = new QDeclarativeComponent(engine,this);

    mythread = new QThread(this);
    download = new Download;
    download->moveToThread(mythread);
    connect(download, SIGNAL(downloadFinished(QNetworkReply*)),SLOT(replyFinished(QNetworkReply*)));
    connect(this , SIGNAL(downloadData(QUrl)), download, SLOT(startDownload(QUrl)));
    connect(this , SIGNAL(stopDownload()), download, SLOT(stopDownload()));
    mythread->start();//启动新的线程
}

const MyXmlListModel::Status MyXmlListModel::status()
{
    return m_status;
}
void MyXmlListModel::setStatus(const Status new_status)
{
    if(new_status!=m_status)
    {
        m_status=new_status;
        emit statusChanged();
    }
}

const QString MyXmlListModel::xml()
{
    return m_xml;
}
void MyXmlListModel::setXml(const QString new_xml)
{
    if(new_xml!=m_xml)
    {
        setSource (QUrl(""));
        m_xml=new_xml;
        emit xmlChanged();
    }
}
const QUrl MyXmlListModel::source()
{
    return m_source;
}

void MyXmlListModel::setSource(QUrl new_source)
{
    if(new_source!=m_source)
    {
        m_source=new_source;
        emit sourceChanged();
    }
}
const QString MyXmlListModel::query()
{
    return m_query;
}
void MyXmlListModel::setQuery(const QString new_query)
{
    if(new_query!=m_query)
    {
        m_query=new_query;
        prefixTags.clear();//先清空原来的
        prefixTags = m_query.split("/");
        for(int i=0;i<prefixTags.count();i++)
        {
            if(prefixTags[i]=="")
                prefixTags.removeAt(i);
        }
        emit queryChanged();
    }
}

const int MyXmlListModel::count()
{
    return m_count;
}
void MyXmlListModel::setCount(const int new_count)
{
    if(new_count!=m_count)
    {
        m_count=new_count;
        emit countChanged();
    }
}

const bool MyXmlListModel::running()
{
    return m_running;
}
void MyXmlListModel::setRunning(const bool new_running)
{
    if(new_running!=m_running)
    {
        m_running=new_running;
        emit runningChanged();
    }
}

void MyXmlListModel::reload()
{
    qDebug()<<QString::fromUtf8("请求解析xml");
    tagsList.clear();//先清空标签////
    tagsType.clear();//同上     ////
    emit deleteQml();//删除动态创建的qml
    objList.clear();              ////
    propertyName.clear();//同上
    m_xml="";                     //////////初始化列表
    m_count=0;                  //////
    errorInfo="";                 /////
    emit stopDownload();//停止上次的下载
    setStatus(MyXmlListModel::Loading);//改变状态为正在加载


    if(source().toString()!="")
    {
        if(source().toString().indexOf("http://")==-1)
        {
            QString xmlPath = source().toLocalFile();
            qDebug()<<QString::fromUtf8("非网络xml资源，正在打开");
            QFile file(xmlPath);
            if(!file.exists())
            {
                qDebug()<<QString::fromUtf8("xml文件不存在,文件地址是:")<<xmlPath;
                return;
            }
            if(!file.open(QIODevice::ReadOnly))
            {
                qDebug()<<QString::fromUtf8("xml文件打开失败了,文件地址是:")<<xmlPath;
                return;
            }
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
            QTextCodec *codec = QTextCodec::codecForName("utf-8");
#else
            QTextCodec *codec = QTextCodec::codecForName("gbk");
#endif
            m_xml= codec->toUnicode(file.readAll());//将内容提取出来
            file.close();
            analyze();//开始解析
        }else{
            qDebug()<<QString::fromUtf8("网络xml资源，正在下载");
            emit downloadData(source());//去get网络数据----在新的线程中
        }
    }
}
void MyXmlListModel::analyze()
{
    QList<MyXmlRole *> list=findChildren<MyXmlRole *>();

    for(int i=0;i<list.length();i++)
    {
        if(list[i]->name()==""||list[i]->query()=="")
        {
            errorInfo = QString::fromUtf8("MyXmlRole的name或者query属性不能为空");
            setStatus(MyXmlListModel::Error);
            emit error(errorInfo);
            return;
        }
        propertyName.append(list[i]->name());//将要解析的标签加进去
        QStringList temp_list = list[i]->query().split("/");
        if(temp_list.count()!=2)
        {
            errorInfo = QString::fromUtf8("MyXmlRole的query参数格式不对");
            setStatus(MyXmlListModel::Error);
            emit error(errorInfo);
            return;
        }
        QString name = temp_list[0];
        tagsList.append(name);//将要解析的标签加进去
        QString type = temp_list[1];
        if(type == "string()")
        {
            tagsType.append("string");
        }else if(type == "number()"){
            tagsType.append("int");
        }else{
            errorInfo=type+QString::fromUtf8("是未知类型，请保证它是string()或者number()");
            setStatus(MyXmlListModel::Error);
            emit error(errorInfo);
            return;
        }
    }
    if(m_xml!=""){
        qDebug()<<QString::fromUtf8("xml文件不为空,解析中");
        setContent(m_xml);
        QDomElement element=documentElement();
        qDebug()<<QString::fromUtf8("root标签的名字是：")<<element.tagName();
        if(prefixTags.count()>0&&prefixTags[0]==element.tagName())
            saveQml(&element,1);//开始递归获取标签内容
        else
            saveQml(&element,0);//开始递归获取标签内容
    }
    setStatus(MyXmlListModel::Ready);//设置状态为完成解析
}

void MyXmlListModel::saveQml(QDomElement *tag, int depth)
{
    //qDebug()<<QString::fromUtf8("分析到了标签的第")<<depth<<QString::fromUtf8("层,总层数为：")<<prefixTags.count();
    if(depth==prefixTags.count())
    {
        QStringList tagsContent;
        for(int i=0;i<tagsList.count();i++)
        {
            //qDebug()<<QString::fromUtf8("当前标签的名字是：")<<tag->tagName()<<" "<<tag->firstChild().toElement().tagName();
            //qDebug()<<QString::fromUtf8("查找的标签的名字是：")<<tagsList[i];
            QDomNodeList rootList = tag->elementsByTagName(tagsList[i]);
            if(rootList.isEmpty())
            {
                tagsContent.append("");
                qDebug()<<QString::fromUtf8("标签未找到");
            }else{
                if(rootList.count()>1)
                {
                    errorInfo=tagsList[i]+QString::fromUtf8("出错，标签有多个");
                    setStatus(MyXmlListModel::Error);
                    emit error(errorInfo);
                    return;
                }else{
                    QString content = rootList.item(0).toElement().text();
                    int pos = content.indexOf("\"");
                    while(pos!=-1)                    //注释掉字符串中的"符号
                    {
                        content.insert(pos,"\\");
                        pos = content.indexOf("\"",pos+2);
                    }
                    tagsContent.append(content);
                }
            }
        }
        creationObj(tagsType,propertyName,tagsContent);//创建qml
    }else{
        QDomNodeList temp=tag->elementsByTagName(prefixTags[depth]);
        //qDebug()<<QString::fromUtf8("要查找的标签和个数是：")<<prefixTags[depth]<<temp.count();
        QDomElement element;
        for(int i=0;i<temp.count();i++)
        {
            element=temp.item(i).toElement();
            saveQml(&element,depth+1);//递归调用
        }
    }
}

void MyXmlListModel::creationObj(QStringList m_tagsType, QStringList m_tagsName, QStringList m_tagsContent)
{
    if(m_tagsType.count()==m_tagsName.count()&&m_tagsName.count()==m_tagsContent.count())
    {
        QString head = "import QtQuick 1.0\nItem{\n";
        for(int i=0;i<m_tagsType.count();i++)
        {
            //head.append("property int title:89");
            if(m_tagsType[i]=="string")
                head.append("property ").append(m_tagsType[i]).append(" ").append(m_tagsName[i]).append(":\"").append(m_tagsContent[i]).append("\";\n");
            else
                head.append("property ").append(m_tagsType[i]).append(" ").append(m_tagsName[i]).append(":").append(m_tagsContent[i]).append(";\n");
        }
        head.append("}");
        QTextCodec *codec = QTextCodec::codecForName("utf-8");

        QByteArray array=codec->fromUnicode(head);
        //qDebug()<<QString::fromUtf8(array);
        component->setData(array, QUrl());
        QObject *obj = component->create();
        if(obj!=NULL)
        {
            //qDebug()<<QString::fromUtf8("创建qml成功");
            connect(this, SIGNAL(deleteQml()), obj, SLOT(deleteLater()));
        }
        objList.append(obj);
        if(!objList[count()])
        {
            errorInfo = QString::fromUtf8("动态创建qml文件失败，请重试");
            setStatus(MyXmlListModel::Error);
            emit error(errorInfo);
            return;
        }
        setCount(count()+1);//设置obj的个数
    }else{
        errorInfo = QString::fromUtf8("数据解析出错，请重试");
        setStatus(MyXmlListModel::Error);
        emit error(errorInfo);
    }
}

const QString MyXmlListModel::errorString()
{
    return errorInfo;
}

void MyXmlListModel::componentComplete()
{
    if(running())
        reload();
}

QObject* MyXmlListModel::get(const int index)
{
    if(index<objList.count())
    {
        return objList[index];
    }
    else{
        errorInfo=QString::fromUtf8("请求的数据超出范围，最大标签数为：")+QString::number(count());
        setStatus(MyXmlListModel::Error);
        emit error(errorInfo);
        return NULL;
    }
}

void MyXmlListModel::replyFinished(QNetworkReply *replys)
{
    if(replys->error() == QNetworkReply::NoError)
    {
        qDebug()<<QString::fromUtf8("网络xml资源，下载完成，马上解析");
        QTextCodec *codec;
        QByteArray temp=replys->readAll();
        int end=temp.indexOf(">");
        if(end!=-1)
        {
            int pos=temp.indexOf("encoding=",end);
            if(pos==-1)
            {
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
                codec = QTextCodec::codecForName("utf-8");
#else
                 codec = QTextCodec::codecForName("utf-8");
#endif
                m_xml=codec->toUnicode(temp);
            }else{
                m_xml=temp;
            }
        }else{
            m_xml=temp;
        }
        analyze();//开始解析
    }else{
        errorInfo=replys->errorString();
        setStatus(MyXmlListModel::Error);
        emit error(errorInfo);
    }
}

MyXmlListModel::~MyXmlListModel()
{
    if(mythread)
    {
        mythread->quit();
        mythread->wait();
        download->deleteLater();
    }
    component->deleteLater();
    engine->deleteLater();
}
