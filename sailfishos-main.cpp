// SPDX-FileCopyrightText: 2025 Peter G. (nephros)
// SPDX-License-Identifier: Apache-2.0
// SPDX-License-Identifier: MIT

#include <QQuickView>
#include <QScopedPointer>
#include <QtQuick>
#include <QString>
#include <QUrl>
#include <QDebug>

#include <sailfishapp.h>

#include "src/plantsimageprovider.hpp"
#include "src/plantsmodel.hpp"

 int main(int argc, char *argv[])
 {
   QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
   QScopedPointer<QQuickView> view(SailfishApp::createView());

   app->setOrganizationName("s710");
   app->setApplicationName("plants");

   // https://qthub.com/static/doc/qt5/qtcore/qtranslator.html
   QTranslator translator;
   if(translator.load(QLocale(), QStringLiteral("harbour-plants"), QStringLiteral("_"), QLatin1String(":/i18n"))) {
       QCoreApplication::installTranslator(&translator);
   } else {
       qWarning() << "Failed to load translation for" << QLocale::system().name().split('_').at(0);
   }

   qmlRegisterType<plants::PlantsModel>("PlantsModel", 1, 0, "PlantsModel");

   view->engine()->addImageProvider(QLatin1String("plants"), new plants::PlantsImageProvider());

   view->setSource(QUrl("qrc:/harbour-plants.qml"));
   view->show();

   return app->exec();
}
