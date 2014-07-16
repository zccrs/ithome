#ifndef UTILITY_H
#define UTILITY_H

#include <QtNetwork>
#include <QString>
#include <QTextCodec>
#include <QByteArray>
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QTextStream>
#include <QClipboard>
#include <QInputContext>
#include <QApplication>
#include <QWebSettings>
#include <QIODevice>
#include <QImage>
#include <QDeclarativeImageProvider>
#include "settings.h"
class Utility : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString cacheImagePrefix READ cacheImagePrefix)//我的状态

public:
    // Not for qml
    explicit Utility(QObject *parent = 0);
    ~Utility();

//#ifdef Q_OS_SYMBIAN
    //Q_INVOKABLE void launchPlayer(const QString &url);
//#endif

public:             // Other functions.
    Q_INVOKABLE void postHttp(const QString postUrl,const QString postData );
private:
    QString queue[50];//自己写的列队,懒的用QQueue了
    int queue_begin,queue_end;//记录列队的队首和队尾
    QString favoritePath;//收藏夹的路径
    QString prefix;//用户路径前缀
    QString coding;//保存文本的编码
    QString imageShowing;//记录显示中的图片

    QString m_cacheImagePrefix;
    QString cacheImagePrefix();
private slots:
    void replyFinished(QNetworkReply* replys);//当post结束时调用
    void loginFinished(QNetworkReply* replys);//当登陆完成时调用
    void getUserDataFinished(QNetworkReply* replys);//获取用户信息完成时调用
    void getCodeFinished(QNetworkReply* replys);//验证码获取成功
    void registerUserGeneralFinished(QNetworkReply* replys);//测试邮箱是否可用完成
signals:
    void postOk(QString returnData);//给qml信号
    void loginOk(QString replyData, QString replyCookie);//发送登陆完成后的信号
    void getUserDataOk( QString replyData );
    void getCodeOk( QString replyData );
    void testEmailOk( QByteArray replyData );
    void registerUserOk( QString replyData );
    void passwordEditOk( QString replyData );//找回密码返回的数据
private:
    QNetworkAccessManager *manager;
    Settings settings;
public slots:
    bool imageIsShow(const QString name);//name=图片类型（标题图片还是文章图）+文章id
    void imageToShow(const QString name);//记录用户点击过的每一个标题图片或者文章图片，以方便下次打开时在显示这个图片

    bool inQueue(const QString sid);//进队
    QString outQueue();//出队
    void consoleLog(QString string);//用了在控制台显示qml过来的中文，防止乱码
    QString saveImageToLocality(const QString imageSrc);
    void setClipboard(const QString string);//操作剪切板
    void setCss(const QString string,const int width);//设置css

    QString getContent_text(const QString sid);//返回文章的纯文字
    QString addMyLikeNews(const QString newsid,const QString item,bool isRecursion=false);//保存喜欢的新闻
    QString deleteMyLikeNews(const QString newsid,bool isRecursion=false);//删除喜欢的新闻

    bool getFavorite(QString newsid);//读取收藏夹
    bool setFavorite(QString newsid,bool value);//加入收藏夹

    bool getFavoriteIsNull();//返回收藏夹是否为空
    
    void login(QByteArray useremail, QByteArray password);
    void getUserData();
    void getCode();//获取验证码
    void registerUserGeneral( QByteArray data, QByteArray url="http://i.ruanmei.com/reg.aspx/EmailExist" );
};

#endif // UTILITY_H
