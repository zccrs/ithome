#ifndef CACHE_H
#define CACHE_H

#include <QObject>
#include <QString>
#include <QFile>
#include <QFileInfo>
#include <QPointer>
#include <QThread>
#include <QTextStream>
#include <QByteArray>
#include "settings.h"
#include "threaddownloadimage.h"
class RemoveCache;
class Cache : public QObject
{
    Q_OBJECT
public:
    explicit Cache(Settings *new_set,QObject *parent = 0);
    //static QString cacheDirPath = "/home/zz/.ithome/cache";
    ~Cache();
private:

    QString prefix,coding;//保存路径开端(因为symbian和meego的系统结构不一样)和文本编码。imageName,content,m_sid,
    QFile file;//用了读写文件
    Settings *setting;//用来保存程序的设置

    void disposeHref(QString &string,int i=0);//修改超链接
    void disposeLetvVideo(QString &string,int i=0);//修改乐视视频的播放
    void disposeYoukuVideo(QString &string,int i=0);//修改优酷视频的播放

    //void saveNoImageModel(const QString sid,QString string);

    QString contentImage;//用了记录带本地图片的新闻内容

    QPointer<QThread> mythread;//创建一个新的线程，用来下载图片
    QPointer<ThreadDownloadImage> threadDownloadImage;//创建用来下载和保存图片的类

    QPointer<QThread> mythread_removeCache;
    QPointer<RemoveCache> reCache;

private slots:
    //void replyFinished(QNetworkReply* replys);
    //void imageDownloadFinish(QNetworkReply* replys);
signals:
    //void content_image(const QString string);
    void imageDownloadFinish(const QString id_content,const QString id_image,const QString suffix);//发送图片下载完成的信号
    void cancleDownloadImages();//发送停止下载的信号,是发送到新的线程
    void imageDownloads(const QString id_content,const QString url,const QString id_image,const QString suffix);//发送信号到新的线程
    void removeCache();//发送信号到新的线程，删除缓存
    void removeResult(bool result);//缓存删除的结果，是否完成
public slots:

    void saveTitle(const QString sid,QString string);//保存新闻标题
    QString getTitle(const QString sid,const QString string);//读取新闻标题
    void saveContent(const QString sid,QString string);//保存新闻内容
    QString getContent_image(const QString sid);//读取带本地图片的新闻内容
    //QString getContent_noImage(const QString sid);
    QString getContent_noImageModel(const QString sid);//读取无图模式下的新闻内容
    void cancleDownloadImage();//停止下载图片
    void imageDownload(const QString id_content,const QString url,const QString id_image,const QString suffix);//下载图片
#if defined(Q_OS_HARMATTAN)
    void clearCache(QString dirPath = QDir::homePath()+"/.ithome/cache", bool deleteSelf=false , bool deleteHidden= false);//删除缓存文件
#else
    void clearCache(QString dirPath ="./cache", bool deleteSelf=false , bool deleteHidden= false);//删除缓存文件
#endif

};

#endif // CACHE_H

#ifndef REMOVECACHE_H
#define REMOVECACHE_H

#include <QObject>
#include <QPointer>
#include <QDir>
#include <QFileInfoList>
#include <QString>
class RemoveCache : public QObject
{
    Q_OBJECT
public:
    explicit RemoveCache(QObject *parent = 0);

signals:
    void removeResult(bool result);
public slots:
#if defined(Q_OS_HARMATTAN)
    bool clearCache(QString dirPath = QDir::homePath()+"/.ithome/cache", bool deleteSelf=false , bool deleteHidden= false);//删除缓存文件
#else
    bool clearCache(QString dirPath ="D:/ithome/cache", bool deleteSelf=false , bool deleteHidden= false);//删除缓存文件
#endif
};

#endif // REMOVECACHE_H

