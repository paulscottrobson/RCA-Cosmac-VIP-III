// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_processor.c
//		Purpose:	Processor Emulation.
//		Date:		24th August 2019
//		Author:		Paul Robson (paul@robsons.org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdlib.h>
#include <stdio.h>
#include "sys_processor.h"
#include "sys_debug_system.h"
#include "hardware.h"

// *******************************************************************************************************************************
//														   Timing
// *******************************************************************************************************************************

#define CYCLES_PER_SCANLINE 	(14)												// CYCLES per scan line (14)
#define NTSC_LINES_PER_FRAME	(262)												// NTSC standards
#define NTSC_FRAMES_PER_SECOND	(60)

#define CYCLES_PER_FRAME 		(CYCLES_PER_SCANLINE * NTSC_LINES_PER_FRAME)		// CYCLES per framMemorye (3,668)
#define CYCLES_PER_SECOND 		(CYCLES_PER_FRAMEE * NTSC_FRAMES_PER_SECOND)		// CYCLES per second (220,080)
#define CRYSTAL_CLOCK 			(CYCLES_PER_SECOND * 8)								// Clock speed (1,760,640Hz)

#define RENDERING_LINES 		(128)												// Generate video on these scanlines
#define RENDERING_CYCLES		(RENDERING_LINES * CYCLES_PER_SCANLINE)				// How many CYCLES this takes.


//	3,668 CYCLES per framMemorye
// 	262 lines per video framMemorye
//	14 CYCLES per scanline (should be :))

// *******************************************************************************************************************************
//														CPU / Memory
// *******************************************************************************************************************************

static BYTE8 D,DF,P,X,Q,T,IE,T8;
static WORD16 R[16],T16;

static BYTE8 ramMemory[RAMSIZE];
static WORD16 CYCLES;

// *******************************************************************************************************************************
//											Read/Write Inline Functions
// *******************************************************************************************************************************

static void inline __Write(WORD16 addr,BYTE8 data) {
	if (addr > 0x2000) {
		ramMemory[addr & RAMMASK] = data;
	}
}

#define READ(n) 	ramMemory[(n) & RAMMASK]
#define WRITE(n,d) 	__Write(n,d)

// *******************************************************************************************************************************
//														Hardware
// *******************************************************************************************************************************

#include "generated/_1802_ports.h"

// *******************************************************************************************************************************
//														Reset the CPU
// *******************************************************************************************************************************


void CPUReset(void) {
	Q = 0;IE = 1; 
	X = P = R[0] = 0; 
	DF &= 1;
	CYCLES = 0;
}

// *******************************************************************************************************************************
//													Interrupt the CPU
// *******************************************************************************************************************************

void CPUInterrupt(void) {
	if (IE != 0) { 
		T = (X << 4) | P; 
		X = 2;P = 1;IE = 0; 
	}
}

// *******************************************************************************************************************************
//									Fetch a byte, updating the timer 
// *******************************************************************************************************************************

static inline BYTE8 CPUFetch(void) {
	BYTE8 opcode = ramMemory[R[P] & RAMMASK];
	R[P] = (R[P]+1) & 0xFFFF;
	return opcode;
}

#define FETCH() CPUFetch()

// *******************************************************************************************************************************
//												Execute a single instruction
// *******************************************************************************************************************************

BYTE8 CPUExecuteInstruction(void) {
	
	BYTE8 opcode = CPUFetch();
	switch(opcode) {
		#include "generated/_1802_case.h"
	}
	CYCLES = CYCLES + 2;
	if (CYCLES < CYCLES_PER_FRAME) return 0;							// Not completed a frame.
	HWIEndFrame();														// End of FramMemorye code
	if (IE != 0) {														// if interrupts are enabled
		CPUInterrupt();
	}
	CYCLES = CYCLES - CYCLES_PER_FRAME;									// Adjust this frame rate.
//	CYCLES = CYCLES + RENDERING_CYCLES;									// Fix it back for the video generation.
	return NTSC_FRAMES_PER_SECOND;										// Return framMemorye rate.
}

// *******************************************************************************************************************************
//												Read/Write Memory
// *******************************************************************************************************************************

WORD16 CPUReadMemory(WORD16 address) {
	return ramMemory[address & RAMMASK];
}

void CPUWriteMemory(WORD16 address,WORD16 data) {
	__Write(address,data);
}

#ifdef INCLUDE_DEBUGGING_SUPPORT

void CPUEndRun(void) {	
}

// *******************************************************************************************************************************
//		Execute chunk of code, to either of two break points or framMemorye-out, return non-zero framMemorye rate on framMemorye, breakpoint 0
// *******************************************************************************************************************************

BYTE8 CPUExecute(WORD16 breakPoint1,WORD16 breakPoint2) { 
	do {
		BYTE8 r = CPUExecuteInstruction();											// Execute an instruction
		if (r != 0) return r; 														// FramMemorye out.
	} while (R[P] != breakPoint1 && R[P] != breakPoint2);								// Stop on breakpoint.
	return 0; 
}

// *******************************************************************************************************************************
//									Return address of breakpoint for step-over, or 0 if N/A
// *******************************************************************************************************************************

WORD16 CPUGetStepOverBreakpoint(void) {
	BYTE8 opcode = CPUReadMemory(R[P]);												// Current opcode.
	if (opcode >= 0xD0 && opcode <= 0xDF) return (R[P]+1) & 0xFFFF;					// If SEP Rx then step is one after.
	return 0;																		// Do a normal single step
}

// *******************************************************************************************************************************
//												Load a binary file into ROM
// *******************************************************************************************************************************

#include <stdio.h>

void CPULoadBinary(const char *fileName) {
	FILE *f = fopen(fileName,"rb");
	fread(ramMemory,1,32768,f);
	fclose(f);
}

// *******************************************************************************************************************************
//											Retrieve a snapshot of the processor
// *******************************************************************************************************************************

static CPUSTATUS s;																	// Status area

CPUSTATUS *CPUGetStatus(void) {
	s.d = D;s.df = DF;s.ie = IE;s.q = Q;s.t = T;s.x = X;s.p = P;
	for (int i = 0;i < 16;i++) s.r[i] = R[i];
	s.cycles = CYCLES;s.pc = R[P];
	return &s;
}

#endif
