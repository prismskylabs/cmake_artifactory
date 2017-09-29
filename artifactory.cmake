function(find_python_module module)
    string(TOUPPER ${module} module_upper)
    if(NOT PY_${module_upper})
        if(ARGC GREATER 1 AND ARGV1 STREQUAL "REQUIRED")
            set(${module}_FIND_REQUIRED TRUE)
        endif()
        # A module's location is usually a directory, but for binary modules
        # it's a .so file.
        execute_process(COMMAND "${PYTHON_EXECUTABLE}" "-c" 
          "import re, ${module}; print re.compile('/__init__.py.*').sub('',${module}.__file__)"
          RESULT_VARIABLE _${module}_status 
          OUTPUT_VARIABLE _${module}_location
          ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
          if(NOT _${module}_status)
              set(PY_${module_upper} ${_${module}_location} CACHE STRING 
               "Location of Python module ${module}")
          endif(NOT _${module}_status)
    endif(NOT PY_${module_upper})
    find_package_handle_standard_args(PY_${module} DEFAULT_MSG PY_${module_upper})
endfunction(find_python_module)

function(check_artifactory_deps)
    include(FindPythonInterp)
    if(NOT PYTHONINTERP_FOUND)
        message(SEND_ERROR "Returned error ${ERR}")
        return()
    endif()
    find_python_module(artifactory REQUIRED)
endfunction()

function(download_artifact repoUrl platform projectName version dstPath)
    #check if artifact already exists locally
    if(EXISTS ${dstPath}/artifact.tar.gz)
       message(STATUS "Artifact exists, skipping download")
       return()
    endif()

    #check that artifact available on server
    message(STATUS "Trying to locate artifact ${repoUrl}, ${projectName}, ${platform}, ${version}")
    execute_process(
       COMMAND python3 -c "import sys, os; sys.path.append(os.path.abspath('./cmake_artifactory')); import cli; cli.find_artifact('${repoUrl}', '${projectName}', '${platform}', '${version}')"
       WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
       OUTPUT_VARIABLE ARTIFACT_SERVER_PATH
       ERROR_VARIABLE ERR
       RESULT_VARIABLE I_RESULT
    )
    if(I_RESULT)
       message(SEND_ERROR "Returned error ${ERR}")
       return()
    endif()
    message(STATUS "Artifact found ${ARTIFACT_SERVER_PATH}")

    #download and unpack
    file(MAKE_DIRECTORY ${dstPath})
    message(STATUS "Trying to download artifact ${repoUrl}, ${projectName}, ${platform}, ${version}, ${dstPath}")
    execute_process(
       COMMAND python3 -c "import sys, os; sys.path.append(os.path.abspath('./cmake_artifactory')); import cli; cli.get_artifact('${repoUrl}', '${projectName}', '${platform}', '${version}','${dstPath}/artifact.tar.gz')"
       WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
       RESULT_VARIABLE I_RESULT
       ERROR_VARIABLE ERR
    )
    if(I_RESULT)
       message(SEND_ERROR "Returned error ${ERR}" )
       return()
    endif()
    execute_process(
       COMMAND tar -xvvf artifact.tar.gz
       WORKING_DIRECTORY ${dstPath}
       RESULT_VARIABLE I_RESULT 
       ERROR_VARIABLE ERR
    )
    if(I_RESULT)
       message(SEND_ERROR "Returned error ${ERR}" )
       return()
    endif()
endfunction()

function(make_upload_artifact_target target_name srcPath repoUrl platform projectName) 
    message(STATUS "Setting up artifact upload")
    add_custom_target(${target_name}
    COMMAND python3 -c \"import sys, os\; sys.path.append(os.path.abspath('./cmake_artifactory'))\; import cli\; cli.put_artifact('${srcPath}', '${repoUrl}', '${projectName}', '${platform}')\"
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    DEPENDS delivery
)
endfunction()
