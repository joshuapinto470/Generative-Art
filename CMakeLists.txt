cmake_minimum_required(VERSION 3.8 FATAL_ERROR)
project(Generative_Art LANGUAGES CXX CUDA)

include_directories(
        "libs/glad/include/"
	"libs/glew/include/"
        "libs/freeglut/include"
        "includes/"
)

find_package(CUDAToolkit)
add_subdirectory(libs/freeglut/)
add_subdirectory(libs/glew)

add_executable(Generative 
src/main.cpp
src/kernel.cu
)

target_compile_features(Generative PUBLIC cxx_std_17)
 
set_target_properties( Generative
                       PROPERTIES CUDA_SEPARABLE_COMPILATION ON)

if(WIN32)
        target_link_libraries(Generative PRIVATE libglew_static freeglut_static opengl32)
endif(WIN32)

if(UNIX)
        target_link_libraries(Generative libglew_static freeglut_static GL)
endif(UNIX)