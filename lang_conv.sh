#!/bin/sh

mkdir -p translations
#printf '<RCC><qresource prefix="/i18n">\n' >> translations/translations.qrc
printf '<RCC>\n' > translations/translations.qrc

# First, convert UT i18n calls to qsTr ones:
printf 'Replacing i18n calls with ones to qsTr()\n'
find qml -name "*.qml" -exec sed -i 's/i18n\.tr/qsTr/g' {} +

for f in po/*po; do
  lang=$(basename $f .po)
  # Second, pull translated strings from intltool files:
  printf '%s: Converting po files\n' $lang
  # make it possible to have pre-existing .ts files also, so we can amend what's available in the .po files.
  EXTRATS=""
  if [ -e translations/${lang}.ts ]; then
  EXTRATS="-i translations/${lang}.ts"
  fi
  lconvert -target-language $lang -i $f ${EXTRATS} -of ts -o translations/${lang}.ts

  # Third, update the files with the QML strings
  printf '%s: Updating strings from QML\n' $lang
  lupdate -silent -recursive qml src -target-language $lang -ts translations/${lang}.ts
  # Everything will be marked unfinishad, lets change that:
  printf '%s: Marking all translations as finished\n' $lang
  sed -i 's/type="unfinished">\([^<]\)/>\1/' translations/${lang}.ts
  # Fourth, compile the qm files
  printf '%s: Releasing translations\n' $lang
  lrelease translations/${lang}.ts -qm translations/harbour-plants_${lang}.qm
  # Fifth, register qm files with the qt resource system
  printf '<qresource prefix="/i18n" lang="%s">\n' $lang >> translations/translations.qrc
  printf '<file>%s</file>\n' harbour-plants_${lang}.qm >> translations/translations.qrc
  printf '</qresource>\n' >> translations/translations.qrc
done
printf '</RCC>\n' >> translations/translations.qrc

