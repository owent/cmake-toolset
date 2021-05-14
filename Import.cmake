include_guard(GLOBAL)

cmake_minimum_required(VERSION 3.16.0)
# cmake_policy(SET CMP0022 NEW) cmake_policy(SET CMP0048 NEW) cmake_policy(SET CMP0054 NEW cmake_policy(SET CMP0067 NEW)
# cmake_policy(SET CMP0074 NEW) cmake_policy(SET CMP0091 NEW)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/modules")

include("${CMAKE_CURRENT_LIST_DIR}/CompilerOption.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/TargetOption.cmake")

# Port configure must be imported after TargetOption.cmake
include("${CMAKE_CURRENT_LIST_DIR}/modules/EchoWithColor.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/modules/ProjectBuildTools.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/modules/FindConfigurePackage.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ports/Configure.cmake")
