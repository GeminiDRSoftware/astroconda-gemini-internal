# Unset some variables that could break our conda env:
unset LD_LIBRARY_PATH PYTHONPATH
unset QT_PLUGIN_PATH QT_QPA_PLATFORM_PLUGIN_PATH
unset QML2_IMPORT_PATH QML_IMPORT_PATH
unset QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_API

## These settings could cause apps such as GINGA & PyGacq to run with non-native
## widgets, but might need uncommenting in the event that certain desktop themes
## (eg. from KDE) get installed on Rocky 9, to avoid Qt5 binaries getting loaded
## from the OS & crashing the Qt6 stack needed by recent conda packages.
#export QT_QPA_PLATFORMTHEME=""
#export QT_STYLE_OVERRIDE="Fusion"

