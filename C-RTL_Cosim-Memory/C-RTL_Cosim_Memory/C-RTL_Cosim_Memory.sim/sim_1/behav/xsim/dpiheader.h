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


/* NOTE: DO NOT EDIT. AUTOMATICALLY GENERATED FILE. CHANGES WILL BE LOST. */

#ifndef DPI_H
#define DPI_H
#ifdef __cplusplus
#define DPI_LINKER_DECL  extern "C" 
#else
#define DPI_LINKER_DECL
#endif

#include "svdpi.h"



/* Exported (from SV) task*/
DPI_LINKER_DECL int sv_tick(
	char c_we_a, short c_addr_a, char c_din_a, char* c_dout_a
	, char c_we_b, short c_addr_b, char c_din_b, char* c_dout_b
);


/* Imported (by SV) task */
DPI_LINKER_DECL DPI_DLLESPEC int run_cpp_test(
);


#endif
