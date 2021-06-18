#[===[.md:
# MaybePopulateSubmodule.cmake

#]===]

include_guard(GLOBAL)

include("${CMAKE_CURRENT_LIST_DIR}/ProjectBuildTools.cmake")

function(maybe_populate_submodule VARNAME SUBMODULE_PATH LOCAL_PATH)
  if(CMAKE_VERSION VERSION_LESS_EQUAL "3.4")
    include(CMakeParseArguments)
  endif()
  set(optionArgs SUBMODULE_RECURSIVE FORCE_RESET RECOMMAND_SHALLOW REMOTE)
  set(oneValueArgs DEPTH CHECK_PATH WORKING_DIRECTORY SET_URL)
  set(multiValueArgs PATCH_FILES GIT_CONFIG)
  cmake_parse_arguments(maybe_poptlate_submodule "${optionArgs}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  set(${VARNAME}_REPO_DIR
      "${LOCAL_PATH}"
      CACHE PATH "PATH to ${SUBMODULE_PATH}")

  if(NOT EXISTS "${${VARNAME}_REPO_DIR}/${maybe_poptlate_submodule_CHECK_PATH}")
    if(NOT maybe_poptlate_submodule_DEPTH)
      set(maybe_poptlate_submodule_DEPTH 100)
    endif()
    if(NOT maybe_poptlate_submodule_CHECK_PATH)
      set(maybe_poptlate_submodule_CHECK_PATH ".git")
    endif()
    if(NOT maybe_poptlate_submodule_WORKING_DIRECTORY)
      get_filename_component(maybe_poptlate_submodule_WORKING_DIRECTORY ${LOCAL_PATH} DIRECTORY)
    endif()
    set(git_global_options -c "advice.detachedHead=false" -c "init.defaultBranch=main")
    if(maybe_poptlate_submodule_GIT_CONFIG)
      foreach(config IN LISTS maybe_poptlate_submodule_GIT_CONFIG)
        list(APPEND git_global_options -c \"${config}\")
      endforeach()
    endif()

    if(maybe_poptlate_submodule_FORCE_RESET)
      if(EXISTS "${LOCAL_PATH}")
        execute_process(
          COMMAND ${GIT_EXECUTABLE} ${git_global_options} clean -dfx
          COMMAND ${GIT_EXECUTABLE} ${git_global_options} reset --hard
          WORKING_DIRECTORY "${LOCAL_PATH}"
          RESULT_VARIABLE LAST_GIT_RESET_RESULT ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
      endif()
    endif()

    if(maybe_poptlate_submodule_SET_URL)
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.25.0")
        execute_process(
          COMMAND ${GIT_EXECUTABLE} ${git_global_options} submodule "set-url" "--" "${SUBMODULE_PATH}"
                  "${maybe_poptlate_submodule_SET_URL}"
          WORKING_DIRECTORY "${maybe_poptlate_submodule_WORKING_DIRECTORY}"
                            ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
        endforeach()
      else()
        message(WARNING "Only git 2.25.0 or upper support git set-url ...")
      endif()
    endif()

    set(maybe_poptlate_submodule_args submodule update --init -f)
    if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "1.8.4")
      list(APPEND maybe_poptlate_submodule_args --depth ${maybe_poptlate_submodule_DEPTH})
    endif()
    if(maybe_poptlate_submodule_SUBMODULE_RECURSIVE)
      list(APPEND maybe_poptlate_submodule_args --recursive)
    endif()
    if(maybe_poptlate_submodule_REMOTE)
      list(APPEND maybe_poptlate_submodule_args --remote)
    endif()
    if(maybe_poptlate_submodule_RECOMMAND_SHALLOW)
      if(GIT_VERSION_STRING VERSION_GREATER_EQUAL "2.10.0")
        list(APPEND maybe_poptlate_submodule_args --recommend-shallow)
      endif()
    endif()
    execute_process(
      COMMAND ${GIT_EXECUTABLE} ${git_global_options} ${maybe_poptlate_submodule_args} -- "${SUBMODULE_PATH}"
      WORKING_DIRECTORY "${maybe_poptlate_submodule_WORKING_DIRECTORY}"
                        ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    set(${VARNAME}_REPO_DIR
        "${LOCAL_PATH}"
        CACHE PATH "PATH to ${SUBMODULE_PATH}" FORCE)

    if(maybe_poptlate_submodule_PATCH_FILES)
      execute_process(
        COMMAND ${GIT_EXECUTABLE} ${git_global_options} -c "core.autocrlf=true" apply
                ${maybe_poptlate_submodule_PATCH_FILES}
        WORKING_DIRECTORY "${${VARNAME}_REPO_DIR}" ${ATFRAMEWORK_CMAKE_TOOLSET_EXECUTE_PROCESS_OUTPUT_OPTIONS})
    endif()
  endif()
endfunction()
