#ifndef OOTBAUTHHELPER_H
#define OOTBAUTHHELPER_H

#include <KAuth/ActionReply>
#include <KAuth/HelperSupport>
#include <QObject>

using namespace KAuth;

class OotbAuthHelper : public QObject
{
    Q_OBJECT

public Q_SLOTS:
    ActionReply apply(const QVariantMap &args);
};

#endif // OOTBAUTHHELPER_H
