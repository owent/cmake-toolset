include_guard(GLOBAL)

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR AND PROJECT_3RD_PARTY_PACKAGE_DIR)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR "${PROJECT_3RD_PARTY_PACKAGE_DIR}")
elseif(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR
      "${PROJECT_SOURCE_DIR}/third_party/packages")
endif()

if(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR AND PROJECT_3RD_PARTY_INSTALL_DIR)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR "${PROJECT_3RD_PARTY_INSTALL_DIR}")
elseif(NOT ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR)
  set(ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR
      "${PROJECT_SOURCE_DIR}/third_party/install/${PROJECT_PREBUILT_PLATFORM_NAME}")
endif()

if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR})
  file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_PACKAGE_DIR})
endif()

if(NOT EXISTS ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR})
  file(MAKE_DIRECTORY ${ATFRAMEWORK_CMAKE_TOOLSET_THIRD_PARTY_INSTALL_DIR})
endif()
