#include "myimage.h"
#include <QDebug>
MyImage::MyImage(QObject *parent) :
    QObject(parent)
{
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
    prefix="/home/user/.ithome";
    QDir temp;
    QFileInfo info("/home");
    if(!info.isDir())
    {
        if( temp.mkdir("/home/"))
        {
            info.setFile("/home/user/");
            if(!info.isDir())
            {
                if( temp.mkdir("/home/user/"))
                {
                    info.setFile(prefix);
                    if(!info.isDir())
                    {
                        if( !temp.mkdir(prefix))
                            qDebug()<<prefix<<QString::fromUtf8("文件夹创建失败");
                    }
                }else
                    qDebug()<<"/home/user/"<<QString::fromUtf8("文件夹创建失败");
            }
        }else
            qDebug()<<"/home/"<<QString::fromUtf8("文件夹创建失败");
    }
#else
    prefix="./";
#endif
    //setFlag(QGraphicsItem::ItemHasNoContents,false);
    m_source="";
    m_sid="image";
    manager = new QNetworkAccessManager(this);
    connect(manager, SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));
    //connect(this,SIGNAL(widthChanged()),SLOT(setImageSize()));
    //connect(this,SIGNAL(heightChanged()),SLOT(setImageSize()));
}
QString MyImage::source(){
    return m_source;
}
void MyImage::setSource(const QString string)
{
    if(string=="noImage") return;
    else{
        m_source=string;
        QFile file;
        QString src=prefix+"/cache/"+m_sid+"/"+"title.jpg";
        file.setFileName(src);
        if(file.exists())
        {
            emit imageClose(imageQmlSrc);
        }else{
            manager->get(QNetworkRequest(QUrl(string)));
        }
    }
}

void MyImage::setSid(QString newid)
{
    if(newid!=m_sid){
        m_sid=newid;
#if defined(Q_OS_LINUX)||defined(Q_OS_HARMATTAN)
        imageQmlSrc=prefix+"/cache/"+m_sid+"/"+"title.jpg";
#else
        imageQmlSrc="../../cache/"+m_sid+"/"+"title.jpg";
#endif
        emit sidChanged();
    }
}
QString MyImage::sid()
{
    return m_sid;
}

void MyImage::replyFinished(QNetworkReply *replys)
{
    if(replys->error() == QNetworkReply::NoError)
    {
        QDir temp;
        QFileInfo info(prefix+"/cache");
        if(!info.isDir()) temp.mkdir(prefix+"/cache");
        QFileInfo fileinfo(prefix+"/cache/"+m_sid);
        if(!fileinfo.isDir())
            temp.mkdir(prefix+"/cache/"+m_sid);
        QImage image;
        QByteArray temp2=replys->readAll();

        image.loadFromData(temp2);
        QString src=prefix+"/cache/"+m_sid+"/"+"title.jpg";
        image.save(src);

        Settings setting;
        setting.setValue("cache_size",setting.getValue("cache_size",0).toLongLong()+temp2.size());
        emit imageClose(imageQmlSrc);
    }
}

MyImage::~MyImage()
{
    manager->deleteLater();
}
