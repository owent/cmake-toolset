include_guard(DIRECTORY)

# =========== third party rpmalloc ==================
# TODO
macro(PROJECT_THIRD_PARTY_RPMALLOC_IMPORT)

endmacro()

if(NOT TARGET rpmalloc)
  if(NOT TARGET rpmalloc)
    project_third_party_port_declare(rpmalloc VERSION "1.4.4" GIT_URL "https://github.com/mjansson/rpmalloc.git")
    project_third_party_rpmalloc_import()
  endif()
endif()
