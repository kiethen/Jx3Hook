// Jx3Server.cpp : 定义 DLL 应用程序的导出函数。
//

#include "stdafx.h"
#include <process.h>
#include <windows.h>
#include "luainc.h"
#include <TLHELP32.H>
#include "Martin.h"

#pragma data_seg("MyJx3Sec") //--节开始

int     g_start = 0x31;//要共享的数据,注意:要往节中放置一个变量,这个变量必须已经初始化 如: int example = 100;
BOOL    g_bIsFace = FALSE;//要共享的数据,注意:要往节中放置一个变量,这个变量必须已经初始化 如: int example = 100;

#pragma data_seg()	//--节结束

//设置节共享:
#pragma comment(linker, "/section:MyJx3Sec,RWS")


HWND g_hWgDlg = NULL;

DWORD GetLuaState()
{
    BYTE* modBaseAddr = NULL;

    //给输入的进程中的所有模块拍一个快照
    HANDLE hModuleSnap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,0);
    if (hModuleSnap == NULL)
    {
        return 0;
    }

    MODULEENTRY32 module32;
    //在使用这个结构之前，先设置它的大小
    module32.dwSize = sizeof(module32);

    //遍历模块快照，轮流显示每个模块的信息
    BOOL bResult = Module32First(hModuleSnap,&module32);
    while(bResult)
    {
        //这里得到一个模块就是进程的主模块，也就是进程对应的可执行程序，所以使用此方法也可以得到进程文件路径
        if (wcsstr(module32.szModule, TEXT("KGUI.dll")) != NULL)
        {
            modBaseAddr = module32.modBaseAddr;
            modBaseAddr = modBaseAddr + 0x181E08;
            break;
        }

        ZeroMemory(&module32, 0);
        module32.dwSize = sizeof(MODULEENTRY32);

        bResult = Module32Next(hModuleSnap,&module32);
    }

    CloseHandle(hModuleSnap);

    DWORD L;
    _asm
    {
        mov esi, modBaseAddr;
        mov esi, [esi];
        lea ecx, [esi+0xD38];
        mov  ebx, [ecx+0x3C];
        mov L, ebx;
    }
    return L;
}

void OnButtionRun()
{
    try {
        lua_State* L = NULL;
        L = (lua_State*)GetLuaState();
        luaL_dostring(L, "Martin_Macro.Run()");      
    } catch (...) {
    }
}

void OnButtionLoad()
{
    lua_State* L = NULL;
    L = (lua_State*)GetLuaState();
    luaL_dofile(L, "C:\\Windows\\Martin_Macro.lua");
}

void OnButtionTms()
{
    try {
        lua_State* L = NULL;
        L = (lua_State*)GetLuaState();
        luaL_dostring(L, "Martin_Macro.FaceToTarget()"); 	
    } catch (...) {
    }
}

WNDPROC OldProc;
#define  WM_LOAD            WM_USER + 500
#define  WM_RUN           WM_USER + 501
#define  WM_TMS             WM_USER + 502

LRESULT CALLBACK MyClassProc(HWND hwnd, UINT message, WPARAM wPraram, LPARAM lParam)
{
    switch (message) {
    case WM_LOAD:
        OnButtionLoad();
        return 0;

    case WM_RUN:
        OnButtionRun();
        return 0;

    case WM_TMS:
        OnButtionTms();
        return 0;
    }

    return CallWindowProc(OldProc, hwnd, message, wPraram, lParam);
}

unsigned int __stdcall ScriptRun(PVOID pM)  
{
    while(true) {
        if (GetKeyState(g_start) < 0) {    //按下1键状态
            if (g_hWgDlg != NULL) {
                ::SendMessage(g_hWgDlg, WM_RUN, NULL, NULL);
                Sleep(370);
            }
        }
        Sleep(30);
    }

    return  0;
}

unsigned int __stdcall TuoMasi(PVOID pM)  
{
    while(true) {
        if (g_bIsFace) {
            if (GetKeyState(g_start) < 0) {    //按下Q键状态
                if (g_hWgDlg != NULL) {
                    ::SendMessage(g_hWgDlg, WM_TMS, NULL, NULL);
                    Sleep(70);
                }
            }
        }
        Sleep(30);
    }

    return  0;
}

BOOL g_bIsFirst = TRUE;
extern HMODULE g_hModule;

LRESULT CALLBACK GameProc(
    int code,       // hook code
    WPARAM wParam,  // virtual-key code == VK_HOME
    LPARAM lParam   // keystroke-message information
    )
{
    if (g_bIsFirst) {
        if (GetKeyState(VK_HOME) < 0) {    //按下HOME键	
            if (g_hWgDlg == NULL) {
                g_hWgDlg = martin->GetGameHwnd();
                if (g_hWgDlg == NULL) {
                    martin->MsgBox(TEXT("提示"), TEXT("加载失败!!请重启游戏!!"));
                } else {
                    martin->Debug(TEXT("0x%X"), g_hWgDlg);
                    ::CloseHandle((HANDLE)_beginthreadex(NULL, 0, ScriptRun, NULL, 0, NULL));
                    ::CloseHandle((HANDLE)_beginthreadex(NULL, 0, TuoMasi, NULL, 0, NULL));
                    OldProc = (WNDPROC)SetWindowLong(g_hWgDlg, GWL_WNDPROC, (LONG)MyClassProc);
                    //martin->ModuleHide(g_hModule);
                    g_bIsFirst = FALSE;
                }

            }
        }
    }

    if (GetKeyState(VK_HOME) < 0) {    //按下HOME键	
        if (g_hWgDlg != NULL) {
            ::SendMessage(g_hWgDlg, WM_LOAD, NULL, NULL);
        }
    }

    return CallNextHookEx(
        0,      // handle to current hook
        code,      // hook code passed to hook procedure
        wParam,  // value passed to hook procedure
        lParam   // value passed to hook procedure
        );

}

extern "C" __declspec(dllexport) void SetHook();
extern "C" __declspec(dllexport) void SetStart(int);
extern "C" __declspec(dllexport) void SetFace(BOOL);


//安装钩子
void SetHook()
{
    //获取游戏主线程ID号
    HWND h = ::FindWindow(NULL,L"剑侠情缘网络版叁PakV3");
    if (h == NULL) {
        martin->MsgBox(TEXT("提示"), TEXT("请先打开游戏!!"));
        return;
    }

    DWORD pid = NULL;
    DWORD tid = GetWindowThreadProcessId(h, &pid);

    SetWindowsHookEx(
        WH_KEYBOARD,        // hook type
        GameProc,     // hook procedure
        GetModuleHandle(TEXT("Jx3Server.dll")),    // handle to application instance
        tid	 // thread identifier
        );
}

//设置按键
void SetStart(int startCode)
{
    g_start = startCode;
}

//设置是否开启面向
void SetFace(BOOL bIsFace)
{
    g_bIsFace = bIsFace;
}