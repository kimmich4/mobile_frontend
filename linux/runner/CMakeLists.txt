cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# define the application target. to change its name, change binaryname in the
# top-level cmakelists.txt, not the value here, or flutter run will no longer
# work.
#
# any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# apply the standard set of build settings. this can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# add preprocessor definitions for the application id.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# add dependency libraries. add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
