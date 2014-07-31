#include "Martin.h"

///////////////////////////////////////////////////////////////
CMartin* CMartin::m_cInstance = NULL;
CMartin* martin = CMartin::GetInstance();

CMartin* CMartin::GetInstance()
{
    if (m_cInstance == NULL) {
        m_cInstance = new CMartin;
    }

    return m_cInstance;
}
///////////////////////////////////////////////////////////////

#pragma warning(push)
#pragma warning(disable : 4996)

int CMartin::MsgBox(const TCHAR* szCaption, const TCHAR* szFormat, ...)
{
    TCHAR szBuffer[1024];
    va_list pArgList;

    va_start(pArgList, szFormat);

    _vsntprintf(szBuffer, sizeof(szBuffer)/sizeof(TCHAR), szFormat, pArgList);

    va_end(pArgList);

    return MessageBox(NULL, szBuffer, szCaption, 0);
}


void CMartin::Debug(const TCHAR* szFormat, ...)
{
#ifdef _DEBUG
    TCHAR szBuffer[1024] = {TEXT("Debug:")};;
    va_list pArgList;

    va_start(pArgList, szFormat);

    _vsntprintf(szBuffer + _tcslen(szBuffer), 1024 - _tcslen(szBuffer)*2, szFormat, pArgList);

    va_end(pArgList);

    return OutputDebugString(szBuffer);
#endif
}
#pragma warning(pop)

//读取内存
INT CMartin::ReadPtrByInt(int beginAddr, TCHAR errorString[])
{
    TCHAR msg[] = TEXT(" ---->> 出现错误!");
    try {
        if (IsBadReadPtr((CONST VOID*)beginAddr, sizeof(INT)) == 0) {
            return *(INT*)beginAddr;
        }
    } catch (...) {

    }
    //提示出错信息
    int len_a = lstrlen(msg);
    int len_b = lstrlen(errorString);
    TCHAR* tmp = new TCHAR[len_a + len_b + 1];
    tmp[0] = TEXT('\0');
    lstrcat(tmp,errorString);
    lstrcat(tmp, msg);
    martin->Debug(TEXT("%s"), tmp);
    delete [] tmp;

    return -1;
}

//读取内存
BYTE CMartin::ReadPtrByByte(int beginAddr, TCHAR errorString[])
{
    TCHAR msg[] = TEXT(" ---->> 出现错误!");
    try {
        if (IsBadReadPtr((CONST VOID*)beginAddr, sizeof(BYTE)) == 0) {
            return *(BYTE*)beginAddr;
        }
    } catch (...) {

    }
    //提示出错信息
    int len_a = lstrlen(msg);
    int len_b = lstrlen(errorString);
    TCHAR* tmp = new TCHAR[len_a + len_b + 1];
    tmp[0] = TEXT('\0');
    lstrcat(tmp,errorString);
    lstrcat(tmp, msg);
    martin->Debug(TEXT("%s"), tmp);
    delete [] tmp;

    return -1;
}

//读取内存
SHORT CMartin::ReadPtrByShort(int beginAddr, TCHAR errorString[])
{
    TCHAR msg[] = TEXT(" ---->> 出现错误!");
    try {
        if (IsBadReadPtr((CONST VOID*)beginAddr, sizeof(SHORT)) == 0) {
            return *(SHORT*)beginAddr;
        }
    } catch (...) {

    }
    //提示出错信息
    int len_a = lstrlen(msg);
    int len_b = lstrlen(errorString);
    TCHAR* tmp = new TCHAR[len_a + len_b + 1];
    tmp[0] = TEXT('\0');
    lstrcat(tmp,errorString);
    lstrcat(tmp, msg);
    martin->Debug(TEXT("%s"), tmp);
    delete [] tmp;

    return -1;
}

/************************************************************************
 *	程序作者: Martin  2014/07/19 23:59
 *	函数名称: FreeResFile
 *	函数功能: 释放资源到指定目录
 *	参数列表: 
        dwResName : 资源ID
        lpResType : 资源标识符
        lpFilePathName : 释放路径
 *	返回说明: 是否成功释放
************************************************************************/
bool CMartin::FreeResFile(DWORD dwResName, LPCWSTR lpResType, LPCWSTR lpFilePathName, DWORD nFlag)
{
    HMODULE hInstance = ::GetModuleHandle(NULL);//得到自身实例句柄          
    HRSRC hResID = ::FindResource(hInstance,MAKEINTRESOURCE(dwResName),lpResType);//查找资源      
    HGLOBAL hRes = ::LoadResource(hInstance,hResID);//加载资源       
    LPVOID pRes = ::LockResource(hRes);//锁定资源                   
    if (pRes == NULL) {//锁定失败       
        return FALSE;       
    }

    DWORD dwResSize = ::SizeofResource(hInstance,hResID);//得到待释放资源文件大小       
    HANDLE hResFile = CreateFile(lpFilePathName,GENERIC_WRITE,0,NULL,nFlag,FILE_ATTRIBUTE_NORMAL,NULL);//创建文件                  
    if (INVALID_HANDLE_VALUE == hResFile) {           //TRACE("创建文件失败！");          
        return FALSE;
    }

    DWORD dwWritten = 0;//写入文件的大小          
    WriteFile(hResFile,pRes,dwResSize,&dwWritten,NULL);//写入文件      
    CloseHandle(hResFile);//关闭文件句柄                   
    return (dwResSize == dwWritten);//若写入大小等于文件大小，返回成功，否则失败 
    //使用示例: FreeResFile(IDR_MYRES,"MYRES","D:\\1.exe");
}

HWND CMartin::GetGameHwnd()
{
    ProcessWindow procwin;  
    procwin.dwProcessId = GetCurrentProcessId();  
    procwin.hwndWindow = NULL;  

    // 查找主窗口  
    EnumWindows(EnumWindowCallBack, (LPARAM)&procwin);  

    return procwin.hwndWindow;
}

BOOL CALLBACK CMartin::EnumWindowCallBack(HWND hWnd, LPARAM lParam)  
{  
    ProcessWindow *pProcessWindow = (ProcessWindow *)lParam;  

    DWORD dwProcessId;  
    GetWindowThreadProcessId(hWnd, &dwProcessId);

    char szDlgName[20] = {0};
    GetWindowTextA(hWnd, szDlgName, sizeof(szDlgName));

    // 判断是否是指定进程的主窗口  
    if (pProcessWindow->dwProcessId == dwProcessId && IsWindowVisible(hWnd) && GetParent(hWnd) == NULL && strstr(szDlgName, "Dialog") == NULL)  
    {  
        pProcessWindow->hwndWindow = hWnd;  

        return FALSE;  
    }  

    return TRUE;  
}

BOOL CMartin::BreakLdrModuleLink(DWORD dwBaseAddr)
{
    PLDR_MODULE pLMFNode = NULL, pLNode = NULL ;
    PLDR_MODULE pLMHNode = NULL, pLMPNode = NULL;
    PLDR_MODULE pLMTNode = NULL;
    BOOL bSuccess = FALSE;

    //获取LDR_MODULE链的头指针
    __asm {
        pushad;
        pushfd;
        xor edx, edx;
        mov ebx, fs:[edx + 0x30];
        mov ecx, [ebx + 0x0C];
        lea edx, [ecx + 0x0C];
        mov ecx, [ecx + 0x0C];
        mov pLMHNode, edx;
        mov pLMFNode, ecx;
        popfd;
        popad;
    }

    //查找目标
    PLDR_MODULE pLMNode = pLMFNode;
    pLMPNode = pLMHNode;
    do {
        //比较是否是目标模块
        if( (DWORD)pLMNode->BaseAddress == dwBaseAddr) {
            bSuccess = TRUE;
            break;
        }
        pLMPNode = pLMNode;
        pLMNode = (PLDR_MODULE)pLMNode->InLoadOrderModuleList.Flink;
    } while (pLMNode != pLMHNode);

    if( !bSuccess ) {
        OutputDebugString(TEXT("cannot find the dest module!"));
        return bSuccess; //未找到目标模块
    }

    //断开InLoadOrderModuleList链
    //重建Flink
    pLMTNode = (PLDR_MODULE)pLMNode->InLoadOrderModuleList.Flink;
    pLMPNode->InLoadOrderModuleList.Flink = (PLIST_ENTRY)pLMTNode;
    //重建Blink
    ((PLDR_MODULE)(pLMNode->InLoadOrderModuleList.Flink))->InLoadOrderModuleList.Blink  = 
        pLMNode->InLoadOrderModuleList.Blink;

    //断开InMemoryOrderModuleList链
    //重建Flink
    pLMPNode->InMemoryOrderModuleList.Flink = 
        pLMNode->InMemoryOrderModuleList.Flink;
    //重建Blink
    pLMTNode = (PLML)(pLMNode->InMemoryOrderModuleList.Flink - sizeof(LIST_ENTRY));
    pLMTNode->InMemoryOrderModuleList.Blink =  
        pLMNode->InMemoryOrderModuleList.Blink;

    //断开InInitializationOrderModuleList链
    //重建Flink
    pLMPNode->InInitializationOrderModuleList.Flink =  
        pLMNode->InInitializationOrderModuleList.Flink;

    //重建Blink
    pLMTNode = (PLML)(pLMNode->InInitializationOrderModuleList.Flink - 2*sizeof(LIST_ENTRY));
    pLMTNode->InInitializationOrderModuleList.Blink  = pLMNode->InInitializationOrderModuleList.Blink;
}

void CMartin::ModuleHide(HMODULE hInjectDll)
{
    DWORD dwOldProtect;
    VirtualProtect((LPVOID)hInjectDll,1024,PAGE_READWRITE, &dwOldProtect);
    PIMAGE_DOS_HEADER pDosHeader = (PIMAGE_DOS_HEADER) hInjectDll;

    //抹去MZ标志
    pDosHeader->e_magic = 0;

    //DOS头后面就是PE头
    PIMAGE_NT_HEADERS pNtHeader = (PIMAGE_NT_HEADERS)(pDosHeader+1);

    //抹去PE标志
    pNtHeader->Signature = 0;

    VirtualProtect((LPVOID)hInjectDll,1024,dwOldProtect, &dwOldProtect);

    //断开LDR_MODULE
    BreakLdrModuleLink((DWORD)hInjectDll);
}