include_guard(GLOBAL)

#[[
+ https://en.cppreference.com/w/cpp/compiler_support
+ https://en.cppreference.com/w/c/compiler_support
]]

set(COMPILER_OPTION_RECOMMEND_C_STANDARD 11)
set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 11)

if(${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
  # C
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12.0")
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 23)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10.0")
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 17)
  endif()

  # C++
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "14")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 23)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "12")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 20)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "7.1")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 17)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "5")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 14)
  endif()
elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang")
  # C
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "17.0")
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 23)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "10.0")
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 17)
  endif()

  # C++
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "17")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 23)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "14")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 20)
  else()
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 17)
  endif()
elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
  # C
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "16.0")
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 23)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "13.0")
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 17)
  endif()

  # C++
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "15.0")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 23)
  elseif(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "13.0")
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 20)
  else()
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 17)
  endif()
elseif(MSVC)
  # C
  if(MSVC_VERSION GREATER_EQUAL 1931)
    set(COMPILER_OPTION_RECOMMEND_C_STANDARD 17)
  endif()
  # C++
  if(MSVC_VERSION GREATER_EQUAL 1937)
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 23)
  elseif(MSVC_VERSION GREATER_EQUAL 1927)
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 20)
  else()
    set(COMPILER_OPTION_RECOMMEND_CXX_STANDARD 17)
  endif()
endif()