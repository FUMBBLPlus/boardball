/*
This is the source code of the Boardball EXE loader.
The only purpose of the EXE is to have the nice Boardball icon
when used with Windows Context Menu's Open with.

Basically all it does is to call boardball.bat in the same
directory with all arguments passed to it.

This is my first C program so it may be even more compact.
If you can make it nicer, please report it to me.

http://faq.cprogramming.com/cgi-bin/smartfaq.cgi?answer=1044654269&id=1043284392
*/

#include <windows.h>
#include <libgen.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
  char buff[4096];
  GetModuleFileName(NULL, buff, 4096);
  char* dname = dirname(buff);

  char* prpath = malloc(snprintf(NULL, 0, "%s\\%s", dname, "boardball.bat") + 1);
  sprintf(prpath, "\"%s\\%s\"", dname, "boardball.bat");

  char* cmdline = GetCommandLine();
  int argslen = strlen(cmdline)-strlen(argv[0])-2;
  char* args = malloc(argslen);
  if(argslen > 0){
    sprintf(args, "%s", &cmdline[strlen(argv[0]) + 2]);
  }
  else
  {
    args = "";
  };
  /* Uncomment to debug:
  MessageBox(HWND_DESKTOP,prpath,"",MB_OK);
  MessageBox(HWND_DESKTOP,args,"",MB_OK);
  */
  HINSTANCE hRet = ShellExecute(
        HWND_DESKTOP, //Parent window
        "open",       //Operation to perform
        prpath,       //Path to program
        args,         //Parameters
        NULL,         //Default directory
        SW_HIDE);     //How to open; replace to SW_SHOW to debug

  /*
  The function returns a HINSTANCE (not really useful in this case)
  So therefore, to test its result, we cast it to a LONG.
  Any value over 32 represents success!
  */

  if((LONG)hRet <= 32)
  {
    MessageBox(HWND_DESKTOP,"Unable to start program","",MB_OK);
    return 1;
  }

  return 0;
}
