#ifndef THREADDOWNLOADIMAGE_H
#define THREADDOWNLOADIMAGE_H

#include <QObject>
#include <QQueue>
#include <QtNetwork>
#include <QByteArray>
#include <QTextCodec>
#include <QString>
#include <QFile>
#include <QImage>
#include <QPointer>
#include "settings.h"
class ThreadDownloadImage : public QObject
{
    Q_OBJECT
public:
    explicit ThreadDownloadImage(QObject *parent = 0);
    ~ThreadDownloadImage();
private:
    bool m_canclePost;//记录用户是否要停止加载图片
    QFile file;//用了读写文件
    QString prefix;//保存路径开端(因为symbian和meego的系统结构不一样)
    QPointer<QNetworkAccessManager> imageManager;
    QQueue<QString> imageUrl;//保存要加载的图片的url
    QQueue<QString> imageId;//保存要加载的图片的img标签的id
    QQueue<QString> contentId;//保存要加载的图片的新闻文章id
    QQueue<QString> imageSuffix;//保存要加载的图片的格式
    bool isImageDownloading;//记录是否正在下载图片

    Settings setting;
private slots:
    void downloadFinish(QNetworkReply *replys);//当图片下载完成的时候调用
signals:
    void imageDownloadFinish(const QString id_content,const QString id_image,const QString suffix);//发送图片下载完成的信号
public slots:
    void imageDownload(const QString id_content,const QString url,const QString id_image,const QString suffix);//下载图片
    void cancleDownloadImage();//停止下载图片

};

#endif // THREADDOWNLOADIMAGE_H
