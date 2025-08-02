find_package(Qt5 REQUIRED COMPONENTS LinguistTools)
find_program(LCONVERT_COMMAND lconvert)

set(DOMAIN ${FULL_PROJECT_NAME})
file(GLOB TS_FILES *.ts)

list(APPEND I18N_SRC_FILES
    ${CMAKE_SOURCE_DIR}/src/network.cpp
    ${CMAKE_SOURCE_DIR}/src/plant.cpp
    ${CMAKE_SOURCE_DIR}/src/plantsmodel.cpp
    ${CMAKE_SOURCE_DIR}/src/plantsimageprovider.cpp
    )


# Builds the binary translations catalog for each language
# it finds source translations (*.ts) for
QT5_ADD_TRANSLATION(QM_FILES ${I18N_SRC_FILES} ${TS_FILES})
set(INSTALL_DIR "${CMAKE_INSTALL_DATA}/${DOMAIN}/translations")
install(FILES ${QM_FILES} DESTINATION ${QM_INSTALL_DIR}) # RENAME ${DOMAIN}-${LANG}.qm)
#include(TranslationUtils)
#add_app_translations_resource(QT_RESOURCES ${QM_FILES})
#add_qt_translations_resource(QT_RESOURCES de fr nl)

#foreach(TS_FILE ${TS_FILES})
#    get_filename_component(LANG ${TS_FILE} NAME_WE)
#    QT5_ADD_TRANSLATION(${TS_FILE})
#    #gettext_process_po_files(${LANG} ALL TS_FILES ${TS_FILE})
#    add_custom_command(
#        OUTPUT ${LANG}.qm
#        COMMAND lconvert -target-language ${LANG} -if po -i ../${LANG}.po -of ts -o ${TS_FILE}
#        COMMAND lupdate -target-language ${LANG} -ts ${TS_FILE}
#        COMMAND lrelease ${TS_FILE}
#        DEPENDS ../${LANG}.po
#    )
#    set(INSTALL_DIR ${CMAKE_INSTALL_DATA}/translations)
#    install(FILES ${LANG}.qm
#            DESTINATION ${INSTALL_DIR}
#            RENAME ${DOMAIN}-${LANG}.qm)
#endforeach(TS_FILE)
