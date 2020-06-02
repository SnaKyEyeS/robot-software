message(status "Chibios version:" ${ChibiOS_FIND_VERSION_MAJOR})

include(ChibiOS/18.2/ChibiOS)

list(remove_duplicates ChibiOS_INCLUDE_DIRS)
list(remove_duplicates ChibiOS_SOURCES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ChibiOS DEFAULT_MSG ChibiOS_SOURCES ChibiOS_INCLUDE_DIRS)
