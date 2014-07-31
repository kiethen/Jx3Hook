#pragma once
#include <oaidl.h>


class CSink : public IDispatch
{
public:
	CSink(void);
	~CSink(void);

	STDMETHODIMP QueryInterface(const struct _GUID &iid,void ** ppv);
	ULONG __stdcall AddRef(void);
	ULONG __stdcall Release(void);
	STDMETHODIMP GetTypeInfoCount(unsigned int *);
	STDMETHODIMP GetTypeInfo(unsigned int,unsigned long, ITypeInfo** );
	STDMETHODIMP GetIDsOfNames(const IID&, LPOLESTR*, UINT, LCID, DISPID*);
	STDMETHODIMP Invoke(long dispID, const _GUID&, unsigned long, unsigned short,
	tagDISPPARAMS* pParams, tagVARIANT*, tagEXCEPINFO*, unsigned int*);

    void OnEvent(long dispID, tagDISPPARAMS* pParams);

	DWORD		m_refCount;
};
