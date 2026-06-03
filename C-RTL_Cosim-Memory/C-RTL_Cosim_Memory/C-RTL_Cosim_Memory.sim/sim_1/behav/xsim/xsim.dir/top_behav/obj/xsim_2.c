/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2020 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/

#if defined(_WIN32)
 #include "stdio.h"
 #define IKI_DLLESPEC __declspec(dllimport)
#else
 #define IKI_DLLESPEC
#endif
#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
#include "svdpi.h"


#if (defined(_MSC_VER) || defined(__MINGW32__) || defined(__CYGWIN__))
#define DPI_DLLISPEC __declspec(dllimport)
#define DPI_DLLESPEC __declspec(dllexport)
#else
#define DPI_DLLISPEC
#define DPI_DLLESPEC
#endif


extern "C"
{
	DPI_DLLISPEC extern void  DPISetMode(int mode) ;
	DPI_DLLISPEC extern int   DPIGetMode() ; 
	DPI_DLLISPEC extern void  DPIAllocateExportedFunctions(int size) ;
	DPI_DLLISPEC extern void  DPIAddExportedFunction(int index, const char* value) ;
	DPI_DLLISPEC extern void  DPIAllocateSVCallerName(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPISetCallerName(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPISetCallerLine(int index, unsigned int y) ;
	DPI_DLLISPEC extern void  DPISetCallerOffset(int index, int y) ;
	DPI_DLLISPEC extern void  DPIAllocateDPIScopes(int size) ;
	DPI_DLLISPEC extern void  DPISetDPIScopeFunctionName(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPISetDPIScopeHierarchy(int index, const char* y) ;
	DPI_DLLISPEC extern void  DPIRelocateDPIScopeIP(int index, char* IP) ;
	DPI_DLLISPEC extern void  DPIAddDPIScopeAccessibleFunction(int index, unsigned int y) ;
	DPI_DLLISPEC extern void  DPIFlushAll() ;
	DPI_DLLISPEC extern void  DPIVerifyScope() ;
	DPI_DLLISPEC extern char* DPISignalHandle(char* sigHandle, int length) ;
	DPI_DLLISPEC extern char* DPIMalloc(unsigned noOfBytes) ;
	DPI_DLLISPEC extern void  DPITransactionAuto(char* srcValue, unsigned int startIndex, unsigned int endIndex, char* net) ;
	DPI_DLLISPEC extern void  DPIScheduleTransactionBlocking(char* var, char* driver, char* src, unsigned setback, unsigned lenMinusOnne) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpi(char* dst, char* src, int numCBytes, int is2state) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSv(char* dst, char* src, int numCBytes, int is2state) ;
	DPI_DLLISPEC extern void  DPIMemsetSvLogic1ToDpi(char* dst, char* src) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvLogic1(char* dst, char* src) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedLogic(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedLogicWithPackedDim(char* dst, char* src, int pckedSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedLogic(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedLogicWithPackedDim(char* dst, char* src, int pckdSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedBit(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetDpiToSvUnpackedBitWithPackedDim(char* dst, char* src, int pckdSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedBit(char* dst, char* src, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPIMemsetSvToDpiUnpackedBitWithPackedDim(char* dst, char* src, int pckdSz, int* numRshift, int* shift) ;
	DPI_DLLISPEC extern void  DPISetFuncName(const char* funcName) ;
	DPI_DLLISPEC extern int   staticScopeCheck(const char* calledFunction) ;
	DPI_DLLISPEC extern void  DPIAllocateSVCallerInfo(int size) ;
	DPI_DLLISPEC extern void* DPICreateContext(int scopeId, char* IP, int callerIdx);
	DPI_DLLISPEC extern void* DPIGetCurrentContext();
	DPI_DLLISPEC extern void  DPISetCurrentContext(void*);
	DPI_DLLISPEC extern void  DPIRemoveContext(void*);
	DPI_DLLISPEC extern int   svGetScopeStaticId();
	DPI_DLLISPEC extern char* svGetScopeIP();
	DPI_DLLISPEC extern unsigned DPIGetUnpackedSizeFromSVOpenArray(svOpenArray*);
	DPI_DLLISPEC extern unsigned DPIGetConstraintSizeFromSVOpenArray(svOpenArray*, int);
	DPI_DLLISPEC extern int   topOffset() ;
	DPI_DLLISPEC extern char* DPIInitializeFunction(char* p, unsigned size, long long offset) ;
	DPI_DLLISPEC extern void  DPIInvokeFunction(char* processPtr, char* SP, void* func, char* IP) ;
	DPI_DLLISPEC extern void  DPIDeleteFunctionInvocation(char* SP) ;
	DPI_DLLISPEC extern void  DPISetTaskScopeId(int scopeId) ;
	DPI_DLLISPEC extern void  DPISetTaskCaller(int index) ;
	DPI_DLLISPEC extern int   DPIGetTaskCaller() ;
	DPI_DLLISPEC extern char* DPIInitializeTask(long long subprogInDPOffset, char* scopePropInIP, unsigned size, char* parentBlock) ;
	DPI_DLLISPEC extern void  DPIInvokeTask(long long subprogInDPOffset, char* SP, void* func, char* IP) ;
	DPI_DLLISPEC extern void  DPIDeleteTaskInvocation(char* SP) ;
	DPI_DLLISPEC extern void* DPICreateTaskContext(int (*wrapper)(char*, char*, char*), char* DP, char* IP, char* SP, size_t stackSz) ;
	DPI_DLLISPEC extern void  DPIRemoveTaskContext(void*) ;
	DPI_DLLISPEC extern void  DPICallCurrentContext() ;
	DPI_DLLISPEC extern void  DPIYieldCurrentContext() ;
	DPI_DLLISPEC extern void* DPIGetCurrentTaskContext() ;
	DPI_DLLISPEC extern int   DPIRunningInNewContext() ;
	DPI_DLLISPEC extern void  DPISetCurrentTaskContext(void* x) ;
}

namespace XILINX_DPI { 

	void dpiInitialize()
	{
		DPIAllocateExportedFunctions(1) ;
		DPIAddExportedFunction(0, "sv_tick") ;
		DPIAllocateSVCallerInfo(1) ;
		DPISetCallerName(0, "/home/user25/Xilinx/Vivado/Projects/C-RTL_Cosim-Memory/top.sv") ;
		DPISetCallerLine(0, 71) ;
		DPISetCallerOffset(0, 1464) ;
		DPIAllocateDPIScopes(2) ;
		DPISetDPIScopeFunctionName(0, "run_cpp_test") ;
		DPISetDPIScopeHierarchy(0, "top") ;
		DPIRelocateDPIScopeIP(0, (char*)(0x7678)) ;
		DPIAddDPIScopeAccessibleFunction(0, 0) ;
	}

}


extern "C" {
	void iki_initialize_dpi()
	{ XILINX_DPI::dpiInitialize() ; } 
}


extern "C" {

	extern int run_cpp_test() ;
	extern void subprog_m_c080504330950eed_e3de7881_1(char*, char*, char*);
}


extern "C" {
	int Dpi_wrapper_run_cpp_test(char *GlobalDP, char *IP, char *SP)
	{
void* myContext = 0 ; 
DPISetMode(3) ; // Task chain mode : with or without context 
if (DPIRunningInNewContext())
{
char* ptrToSP = SP ;

		    /******* Convert SV types to DPI-C Types *******/ 

		    /******* Create and populate DPI-C types for the arguments *******/ 

		    /******* Done Conversion of SV types to DPI-C Types *******/ 
		    /******* Call the DPI-C function *******/ 
		DPISetFuncName("run_cpp_test");
		DPIFlushAll();
		int result = 0 ;
		result = run_cpp_test();

		    /******* Write result value into the SP *******/ 
		ptrToSP = SP + 384 ; 
		DPIFlushAll();
		DPISetFuncName(0);
		*((int*)ptrToSP) = result; 
		*((int*)ptrToSP+1) = 0; 
		 /****** Set the finished flag for task invocation ******/
		* ((unsigned int*)(SP  + 161)) = 1; 
		return result ;
}
if ((*(char**)(SP + 40)) != 0)
{
myContext = (*((void**)(SP + 192))) ;
}
else
{
myContext = DPICreateTaskContext(Dpi_wrapper_run_cpp_test, GlobalDP, IP, SP, 65536) ;
DPISetCurrentContext(myContext) ;
char* ptrToSP = SP ;
		ptrToSP = ptrToSP + 208; 
DPISetTaskScopeId(*(int*)(ptrToSP)) ;
ptrToSP = (char*)(ptrToSP + 4) ;
DPISetTaskCaller(*((int*)ptrToSP)) ;
(*(int*)(SP + 40)) = 1 ;
(*((void**)(SP +  192))) = myContext ;
}
DPISetCurrentContext(myContext) ;
DPICallCurrentContext() ;
if (*(unsigned int*)(SP + 161) == 1) 
{
DPIRemoveTaskContext(myContext) ;
}
return 0 ;
	}
}


extern "C" {
	DPI_DLLESPEC 
	int sv_tick(char arg0, short arg1, char arg2, char* arg3, char arg4, short arg5, char arg6, char* arg7)
	{
		int result ;
		DPIVerifyScope();
		int functionToCall = staticScopeCheck("sv_tick") ;
		switch(functionToCall)
		{
			case 0:
			{

	{
		DPIFlushAll();
		int staticIndex = 0 ;
		char* IP = NULL ;
		staticIndex = svGetScopeStaticId() ;
		IP = svGetScopeIP();
		int callingProcessOffset = DPIGetTaskCaller() ;
		char* SP ;
		void* oldSPcontext = DPIGetCurrentContext();
		SP = DPIInitializeTask(29672, IP + 3336, 208, 0) ;
		char driver0[32] ;
		for(int i = 0 ; i < 32 ; ++i) driver0[i] = 0 ;
		char driver1[32] ;
		for(int i = 0 ; i < 32 ; ++i) driver1[i] = 0 ;
		char driver2[32] ;
		for(int i = 0 ; i < 32 ; ++i) driver2[i] = 0 ;
		char driver4[32] ;
		for(int i = 0 ; i < 32 ; ++i) driver4[i] = 0 ;
		char driver5[32] ;
		for(int i = 0 ; i < 32 ; ++i) driver5[i] = 0 ;
		char driver6[32] ;
		for(int i = 0 ; i < 32 ; ++i) driver6[i] = 0 ;
		char copyArg_0_0[8];
		{
		char* ptrToSP = (char*)copyArg_0_0;
		DPIMemsetDpiToSv( ptrToSP, (char*)(&arg0), 1, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		DPIScheduleTransactionBlocking(IP +2888, driver0, (char*)(&copyArg_0_0), 0, 7) ;
		char copyArg_1_1[8];
		{
		char* ptrToSP = (char*)copyArg_1_1;
		DPIMemsetDpiToSv( ptrToSP, (char*)(&arg1), 2, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		DPIScheduleTransactionBlocking(IP +2944, driver1, (char*)(&copyArg_1_1), 0, 15) ;
		char copyArg_2_2[8];
		{
		char* ptrToSP = (char*)copyArg_2_2;
		DPIMemsetDpiToSv( ptrToSP, (char*)(&arg2), 1, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		DPIScheduleTransactionBlocking(IP +3000, driver2, (char*)(&copyArg_2_2), 0, 7) ;
		char copyArg_3_4[8];
		{
		char* ptrToSP = (char*)copyArg_3_4;
		DPIMemsetDpiToSv( ptrToSP, (char*)(&arg4), 1, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		DPIScheduleTransactionBlocking(IP +3112, driver4, (char*)(&copyArg_3_4), 0, 7) ;
		char copyArg_4_5[8];
		{
		char* ptrToSP = (char*)copyArg_4_5;
		DPIMemsetDpiToSv( ptrToSP, (char*)(&arg5), 2, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		DPIScheduleTransactionBlocking(IP +3168, driver5, (char*)(&copyArg_4_5), 0, 15) ;
		char copyArg_5_6[8];
		{
		char* ptrToSP = (char*)copyArg_5_6;
		DPIMemsetDpiToSv( ptrToSP, (char*)(&arg6), 1, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		DPIScheduleTransactionBlocking(IP +3224, driver6, (char*)(&copyArg_5_6), 0, 7) ;
		char* oldSP = *((char**)(IP + callingProcessOffset + 80)) ; 
		DPIInvokeTask(29672, SP, (void*)subprog_m_c080504330950eed_e3de7881_1, IP) ;
		DPIYieldCurrentContext() ;
		{
		char* ptrToSP = (char*)DPISignalHandle(IP +3056, 8);
		DPIMemsetSvToDpi( (char*)(arg3), ptrToSP, 1, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		{
		char* ptrToSP = (char*)DPISignalHandle(IP +3280, 8);
		DPIMemsetSvToDpi( (char*)(arg7), ptrToSP, 1, 1 );
		ptrToSP = ptrToSP + 8; 
		}
		*((char**)(IP + callingProcessOffset + 80)) = oldSP ; 
		DPISetCurrentContext(oldSPcontext);
		DPIFlushAll();
if (*(unsigned int*)(SP + 163) == 1) 
{
result = 1 ;
}
else
{
result = 0 ;
}
		DPIDeleteTaskInvocation(SP) ;
	}
			}
			break ;
			default:
			break ;
		}
		return result ;
	}
}

