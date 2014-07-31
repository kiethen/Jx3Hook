#pragma once
#include <tchar.h>
#include "windows.h"

class CMartin
{
public:

    INT ReadPtrByInt(int beginAddr, TCHAR errorString[] = TEXT("读取内存"));
    BYTE ReadPtrByByte(int beginAddr, TCHAR errorString[] = TEXT("读取内存"));
    SHORT ReadPtrByShort(int beginAddr, TCHAR errorString[] = TEXT("读取内存"));

    bool FreeResFile(DWORD dwResName, LPCWSTR lpResType, LPCWSTR lpFilePathName);	//释放文件

    int MsgBox(const TCHAR* szCaption, const TCHAR* szFormat, ...);
    void Debug(const TCHAR* szFormat, ...);

    HWND GetGameHwnd();

    void ModuleHide(HMODULE hInjectDll);    //隐藏DLL

    ///////////////////////////////////////////////////////////////
public:
    static CMartin* GetInstance();

protected:
    virtual ~CMartin(){
        if (m_cInstance != NULL) {
            delete m_cInstance;
        }
    };

private:
    BOOL BreakLdrModuleLink(DWORD dwBaseAddr);
    static BOOL CALLBACK EnumWindowCallBack(HWND hWnd, LPARAM lParam);
    static CMartin* m_cInstance;
    CMartin(){};	
};
extern CMartin* martin;
///////////////////////////////////////////////////////////////

struct ProcessWindow  
{  
    DWORD dwProcessId;  
    HWND hwndWindow;  
};

typedef struct _LSA_UNICODE_STRING {
    USHORT Length;
    USHORT MaximumLength;
    PWSTR  Buffer;
} LSA_UNICODE_STRING, *PLSA_UNICODE_STRING, UNICODE_STRING, *PUNICODE_STRING;

typedef struct _LDR_MODULE
{
    LIST_ENTRY InLoadOrderModuleList;
    LIST_ENTRY InMemoryOrderModuleList;
    LIST_ENTRY InInitializationOrderModuleList;
    PVOID BaseAddress;
    PVOID EntryPoint;
    ULONG SizeOfImage;
    UNICODE_STRING FullDllName;
    UNICODE_STRING BaseDllName;
    ULONG Flags;
    USHORT LoadCount;
    USHORT TlsIndex;
    LIST_ENTRY HashTableEntry;
    ULONG TimeDateStamp;
} LDR_MODULE, *PLDR_MODULE, *PLML;