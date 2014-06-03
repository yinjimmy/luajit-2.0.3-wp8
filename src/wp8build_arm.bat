@rem Script to build LuaJIT with MSVC.
@rem Copyright (C) 2005-2014 Mike Pall. See Copyright Notice in luajit.h
@rem
@rem Either open a "Visual Studio ARM Phone Tools Command Prompt"
@rem Then cd to this directory and run this script.

@if not defined INCLUDE goto :FAIL

@setlocal

@set LJCOMPILE=cl /c /D "LUAJIT_TARGET=LUAJIT_ARCH_ARM" /D "LJ_ARCH_HASFPU=0" /D "LJ_ABI_SOFTFP=1" /D_CRT_SECURE_NO_DEPRECATE /DWP8 /DLUAJIT_USE_SYSMALLOC /DLUAJIT_DISABLE_JIT /DLUAJIT_DISABLE_FFI /MP /GS /GL /analyze- /W1 /Gy /Zc:wchar_t /Zi /Gm- /O2 /fp:precise /D "_WINRT_DLL" /D "NDEBUG" /D "_WINDLL" /D "_UNICODE" /D "UNICODE" /D "WINAPI_FAMILY=WINAPI_FAMILY_PHONE_APP" /errorReport:prompt /WX- /Zc:forScope /Gd /Oy- /MD /EHsc
@set LJLINK=link /MACHINE:ARM  /nologo
@set LJLIB=lib /nologo /nodefaultlib
@set ASMCOMPILE=armasm -machine ARM
@set DASMDIR=..\dynasm
@set DASM=%DASMDIR%\dynasm.lua
@set LJDLLNAME=luajit_wp8_arm.dll
@set LJLIBNAME=luajit_wp8_arm.lib
@set ALL_LIB=lib_base.c lib_math.c lib_bit.c lib_string.c lib_table.c lib_io.c lib_os.c lib_package.c lib_debug.c lib_jit.c lib_ffi.c

@set DASMFLAGS=-D WIN 
@set LJARCH=ARM
minilua %DASM% -LN %DASMFLAGS% -o host\buildvm_arch.h vm_arm.dasc
@if errorlevel 1 goto :BAD

%ASMCOMPILE% -o lj_vm.obj lj_vm_wp8_arm.asm
@if errorlevel 1 goto :BAD
buildvm -m bcdef -o lj_bcdef.h %ALL_LIB%
@if errorlevel 1 goto :BAD
buildvm -m ffdef -o lj_ffdef.h %ALL_LIB%
@if errorlevel 1 goto :BAD
buildvm -m libdef -o lj_libdef.h %ALL_LIB%
@if errorlevel 1 goto :BAD
buildvm -m recdef -o lj_recdef.h %ALL_LIB%
@if errorlevel 1 goto :BAD
buildvm -m vmdef -o jit\vmdef.lua %ALL_LIB%
@if errorlevel 1 goto :BAD
buildvm -m folddef -o lj_folddef.h lj_opt_fold.c
@if errorlevel 1 goto :BAD

@if "%1"=="amalg" goto :AMALGDLL
@if "%1"=="static" goto :static
:DLL
%LJCOMPILE% /MD /DLUA_BUILD_AS_DLL lj_*.c lib_*.c
@if errorlevel 1 goto :BAD
%LJLINK% /DLL /out:%LJDLLNAME% lj_*.obj lib_*.obj
@if errorlevel 1 goto :BAD
@goto :OVER
:AMALGDLL
%LJCOMPILE% /MD /DLUA_BUILD_AS_DLL ljamalg.c
@if errorlevel 1 goto :BAD
%LJLINK% /DLL /out:%LJDLLNAME% ljamalg.obj lj_vm.obj
@if errorlevel 1 goto :BAD
@goto :OVER
:STATIC
%LJCOMPILE% lj_*.c lib_*.c
@if errorlevel 1 goto :BAD
%LJLIB% /OUT:%LJLIBNAME% lj_*.obj lib_*.obj
@if errorlevel 1 goto :BAD
@goto :OVER

:OVER
@del *.obj *.pdb
@echo.
@echo === Successfully built LuaJIT for wp8/%LJARCH% ===
@goto :END
:BAD
@echo.
@echo *******************************************************
@echo *** Build FAILED -- Please check the error messages ***
@echo *******************************************************
@goto :END
:FAIL
@echo You must open a "Visual Studio ARM Phone Tools Command Prompt" to run this script
:END
