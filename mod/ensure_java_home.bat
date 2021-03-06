@echo off
rem https://sites.google.com/site/forthenerdwithin/cool-scripts/cool-command-scripts
setlocal enableextensions enabledelayedexpansion
set root=%~dp0
rem remove trailing forthslash
set root=%root:~0,-1%

echo Searching for JAVA_HOME...
echo   Checking existing JAVA_HOME environment variable...
if not "%JAVA_HOME%" == "" endlocal & goto java_home_set

rem http://stackoverflow.com/questions/889518/windows-batch-files-how-to-set-a-variable-with-the-result-of-a-command
set key_names="HKLM\Software\JavaSoft\Java Runtime Environment", "HKLM\Software\Wow6432Node\JavaSoft\Java Runtime Environment", "HKLM\Software\JavaSoft\Java Development Kit", "HKLM\Software\Wow6432Node\JavaSoft\Java Development Kit"
for %%k in (%key_names%) do (
  set key=%%k
  rem remove double quotes
  set key=!key:~1,-1!
  echo   Attempting to get JAVA_HOME from !key! ...
  for /f "tokens=3*" %%a in ('reg query "!key!" /v CurrentVersion 2^>NUL ^| find "CurrentVersion"') do set "LOCAL_JAVA_VERSION=%%a"
  if not "!LOCAL_JAVA_VERSION!" == "" (
    echo     Java Version Found: !LOCAL_JAVA_VERSION!
    rem http://stackoverflow.com/a/22353131/2334951
    for /f "usebackq tokens=2,* skip=2" %%a in (`reg query "!key!\!LOCAL_JAVA_VERSION!" /v JavaHome 2^>NUL`) do set "LOCAL_JAVA_HOME=%%b"
    if not "LOCAL_JAVA_HOME" == "" goto got_local_java_home
  )
)
endlocal
echo Error. Java Path not found. Please install Java.
exit /B 1
goto end

:java_exe_found
for %%a in ("%JAVA_EXE%") do set "LOCAL_JAVA_HOME=%%~dpa"
rem remove trailing forthslash
set LOCAL_JAVA_HOME=%LOCAL_JAVA_HOME:~0,-1%

:got_local_java_home
endlocal & set "JAVA_HOME=%LOCAL_JAVA_HOME%"

:java_home_set
echo     JAVA_HOME found: "%JAVA_HOME%"
echo Done.

:end
endlocal
