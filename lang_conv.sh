#!/bin/sh

mkdir -p translations
printf '<RCC><qresource prefix="/i18n">\n' >> translations/translations.qrc
for f in po/*po; do
  lang=$(basename $f .po)
  echo $lang
  lconvert -target-language $lang -if po -i $f -of qm -o translations/${lang}.qm
  printf '<file>%s</file>\n' ${lang}.qm >> translations/translations.qrc
done
printf '</qresource></RCC>\n' >> translations/translations.qrc
