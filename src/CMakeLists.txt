set_directory_properties(PROPERTIES LABELS pathlib)

add_library(pathlib pathlib.f90 pure.f90 impure.f90 envvar.f90)
if(WIN32)
  target_sources(pathlib PRIVATE windows_crt.f90 windows_path.f90 windows_sys.f90)
else()
  target_sources(pathlib PRIVATE posix_crt.f90 posix_path.f90 posix_sys.f90)
endif()
if(CMAKE_Fortran_COMPILER_ID STREQUAL GNU)
  target_sources(pathlib PRIVATE gcc.f90)
elseif(CMAKE_Fortran_COMPILER_ID MATCHES "^Intel")
  target_sources(pathlib PRIVATE intel.f90)
else()
  target_sources(pathlib PRIVATE dummy_compiler.f90)
endif()
target_include_directories(pathlib INTERFACE ${PROJECT_BINARY_DIR}/include)

add_executable(pathlib_cli cli.f90)
target_link_libraries(pathlib_cli PRIVATE pathlib)
set_target_properties(pathlib_cli PROPERTIES
RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})

install(TARGETS pathlib_cli EXPORT ${PROJECT_NAME}-targets)

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()
