// *******************************************************************************************************************************
// *******************************************************************************************************************************
//
//		Name:		sys_debug_vip.c
//		Purpose:	Debugger Code (System Dependent)
//		Date:		24th August 2019
//		Author:		Paul Robson (paul@robsons->org.uk)
//
// *******************************************************************************************************************************
// *******************************************************************************************************************************

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gfx.h"
#include "sys_processor.h"
#include "debugger.h"
#include "hardware.h"

static const char *_mnemonics[256] =
	#include "generated/_1802_mnemonics.h"

#define DBGC_ADDRESS 	(0x0F0)														// Colour scheme.
#define DBGC_DATA 		(0x0FF)														// (Background is in main.c)
#define DBGC_HIGHLIGHT 	(0xFF0)

// *******************************************************************************************************************************
//											This renders the debug screen
// *******************************************************************************************************************************

static const char *labels[] = { "D","DF","P","X","T","Q","IE","RP","RX","CY","BP", NULL };

static int colours[8] = { 0x000,0xF00,0x00F,0xF0F,0x0F0,0xFF0,0x0FF,0xFFF };

// {BLACK, RED, BLUE, VIOLET, GREEN, YELLOW, AQUA, WHITE};
void DBGXRender(int *address,int runMode) {
	int n = 0;
	char buffer[32];
	CPUSTATUS *s = CPUGetStatus();
	GFXSetCharacterSize(32,23);
	DBGVerticalLabel(15,0,labels,DBGC_ADDRESS,-1);									// Draw the labels for the register

	#define DN(v,w) GFXNumber(GRID(18,n++),v,16,w,GRIDSIZE,DBGC_DATA,-1)			// Helper macro

	n = 0;
	DN(s->d,2);DN(s->df,1);DN(s->p,1);DN(s->x,1);DN(s->t,2);DN(s->q,1);DN(s->ie,1);	// Registers
	DN(s->pc,4);DN(s->r[s->x],4);DN(s->cycles,4);DN(address[3],4);					// Others

	for (int i = 0;i < 16;i++) {													// 16 bit registers
		sprintf(buffer,"R%x",i);
		GFXString(GRID(i % 4 * 8,i/4+12),buffer,GRIDSIZE,DBGC_ADDRESS,-1);
		GFXString(GRID(i % 4 * 8+2,i/4+12),":",GRIDSIZE,DBGC_HIGHLIGHT,-1);
		GFXNumber(GRID(i % 4 * 8+3,i/4+12),s->r[i],16,4,GRIDSIZE,DBGC_DATA,-1);
	}

	int a = address[1];																// Dump Memory.
	for (int row = 17;row < 23;row++) {
		GFXNumber(GRID(2,row),a,16,4,GRIDSIZE,DBGC_ADDRESS,-1);
		GFXCharacter(GRID(6,row),':',GRIDSIZE,DBGC_HIGHLIGHT,-1);
		for (int col = 0;col < 8;col++) {
			GFXNumber(GRID(7+col*3,row),CPUReadMemory(a),16,2,GRIDSIZE,DBGC_DATA,-1);
			a = (a + 1) & 0xFFFF;
		}		
	}

	int p = address[0];																// Dump program code. 
	int opc;

	for (int row = 0;row < 11;row++) {
		int isPC = (p == ((s->pc) & 0xFFFF));										// Tests.
		int isBrk = (p == address[3]);
		GFXNumber(GRID(0,row),p,16,4,GRIDSIZE,isPC ? DBGC_HIGHLIGHT:DBGC_ADDRESS,	// Display address / highlight / breakpoint
																	isBrk ? 0xF00 : -1);
		opc = CPUReadMemory(p);p = (p + 1) & 0xFFFF;								// Read opcode.
		strcpy(buffer,_mnemonics[opc]);												// Work out the opcode.
		char *at = buffer+strlen(buffer)-2;											// 2nd char from end
		if (*at == '.') {															// Operand ?
			if (at[1] == '1') {
				sprintf(at,"%02x",CPUReadMemory(p));
				p = (p+1) & 0xFFFF;
			}
			else if (at[1] == '2') {
				sprintf(at,"%02x%02x",CPUReadMemory(p),CPUReadMemory(p+1));
				p = (p+2) & 0xFFFF;
			}
		}
		GFXString(GRID(5,row),buffer,GRIDSIZE,isPC ? DBGC_HIGHLIGHT:DBGC_DATA,-1);	// Print the mnemonic
	}

	if (runMode != 0) {
		SDL_Rect rc;
		rc.w = rc.h = 10;
		for (int x = 0;x < 16;x++) {
			for (int y = 0;y < 64;y++) {
				int fCol = colours[CPUReadMemory(x+y*16+0x2800) & 0x07];
				int bCol = 0x000;
				int pixel = CPUReadMemory(x+y*16+0x2000);
				rc.x = x * rc.w * 8 + (WIN_WIDTH-rc.w * 128) / 2;
				rc.y = y * rc.h + (WIN_HEIGHT-rc.h * 64) / 2;
				for (int xi = 0;xi < 8;xi++) {
					GFXRectangle(&rc,(pixel & 0x80) ? fCol:bCol);
					pixel = pixel << 1;
					rc.x += rc.w;
				}
			}
		}
	}
}	