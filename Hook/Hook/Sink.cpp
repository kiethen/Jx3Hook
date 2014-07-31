#include "Sink.h"
#include "Release\allpurauthentic.tlh"

CSink::CSink(void)
{
	m_refCount = 1;
}

CSink::~CSink(void)
{
}

STDMETHODIMP CSink::QueryInterface(const struct _GUID &iid, void** ppv)
{
    if (iid == IID_IUnknown)
    {
        m_refCount++;
        *ppv = (void *)this;
        return S_OK;
    }

    if (iid == DIID__ICurrencyAuthEvents)
    {
        m_refCount++;
        *ppv = (void *)this;
        return S_OK;
    }

    return E_NOINTERFACE;
}

ULONG __stdcall CSink::AddRef(void)
{
    m_refCount++;
    return m_refCount;
}

ULONG __stdcall CSink::Release(void)
{
	if(--m_refCount <= 0) 
	{
		return 0;
	}
 
	return m_refCount;
}

STDMETHODIMP CSink::GetTypeInfoCount(unsigned int *)
{
	return E_NOTIMPL;
}

STDMETHODIMP CSink::GetTypeInfo(unsigned int, unsigned long, ITypeInfo** )
{
	return E_NOTIMPL;
}

STDMETHODIMP CSink::GetIDsOfNames(const IID&, LPOLESTR*, UINT, LCID, DISPID*)
{
	return E_NOTIMPL;
}

STDMETHODIMP CSink::Invoke(long dispID, const _GUID&, unsigned long, unsigned short,
tagDISPPARAMS * pParams, tagVARIANT*, tagEXCEPINFO*, unsigned int*)
{
	OnEvent(dispID, pParams);
	return S_OK;
}

extern HWND g_hDlg;
#define IDD_UPDATA      5001
#define IDD_NOTICES     5002

void CSink::OnEvent(long dispID, tagDISPPARAMS* pParams)
{
    //收到验证组件触发的事件
    switch(dispID) {
    case 1: //有自动更新下载到temp目录, 调用Update可替换更新并重启
        MessageBox(NULL, TEXT("辅助有更新, 点击确定开始更新\r\n详细信息请看下方公告"), TEXT("提示"), MB_OK);
        //pAuth->Update();    //Update 的过程 退出本程序->替换已下载的文件->重启本程序
        SendMessage(g_hDlg, WM_COMMAND, (WPARAM)IDD_UPDATA, NULL);
        break;

    case 2:	//变为无效状态, 30秒后插件会退出本程序
        MessageBox(NULL, TEXT("此卡已失效, 30秒后自动退出\r\n请联系软件客服充值!"), TEXT("提示"), MB_OK);
        break;

    case 3:	//收到公告
        //::MessageBox(NULL, L"公告!", L"公告", MB_OK);
        SendMessage(g_hDlg, WM_COMMAND, (WPARAM)IDD_NOTICES, (LPARAM)pParams->rgvarg[0].bstrVal);
        break;
    }
}