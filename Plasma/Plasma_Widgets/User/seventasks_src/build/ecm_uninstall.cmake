if(NOT EXISTS "/mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/Desktop/Aero_Theme/Plasma/Plasma Widgets/User/seventasks_src/build/install_manifest.txt")
    message(FATAL_ERROR "Cannot find install manifest: /mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/Desktop/Aero_Theme/Plasma/Plasma Widgets/User/seventasks_src/build/install_manifest.txt")
endif()

file(READ "/mnt/792afca2-ecd6-4e41-938a-2e818d0f60d1/home/anon/Desktop/Aero_Theme/Plasma/Plasma Widgets/User/seventasks_src/build/install_manifest.txt" files)
string(REGEX REPLACE "\n" ";" files "${files}")
foreach(file ${files})
    message(STATUS "Uninstalling $ENV{DESTDIR}${file}")
    if(IS_SYMLINK "$ENV{DESTDIR}${file}" OR EXISTS "$ENV{DESTDIR}${file}")
        exec_program(
            "/usr/bin/cmake" ARGS "-E remove \"$ENV{DESTDIR}${file}\""
            OUTPUT_VARIABLE rm_out
            RETURN_VALUE rm_retval
            )
        if(NOT "${rm_retval}" STREQUAL 0)
            message(FATAL_ERROR "Problem when removing $ENV{DESTDIR}${file}")
        endif()
    else()
        message(STATUS "File $ENV{DESTDIR}${file} does not exist.")
    endif()
endforeach()
