@echo off
set root=%~dp0
set root=%root:~0,-1%

echo Determining Java Path...
if not "%JAVA_HOME%" == "" goto java_home_set
setlocal
set LOCAL_JAVA_HOME=
rem http://stackoverflow.com/questions/889518/windows-batch-files-how-to-set-a-variable-with-the-result-of-a-command
rem reg query "HKLM\Software\Wow6432Node\JavaSoft\Java Runtime Environment" /v CurrentVersion 2>NUL | "%root%\bin\w32\gnuwin32\egrep.exe" -o "CurrentVersion.+" | "%root%\bin\w32\gnuwin32\sed.exe" "s/CurrentVersion\s\+REG_SZ\s\+\(.\+\)/\1/" > java_home.txt
for /f "delims=" %%a in ('reg query "HKLM\Software\Wow6432Node\JavaSoft\Java Runtime Environment" /v CurrentVersion 2^>NUL ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o "CurrentVersion.+" ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/CurrentVersion\s\+REG_SZ\s\+\(.\+\)/\1/"') do @set LOCAL_JAVA_VERSION=%%a
if not "%LOCAL_JAVA_VERSION%" == "" (
  echo   Java Version Found: %LOCAL_JAVA_VERSION%
  for /f "delims=" %%a in ('reg query "HKLM\Software\Wow6432Node\JavaSoft\Java Runtime Environment\%LOCAL_JAVA_VERSION%" /v JavaHome 2^>NUL ^| "%root%\bin\w32\gnuwin32\egrep.exe" -o "JavaHome.+" ^| "%root%\bin\w32\gnuwin32\sed.exe" "s/JavaHome\s\+REG_SZ\s\+\(.\+\)/\1/"') do @set LOCAL_JAVA_HOME=%%a
  if not "LOCAL_JAVA_HOME" == "" goto got_local_java_home
)
endlocal
echo Error. Java Path not found. Please install Java.
exit /B 1
goto end

:got_local_java_home
endlocal & set "JAVA_HOME=%LOCAL_JAVA_HOME%"
goto java_home_set

:java_home_set
echo   JAVA_HOME found: "%JAVA_HOME%"
echo Done.

:end


