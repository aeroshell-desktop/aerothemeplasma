if(NOT EXISTS "/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/build/install_manifest.txt")
    message(FATAL_ERROR "Cannot find install manifest: /mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/build/install_manifest.txt")
endif()

file(READ "/mnt/dba39c4b-f659-456f-8698-0058d9b0d301/home/anon/Desktop/Aero_Theme/KWin/kwin_fixblur/build/install_manifest.txt" files)
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
