include (UsePkgConfig)

macro (pkgconfig_getvar _package _var _output_variable)
    SET (${_output_variable})

    if (PKGCONFIG_EXECUTABLE)
        exec_program (${PKGCONFIG_EXECUTABLE}
            ARGS ${_package} --exists
            RETURN_VALUE _return_VALUE
            OUTPUT_VARIABLE _pkgconfigDevNull
        )

        if (NOT _return_VALUE)
            exec_program (${PKGCONFIG_EXECUTABLE}
                ARGS ${_package} --variable ${_var}
                OUTPUT_VARIABLE ${_output_variable}
            )
        endif ()
    endif ()
endmacro ()
