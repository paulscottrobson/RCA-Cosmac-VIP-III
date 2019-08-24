// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_processor.h
//		Purpose:	Processor Emulation (header)
//		Date:		24th August 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#ifndef _PROCESSOR_H
#define _PROCESSOR_H

#define RAMSIZE 	(32768)
#define RAMMASK 	(0x7FFF)

typedef unsigned short WORD16;														// 8 and 16 bit types.
typedef unsigned char  BYTE8;

void CPUReset(void);
BYTE8 CPUExecuteInstruction(void);
WORD16 CPUReadMemory(WORD16 address);
void CPUWriteMemory(WORD16 address,WORD16 data);

#ifdef INCLUDE_DEBUGGING_SUPPORT													// Only required for debugging

typedef struct __CPUSTATUS {
	BYTE8 d,df,ie,q,t,x,p;
	WORD16 r[16],cycles;
	WORD16 pc;
} CPUSTATUS;

CPUSTATUS *CPUGetStatus(void);
BYTE8 CPUExecute(WORD16 breakPoint1,WORD16 breakPoint2);
WORD16 CPUGetStepOverBreakpoint(void);
void CPULoadBinary(const char *fileName);
void CPUEndRun(void);

#endif
#endif
