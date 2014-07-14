#include "threaddownloadimage.h"
#include <QDebug>
#include <QDir>
ThreadDownloadImage::ThreadDownloadImage(QObject *parent) :
    QObject(parent)
{
#if defined(Q_OS_HARMATTAN)
    prefix=QDir::homePath()+"/.ithome";
#else
    prefix="D:/ithome";
#endif
    isImageDownloading=false;
    m_canclePost=false;
    //qDebug()<<QString::fromUtf8("主线程地址是：")<<QThread::currentThread();
}

void ThreadDownloadImage::cancleDownloadImage()
{
    m_canclePost=true;
}
void ThreadDownloadImage::imageDownload(const QString id_content,const QString url,const QString id_image,const QString suffix)
{
    //qDebug()<<QString::fromUtf8("新线程地址是：")<<QThread::currentThread();
    //qDebug()<<QString::fromUtf8("请求下载图片的文章id：")+id_content<<"\n"<<QString::fromUtf8("图片的地址id：")+url<<"\n"<<QString::fromUtf8("图片的id：")+id_image<<"\n"<<QString::fromUtf8("图片的格式：")+suffix;
    file.setFileName(prefix+"/cache/"+id_content+"/"+id_image+suffix);
    if(!file.exists())
    {
        imageId.enqueue(id_image);
        imageSuffix.enqueue(suffix);
        contentId.enqueue(id_content);
        if(!isImageDownloading)
        {
            isImageDownloading=true;
            if(imageManager.isNull())
            {
                imageManager = new QNetworkAccessManager(this);
                connect(imageManager, SIGNAL(finished(QNetworkReply*)),this, SLOT(downloadFinish(QNetworkReply*)));
            }
            imageManager->get(QNetworkRequest(QUrl(url)));
            qDebug()<<QString::fromUtf8("将要下载图片：")<<url;
        }
        else imageUrl.enqueue(url);
    }else{
        qDebug()<<QString::fromUtf8("图片已经存在，不用下载了");
        emit imageDownloadFinish(id_content,id_image,suffix);
    }
}
void ThreadDownloadImage::downloadFinish(QNetworkReply *replys)
{
    if(replys->error() == QNetworkReply::NoError)
    {
        QByteArray temp=replys->readAll();
        qDebug()<<QString::fromUtf8("图片下载成功");
        QImage image;
        image.loadFromData(temp);
        QString id_content=contentId.dequeue();
        QString id_image=imageId.dequeue();
        QString suffix=imageSuffix.dequeue();
        QString imageName;
        if( id_content=="avatar" ){
            if( QFile::exists (imageName))
                QFile::remove (imageName);
#if defined(Q_OS_HARMATTAN)
            imageName = prefix+"/cache/"+id_image+suffix;//这是一个局部变量
#else
            imageName = "./qml/general/"+id_image+suffix;//这是一个局部变量
#endif
        }else
            imageName = prefix+"/cache/"+id_content+"/"+id_image+suffix;//这是一个局部变量
        if(!QFile::exists(imageName))
        {
            qDebug()<<QString::fromUtf8("保存地址是：")+imageName;
            if(!image.save(imageName))
                qDebug()<<QString::fromUtf8("不知为何图片保存失败了");
            QTextCodec *codec = QTextCodec::codecForName("gbk");
            qDebug()<<codec->toUnicode(temp);
        }

        setting.setValue("cache_size",setting.getValue("cache_size",0).toLongLong()+temp.size());
        emit imageDownloadFinish(id_content,id_image,suffix);//下载完成发送信号

        if(imageUrl.isEmpty())
        {
            isImageDownloading=false;
        }
        else if(!m_canclePost)//如果用户没有停止加载图片
            imageManager->get(QNetworkRequest(QUrl(imageUrl.dequeue())));
        else
            m_canclePost=false;//如果用户停止了下载，就不再调用get函数，另外，别忘了置为false
    }
}
ThreadDownloadImage::~ThreadDownloadImage()
{
    imageManager->deleteLater();
}
