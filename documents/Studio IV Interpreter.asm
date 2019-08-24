; Studio IV Interpreter final by Joe Weisbecker

; disassembled in Emma 02 from Weisbecker Collection cassette 
; tape S.572.21B_Studio_IV_Interpreter_final_1_of_1.wav

; The Sarnoff Collection, The College of New Jersey
; Extracted by Andy Modla 2/22/2018
; Comments by Marcel van Tongeren

; Memory Map:
; 0000 - 07FF System ROM 
; 0800 - 0FFF Cartridge ROM 1
; 1000 - 1FFF Cartridge ROM 2
; 2000 - 23FF Display RAM (SW changeable via RAM pointer on 27F2/27F3)
; 2400 - 26FF Not used or possibly RAM?
; 2700 - 27FF RAM used by System ROM
; 2800 - 2BFF Colour RAM, lower 3 or 4 bits used for colour indication
; 2C00 - FFFF Not used?

; I/O Map:
; Q: Sound on/off, frequency as defined by tone latch 
; EF3: Key pressed on selected port (key pad 1) 
; EF4: Key pressed on selected port (key pad 2) 
; OUT 1: Tone latch, which sets tone frequency 
; OUT 2: Select key / port 
; OUT 4&6: bit 0-2 background colour, bit 3 white foreground
; OUT 4&6: bit 4-5 enable graphics, bit 6 PAL/NTSC
; OUT 5&7: Signal video chip to enable DMA towards the 1802 to fetch display data

; Register usage
; R0 DMA pointer
; R1 Interrupt Routine program counter
; R2 Stack pointer
; R3 interpreter program counter
; R4 call routine program counter
; R5 pseudo code instruction pointer
; R6 Vx pointer
; R7 Vy pointer
; R8 
; R9 Random number
; RA
; RB Display page pointer
; RC
; RD
; RE I pointer
; RF
;
; Program Variables V0 to VF
; 27E0 - 27EF
;
; Interpreter variables
; 2700/2701 Temporary storage for I register
; 2702-270B Temporary storage for V0 to V9 via PUSH/POP commands
; 270B      Random number after using RND [270B] command
;
; 27F2/27F3 Display buffer address pointer
; 27F4      OUT 4 value
; 27F5		Number of vertical lines (0x40, 64)
; 27F6/27F7 I Pointer to memory 0000 to 3FFF
		
; Origin set to 00000H, EOF = 007FFH
		ORG  00000H

; CPU Type:
		CPU 1802

; Studio IV Pseudo code definition
; Addr. CODE    Emma 02 code	  Explanation
; ===== ====    ============      ===========
; 0293: 0aaa    LD I, 0aaa        Load I with address 0000 to 0FFF
;       1aaa    LD I, 1aaa        Load I with address 1000 to 1FFF
;       2aaa    LD I, 2aaa        Load I with address 2000 to 2FFF
;       3aaa    LD I, 3aaa        Load I with address 3000 to 3FFF
; 0100:
; 010B: 4x0y    LD B, [Vy], Vx	  Convert Vx to 3 digit decimal at [Vy+2700], [Vy+2701], [Vy+2702]
;               LD B, Vy, Vx
; 013E: 4x1y    OR Vx, Vy         Vx = Vx OR Vy
;       4x2y    AND Vx, Vy        Vx = Vx + Vy
;       4x3y    XOR Vx, Vy        Vx = Vx XOR Vy
;       4x4y    ADD Vx, Vy        Vx = Vx + Vy, VB is carry / not borrow
;       4x5y    SUB Vx, Vy        Vx = Vx - Vy, VB is carry / not borrow
; 0155: 4x6n    SHL Vx, n         Vx = Vx SHL n times, VB will contains bits shifted 'out of Vx'
; 0198: 4x7y    KEYP Vy           Wait for key and return key in Vy
;                                 VA contains keypad (0 key pad player 1, 1 keypad player 2)
; 								  VC = x << 3
;       4x8y    KEYR Vy           Wait for key press/release and return key in Vy
;                                 VA contains keypad (0 key pad player 1, 1 keypad player 2)
;                                 VC = x << 3
; 016D: 4x9n    SHR Vx, n         Vx = Vx SHR n times, VB will contains bits shifted 'out of Vx'
; 0128: 4xAy    ADDN Vx, Vy       ADD Nibbles, Vx-n0 = Vx-n0 + Vy-n0 and Vx-n1 = Vx-n1 + Vy-n1
;                                 (Vx-n0 is the lower 4 bits of Vx, Vx-n1 the higer 4 bits)
; 0183: 4.B.    JP I              Jump to address I
;				JP
; 018A: 4xCy    SHR Vx, Vy        Vx = (Vx SHR 3) AND 0xF, Vy =(Vy SHR 2) AND 0xF
; 0188: 4.D.    STOP              Wait in endless loop
; 01E0: 4xEn	DRW I, Vx, n      Draw pattern from [I] on screen position Vx, V(x+1) (128x64 positions),
;                                 width 8 pixels; n lines.
; 01CA: 4.Fy    KEY Vy            Check if key is pressed, if so return key in Vy and VB=1
;                                 (VB=0, no key pressed)
;                                 VA contains keypad (0 key pad player 1, 1 keypad player 2)
; 0300: 
; 0360: 5.0.    SYS I             Call 1802 routine at address I, end routine with SEP R4
; 031C: 5x1y    SWITCH Vx, Vy,[I] Switch value [I] and onwards with Vx until Vy
;               SWITCH Vx, Vy, I
; 0374: 5x2.    DRW I, Vx         Draw patterns from [I] on screen
; 								  size: 8*4 (w*h)
;								  Repeat horizontal: Vx high nibble
;								  Repeat vertical: Vx+1 high nibble
; 								  Screen position: Vx, Vx+1 low nibble (16x16 positions)
; 032E: 5x3y    JE I, Vx, Vy      IF Vx=Vy THEN jump to I
;               JE Vx, Vy
; 0337: 5x4y    JU I, Vx, Vy      IF Vx!=Vy THEN jump to I
;               JU Vx, Vy
; 036C: 5x5y    CLR Vx, Vy    	  Store colour Vy (lowest 4 bit) in colour RAM
; 								  size: 8*4 (w*h)
;								  Repeat horizontal: Vx high nibble
;								  Repeat vertical: Vx+1 high nibble
; 								  Screen position: Vx, Vx+1 low nibble (16x16 positions)
; 036F: 5x6c    CLR Vx, c         Store colour c in colour RAM
; 								  size: 8*4 (w*h)
;								  Repeat horizontal: Vx high nibble
;								  Repeat vertical: Vx+1 high nibble
; 								  Screen position: Vx, Vx+1 low nibble (16x16 positions)
; 0374: 5x7.    DRWR I, Vx        Draw pattern from [I] on screen and repeat the same pattern
; 								  size: 8*4 (w*h)
;								  Repeat horizontal: Vx high nibble
;								  Repeat vertical: Vx+1 high nibble
; 								  Screen position: Vx, Vx+1 low nibble (16x16 positions)
; 034A: 5.8y    JK I, Vy          IF KEY Vy is pressed THEN jump to I
;               JK Vy             VA contains keypad (0 key pad player 1, 1 keypad player 2)
; 0354: 5.9y    JNK I, Vy         IF KEY Vy not pressed THEN jump to I   
;               JNK Vy            VA contains keypad (0 key pad player 1, 1 keypad player 2)
; 033C: 5xAy    JG I, Vx, Vy      IF Vx > Vy THEN jump to I
;				JG Vx, Vy
; 0345: 5xBy    JS I, Vx, Vy      IF Vx < Vy THEN jump to I
;				JS Vx, Vy
; 0310: 5xCy    CP Vx, Vy, [I]    copy value Vx until Vy to [I] until [I+y]
;               CP Vx, Vy, I
; 0316: 5xDy    CP [I], Vx, Vy    copy value [I] until [I+y] to Vx until Vy
;               CP I, Vx, Vy
; 0326: 5xEy    LD [Vy], Vx       [VyV(y+1)]=Vx
; 03F8: 5xFy    LD Vx, [Vy]  	  Vx=[VyV(y+1)]
; 0400: 
; 046A: 60kk    CALL 10kk		  Call subroutine on 10kk, return with 6B.. (RET)
; 0478: 61kk    CALL 11kk		  Call subroutine on 11kk, return with 6B.. (RET) 
; 0406: 62kk    ADD I, kk         Add kk to Low byte of I; no carry to high byte is done
; 040E: 63kk    LD I, [27kk]      LD I with high byte from [27kk] and low byte from [27kk+1]
;       63Ey    LD I, Vy, Vy+1    LD I with high byte from Vy and low byte from Vy+1 
; 0419: 64kk    LD [27kk], I      LD I high byte to [27kk] and low byte to [27kk+1]
;       64Ey    LD Vy, Vy+1, I    LD Vy with high byte from I and Vy+1 with low byte from I
; 0420: 65kk    JP kk             Jump to kk in same page 
; 047D: 66kk    CALL 06kk         Call subroutine on 6kk, return with 6B.. (RET)
; 0600: 6600	PUSH V0-V9		  PUSH (save) V0 to V9 on 2702-270B
;				PUSH
; 060A: 660A 	POP V0-V9		  POP (get) V0 to V9 from 2702-270B
;				POP
; 0612: 6612 	SCR CLS 		  Print 8*4 pattern from 0575-0578 (zeros) on screen with DRWR I, Vx,
;                                 address following subroutine call contains:
;				CLS				  byte 1: Vx value
; 								  byte 2: Vx+1 value
; 0626: 6626 	SCR FILL		  Print 8*4 pattern from 05FC-05FF (#ff) on screen with DRWR I, Vx,
;                                 address following subroutine call contains:
; 								  byte 1: Vx value
; 								  byte 2: Vx+1 value
; 062C: 662C 	CHAR [I], V0, V1  Print character stored on [I] on screen position horizontal V0, vertical V1
;				CHAR [I]
; 062E: 662E 	CHAR [V2V3],V0,V1 Print character stored on [V2V3] on screen position horizontal V0, vertical V1
;				CHAR [V2V3]		
; 0648: 6648 	PRINT			  Print characters on screen, address following subroutine call contains:
; 								  byte 1: horizontal position on screen (0 to 128)
; 								  byte 2: vertical position on screen (0 to 64)
; 								  byte 3 and onwards: character number as on 05nn see 0500-052F table.
;								  last byte 0xFF
; 0656: 6656 	PRINT [I]		  Print characters on screen, [I] contains:
; 				PRINT I           byte 1: horizontal position on screen (0 to 128)
; 								  byte 2: vertical position on screen (0 to 64)
; 								  byte 3 and onwards: character number as on 05nn see 0500-052F table.
;								  last byte 0xFF
; 0660: 6660 	PRINT D, 3		  Print decimal value of V9 (3 digits) on screen, address following subroutine
;                                 call contains:
; 								  byte 1: horizontal position on screen (0 to 128)
; 								  byte 2: vertical position on screen (0 to 64)
; 067C: 667C 	PRINT D, 2		  Print decimal value of V9 (2 digits) on screen, address following subroutine
;                                 call contains:
; 								  byte 1: horizontal position on screen (0 to 128)
; 								  byte 2: vertical position on screen (0 to 64)
; 0682: 6682 	PRINT D, 1  	  Print decimal value of V9 (1 digit) on screen, address following subroutine
;                                 call contains:
; 								  byte 1: horizontal position on screen (0 to 128)
; 								  byte 2: vertical position on screen (0 to 64)
; 0688: 6688 	CLR				  Colour 2 blocks on the screen with CLR Vx, Vy, address following subroutine
;                                 call contains:
; 								  byte 1/2: Screen position first CLR command (Vx and Vx+1)
; 								  byte 3/4: Screen position second CLR command (Vx and Vx+1)
; 								  byte 5: Colour first CLR command (Vy)
; 								  byte 6: Colour second CLR command (Vy)
; 								  If byte 6 highest nible is not 0 then 2 more blocks in following 6 bytes
;                                 will be coloured.
;								  (Code on 0424-0432 and 04CE-04D1 is part of this routine)
; 0690: 6690 	CP [I]			  Copy to [I] from memory after subroutine call, number of bytes stored in V9
;								  (Code on 04D4-04EB is part of this routine)
; 047D: 67kk    CALL 07kk		  Call subroutine on 7kk, return with 6B.. (RET)
; 0700:	6700 	RESET RAM		  Reset 2700-279F to 0
; 070B: 670B 	SCR XOR			  XOR Screen memory with 0xFF
; 071C: 671C 	KEY SWITCH		  Key switch subroutine
; 								  Following bytes are used as input:
; 								  byte 1: First key
; 								  byte 2: Last key
; 								  byte 3/4: return address if no key pressed
; 								  following bytes contain jump table for the pressed keys, first two byte key 0,
;                                 next 2 key 1 etc.
; 0754: 6754 	ADD [V0V1],[V2V3] Add decimal values [V0V1] and [V2V3] store result on [V0V1]
;				ADD V0V1, V2V3	  Number of digits stored in V9.
;								  LSD is on V0V1 and V2V3, following digit is on one address lower
; 								  Each address (byte) only contains one decimal digit
; 075A: 675A 	SUB [V0V1],[V2V3] Subtract decimal values [V2V3] from [V0V1] store result on [V0V1]
;				SUB V0V1, V2V3    Number of digits stored in V9.
;								  LSD is on V0V1 and V2V3, following on one address lower
; 								  Each address (byte) only contains one decimal digit
; 078E: 678E 	ADD I, V9		  I = I + V9
; 079C: 679C 	LD I, [I+V9]	  I = [I+V9]
; 079E: 679E 	LD I, [I]		  I = [I]
; 07AA: 67AA 	KEY WAIT		  Wait for key from either keypad and return key in V9, VA indicates keypad
; 07B6: 67B6 	RND [270B], V9	  Store random number between 0 and V9 on [270B]
;				RND V9						  
; 07BC: 67BC 	RND [270B],V8,V9  Store random number between V8 and V9 on [270B]
; 				RND V8, V9
; 047D: 68kk    CALL 08kk		  Call subroutine on 8kk, return with 6B.. (RET)  
; 0434: 69kk    CALL I, kk        Call subroutine on I, V9=kk, return with 6B.. (RET)
; 0449: 6A..    PUSH I            Store value I on stack
; 0444: 6B..    RET               Return from subrouting (any CALL)
; 0450: 6C..    POP I             Load I from stack
; 04A0: 6Dkk    WAIT [I], kk	  WAIT with a value kk, using [I] towards a table on 049h and 048l where hl is
;                                 the byte on [I]
; 045A: 6E.y    OUT4 Vy        	  OUT 4 with value Vx, 0x27F4 = Vx
; 0462: 6Fkk    OUT4 kk           OUT 4 with value kk, 0x27F4 = kk
; 01DD: 7xkk    ADD Vx, kk        Vx=Vx+kk
; 0289: 8xkk    JZ Vx, kk         Jump if variable Vx is zero to current page with offset kk
; 028F: 9xkk    JNZ Vx, kk        Jump if variable Vx is not zero to current page with offset kk
; 03EB: Axkk    JE I, Vx, kk      Jump to I if Vx = kk
;				JE Vx, kk
; 03F1: Bxkk    JNE I, Vx, kk     Jump to I if Vx != kk
;				JNE Vx, kk
; 0272: Cxkk    RND Vx, kk        Vx = random byte masked by kk
; 02D2: Dxkk    LD [27kk], Vx     Load address [27kk] with Vx
; 02D7: Exkk    LD Vx, [27kk]	  Load Vx with value on address [27kk]
; 029E: Fxkk    LD Vx, kk         Vx = kk

; Labels:
MAIN_OPCODE_LOOP	EQU 0016H
R0047	EQU 0047H
R0048	EQU 0048H
R006C	EQU 006CH
R007E	EQU 007EH
R0089	EQU 0089H
R008E	EQU 008EH
R00F3	EQU 00F3H
R0113	EQU 0113H
R0116	EQU 0116H
R0121	EQU 0121H
R013A	EQU 013AH
R015E	EQU 015EH
R0162	EQU 0162H
R0176	EQU 0176H
R017A	EQU 017AH
OPCODE0123 EQU 0293H
OPCODE4		EQU 0100H
OPCODE4-0	EQU 010BH
OPCODE4-12345	EQU 013EH
OPCODE4-6 	EQU 0155H
OPCODE4-78 	EQU 0198H
OPCODE4-9 	EQU 016DH
OPCODE4-A	EQU 0128H
OPCODE4-B 	EQU 0183H
OPCODE4-C 	EQU 018AH
OPCODE4-D 	EQU 0188H
OPCODE4-E 	EQU 01E0H
OPCODE4-F 	EQU 01CAH
OPCODE5 	EQU 0300H
OPCODE6		EQU 0400H
OPCODE7 	EQU 01DDH
OPCODE8 	EQU 0289H
OPCODE9 	EQU 028FH
OPCODEC 	EQU 0272H
OPCODED 	EQU 02D2H
OPCODEF 	EQU 029EH
R019B	EQU 019BH
R01AE	EQU 01AEH
R01B6	EQU 01B6H
R01B9	EQU 01B9H
R01C3	EQU 01C3H
R01C7	EQU 01C7H
R01D7	EQU 01D7H
R01FE	EQU 01FEH
R0202	EQU 0202H
R020B	EQU 020BH
R0212	EQU 0212H
R0219	EQU 0219H
R021E	EQU 021EH
R022A	EQU 022AH
R0232	EQU 0232H
R0243	EQU 0243H
R024E	EQU 024EH
R025E	EQU 025EH
R0262	EQU 0262H
R026F	EQU 026FH
R028C	EQU 028CH
R028E	EQU 028EH
R02A8	EQU 02A8H
R02AD	EQU 02ADH
R02B7	EQU 02B7H
R02BB	EQU 02BBH
R02C1	EQU 02C1H
R02C5	EQU 02C5H
R0310	EQU 0310H
R0316	EQU 0316H
R031C	EQU 031CH
R0332	EQU 0332H
R0336	EQU 0336H
R0344	EQU 0344H
R0370	EQU 0370H
R0375	EQU 0375H
R038D	EQU 038DH
R039D	EQU 039DH
R03A1	EQU 03A1H
R03B1	EQU 03B1H
R03B7	EQU 03B7H
R03BA	EQU 03BAH
R03BE	EQU 03BEH
R03D4	EQU 03D4H
R03DC	EQU 03DCH
R03E7	EQU 03E7H
R0413	EQU 0413H
R046D	EQU 046DH
R04A6	EQU 04A6H
R04BE	EQU 04BEH
R04BF	EQU 04BFH
R04C4	EQU 04C4H
R0703	EQU 0703H
R0711	EQU 0711H

; Unused or indirect labels:
; S004C
; S00F4
; S014D
; S01D3
; S0236
; S02A2
; S02C9
; S0313
; S0319
; S0323
; S035B
; S0367
; S037A
; S03EB
; S03F1

; Register Definitions:
R0		EQU 0
R1		EQU 1
R2		EQU 2
R3		EQU 3
R4		EQU 4
R5		EQU 5
R6		EQU 6
R7		EQU 7
R8		EQU 8
R9		EQU 9
RA		EQU 10
RB		EQU 11
RC		EQU 12
RD		EQU 13
RE		EQU 14
RF		EQU 15

; Start code segment
		GHI  R0              ;0000: 90          
		PHI  R4              ;0001: B4          
		PHI  R1              ;0002: B1          
		LDI  16H             ;0003: F8 16       
		PLO  R4              ;0005: A4          
		LDI  4FH             ;0006: F8 4F       
		PLO  R1              ;0008: A1          
		LDI  27H             ;0009: F8 27       
		PHI  R2              ;000B: B2          
		LDI  0BFH            ;000C: F8 BF       
		PLO  R2              ;000E: A2          
		LDI  02H             ;000F: F8 02       
		PHI  R5              ;0011: B5          
		LDI  0DCH            ;0012: F8 DC       
		PLO  R5              ;0014: A5          
		SEP  R4              ;0015: D4  
        
MAIN_OPCODE_LOOP
		LDI  27H             ;0016: F8 27       
		PHI  R6              ;0018: B6          
		PHI  R7              ;0019: B7          
		SEX  R2              ;001A: E2          
		LDI  0F6H            ;001B: F8 F6       
		PLO  R6              ;001D: A6          
		LDA  R6              ;001E: 46          
		PHI  RE              ;001F: BE          
		LDN  R6              ;0020: 06          
		PLO  RE              ;0021: AE          
		GHI  R4              ;0022: 94          
		PHI  RC              ;0023: BC          
		LDA  R5              ;0024: 45          
		PHI  RF              ;0025: BF          
		SHR                  ;0026: F6          
		SHR                  ;0027: F6          
		SHR                  ;0028: F6          
		SHR                  ;0029: F6          
		ORI  0D0H            ;002A: F9 D0       
		PLO  RC              ;002C: AC          
		GHI  RF              ;002D: 9F          
		ANI  0FH             ;002E: FA 0F       
		PHI  RF              ;0030: BF          
		ORI  0E0H            ;0031: F9 E0       
		PLO  R6              ;0033: A6          
		LDA  R5              ;0034: 45          
		PLO  RF              ;0035: AF          
		ANI  0FH             ;0036: FA 0F       
		ORI  0E0H            ;0038: F9 E0       
		PLO  R7              ;003A: A7          
		LDA  RC              ;003B: 4C          
		PHI  R3              ;003C: B3          
		GLO  RC              ;003D: 8C          
		ADI  0FH             ;003E: FC 0F       
		PLO  RC              ;0040: AC          
		LDN  RC              ;0041: 0C          
		PLO  R3              ;0042: A3          
		SEP  R3              ;0043: D3     
RET_AFTER_OPCODE
		BR   MAIN_OPCODE_LOOP;0044: 30 16       
		DB   00H             ;0046: 00
		
; Interrupt routine        
R0047
		REQ                  ;0047: 7A          
R0048
		LDI  0F9H            ;0048: F8 F9       
		PLO  R8              ;004A: A8          
		SEP  R8              ;004B: D8          
S004C
		SEX  R2              ;004C: E2          
		LDA  R2              ;004D: 42  
		RET                  ;004E: 70  	Return from interrupt         
		NOP                  ;004F: C4  	Entry point      
		DEC  R2              ;0050: 22          
		SAV                  ;0051: 78          
		DEC  R2              ;0052: 22          
		STR  R2              ;0053: 52          
		LDI  27H             ;0054: F8 27       
		PHI  R8              ;0056: B8          
		LDI  0F2H            ;0057: F8 F2       
		PLO  R8              ;0059: A8          
		LDA  R8              ;005A: 48          
		PHI  R0              ;005B: B0          
		SEX  R1              ;005C: E1          
		LDA  R8              ;005D: 48          
		PLO  R0              ;005E: A0  	R0 = Screen location in RAM on 27F2/27F3, normal case 0x2000        
		LDA  R8              ;005F: 48          
		ANI  40H             ;0060: FA 40       
		PHI  RA              ;0062: BA      RA.1 = OUT 4 value (from 27F4) AND 0x40, NTSC = 0 and PAL = 0x40    
		LDA  R8              ;0063: 48          
		PLO  RA              ;0064: AA      RA.0 = Number of vertical lines (0x40, 64) value from 27F5  
		INC  R9              ;0065: 19          
		SEX  R1              ;0066: E1          
		SEX  R1              ;0067: E1          
		SEX  R1              ;0068: E1          
		SEX  R1              ;0069: E1          
		SEX  R1              ;006A: E1          
		SEX  R1              ;006B: E1          
R006C
		GLO  R0              ;006C: 80    	Start of screen refresh routine   
		PLO  RB              ;006D: AB          
		DEC  RA              ;006E: 2A          
		OUT  5               ;006F: 65      Enable first burst of DMA outs by Video chip, 0x10 Bytes  
		DB   00H             ;0070: 00
		DEC  R0              ;0071: 20          
		GLO  RB              ;0072: 8B         
		PLO  R0              ;0073: A0      Reset R0    
		GHI  RA              ;0074: 9A          
		BZ   R007E           ;0075: 32 7E   Jump to 0x7E if NTSC and only do 2 visible lines for every pixel     
		OUT  5               ;0077: 65      Enable second burst (PAL only) of DMA outs by Video chip, 0x10 Bytes   
		DB   00H             ;0078: 00
		DEC  R0              ;0079: 20          
		GLO  RB              ;007A: 8B          
		PLO  R0              ;007B: A0      Reset R0    
		SEX  R1              ;007C: E1          
		SEX  R1              ;007D: E1          
R007E
		OUT  5               ;007E: 65       Enable second (NTSC) or third (PAL) burst of DMA outs by Video chip, 0x10 Bytes   
		DB   00H             ;007F: 00
		GLO  RA              ;0080: 8A          
		BNZ  R006C           ;0081: 3A 6C    Loop back to 0x6c until 64 lines are done.   
		LDI  03H             ;0083: F8 03       
		PLO  RB              ;0085: AB          
		LDI  0EFH            ;0086: F8 EF       
		PLO  R8              ;0088: A8          
R0089
		LDN  R8              ;0089: 08          
		PLO  RA              ;008A: AA          
		BZ   R008E           ;008B: 32 8E       
		DEC  RA              ;008D: 2A          
R008E
		GLO  RA              ;008E: 8A          
		STR  R8              ;008F: 58          
		DEC  R8              ;0090: 28          
		DEC  RB              ;0091: 2B          
		GLO  RB              ;0092: 8B          
		BNZ  R0089           ;0093: 3A 89       
		SEX  R8              ;0095: E8          
		LDN  R8              ;0096: 08          
		OUT  1               ;0097: 61       Set frequency   
		BZ   R0047           ;0098: 32 47       
		LDN  R8              ;009A: 08          
		BZ   R0047           ;009B: 32 47       
		SEQ                  ;009D: 7B          
		BR   R0048           ;009E: 30 48    

		
; Jump table command 4.n. to address 01xx
		DB   0BH             ;00A0: 0B
		DB   3EH             ;00A1: 3E
		DB   3EH             ;00A2: 3E
		DB   3EH             ;00A3: 3E
		DB   3EH             ;00A4: 3E
		DB   3EH             ;00A5: 3E
		DB   55H             ;00A6: 55
		DB   98H             ;00A7: 98
		DB   98H             ;00A8: 98
		DB   6DH             ;00A9: 6D
		DB   28H             ;00AA: 28
		DB   83H             ;00AB: 83
		DB   8AH             ;00AC: 8A
		DB   88H             ;00AD: 88
		DB   0E0H            ;00AE: E0
		DB   0CAH            ;00AF: CA

; Jump table command 5.n. to address 03xx
		DB   60H             ;00B0: 60
		DB   1CH             ;00B1: 1C
		DB   74H             ;00B2: 74
		DB   2EH             ;00B3: 2E
		DB   37H             ;00B4: 37
		DB   6CH             ;00B5: 6C
		DB   6FH             ;00B6: 6F
		DB   74H             ;00B7: 74
		DB   4AH             ;00B8: 4A
		DB   54H             ;00B9: 54
		DB   3CH             ;00BA: 3C
		DB   45H             ;00BB: 45
		DB   10H             ;00BC: 10
		DB   16H             ;00BD: 16
		DB   26H             ;00BE: 26
		DB   0F8H            ;00BF: F8

; Jump table command 6n..  to address 04xx
		DB   6AH             ;00C0: 6A
		DB   78H             ;00C1: 78
		DB   06H             ;00C2: 06
		DB   0EH             ;00C3: 0E
		DB   19H             ;00C4: 19
		DB   20H             ;00C5: 20
		DB   7DH             ;00C6: 7D
		DB   7DH             ;00C7: 7D
		DB   7DH             ;00C8: 7D
		DB   34H             ;00C9: 34
		DB   49H             ;00CA: 49
		DB   44H             ;00CB: 44
		DB   50H             ;00CC: 50
		DB   0A0H            ;00CD: A0
		DB   5AH             ;00CE: 5A
		DB   62H             ;00CF: 62
		
; Jump table for comand handling, high byte on Dx, low byt on Ex, x is first nibble of the command
		DB   02H             ;00D0: 02
		DB   02H             ;00D1: 02
		DB   02H             ;00D2: 02
		DB   02H             ;00D3: 02
		DB   01H             ;00D4: 01
		DB   03H             ;00D5: 03
		DB   04H             ;00D6: 04
		DB   01H             ;00D7: 01
		DB   02H             ;00D8: 02
		DB   02H             ;00D9: 02
		DB   03H             ;00DA: 03
		DB   03H             ;00DB: 03
		DB   02H             ;00DC: 02
		DB   02H             ;00DD: 02
		DB   02H             ;00DE: 02
		DB   02H             ;00DF: 02
		DB   93H             ;00E0: 93
		DB   93H             ;00E1: 93
		DB   93H             ;00E2: 93
		DB   93H             ;00E3: 93
		DB   00H             ;00E4: 00
		DB   00H             ;00E5: 00
		DB   00H             ;00E6: 00
		DB   0DDH            ;00E7: DD
		DB   89H             ;00E8: 89
		DB   8FH             ;00E9: 8F
		DB   0EBH            ;00EA: EB
		DB   0F1H            ;00EB: F1
		DB   72H             ;00EC: 72
		DB   0D2H            ;00ED: D2
		DB   0D7H            ;00EE: D7
		DB   9EH             ;00EF: 9E
		
; 3 bytes used for decimal conversions
		DB   64H             ;00F0: 64
		DB   0AH             ;00F1: 0A
		DB   01H             ;00F2: 01
		
R00F3
		SEP  R3              ;00F3: D3          
S00F4
		DEC  R2              ;00F4: 22          
		GLO  R6              ;00F5: 86          
		STR  R2              ;00F6: 52          
		SEX  R2              ;00F7: E2          
		GLO  R7              ;00F8: 87          
		XOR                  ;00F9: F3          
		INC  R6              ;00FA: 16          
		INC  RE              ;00FB: 1E          
		INC  R2              ;00FC: 12          
		BR   R00F3           ;00FD: 30 F3       
		DB   00H             ;00FF: 00

; Opcode: 4.n. Start routine, jump table on 00A0, jump on n.
OPCODE4
		GLO  RF              ;0100: 8F          
		SHR                  ;0101: F6          
		SHR                  ;0102: F6          
		SHR                  ;0103: F6          
		SHR                  ;0104: F6          
		SEX  R6              ;0105: E6          
		ORI  0A0H            ;0106: F9 A0       
		PLO  RC              ;0108: AC          
		LDN  RC              ;0109: 0C          
		PLO  R3              ;010A: A3          

; Opcode: 4x0y    LD B, [Vy], Vx	  Convert Vx to 3 digit decimal at [Vy+2700], [Vy+2701], [Vy+2702]
;                 LD B, Vy, Vx
OPCODE4-0
		LDN  R6              ;010B: 06          
		PHI  RF              ;010C: BF          
		LDI  0F0H            ;010D: F8 F0       
		PLO  RC              ;010F: AC          
		LDN  R7              ;0110: 07          
		PLO  R7              ;0111: A7          
		DEC  R7              ;0112: 27          
R0113
		INC  R7              ;0113: 17          
		GHI  R4              ;0114: 94          
		STR  R7              ;0115: 57          
R0116
		LDN  RC              ;0116: 0C          
		SD                   ;0117: F5          
		BNF  R0121           ;0118: 3B 21       
		STR  R6              ;011A: 56          
		LDN  R7              ;011B: 07          
		ADI  01H             ;011C: FC 01       
		STR  R7              ;011E: 57          
		BR   R0116           ;011F: 30 16       
R0121
		LDA  RC              ;0121: 4C          
		SHR                  ;0122: F6          
		BNF  R0113           ;0123: 3B 13       
		GHI  RF              ;0125: 9F          
		STR  R6              ;0126: 56          
		SEP  R4              ;0127: D4          

; Opcode: 4xAy    ADDN Vx, Vy       ADD Nibbles, Vx-n0 = Vx-n0 + Vy-n0 and Vx-n1 = Vx-n1 + Vy-n1
;                                   (Vx-n0 is the lower 4 bits of Vx, Vx-n1 the higer 4 bits)
OPCODE4-A
		LDN  R7              ;0128: 07          
		ADD                  ;0129: F4          
		ANI  0FH             ;012A: FA 0F       
		PHI  RC              ;012C: BC          
		LDN  R6              ;012D: 06          
		ANI  0F0H            ;012E: FA F0       
		STR  R6              ;0130: 56          
		LDN  R7              ;0131: 07          
		ANI  0F0H            ;0132: FA F0       
		ADD                  ;0134: F4          
		STR  R6              ;0135: 56          
		GHI  RC              ;0136: 9C          
		OR                   ;0137: F1          
		STR  R6              ;0138: 56          
		SEP  R4              ;0139: D4          
R013A
		GLO  RF              ;013A: 8F          
		ADD                  ;013B: F4          
		STR  R6              ;013C: 56          
		SEP  R4              ;013D: D4          

; Opcode: 4x1y    OR Vx, Vy         Vx = Vx OR Vy
;         4x2y    AND Vx, Vy        Vx = Vx + Vy
;         4x3y    XOR Vx, Vy        Vx = Vx XOR Vy
;         4x4y    ADD Vx, Vy        Vx = Vx + Vy, VB is carry / not borrow
;         4x5y    SUB Vx, Vy        Vx = Vx - Vy, VB is carry / not borrow
OPCODE4-12345
		DEC  R2              ;013E: 22          
		LDI  0D3H            ;013F: F8 D3       
		STR  R2              ;0141: 52          
		DEC  R2              ;0142: 22          
		GLO  RF              ;0143: 8F          
		SHR                  ;0144: F6          
		SHR                  ;0145: F6          
		SHR                  ;0146: F6          
		SHR                  ;0147: F6          
		ORI  0F0H            ;0148: F9 F0       
		STR  R2              ;014A: 52          
		LDN  R7              ;014B: 07          
		SEP  R2              ;014C: D2          
S014D
		STR  R6              ;014D: 56          
		LDI  0EBH            ;014E: F8 EB       
		PLO  R7              ;0150: A7          
		GHI  R4              ;0151: 94          
		SHLC                 ;0152: 7E          
		STR  R7              ;0153: 57          
		SEP  R4              ;0154: D4          

; Opcode: 4x6n    SHL Vx, n         Vx = Vx SHL n times, VB will contains bits shifted 'out of Vx'
OPCODE4-6
		GLO  RF              ;0155: 8F          
		ANI  0FH             ;0156: FA 0F       
		PLO  RF              ;0158: AF          
		LDI  0EBH            ;0159: F8 EB       
		PLO  R7              ;015B: A7          
		GHI  R4              ;015C: 94          
		STR  R7              ;015D: 57          
R015E
		GLO  RF              ;015E: 8F          
		BNZ  R0162           ;015F: 3A 62       
		SEP  R4              ;0161: D4          
R0162
		LDN  R6              ;0162: 06          
		SHL                  ;0163: FE          
		STR  R6              ;0164: 56          
		LDN  R7              ;0165: 07          
		SHLC                 ;0166: 7E          
		STR  R7              ;0167: 57          
		DEC  RF              ;0168: 2F          
		BR   R015E           ;0169: 30 5E       
		DB   00H             ;016B: 00
		DB   00H             ;016C: 00

; Opcode: 4x9n    SHR Vx, n         Vx = Vx SHR n times, VB will contains bits shifted 'out of Vx'
OPCODE4-9
		GLO  RF              ;016D: 8F          
		ANI  0FH             ;016E: FA 0F       
		PLO  RF              ;0170: AF          
		LDI  0EBH            ;0171: F8 EB       
		PLO  R7              ;0173: A7          
		GHI  R4              ;0174: 94          
		STR  R7              ;0175: 57          
R0176
		GLO  RF              ;0176: 8F          
		BNZ  R017A           ;0177: 3A 7A       
		SEP  R4              ;0179: D4          
R017A
		LDN  R6              ;017A: 06          
		SHR                  ;017B: F6          
		STR  R6              ;017C: 56          
		LDN  R7              ;017D: 07          
		SHRC                 ;017E: 76          
		STR  R7              ;017F: 57          
		DEC  RF              ;0180: 2F          
		BR   R0176           ;0181: 30 76       

; Opcode: 4.B.    JP I              Jump to address I
; 				  JP
		GHI  RE              ;0183: 9E          
		PHI  R5              ;0184: B5          
		GLO  RE              ;0185: 8E          
		PLO  R5              ;0186: A5          
		SEP  R4              ;0187: D4          

; Opcode: 4.D.    STOP              Wait in endless loop
OPCODE4-D
		BR   OPCODE4-D       ;0188: 30 88       

; Opcode: 4xCy    SHR Vx, Vy        Vx = (Vx SHR 3) AND 0xF, Vy =(Vy SHR 2) AND 0xF
OPCODE4-C
		LDN  R6              ;018A: 06          
		SHR                  ;018B: F6          
		SHR                  ;018C: F6          
		SHR                  ;018D: F6          
		ANI  0FH             ;018E: FA 0F       
		STR  R6              ;0190: 56          
		LDN  R7              ;0191: 07          
		SHR                  ;0192: F6          
		SHR                  ;0193: F6          
		ANI  0FH             ;0194: FA 0F       
		STR  R7              ;0196: 57          
		SEP  R4              ;0197: D4          

; Opcode: 4x7y    KEYP Vy           Wait for key and return key in Vy
;                                   VA contains keypad (0 key pad player 1, 1 keypad player 2)
; 	  		  					    VC = x << 3
;         4x8y    KEYR Vy           Wait for key press/release and return key in Vy
;                                   VA contains keypad (0 key pad player 1, 1 keypad player 2)
;                                   VC = x << 3
OPCODE4-78
		LDI  02H             ;0198: F8 02       
		PHI  RC              ;019A: BC          
R019B
		LDI  0A2H            ;019B: F8 A2       
		PLO  RC              ;019D: AC          
		SEP  RC              ;019E: DC          
		BDF  R019B           ;019F: 33 9B       
		STR  R7              ;01A1: 57          
		LDI  0ECH            ;01A2: F8 EC       
		PLO  R7              ;01A4: A7          
		GHI  RF              ;01A5: 9F          
		SHL                  ;01A6: FE          
		SHL                  ;01A7: FE          
		SHL                  ;01A8: FE          
		STR  R7              ;01A9: 57          
		INC  R7              ;01AA: 17          
		LDI  05H             ;01AB: F8 05       
		STR  R7              ;01AD: 57          
R01AE
		LDN  R7              ;01AE: 07          
		BNZ  R01AE           ;01AF: 3A AE       
		GLO  RF              ;01B1: 8F          
		SHL                  ;01B2: FE          
		BDF  R01B6           ;01B3: 33 B6       
		SEP  R4              ;01B5: D4          
R01B6
		LDI  05H             ;01B6: F8 05       
		STR  R7              ;01B8: 57          
R01B9
		LDN  R6              ;01B9: 06          
		SHR                  ;01BA: F6          
		BDF  R01C3           ;01BB: 33 C3       
		BN3  R01C7           ;01BD: 3E C7       
		B3   R01B6           ;01BF: 36 B6       
		BR   R01C7           ;01C1: 30 C7       
R01C3
		BN4  R01C7           ;01C3: 3F C7       
		B4   R01B6           ;01C5: 37 B6       
R01C7
		BQ   R01B9           ;01C7: 31 B9       
		SEP  R4              ;01C9: D4          

; Opcode: 4.Fy    KEY Vy            Check if key is pressed, if so return key in Vy and VB=1
;                                   (VB=0, no key pressed)
;                                   VA contains keypad (0 key pad player 1, 1 keypad player 2)

		LDI  02H             ;01CA: F8 02       
		PHI  RC              ;01CC: BC          
		LDI  0A2H            ;01CD: F8 A2       
		PLO  RC              ;01CF: AC          
		GHI  R4              ;01D0: 94          
		PLO  RF              ;01D1: AF          
		SEP  RC              ;01D2: DC          
S01D3
		BDF  R01D7           ;01D3: 33 D7       
		INC  RF              ;01D5: 1F          
		STR  R7              ;01D6: 57          
R01D7
		LDI  0EBH            ;01D7: F8 EB       
		PLO  R7              ;01D9: A7          
		GLO  RF              ;01DA: 8F          
		STR  R7              ;01DB: 57          
		SEP  R4              ;01DC: D4      
		
; Opcode: 7xkk    ADD Vx, kk        Vx=Vx+kk
OPCODE7
		SEX  R6              ;01DD: E6          
		BR   R013A           ;01DE: 30 3A       

; Opcode: 4xEn	DRW I, Vx, n      Draw pattern from [I] on screen position Vx, V(x+1) (128x64 positions),
;                                 width 8 pixels; n lines.
OPCODE4-E
		SEX  R2              ;01E0: E2          
		DEC  R2              ;01E1: 22          
		LDN  R6              ;01E2: 06          
		ANI  07H             ;01E3: FA 07       
		PHI  R7              ;01E5: B7          
		LDA  R6              ;01E6: 46          
		ANI  7FH             ;01E7: FA 7F       
		SHR                  ;01E9: F6          
		SHR                  ;01EA: F6          
		SHR                  ;01EB: F6          
		STR  R2              ;01EC: 52          
		GLO  RF              ;01ED: 8F          
		ANI  0FH             ;01EE: FA 0F       
		PHI  RF              ;01F0: BF          
		LDI  20H             ;01F1: F8 20       
		PLO  RF              ;01F3: AF          
		LDN  R6              ;01F4: 06          
		ANI  3FH             ;01F5: FA 3F       
		SHL                  ;01F7: FE          
		SHL                  ;01F8: FE          
		SHL                  ;01F9: FE          
		BNF  R01FE           ;01FA: 3B FE       
		INC  RF              ;01FC: 1F          
		INC  RF              ;01FD: 1F          
R01FE
		SHL                  ;01FE: FE          
		BNF  R0202           ;01FF: 3B 02       
		INC  RF              ;0201: 1F          
R0202
		ADD                  ;0202: F4          
		PLO  RC              ;0203: AC          
		GLO  RF              ;0204: 8F          
		PHI  RC              ;0205: BC          
		LDI  0C0H            ;0206: F8 C0       
		PLO  R6              ;0208: A6          
		GHI  RF              ;0209: 9F          
		PLO  RF              ;020A: AF          
R020B
		GHI  R4              ;020B: 94          
		PLO  RD              ;020C: AD          
		GLO  RF              ;020D: 8F          
		BNZ  R0219           ;020E: 3A 19       
		GHI  RF              ;0210: 9F          
		PLO  RF              ;0211: AF          
R0212
		GLO  RF              ;0212: 8F          
		BZ   R0232           ;0213: 32 32       
		DEC  RE              ;0215: 2E          
		DEC  RF              ;0216: 2F          
		BR   R0212           ;0217: 30 12       
R0219
		DEC  RF              ;0219: 2F          
		LDA  RE              ;021A: 4E          
		PHI  RD              ;021B: BD          
		GHI  R7              ;021C: 97          
		PLO  R7              ;021D: A7          
R021E
		GLO  R7              ;021E: 87          
		BZ   R022A           ;021F: 32 2A       
		GHI  RD              ;0221: 9D          
		SHR                  ;0222: F6          
		PHI  RD              ;0223: BD          
		GLO  RD              ;0224: 8D          
		SHRC                 ;0225: 76          
		PLO  RD              ;0226: AD          
		DEC  R7              ;0227: 27          
		BR   R021E           ;0228: 30 1E       
R022A
		GHI  RD              ;022A: 9D          
		STR  R6              ;022B: 56          
		INC  R6              ;022C: 16          
		GLO  RD              ;022D: 8D          
		STR  R6              ;022E: 56          
		INC  R6              ;022F: 16          
		BR   R020B           ;0230: 30 0B       
R0232
		LDI  0F0H            ;0232: F8 F0       
		PLO  R6              ;0234: A6          
		SEP  R6              ;0235: D6          
S0236
		SEX  RC              ;0236: EC          
		LDI  0C0H            ;0237: F8 C0       
		PLO  R6              ;0239: A6          
		GHI  R6              ;023A: 96          
		PHI  RD              ;023B: BD          
		LDI  0F8H            ;023C: F8 F8       
		PLO  RD              ;023E: AD          
		GHI  R4              ;023F: 94          
		STR  RD              ;0240: 5D          
		GHI  RF              ;0241: 9F          
		PLO  RF              ;0242: AF          
R0243
		GLO  RF              ;0243: 8F          
		BZ   R026F           ;0244: 32 6F       
		LDN  R6              ;0246: 06          
		AND                  ;0247: F2          
		DEC  RF              ;0248: 2F          
		BZ   R024E           ;0249: 32 4E       
		LDI  01H             ;024B: F8 01       
		STR  RD              ;024D: 5D          
R024E
		LDA  R6              ;024E: 46          
		XOR                  ;024F: F3          
		STR  RC              ;0250: 5C          
		LDN  R2              ;0251: 02          
		XRI  0FH             ;0252: FB 0F       
		BZ   R0262           ;0254: 32 62       
		INC  RC              ;0256: 1C          
		LDN  R6              ;0257: 06          
		AND                  ;0258: F2          
		BZ   R025E           ;0259: 32 5E       
		LDI  01H             ;025B: F8 01       
		STR  RD              ;025D: 5D          
R025E
		LDN  R6              ;025E: 06          
		XOR                  ;025F: F3          
		STR  RC              ;0260: 5C          
		DEC  RC              ;0261: 2C          
R0262
		INC  R6              ;0262: 16          
		GLO  RC              ;0263: 8C          
		ADI  10H             ;0264: FC 10       
		PLO  RC              ;0266: AC          
		GHI  RC              ;0267: 9C          
		ADCI 00H             ;0268: 7C 00       
		PHI  RC              ;026A: BC          
		XRI  24H             ;026B: FB 24       
		BNZ  R0243           ;026D: 3A 43       
R026F
		INC  R2              ;026F: 12          
		SEP  R4              ;0270: D4          
		DB   00H             ;0271: 00
		
; Opcode: Cxkk    RND Vx, kk        Vx = random byte masked by kk
OPCODEC
		INC  R9              ;0272: 19          
		GLO  R9              ;0273: 89          
		PLO  RE              ;0274: AE          
		SHR                  ;0275: F6          
		SHR                  ;0276: F6          
		SHR                  ;0277: F6          
		SHR                  ;0278: F6          
		SHR                  ;0279: F6          
		SHR                  ;027A: F6          
		PHI  RE              ;027B: BE          
		GHI  R9              ;027C: 99          
		SEX  RE              ;027D: EE          
		ADD                  ;027E: F4          
		STR  R6              ;027F: 56          
		SHR                  ;0280: F6          
		SEX  R6              ;0281: E6          
		ADD                  ;0282: F4          
		PHI  R9              ;0283: B9          
		STR  R6              ;0284: 56          
		GLO  RF              ;0285: 8F          
		AND                  ;0286: F2          
		STR  R6              ;0287: 56          
		SEP  R4              ;0288: D4       
		
; Opcode: 8xkk    JZ Vx, kk         Jump if variable Vx is zero to current page with offset kk
OPCDOE8
		LDN  R6              ;0289: 06          
		BNZ  R028E           ;028A: 3A 8E       
R028C
		GLO  RF              ;028C: 8F          
		PLO  R5              ;028D: A5          
R028E
		SEP  R4              ;028E: D4          
		
; Opcode: 9xkk    JNZ Vx, kk        Jump if variable Vx is not zero to current page with offset kk
OPCDOE9
		LDN  R6              ;028F: 06          
		BNZ  R028C           ;0290: 3A 8C       
		SEP  R4              ;0292: D4          

; Opcode: 0aaa    LD I, 0aaa        Load I with address 0000 to 0FFF
;         1aaa    LD I, 1aaa        Load I with address 1000 to 1FFF
;         2aaa    LD I, 2aaa        Load I with address 2000 to 2FFF
;         3aaa    LD I, 3aaa        Load I with address 3000 to 3FFF
OPCODE0123
		LDI  0F6H            ;0293: F8 F6       
		PLO  R6              ;0295: A6          
		DEC  R5              ;0296: 25          
		DEC  R5              ;0297: 25          
		LDA  R5              ;0298: 45          
		STR  R6              ;0299: 56          
		INC  R6              ;029A: 16          
		LDA  R5              ;029B: 45          
		STR  R6              ;029C: 56          
		SEP  R4              ;029D: D4    
		
; Opcode: Fxkk    LD Vx, kk         Vx = kk
OPCODEF
		GLO  RF              ;029E: 8F          
		STR  R6              ;029F: 56          
		SEP  R4              ;02A0: D4          
		DB   00H             ;02A1: 00
S02A2
		LDI  0EAH            ;02A2: F8 EA       
		PLO  R6              ;02A4: A6          
		LDI  0FH             ;02A5: F8 0F       
		PLO  RD              ;02A7: AD          
R02A8
		DEC  R2              ;02A8: 22          
		SEX  R2              ;02A9: E2          
		GLO  RD              ;02AA: 8D          
		STR  R2              ;02AB: 52          
		OUT  2               ;02AC: 62          
R02AD
		LDN  R6              ;02AD: 06          
		SHR                  ;02AE: F6          
		BDF  R02B7           ;02AF: 33 B7       
		BN3  R02BB           ;02B1: 3E BB       
		B3   R02C5           ;02B3: 36 C5       
		BR   R02BB           ;02B5: 30 BB       
R02B7
		BN4  R02BB           ;02B7: 3F BB       
		B4   R02C5           ;02B9: 37 C5       
R02BB
		GLO  RD              ;02BB: 8D          
		BZ   R02C1           ;02BC: 32 C1       
		DEC  RD              ;02BE: 2D          
		BR   R02A8           ;02BF: 30 A8       
R02C1
		LDI  01H             ;02C1: F8 01       
		SHR                  ;02C3: F6          
		SEP  R3              ;02C4: D3          
R02C5
		GHI  R4              ;02C5: 94          
		SHR                  ;02C6: F6          
		GLO  RD              ;02C7: 8D          
		SEP  R3              ;02C8: D3          
S02C9
		LDI  0EAH            ;02C9: F8 EA       
		PLO  R6              ;02CB: A6          
		SEX  R7              ;02CC: E7          
		OUT  2               ;02CD: 62          
		GHI  R4              ;02CE: 94          
		PLO  RD              ;02CF: AD          
		BR   R02AD           ;02D0: 30 AD    
		
; Opcode: Dxkk    LD [27kk], Vx     Load address [27kk] with Vx
OPCODED
		GLO  RF              ;02D2: 8F          
		PLO  R7              ;02D3: A7          
		LDN  R6              ;02D4: 06          
		STR  R7              ;02D5: 57          
		SEP  R4              ;02D6: D4          
		
; Opcode: Exkk    LD Vx, [27kk]	  Load Vx with value on address [27kk]
		GLO  RF              ;02D7: 8F          
		PLO  R7              ;02D8: A7          
		LDN  R7              ;02D9: 07          
		STR  R6              ;02DA: 56          
		SEP  R4              ;02DB: D4          

; 02DC-02FE Studio IV Psuedo code, Start-up routine, initializing RAM and registers, continues on 04F0
		DB   0FAH, 00H		 ;   02DC: LD    VA, 00        
		DB   0FCH, 7EH		 ;   02DE: LD    VC, 7E        
		DB   0FDH, 10H		 ;   02E0: LD    VD, 10        
		DB   0F0H, 00H		 ;   02E2: LD    V0, 00        
		DB   0F1H, 0D3H		 ;   02E4: LD    V1, D3        
		DB   0F2H, 20H		 ;   02E6: LD    V2, 20        
		DB   0F3H, 00H		 ;   02E8: LD    V3, 00        
		DB   0F4H, 00H		 ;   02EA: LD    V4, 00        
		DB   0F5H, 40H		 ;   02EC: LD    V5, 40        
		DB   27H, 0F0H		 ;   02EE: LD    I, 27F0       
		DB   50H, 0C5H		 ;   02F0: CP    V0, V5, [I]   
		DB   0F0H, 0D1H		 ;   02F2: LD    V0, D1        
		DB   0D0H, 0F9H		 ;   02F4: LD    [27F9], V0    
		DB   0FFH, 00H		 ;   02F6: LD    VF, 00        
		DB   0F6H, 00H		 ;   02F8: LD    V6, 00        
		DB   0F9H, 00H		 ;   02FA: LD    V9, 00        
		DB   04H, 0F0H		 ;   02FC: LD    I, 04F0       
		DB   4BH, 0BBH		 ;   02FE: JP    I 
		
; Opcode: 5.n. Start routine, jump table on 00B0, jump on n.
OPCODE5
		GHI  R4              ;0300: 94          
		PHI  RD              ;0301: BD          
		LDI  0F4H            ;0302: F8 F4       
		PLO  RD              ;0304: AD          
		GLO  RF              ;0305: 8F          
		SHR                  ;0306: F6          
		SHR                  ;0307: F6          
		SHR                  ;0308: F6          
		SHR                  ;0309: F6          
		SEX  R6              ;030A: E6          
		ORI  0B0H            ;030B: F9 B0       
		PLO  RC              ;030D: AC          
		LDN  RC              ;030E: 0C          
		PLO  R3              ;030F: A3          

; Opcode: 5xCy    CP Vx, Vy, [I]    copy value Vx until Vy to [I] until [I+y]
;                 CP Vx, Vy, I
R0310
		LDN  R6              ;0310: 06          
		STR  RE              ;0311: 5E          
		SEP  RD              ;0312: DD          
S0313
		BNZ  R0310           ;0313: 3A 10       
		SEP  R4              ;0315: D4          

; Opcode: 5xDy    CP [I], Vx, Vy    copy value [I] until [I+y] to Vx until Vy
;                 CP I, Vx, Vy
R0316
		LDN  RE              ;0316: 0E          
		STR  R6              ;0317: 56          
		SEP  RD              ;0318: DD          
S0319
		BNZ  R0316           ;0319: 3A 16       
		SEP  R4              ;031B: D4    
		
; Opcode: 5x1y    SWITCH Vx, Vy,[I] Switch value [I] and onwards with Vx until Vy
;                 SWITCH Vx, Vy, I
R031C
		LDN  RE              ;031C: 0E          
		PLO  RF              ;031D: AF          
		LDN  R6              ;031E: 06          
		STR  RE              ;031F: 5E          
		GLO  RF              ;0320: 8F          
		STR  R6              ;0321: 56          
		SEP  RD              ;0322: DD          
S0323
		BNZ  R031C           ;0323: 3A 1C       
		SEP  R4              ;0325: D4   
		
; Opcode: 5xEy    LD [Vy], Vx       [VyV(y+1)]=Vx
		LDA  R7              ;0326: 47          
		PHI  RE              ;0327: BE          
		LDN  R7              ;0328: 07          
		PLO  RE              ;0329: AE          
		LDN  R6              ;032A: 06          
		STR  RE              ;032B: 5E          
		SEP  R4              ;032C: D4          
		DB   00H             ;032D: 00
		
; Opcode: 5x3y    JE I, Vx, Vy      IF Vx=Vy THEN jump to I
;				  JE Vx, kk
		LDN  R7              ;032E: 07          
		XOR                  ;032F: F3          
		BNZ  R0336           ;0330: 3A 36       
R0332
		GHI  RE              ;0332: 9E          
		PHI  R5              ;0333: B5          
		GLO  RE              ;0334: 8E          
		PLO  R5              ;0335: A5          
R0336
		SEP  R4              ;0336: D4      
		
; Opcode: 5x4y    JU I, Vx, Vy      IF Vx!=Vy THEN jump to I
		LDN  R7              ;0337: 07          
		XOR                  ;0338: F3          
		BNZ  R0332           ;0339: 3A 32       
		SEP  R4              ;033B: D4          

; Opcode: 5xAy    JG I, Vx, Vy      IF Vx > Vy THEN jump to I
;				  JG Vx, Vy
		LDN  R7              ;033C: 07          
		XOR                  ;033D: F3          
		BZ   R0344           ;033E: 32 44       
		LDN  R7              ;0340: 07          
		SD                   ;0341: F5          
		BDF  R0332           ;0342: 33 32       
R0344
		SEP  R4              ;0344: D4   
		
; Opcode: 5xBy    JS I, Vx, Vy      IF Vx < Vy THEN jump to I
;				  JS Vx, Vy
		LDN  R7              ;0345: 07          
		SD                   ;0346: F5          
		BNF  R0332           ;0347: 3B 32       
		SEP  R4              ;0349: D4       
		
; Opcode: 5.8y    JK I, Vy          IF KEY Vy is pressed THEN jump to I
;                 JK Vy             VA contains keypad (0 key pad player 1, 1 keypad player 2)
		LDI  02H             ;034A: F8 02       
		PHI  RC              ;034C: BC          
		LDI  0C9H            ;034D: F8 C9       
		PLO  RC              ;034F: AC          
		SEP  RC              ;0350: DC          
		BNF  R0332           ;0351: 3B 32       
		SEP  R4              ;0353: D4       
		
; Opcode: 5.9y    JNK I, Vy         IF KEY Vy not pressed THEN jump to I   
;                 JNK Vy            VA contains keypad (0 key pad player 1, 1 keypad player 2)
		LDI  02H             ;0354: F8 02       
		PHI  RC              ;0356: BC          
		LDI  0C9H            ;0357: F8 C9       
		PLO  RC              ;0359: AC          
		SEP  RC              ;035A: DC          
S035B
		BDF  R0332           ;035B: 33 32       
		SEP  R4              ;035D: D4          
		DB   00H             ;035E: 00
		DB   00H             ;035F: 00
		
; Opcode: 5.0.    SYS I             Call 1802 routine at address I, end routine with SEP R4
		LDI  03H             ;0360: F8 03       
		PHI  RC              ;0362: BC          
		LDI  67H             ;0363: F8 67       
		PLO  RC              ;0365: AC          
		SEP  RC              ;0366: DC          
S0367
		GHI  RE              ;0367: 9E          
		PHI  R3              ;0368: B3          
		GLO  RE              ;0369: 8E          
		PLO  R3              ;036A: A3          
		SEP  R3              ;036B: D3          

; Opcode: 5x5y    CLR Vx, Vy    	Store colour Vy (lowest 4 bit) in colour RAM
; 		   						    size: 8*4 (w*h)
;								    Repeat horizontal: Vx high nibble
;								    Repeat vertical: Vx+1 high nibble
; 								    Screen position: Vx, Vx+1 low nibble (16x16 positions)
		LDN  R7              ;036C: 07          
		BR   R0370           ;036D: 30 70       
		
; Opcode: 5x6c    CLR Vx, c         Store colour c in colour RAM
; 								    size: 8*4 (w*h)
;								    Repeat horizontal: Vx high nibble
;								    Repeat vertical: Vx+1 high nibble
; 								    Screen position: Vx, Vx+1 low nibble (16x16 positions)
		GLO  RF              ;036F: 8F          
R0370
		ORI  0F0H            ;0370: F9 F0       
		BR   R0375           ;0372: 30 75 
		
; Opcode: 5x7.    DRWR I, Vx        Draw pattern from [I] on screen and repeat the same pattern
; 								    size: 8*4 (w*h)
;								    Repeat horizontal: Vx high nibble
;								    Repeat vertical: Vx+1 high nibble
; 								    Screen position: Vx, Vx+1 low nibble (16x16 positions)
; Opcode: 5x2.    DRW I, Vx         Draw patterns from [I] on screen
; 								    size: 8*4 (w*h)
;								    Repeat horizontal: Vx high nibble
;								    Repeat vertical: Vx+1 high nibble
; 								    Screen position: Vx, Vx+1 low nibble (16x16 positions)
		GHI  R4              ;0374: 94          
R0375
		PHI  RD              ;0375: BD          
		LDI  0F0H            ;0376: F8 F0       
		PLO  R7              ;0378: A7          
		SEP  R7              ;0379: D7          
S037A
		LDA  R6              ;037A: 46          
		PLO  RC              ;037B: AC          
		LDN  R6              ;037C: 06          
		PHI  RC              ;037D: BC          
		GLO  RC              ;037E: 8C          
		ANI  0FH             ;037F: FA 0F       
		DEC  R2              ;0381: 22          
		STR  R2              ;0382: 52          
		SEX  R2              ;0383: E2          
		LDI  20H             ;0384: F8 20       
		PLO  R6              ;0386: A6          
		GHI  RD              ;0387: 9D          
		BZ   R038D           ;0388: 32 8D       
		LDI  28H             ;038A: F8 28       
		PLO  R6              ;038C: A6          
R038D
		GHI  RC              ;038D: 9C          
		SHR                  ;038E: F6          
		SHR                  ;038F: F6          
		SHR                  ;0390: F6          
		SHR                  ;0391: F6          
		PLO  RD              ;0392: AD          
		GHI  RC              ;0393: 9C          
		SHL                  ;0394: FE          
		SHL                  ;0395: FE          
		SHL                  ;0396: FE          
		SHL                  ;0397: FE          
		SHL                  ;0398: FE          
		BNF  R039D           ;0399: 3B 9D       
		INC  R6              ;039B: 16          
		INC  R6              ;039C: 16          
R039D
		SHL                  ;039D: FE          
		BNF  R03A1           ;039E: 3B A1       
		INC  R6              ;03A0: 16          
R03A1
		ADD                  ;03A1: F4          
		PHI  RC              ;03A2: BC          
		GLO  R6              ;03A3: 86          
		PHI  R6              ;03A4: B6          
		GHI  RC              ;03A5: 9C          
		PLO  R6              ;03A6: A6          
		GLO  RF              ;03A7: 8F          
		ANI  40H             ;03A8: FA 40       
		PHI  RF              ;03AA: BF          
		GLO  RC              ;03AB: 8C          
		SHR                  ;03AC: F6          
		SHR                  ;03AD: F6          
		SHR                  ;03AE: F6          
		SHR                  ;03AF: F6          
		PLO  RF              ;03B0: AF          
R03B1
		GHI  R6              ;03B1: 96          
		PHI  R7              ;03B2: B7          
		GLO  R6              ;03B3: 86          
		PLO  R7              ;03B4: A7          
		GLO  RD              ;03B5: 8D          
		PHI  RC              ;03B6: BC          
R03B7
		LDI  04H             ;03B7: F8 04       
		PLO  RC              ;03B9: AC          
R03BA
		GHI  RD              ;03BA: 9D          
		BNZ  R03BE           ;03BB: 3A BE       
		LDA  RE              ;03BD: 4E          
R03BE
		STR  R7              ;03BE: 57          
		GLO  R7              ;03BF: 87          
		ADI  10H             ;03C0: FC 10       
		PLO  R7              ;03C2: A7          
		DEC  RC              ;03C3: 2C          
		GLO  RC              ;03C4: 8C          
		BNZ  R03BA           ;03C5: 3A BA       
		GHI  R7              ;03C7: 97          
		ADCI 00H             ;03C8: 7C 00       
		ANI  2BH             ;03CA: FA 2B       
		PHI  R7              ;03CC: B7          
		GHI  RF              ;03CD: 9F          
		BZ   R03D4           ;03CE: 32 D4       
		DEC  RE              ;03D0: 2E          
		DEC  RE              ;03D1: 2E          
		DEC  RE              ;03D2: 2E          
		DEC  RE              ;03D3: 2E          
R03D4
		GHI  RC              ;03D4: 9C          
		BZ   R03DC           ;03D5: 32 DC       
		SMI  01H             ;03D7: FF 01       
		PHI  RC              ;03D9: BC          
		BR   R03B7           ;03DA: 30 B7       
R03DC
		INC  R6              ;03DC: 16          
		GLO  R6              ;03DD: 86          
		ANI  0CFH            ;03DE: FA CF       
		PLO  R6              ;03E0: A6          
		GLO  RF              ;03E1: 8F          
		BZ   R03E7           ;03E2: 32 E7       
		DEC  RF              ;03E4: 2F          
		BR   R03B1           ;03E5: 30 B1       
R03E7
		INC  R2              ;03E7: 12          
		SEP  R4              ;03E8: D4          
		DB   00H             ;03E9: 00
		DB   00H             ;03EA: 00
		
; Opcode: Axkk    JE I, Vx, kk      Jump to I if Vx = kk
S03EB
		SEX  R6              ;03EB: E6          
		GLO  RF              ;03EC: 8F          
		XOR                  ;03ED: F3          
		BZ   R0332           ;03EE: 32 32       
		SEP  R4              ;03F0: D4   
		
; Opcode: Bxkk    JNE I, Vx, kk     Jump to I if Vx != kk
;				  JNE Vx, kk
S03F1
		SEX  R6              ;03F1: E6          
		GLO  RF              ;03F2: 8F          
		XOR                  ;03F3: F3          
		BNZ  R0332           ;03F4: 3A 32       
		SEP  R4              ;03F6: D4          
		DB   00H             ;03F7: 00
		
; Opcode: 5xFy    LD Vx, [Vy]  	  Vx=[VyV(y+1)]
		LDA  R7              ;03F8: 47          
		PHI  RE              ;03F9: BE          
		LDN  R7              ;03FA: 07          
		PLO  RE              ;03FB: AE          
		LDN  RE              ;03FC: 0E          
		STR  R6              ;03FD: 56          
		SEP  R4              ;03FE: D4          
		DB   00H             ;03FF: 00
		
; Opcode: 6n.. Start routine, jump table on 00C0, jump on n.
OPCODE6
		GHI  RF              ;0400: 9F          
		ORI  0C0H            ;0401: F9 C0       
		PLO  RC              ;0403: AC          
		LDN  RC              ;0404: 0C          
		PLO  R3              ;0405: A3   

; Opcode: 62kk    ADD I, kk         Add kk to Low byte of I; no carry to high byte is done
		LDI  0F7H            ;0406: F8 F7       
		PLO  R6              ;0408: A6          
		SEX  R6              ;0409: E6          
		GLO  RF              ;040A: 8F          
		ADD                  ;040B: F4          
		STR  R6              ;040C: 56          
		SEP  R4              ;040D: D4   
		
; Opcode: 63kk    LD I, [27kk]      LD I with high byte from [27kk] and low byte from [27kk+1]
;         63Ey    LD I, Vy, Vy+1    LD I with high byte from Vy and low byte from Vy+1 
		LDI  0F6H            ;040E: F8 F6       
		PLO  R7              ;0410: A7          
		GLO  RF              ;0411: 8F          
		PLO  R6              ;0412: A6          
R0413
		LDA  R6              ;0413: 46          
		STR  R7              ;0414: 57          
		INC  R7              ;0415: 17          
		LDN  R6              ;0416: 06          
		STR  R7              ;0417: 57          
		SEP  R4              ;0418: D4   
		
; Opcode: 64kk    LD [27kk], I      LD I high byte to [27kk] and low byte to [27kk+1]
;         64Ey    LD Vy, Vy+1, I    LD Vy with high byte from I and Vy+1 with low byte from I
		LDI  0F6H            ;0419: F8 F6       
		PLO  R6              ;041B: A6          
		GLO  RF              ;041C: 8F          
		PLO  R7              ;041D: A7          
		BR   R0413           ;041E: 30 13       
		
; Opcode: 65kk    JP kk             Jump to kk in same page 
		GLO  RF              ;0420: 8F          
		PLO  R5              ;0421: A5          
		SEP  R4              ;0422: D4          
		DB   00H             ;0423: 00
		DB   63H, 00H  		 ;   0424: LD    I, [2700]     
		DB   50H, 0D5H		 ;   0426: CP    [I], V0, V5   
		DB   62H, 06H		 ;   0428: ADD   I, 06         
		DB   50H, 54H		 ;   042A: CLR   V0, V4        
		DB   52H, 55H		 ;   042C: CLR   V2, V5        
		DB   45H, 94H		 ;   042E: SHR   V5, 4         
		DB   95H, 26H		 ;   0430: JNZ   V5, 26        
		DB   65H, 0CEH		 ;   0432: JP    CE            
		
; Opcode: 69kk    CALL I, kk        Call subroutine on I, V9=kk, return with 6B.. (RET)
		LDI  0E9H            ;0434: F8 E9       
		PLO  R6              ;0436: A6          
		GLO  RF              ;0437: 8F          
		STR  R6              ;0438: 56          
		DEC  R2              ;0439: 22          
		GLO  R5              ;043A: 85          
		STR  R2              ;043B: 52          
		DEC  R2              ;043C: 22          
		GHI  R5              ;043D: 95          
		STR  R2              ;043E: 52          
		GHI  RE              ;043F: 9E          
		PHI  R5              ;0440: B5          
		GLO  RE              ;0441: 8E          
		PLO  R5              ;0442: A5          
		SEP  R4              ;0443: D4
		
; Opcode: 6B..    RET               Return from subrouting (any CALL)
		LDA  R2              ;0444: 42          
		PHI  R5              ;0445: B5          
		LDA  R2              ;0446: 42          
		PLO  R5              ;0447: A5          
		SEP  R4              ;0448: D4          
		
; Opcode: 6A..    PUSH I            Store value I on stack
		DEC  R2              ;0449: 22          
		GLO  RE              ;044A: 8E          
		STR  R2              ;044B: 52          
		DEC  R2              ;044C: 22          
		GHI  RE              ;044D: 9E          
		STR  R2              ;044E: 52          
		SEP  R4              ;044F: D4          
		
; Opcode: 6C..    POP I             Load I from stack
		LDI  0F6H            ;0450: F8 F6       
		PLO  R6              ;0452: A6          
		LDA  R2              ;0453: 42          
		STR  R6              ;0454: 56          
		INC  R6              ;0455: 16          
		LDA  R2              ;0456: 42          
		STR  R6              ;0457: 56          
		SEP  R4              ;0458: D4          
		DB   00H             ;0459: 00
		
; Opcode: 6E.y    OUT4 Vy        	  OUT 4 with value Vx, 0x27F4 = Vx
		LDI  0F4H            ;045A: F8 F4       
		PLO  R6              ;045C: A6          
		SEX  R6              ;045D: E6          
		LDN  R7              ;045E: 07          
		STR  R6              ;045F: 56          
		OUT  4               ;0460: 64          
		SEP  R4              ;0461: D4          
		
; Opcode: 6Fkk    OUT4 kk           OUT 4 with value kk, 0x27F4 = kk
		LDI  0F4H            ;0462: F8 F4       
		PLO  R6              ;0464: A6          
		SEX  R6              ;0465: E6          
		GLO  RF              ;0466: 8F          
		STR  R6              ;0467: 56          
		OUT  4               ;0468: 64          
		SEP  R4              ;0469: D4    
		
; Opcode: 60kk    CALL 10kk		  Call subroutine on 10kk, return with 6B.. (RET)
		LDI  10H             ;046A: F8 10       
		PHI  RF              ;046C: BF          
R046D
		DEC  R2              ;046D: 22          
		GLO  R5              ;046E: 85          
		STR  R2              ;046F: 52          
		DEC  R2              ;0470: 22          
		GHI  R5              ;0471: 95          
		STR  R2              ;0472: 52          
		GHI  RF              ;0473: 9F          
		PHI  R5              ;0474: B5          
		GLO  RF              ;0475: 8F          
		PLO  R5              ;0476: A5          
		SEP  R4              ;0477: D4          
		
; Opcode: 61kk    CALL 11kk		  Call subroutine on 11kk, return with 6B.. (RET) 
		LDI  11H             ;0478: F8 11       
		PHI  RF              ;047A: BF          
		BR   R046D           ;047B: 30 6D       
		
; Opcode: 66kk    CALL 06kk       Call subroutine on 6kk, return with 6B.. (RET)
; Opcode: 67kk    CALL 07kk		  Call subroutine on 7kk, return with 6B.. (RET)
; Opcode: 68kk    CALL 08kk		  Call subroutine on 8kk, return with 6B.. (RET)  
		BR   R046D           ;047D: 30 6D       
		DB   00H             ;047F: 00
		DB   00H             ;0480: 00
		DB   0D5H            ;0481: D5
		DB   0BDH            ;0482: BD
		DB   0A9H            ;0483: A9
		DB   9FH             ;0484: 9F
		DB   96H             ;0485: 96
		DB   8EH             ;0486: 8E
		DB   7EH             ;0487: 7E
		DB   77H             ;0488: 77
		DB   70H             ;0489: 70
		DB   6AH             ;048A: 6A
		DB   5EH             ;048B: 5E
		DB   54H             ;048C: 54
		DB   4FH             ;048D: 4F
		DB   4BH             ;048E: 4B
		DB   46H             ;048F: 46
		DB   00H             ;0490: 00
		DB   02H             ;0491: 02
		DB   03H             ;0492: 03
		DB   04H             ;0493: 04
		DB   06H             ;0494: 06
		DB   08H             ;0495: 08
		DB   0CH             ;0496: 0C
		DB   10H             ;0497: 10
		DB   18H             ;0498: 18
		DB   20H             ;0499: 20
		DB   30H             ;049A: 30
		DB   40H             ;049B: 40
		DB   60H             ;049C: 60
		DB   80H             ;049D: 80
		DB   0C0H            ;049E: C0
		DB   0FFH            ;049F: FF
		
; Opcode: 6D..    WAIT [I], kk	  WAIT with a value kk, using [I] towards a table on 049h and 048l where hl is
;                                 the byte on [I]
		LDI  0ECH            ;04A0: F8 EC       
		PLO  R6              ;04A2: A6          
		LDI  0EDH            ;04A3: F8 ED       
		PLO  R7              ;04A5: A7          
R04A6
		GHI  R3              ;04A6: 93          
		PHI  RC              ;04A7: BC          
		LDN  RE              ;04A8: 0E          
		SHR                  ;04A9: F6          
		SHR                  ;04AA: F6          
		SHR                  ;04AB: F6          
		SHR                  ;04AC: F6          
		ORI  90H             ;04AD: F9 90       
		PLO  RC              ;04AF: AC          
		LDN  RC              ;04B0: 0C          
		PHI  RD              ;04B1: BD          
		LDA  RE              ;04B2: 4E          
		ANI  0FH             ;04B3: FA 0F       
		ORI  80H             ;04B5: F9 80       
		PLO  RC              ;04B7: AC          
		LDN  RC              ;04B8: 0C          
		PLO  RD              ;04B9: AD          
		GLO  RF              ;04BA: 8F          
		BNZ  R04BE           ;04BB: 3A BE       
		SEP  R4              ;04BD: D4          
R04BE
		DEC  RF              ;04BE: 2F          
R04BF
		LDN  R7              ;04BF: 07          
		BNZ  R04BF           ;04C0: 3A BF       
		LDI  80H             ;04C2: F8 80       
R04C4
		SMI  01H             ;04C4: FF 01       
		BNZ  R04C4           ;04C6: 3A C4       
		GHI  RD              ;04C8: 9D          
		STR  R7              ;04C9: 57          
		GLO  RD              ;04CA: 8D          
		STR  R6              ;04CB: 56          
		BR   R04A6           ;04CC: 30 A6       
		DB   6AH, 00H		 ;   04CE: PUSH  I             
		DB   66H, 0AH		 ;   04D0: POP   V0-V9         
		DB   6BH, 00H		 ;   04D2: RET                 
		DB   63H, 00H		 ;   04D4: LD    I, [2700]     
		DB   64H, 0E2H		 ;   04D6: LD    V2, V3, I     
		DB   63H, 0EH		 ;   04D8: LD    I, [270E]     
		DB   56H, 0F2H		 ;   04DA: LD    V6, [V2]      
		DB   56H, 0C6H		 ;   04DC: CP    V6, V6, [I]   
		DB   73H, 01H		 ;   04DE: ADD   V3, 01        
		DB   62H, 01H		 ;   04E0: ADD   I, 01         
		DB   79H, 0FFH		 ;   04E2: ADD   V9, FF        
		DB   99H, 0DAH		 ;   04E4: JNZ   V9, DA        
		DB   64H, 00H		 ;   04E6: LD    [2700], I     
		DB   63H, 0E2H		 ;   04E8: LD    I, V2, V3     
		DB   65H, 0CEH		 ;   04EA: JP    CE            
		DB   0F9H, 0FH		 ;   04EC: LD    V9, 0F        
		DB   0F6H, 00H		 ;   04EE: LD    V6, 00        

; 04F0-04FD Studio IV Psuedo code, Initialize registers and continue on 05DE
		DB   0FAH, 00H		 ;   04F0: LD    VA, 00        
		DB   0F0H, 70H		 ;   04F2: LD    V0, 70        
		DB   0F1H, 70H		 ;   04F4: LD    V1, 70        
		DB   0F7H, 02H		 ;   04F6: LD    V7, 02        
		DB   0F8H, 0FDH		 ;   04F8: LD    V8, FD        
		DB   05H, 0DEH		 ;   04FA: LD    I, 05DE       
		DB   4BH, 0BBH		 ;   04FC: JP    I             
		DB   00H             ;04FE: 00
		DB   00H             ;04FF: 00
		
;Character set address table
		DB   0A7H            ;0500: A7 - 0 05A7
		DB   39H             ;0501: 39 - 1 0539
		DB   44H             ;0502: 44 - 2 0544
		DB   0ABH            ;0503: AB - 3 05AB
		DB   85H             ;0504: 85 - 4 0585
		DB   0AFH            ;0505: AF - 5
		DB   46H             ;0506: 46 - 6
		DB   96H             ;0507: 96 - 7
		DB   48H             ;0508: 48 - 8
		DB   42H             ;0509: 42 - 9
		DB   4AH             ;050A: 4A - A
		DB   0B7H            ;050B: B7 - B
		DB   8EH             ;050C: 8E - C
		DB   0BBH            ;050D: BB - D 
		DB   92H             ;050E: 92 - E 
		DB   0BFH            ;050F: BF - F 
		DB   3EH             ;0510: 3E - G 
		DB   55H             ;0511: 55 - H
		DB   0A3H            ;0512: A3 - I 
		DB   98H             ;0513: 98 - J 
		DB   30H             ;0514: 30 - K
		DB   9FH             ;0515: 9F - L 
		DB   52H             ;0516: 52 - M 
		DB   0C4H            ;0517: C4 - N 
		DB   0A7H            ;0518: A7 - O 
		DB   9CH             ;0519: 9C - P 
		DB   0C9H            ;051A: C9 - Q
		DB   0CEH            ;051B: CE - R 
		DB   0AFH            ;051C: AF - S 
		DB   68H             ;051D: 68 - T 
		DB   4DH             ;051E: 4D - U 
		DB   5DH             ;051F: 5D - V 
		DB   58H             ;0520: 58 - W 
		DB   5FH             ;0521: 5F - X 
		DB   63H             ;0522: 63 - Y 
		DB   0B3H            ;0523: B3 - Z 
		DB   35H             ;0524: 35 - ?
		DB   6AH             ;0525: 6A - !
		DB   80H             ;0526: 80 - @
		DB   78H             ;0527: 78 - - 
		DB   66H             ;0528: 66 - +
		DB   70H             ;0529: 70 - divide 
		DB   6DH             ;052A: 6D - : 
		DB   0D3H            ;052B: D3 - /
		DB   8AH             ;052C: 8A - $
		DB   7CH             ;052D: 7C - =
		DB   0D8H            ;052E: D8 - #
		DB   75H             ;052F: 75 - space

Character set 0530-05dC
DB   88H             ;0530: 88 X...X    K
DB   90H             ;0531: 90 X..X.
DB   0E0H            ;0532: E0 XXX..
DB   90H             ;0533: 90 X..X.
DB   88H             ;0534: 88 X...X
DB   70H             ;0535: 70 .XXX.    ?
DB   88H             ;0536: 88 X...X
DB   10H             ;0537: 10 ...X.
DB   20H             ;0538: 20 ..X..
DB   20H             ;0539: 20 ..X..    1
DB   60H             ;053A: 60 .XX..
DB   20H             ;053B: 20 ..X..
DB   20H             ;053C: 20 ..X..
DB   70H             ;053D: 70 .XXX.
DB   0F8H            ;053E: F8 XXXXX    G
DB   80H             ;053F: 80 X....
DB   98H             ;0540: 98 X..XX
DB   88H             ;0541: 88 X...X
DB   0F8H            ;0542: F8 XXXXX    9
DB   88H             ;0543: 88 X...X
DB   0F8H            ;0544: F8 XXXXX    2
DB   08H             ;0545: 08 ....X
DB   0F8H            ;0546: F8 XXXXX    6
DB   80H             ;0547: 80 X....
DB   0F8H            ;0548: F8 XXXXX    8
DB   88H             ;0549: 88 X...X
DB   0F8H            ;054A: F8 XXXXX    A
DB   88H             ;054B: 88 X...X
DB   0F8H            ;054C: F8 XXXXX
DB   88H             ;054D: 88 X...X    U
DB   88H             ;054E: 88 X...X
DB   88H             ;054F: 88 X...X
DB   88H             ;0550: 88 X...X
DB   0F8H            ;0551: F8 XXXXX
DB   0D8H            ;0552: D8 XX.XX    M
DB   0F8H            ;0553: F8 XXXXX
DB   0A8H            ;0554: A8 X.X.X
DB   88H             ;0555: 88 X...X    H
DB   88H             ;0556: 88 X...X
DB   0F8H            ;0557: F8 XXXXX
DB   88H             ;0558: 88 X...X    W
DB   88H             ;0559: 88 X...X
DB   0A8H            ;055A: A8 X.X.X
DB   0F8H            ;055B: F8 XXXXX
DB   0D8H            ;055C: D8 XX.XX
DB   88H             ;055D: 88 X...X    V
DB   88H             ;055E: 88 X...X
DB   88H             ;055F: 88 X...X    X
DB   50H             ;0560: 50 .X.X.
DB   20H             ;0561: 20 ..X..
DB   50H             ;0562: 50 .X.X.
DB   88H             ;0563: 88 X...X    Y
DB   88H             ;0564: 88 X...X
DB   0F8H            ;0565: F8 XXXXX
DB   20H             ;0566: 20 ..X..    +
DB   20H             ;0567: 20 ..X..
DB   0F8H            ;0568: F8 XXXXX    T
DB   20H             ;0569: 20 ..X..
DB   20H             ;056A: 20 ..X..    !
DB   20H             ;056B: 20 ..X..
DB   20H             ;056C: 20 ..X..
DB   00H             ;056D: 00 .....    :
DB   20H             ;056E: 20 ..X..
DB   00H             ;056F: 00 .....
DB   20H             ;0570: 20 ..X..    divide
DB   00H             ;0571: 00 .....
DB   0F8H            ;0572: F8 XXXXX
DB   00H             ;0573: 00 .....
DB   20H             ;0574: 20 ..X..    '
DB   00H             ;0575: 00 .....    space
DB   00H             ;0576: 00 .....
DB   00H             ;0577: 00 .....
DB   00H             ;0578: 00 .....    -
DB   00H             ;0579: 00 .....
DB   0F8H            ;057A: F8 XXXXX
DB   00H             ;057B: 00 .....
DB   00H             ;057C: 00 .....    =
DB   0F8H            ;057D: F8 XXXXX
DB   00H             ;057E: 00 .....
DB   0F8H            ;057F: F8 XXXXX
DB   00H             ;0580: 00 .....    @
DB   70H             ;0581: 70 .XXX.
DB   70H             ;0582: 70 .XXX.
DB   70H             ;0583: 70 .XXX.
DB   00H             ;0584: 00 .....
DB   10H             ;0585: 10 ...X.    4
DB   90H             ;0586: 90 X..X.
DB   0F8H            ;0587: F8 XXXXX
DB   10H             ;0588: 10 ...X.
DB   10H             ;0589: 10 ...X.
DB   0F8H            ;058A: F8 XXXXX    $
DB   0A0H            ;058B: A0 X.X..
DB   0F8H            ;058C: F8 XXXXX
DB   28H             ;058D: 28 ..X.X
DB   0F8H            ;058E: F8 XXXXX    C
DB   80H             ;058F: 80 X....
DB   80H             ;0590: 80 X....
DB   80H             ;0591: 80 X....
DB   0F8H            ;0592: F8 XXXXX    E
DB   80H             ;0593: 80 X....
DB   0F0H            ;0594: F0 XXXX.
DB   80H             ;0595: 80 X....
DB   0F8H            ;0596: F8 XXXXX    7
DB   08H             ;0597: 08 ....X
DB   08H             ;0598: 08 ....X    J
DB   08H             ;0599: 08 ....X
DB   08H             ;059A: 08 ....X
DB   88H             ;059B: 88 X...X
DB   0F8H            ;059C: F8 XXXXX    P
DB   88H             ;059D: 88 X...X
DB   0F8H            ;059E: F8 XXXXX
DB   80H             ;059F: 80 X....    L
DB   80H             ;05A0: 80 X....
DB   80H             ;05A1: 80 X....
DB   80H             ;05A2: 80 X....
DB   0F8H            ;05A3: F8 XXXXX    I
DB   20H             ;05A4: 20 ..X..
DB   20H             ;05A5: 20 ..X..
DB   20H             ;05A6: 20 ..X..
DB   0F8H            ;05A7: F8 XXXXX    O / 0
DB   88H             ;05A8: 88 X...X
DB   88H             ;05A9: 88 X...X
DB   88H             ;05AA: 88 X...X
DB   0F8H            ;05AB: F8 XXXXX    3
DB   08H             ;05AC: 08 ....X
DB   38H             ;05AD: 38 ..XXX
DB   08H             ;05AE: 08 ....X
DB   0F8H            ;05AF: F8 XXXXX    S / 5
DB   80H             ;05B0: 80 X....
DB   0F8H            ;05B1: F8 XXXXX
DB   08H             ;05B2: 08 ....X
DB   0F8H            ;05B3: F8 XXXXX    Z
DB   10H             ;05B4: 10 ...X.
DB   20H             ;05B5: 20 ..X..
DB   40H             ;05B6: 40 .X...
DB   0F8H            ;05B7: F8 XXXXX    B
DB   48H             ;05B8: 48 .X..X
DB   78H             ;05B9: 78 .XXXX
DB   48H             ;05BA: 48 .X..X
DB   0F8H            ;05BB: F8 XXXXX    D
DB   48H             ;05BC: 48 .X..X
DB   48H             ;05BD: 48 .X..X
DB   48H             ;05BE: 48 .X..X
DB   0F8H            ;05BF: F8 XXXXX    F
DB   80H             ;05C0: 80 X....
DB   0F0H            ;05C1: F0 XXXX.
DB   80H             ;05C2: 80 X....
DB   80H             ;05C3: 80 X....
DB   0C8H            ;05C4: C8 XX..X    N
DB   0C8H            ;05C5: C8 XX..X
DB   0A8H            ;05C6: A8 X.X.X
DB   98H             ;05C7: 98 X..XX
DB   98H             ;05C8: 98 X..XX
DB   70H             ;05C9: 70 .XXX.    Q
DB   88H             ;05CA: 88 X...X
DB   88H             ;05CB: 88 X...X
DB   98H             ;05CC: 98 X..XX
DB   78H             ;05CD: 78 .XXX.
DB   0F8H            ;05CE: F8 XXXXX    R
DB   88H             ;05CF: 88 X...X
DB   0F8H            ;05D0: F8 XXXXX
DB   90H             ;05D1: 90 X..X.
DB   88H             ;05D2: 88 X...X
DB   08H             ;05D3: 08 ....X    /
DB   10H             ;05D4: 10 ...X.
DB   20H             ;05D5: 20 ..X..
DB   40H             ;05D6: 40 .X...
DB   80H             ;05D7: 80 X....
DB   50H             ;05D8: 50 .X.X.    #
DB   0F8H            ;05D9: F8 XXXXX
DB   50H             ;05DA: 50 .X.X.
DB   0F8H            ;05DB: F8 XXXXX
DB   50H             ;05DC: 50 .X.X.

; 05DE-05FB Check on presence of cartridges on 0800 or 1000
		DB   99H, 0F4H		 ;   05DE: JNZ   V9, F4        
		DB   66H, 9AH		 ;   05E0: CALL  69A           
		DB   10H, 00H		 ;   05E2: LD    I, 1000       
		DB   55H, 0D5H		 ;   05E4: CP    [I], V5, V5   
		DB   10H, 02H		 ;   05E6: LD    I, 1002       
		DB   0A5H, 0AAH		 ;   05E8: JE    I, V5, AA     
		DB   08H, 00H		 ;   05EA: LD    I, 0800       
		DB   55H, 0D5H		 ;   05EC: CP    [I], V5, V5   
		DB   08H, 02H		 ;   05EE: LD    I, 0802       
		DB   0A5H, 0AAH		 ;   05F0: JE    I, V5, AA     
		DB   65H, 0DEH		 ;   05F2: JP    DE            
		DB   9FH, 0E2H		 ;   05F4: JNZ   VF, E2        
		DB   79H, 0FFH		 ;   05F6: ADD   V9, FF        
		DB   0FFH, 0FFH		 ;   05F8: LD    VF, FF        
		DB   65H, 0E2H		 ;   05FA: JP    E2    

; 05FC-05FF 'FILL' character, used to fill the screen with FF during the demo        
		DB   0FFH            ;05FC: FF
		DB   0FFH            ;05FD: FF
		DB   0FFH            ;05FE: FF
		DB   0FFH            ;05FF: FF
		
; 0600-0609 PUSH V0-V9
;			Save V0 to V9 on 2702-270B
		DB   64H, 00H		 ;   0600: LD    [2700], I     
		DB   27H, 02H		 ;   0602: LD    I, 2702       
		DB   50H, 0C9H		 ;   0604: CP    V0, V9, [I]   
		DB   63H, 00H		 ;   0606: LD    I, [2700]     
		DB   6BH, 00H		 ;   0608: RET                 

; 060A-0611 POP V0-V9
;			Load V0 to V9 from 2702-270B
		DB   64H, 00H		 ;   060A: LD    [2700], I     
		DB   27H, 02H		 ;   060C: LD    I, 2702       
		DB   50H, 0D9H		 ;   060E: CP    [I], V0, V9   
		DB   65H, 06H		 ;   0610: JP    06            
		
; 0612-0625 SCR CLS or CLS
;			Print 8*4 pattern from 0575-0578 (zeros) on screen with DRWR I, Vx, address following subroutine call contains:
; 			byte 1: Vx value
; 			byte 2: Vx+1 value
		DB   66H, 00H		 ;   0612: PUSH  V0-V9         
		DB   0F3H, 75H		 ;   0614: LD    V3, 75        
		DB   6CH, 00H		 ;   0616: POP   I             
		DB   50H, 0D1H		 ;   0618: CP    [I], V0, V1   
		DB   62H, 02H		 ;   061A: ADD   I, 02         
		DB   6AH, 00H		 ;   061C: PUSH  I             
		DB   05H, 00H		 ;   061E: LD    I, 0500       
		DB   0D3H, 0F7H		 ;   0620: LD    [27F7], V3    
		DB   50H, 70H		 ;   0622: DRWR  I, V0         
		DB   65H, 0CH		 ;   0624: JP    0C            
		
; 0626-062B SCR FILL
;			Print 8*4 pattern from 05FC-05FF (#ff) on screen with DRWR I, Vx, address following subroutine call contains:
; 			byte 1: Vx value
; 			byte 2: Vx+1 value
		DB   66H, 00H		 ;   0626: PUSH  V0-V9         
		DB   0F3H, 0FCH		 ;   0628: LD    V3, FC        
		DB   65H, 16H		 ;   062A: JP    16            
		
; 062C-0647 CHAR [I], V0, V1 or CHAR [I]
;			Print character on [I] using screen position horizontal V0, vertical V1
		DB   64H, 0E2H		 ;   062C: LD    V2, V3, I     
		
; 062E-0647 CHAR [V2V3], V0, V1 or CHAR [V2V3]
;			Print character on [V2V3] on screen position horizontal V0, vertical V1
		DB   56H, 0F2H		 ;   062E: LD    V6, [V2]      
		DB   73H, 01H		 ;   0630: ADD   V3, 01        
		DB   06H, 3AH		 ;   0632: LD    I, 063A       
		DB   0B6H, 0FFH		 ;   0634: JNE   I, V6, FF     
		DB   63H, 0E2H		 ;   0636: LD    I, V2, V3     
		DB   6BH, 00H		 ;   0638: RET                 
		DB   05H, 00H		 ;   063A: LD    I, 0500       
		DB   0D6H, 0F7H		 ;   063C: LD    [27F7], V6    
		DB   56H, 0D6H		 ;   063E: CP    [I], V6, V6   
		DB   0D6H, 0F7H		 ;   0640: LD    [27F7], V6    
		DB   40H, 0E5H		 ;   0642: DRW   I, V0, 5      
		DB   70H, 06H		 ;   0644: ADD   V0, 06        
		DB   65H, 2EH		 ;   0646: JP    2E            
		
; 0648-0655 PRINT
;			Print characters on screen, address following subroutine call contains:
; 			byte 1: horizontal position on screen (0 to 128)
; 			byte 2: vertical position on screen (0 to 64)
; 			byte 3 and onwards: character number as on 05nn see 0500-052F table.
;			last byte 0xFF
		DB   6CH, 00H		 ;   0648: POP   I             
		DB   66H, 00H		 ;   064A: PUSH  V0-V9         
		DB   50H, 0D1H		 ;   064C: CP    [I], V0, V1   
		DB   62H, 02H		 ;   064E: ADD   I, 02         
		DB   66H, 2CH		 ;   0650: CHAR  [I], V0, V1   
		DB   6AH, 00H		 ;   0652: PUSH  I             
		DB   65H, 0AH		 ;   0654: JP    0A            
		
; 0656-065F PRINT [I]
;			Print characters on screen, [I] contains:
; 			byte 1: horizontal position on screen (0 to 128)
; 			byte 2: vertical position on screen (0 to 64)
; 			byte 3 and onwards: character number as on 05nn see 0500-052F table.
;			last byte 0xFF
		DB   66H, 00H		 ;   0656: PUSH  V0-V9         
		DB   50H, 0D1H		 ;   0658: CP    [I], V0, V1   
		DB   62H, 02H		 ;   065A: ADD   I, 02         
		DB   66H, 2CH		 ;   065C: CHAR  [I], V0, V1   
		DB   65H, 0AH		 ;   065E: JP    0A            
		
; 0660-067B PRINT D, 3
;			Print decimal value of V9 (3 digits) on screen, address following subroutine call contains:
; 			byte 1: horizontal position on screen (0 to 128)
; 			byte 2: vertical position on screen (0 to 64)
		DB   66H, 00H		 ;   0660: PUSH  V0-V9         
		DB   0F8H, 0CH		 ;   0662: LD    V8, 0C        
		DB   6CH, 00H		 ;   0664: POP   I             
		DB   50H, 0D1H		 ;   0666: CP    [I], V0, V1   
		DB   62H, 02H		 ;   0668: ADD   I, 02         
		DB   6AH, 00H		 ;   066A: PUSH  I             
		DB   0F2H, 27H		 ;   066C: LD    V2, 27        
		DB   0F3H, 0CH		 ;   066E: LD    V3, 0C        
		DB   49H, 03H		 ;   0670: LD    B, [V3], V9   
		DB   0F6H, 0FFH		 ;   0672: LD    V6, FF        
		DB   0D6H, 0FH		 ;   0674: LD    [270F], V6    
		DB   0D8H, 0E3H		 ;   0676: LD    V3, V8        
		DB   66H, 2EH		 ;   0678: CHAR  [V2V3],V0,V1  
		DB   65H, 0AH		 ;   067A: JP    0A            
		
; 067C-0681 PRINT D, 2
;			Print decimal value of V9 (2 digits) on screen, address following subroutine call contains:
; 			byte 1: horizontal position on screen (0 to 128)
; 			byte 2: vertical position on screen (0 to 64)
		DB   66H, 00H		 ;   067C: PUSH  V0-V9         
		DB   0F8H, 0DH		 ;   067E: LD    V8, 0D        
		DB   65H, 64H		 ;   0680: JP    64            
		
; 0682-0687 PRINT D, 1
;			Print decimal value of V9 (1 digit) on screen, address following subroutine call contains:
; 			byte 1: horizontal position on screen (0 to 128)
; 			byte 2: vertical position on screen (0 to 64)
		DB   66H, 00H		 ;   0682: PUSH  V0-V9         
		DB   0F8H, 0EH		 ;   0684: LD    V8, 0E        
		DB   65H, 64H		 ;   0686: JP    64 
		
; 0688-0690 CLR
;			Colour 2 blocks on the screen with CLR Vx, Vy, address following subroutine call contains:
; 			byte 1/2: Screen position first CLR command (Vx and Vx+1)
; 			byte 3/4: Screen position second CLR command (Vx and Vx+1)
; 			byte 5: Colour first CLR command (Vy)
; 			byte 6: Colour second CLR command (Vy)
; 			If byte 6 highest nible is not 0 then 2 more blocks in following 6 bytes will be coloured.
;			(Code on 0424-0432 and 04CE-04D1 is part of this routine)
		DB   6CH, 00H		 ;   0688: POP   I             
		DB   66H, 00H		 ;   068A: PUSH  V0-V9         
		DB   04H, 24H		 ;   068C: LD    I, 0424       
		DB   4BH, 0BBH		 ;   068E: JP    I   
		
; 0690-0699 CP [I]
;			Copy to [I] from memory after subroutine call, number of bytes stored in V9
;			(Code on 04D4-04EB is part of this routine)
		DB   64H, 0EH		 ;   0690: LD    [270E], I     
		DB   6CH, 00H		 ;   0692: POP   I             
		DB   66H, 00H		 ;   0694: PUSH  V0-V9         
		DB   04H, 0D4H		 ;   0696: LD    I, 04D4       
		DB   4BH, 0BBH		 ;   0698: JP    I       
		
; 069A-06FD Colour / sound demo
		DB   96H, 0A4H		 ;   069A: JNZ   V6, A4        
		DB   0F6H, 0FFH		 ;   069C: LD    V6, FF        
		DB   6FH, 72H		 ;   069E: OUT4  72            
		DB   66H, 26H		 ;   06A0: SCR   FILL          
		DB   0F0H            ;06A2: F0
		DB   0F0H            ;06A3: F0
		DB   0FAH, 01H		 ;   06A4: LD    VA, 01        
		DB   0D0H, 0E5H		 ;   06A6: LD    V5, V0        
		DB   45H, 64H		 ;   06A8: SHL   V5, 4         
		DB   0DBH, 0E4H		 ;   06AA: LD    V4, VB        
		DB   45H, 94H		 ;   06AC: SHR   V5, 4         
		DB   45H, 44H		 ;   06AE: ADD   V5, V4        
		DB   0FBH, 07H		 ;   06B0: LD    VB, 07        
		DB   06H, 0D6H		 ;   06B2: LD    I, 06D6       
		DB   55H, 0ABH		 ;   06B4: JG    I, V5, VB     
		DB   0D1H, 0E5H		 ;   06B6: LD    V5, V1        
		DB   45H, 64H		 ;   06B8: SHL   V5, 4         
		DB   0DBH, 0E5H		 ;   06BA: LD    V5, VB        
		DB   0D0H, 0E2H		 ;   06BC: LD    V2, V0        
		DB   0D1H, 0E3H		 ;   06BE: LD    V3, V1        
		DB   52H, 57H		 ;   06C0: CLR   V2, V7        
		DB   44H, 0A0H		 ;   06C2: ADDN  V4, V0        
		DB   0F2H, 0FH		 ;   06C4: LD    V2, 0F        
		DB   42H, 34H		 ;   06C6: XOR   V2, V4        
		DB   52H, 57H		 ;   06C8: CLR   V2, V7        
		DB   45H, 0A1H		 ;   06CA: ADDN  V5, V1        
		DB   0F3H, 0FH		 ;   06CC: LD    V3, 0F        
		DB   43H, 35H		 ;   06CE: XOR   V3, V5        
		DB   52H, 57H		 ;   06D0: CLR   V2, V7        
		DB   0D0H, 0E2H		 ;   06D2: LD    V2, V0        
		DB   52H, 57H		 ;   06D4: CLR   V2, V7        
		DB   40H, 48H		 ;   06D6: ADD   V0, V8        
		DB   41H, 48H		 ;   06D8: ADD   V1, V8        
		DB   0C5H, 03H		 ;   06DA: RND   V5, 03        
		DB   0F7H, 02H		 ;   06DC: LD    V7, 02        
		DB   85H, 0E2H		 ;   06DE: JZ    V5, E2        
		DB   0C7H, 07H		 ;   06E0: RND   V7, 07        
		DB   40H, 0F8H		 ;   06E2: KEY   V8            
		DB   8BH, 0F6H		 ;   06E4: JZ    VB, F6        
		DB   9DH, 0ECH		 ;   06E6: JNZ   VD, EC        
		DB   7CH, 0FBH		 ;   06E8: ADD   VC, FB        
		DB   0CDH, 0CH		 ;   06EA: RND   VD, 0C        
		DB   6FH, 30H		 ;   06EC: OUT4  30            
		DB   48H, 65H		 ;   06EE: SHL   V8, 5         
		DB   0FBH, 11H		 ;   06F0: LD    VB, 11        
		DB   48H, 1BH		 ;   06F2: OR    V8, VB        
		DB   65H, 0FAH		 ;   06F4: JP    FA            
		DB   6FH, 72H		 ;   06F6: OUT4  72            
		DB   78H, 01H		 ;   06F8: ADD   V8, 01        
		DB   0FAH, 00H		 ;   06FA: LD    VA, 00        
		DB   6BH, 00H		 ;   06FC: RET                 
		DB   00H             ;06FE: 00
		DB   00H             ;06FF: 00
		
; 0700-070A RESET RAM
;			Reset 2700-279F to 0
		LDI  0A0H            ;0700: F8 A0       
		PLO  R6              ;0702: A6          
R0703
		DEC  R6              ;0703: 26          
		LDI  00H             ;0704: F8 00       
		STR  R6              ;0706: 56          
		GLO  R6              ;0707: 86          
		BNZ  R0703           ;0708: 3A 03       
		SEP  R4              ;070A: D4          
		
; 070B-071B SCR XOR
;			XOR Screen memory with 0xFF
		LDI  20H             ;070B: F8 20       
		PHI  RF              ;070D: BF          
		LDI  00H             ;070E: F8 00       
		PLO  RF              ;0710: AF          
R0711
		LDN  RF              ;0711: 0F          
		XRI  0FFH            ;0712: FB FF       
		STR  RF              ;0714: 5F          
		INC  RF              ;0715: 1F          
		GHI  RF              ;0716: 9F          
		SMI  24H             ;0717: FF 24       
		BNZ  R0711           ;0719: 3A 11       
		SEP  R4              ;071B: D4          
		
; 071C-0753 KEY SWITCH
;			Key switch subroutine
; 			Following bytes are used as input:
; 			byte 1: First key
; 			byte 2: Last key
; 			byte 3/4: return address if no key pressed
; 			following bytes contain jump table for the pressed keys, first two byte key 0, next 2 key 1 etc. 
		DB   6CH, 00H		 ;   071C: POP   I             
		DB   52H, 0D3H		 ;   071E: CP    [I], V2, V3   
		DB   62H, 02H		 ;   0720: ADD   I, 02         
		DB   6AH, 00H		 ;   0722: PUSH  I             
		DB   0D2H, 0E4H		 ;   0724: LD    V4, V2        
		DB   07H, 32H		 ;   0726: LD    I, 0732       
		DB   50H, 82H		 ;   0728: JK    I, V2         
		DB   72H, 01H		 ;   072A: ADD   V2, 01        
		DB   07H, 50H		 ;   072C: LD    I, 0750       
		DB   52H, 0A3H		 ;   072E: JG    I, V2, V3     
		DB   65H, 26H		 ;   0730: JP    26            
		DB   0FDH, 02H		 ;   0732: LD    VD, 02        
		DB   9DH, 34H		 ;   0734: JNZ   VD, 34        
		DB   07H, 36H		 ;   0736: LD    I, 0736       
		DB   50H, 82H		 ;   0738: JK    I, V2         
		DB   0FDH, 02H		 ;   073A: LD    VD, 02        
		DB   9DH, 3CH		 ;   073C: JNZ   VD, 3C        
		DB   42H, 54H		 ;   073E: SUB   V2, V4        
		DB   6CH, 00H		 ;   0740: POP   I             
		DB   62H, 02H		 ;   0742: ADD   I, 02         
		DB   82H, 4AH		 ;   0744: JZ    V2, 4A        
		DB   72H, 0FFH		 ;   0746: ADD   V2, FF        
		DB   65H, 42H		 ;   0748: JP    42            
		DB   52H, 0D3H		 ;   074A: CP    [I], V2, V3   
		DB   63H, 0E2H		 ;   074C: LD    I, V2, V3     
		DB   4BH, 0BBH		 ;   074E: JP    I             
		DB   6CH, 00H		 ;   0750: POP   I             
		DB   65H, 4AH		 ;   0752: JP    4A            
		
; 0754-078D ADD [V0V1], [V2V3] or ADD V0V1, V2V3
;			Add decimal values [V0V1] and [V2V3] store result on [V0V1]
;			Number of digits stored in V9. 
;			LSD is on V0V1 and V2V3, following digit is on one address lower
; 			Each address (byte) only contains one decimal digit
		DB   66H, 00H		 ;   0754: PUSH  V0-V9         
		DB   0F5H, 00H		 ;   0756: LD    V5, 00        
		DB   65H, 5EH		 ;   0758: JP    5E            
		
; 075A-078D SUB [V0V1], [V2V3] or SUB V0V1, V2V3
;			Subtract decimal values [V2V3] from [V0V1] store result on [V0V1]
;			Number of digits stored in V9.
;			LSD is on V0V1 and V2V3, following on one address lower
; 			Each address (byte) only contains one decimal digit
		DB   66H, 00H		 ;   075A: PUSH  V0-V9         
		DB   0F5H, 01H		 ;   075C: LD    V5, 01        
		DB   0FBH, 00H		 ;   075E: LD    VB, 00        
		DB   57H, 0F2H		 ;   0760: LD    V7, [V2]      
		DB   56H, 0F0H		 ;   0762: LD    V6, [V0]      
		DB   95H, 80H		 ;   0764: JNZ   V5, 80        
		DB   46H, 4BH		 ;   0766: ADD   V6, VB        
		DB   46H, 47H		 ;   0768: ADD   V6, V7        
		DB   0F7H, 0AH		 ;   076A: LD    V7, 0A        
		DB   46H, 57H		 ;   076C: SUB   V6, V7        
		DB   9BH, 72H		 ;   076E: JNZ   VB, 72        
		DB   76H, 0AH		 ;   0770: ADD   V6, 0A        
		DB   56H, 0E0H		 ;   0772: LD    [V0], V6      
		DB   71H, 0FFH		 ;   0774: ADD   V1, FF        
		DB   73H, 0FFH		 ;   0776: ADD   V3, FF        
		DB   79H, 0FFH		 ;   0778: ADD   V9, FF        
		DB   99H, 60H		 ;   077A: JNZ   V9, 60        
		DB   66H, 0AH		 ;   077C: POP   V0-V9         
		DB   6BH, 00H		 ;   077E: RET                 
		DB   46H, 5BH		 ;   0780: SUB   V6, VB        
		DB   46H, 57H		 ;   0782: SUB   V6, V7        
		DB   0F7H, 0AH		 ;   0784: LD    V7, 0A        
		DB   46H, 47H		 ;   0786: ADD   V6, V7        
		DB   9BH, 72H		 ;   0788: JNZ   VB, 72        
		DB   76H, 0F6H		 ;   078A: ADD   V6, F6        
		DB   65H, 72H		 ;   078C: JP    72            
		
; 078E-079B ADD I, V9
;			I = I + V9
		DB   0EBH, 0F7H		 ;   078E: LD    VB, [27F7]    
		DB   49H, 4BH		 ;   0790: ADD   V9, VB        
		DB   0D9H, 0F7H		 ;   0792: LD    [27F7], V9    
		DB   0E9H, 0F6H		 ;   0794: LD    V9, [27F6]    
		DB   49H, 4BH		 ;   0796: ADD   V9, VB        
		DB   0D9H, 0F6H		 ;   0798: LD    [27F6], V9    
		DB   6BH, 00H		 ;   079A: RET                 
		
; 079C-07A9 LD I, [I+V9]
;			I = [I+V9]
		DB   67H, 8EH		 ;   079C: ADD   I, V9         
		
; 079E-07A9 LD I, [I]
;			I = [I]
		DB   0DAH, 0EBH		 ;   079E: LD    VB, VA        
		DB   59H, 0DAH		 ;   07A0: CP    [I], V9, VA   
		DB   0D9H, 0F6H		 ;   07A2: LD    [27F6], V9    
		DB   0DAH, 0F7H		 ;   07A4: LD    [27F7], VA    
		DB   0DBH, 0EAH		 ;   07A6: LD    VA, VB        
		DB   6BH, 00H		 ;   07A8: RET                 
		
; 07AA-07B5 KEY WAIT
;			Wait for key from either keypad and return key in V9, VA indicates keypad
		DB   40H, 0F9H		 ;   07AA: KEY   V9            
		DB   8BH, 0B0H		 ;   07AC: JZ    VB, B0        
		DB   6BH, 00H		 ;   07AE: RET                 
		DB   0FBH, 01H		 ;   07B0: LD    VB, 01        
		DB   4AH, 3BH		 ;   07B2: XOR   VA, VB        
		DB   65H, 0AAH		 ;   07B4: JP    AA            
		
; 07B6-07CF RND [270B], V9
;			RND V9
;			Store random number between 0 and V9 on [270B]
		DB   66H, 00H		 ;   07B6: PUSH  V0-V9         
		DB   0F8H, 00H		 ;   07B8: LD    V8, 00        
		DB   65H, 0BEH		 ;   07BA: JP    BE      
		
; 07BC-07CF RND [270B], V8, V9
; 			RND V8, V9
;			Store random number between V8 and V9 on [270B]
		DB   66H, 00H		 ;   07BC: PUSH  V0-V9         
		DB   0C7H, 0FFH		 ;   07BE: RND   V7, FF        
		DB   07H, 0CAH		 ;   07C0: LD    I, 07CA       
		DB   57H, 0A9H		 ;   07C2: JG    I, V7, V9     
		DB   47H, 48H		 ;   07C4: ADD   V7, V8        
		DB   0D7H, 0BH		 ;   07C6: LD    [270B], V7    
		DB   65H, 7CH		 ;   07C8: JP    7C            
		DB   47H, 59H		 ;   07CA: SUB   V7, V9        
		DB   77H, 0FFH		 ;   07CC: ADD   V7, FF        
		DB   65H, 0C0H		 ;   07CE: JP    C0            
		DB   00H             ;07D0: 00
		DB   00H             ;07D1: 00
		DB   0FFH            ;07D2: FF
		DB   0FFH            ;07D3: FF
		DB   00H             ;07D4: 00
		DB   0FFH            ;07D5: FF
		DB   01H             ;07D6: 01
		DB   0FFH            ;07D7: FF
		DB   0FFH            ;07D8: FF
		DB   00H             ;07D9: 00
		DB   00H             ;07DA: 00
		DB   00H             ;07DB: 00
		DB   01H             ;07DC: 01
		DB   00H             ;07DD: 00
		DB   0FFH            ;07DE: FF
		DB   01H             ;07DF: 01
		DB   00H             ;07E0: 00
		DB   01H             ;07E1: 01
		DB   01H             ;07E2: 01
		DB   01H             ;07E3: 01
		DB   00H             ;07E4: 00
		DB   00H             ;07E5: 00
		DB   00H             ;07E6: 00
		DB   00H             ;07E7: 00
		DB   00H             ;07E8: 00
		DB   00H             ;07E9: 00
		DB   0FH             ;07EA: 0F
		DB   0FH             ;07EB: 0F
		DB   00H             ;07EC: 00
		DB   0FH             ;07ED: 0F
		DB   01H             ;07EE: 01
		DB   0FH             ;07EF: 0F
		DB   0FH             ;07F0: 0F
		DB   00H             ;07F1: 00
		DB   00H             ;07F2: 00
		DB   00H             ;07F3: 00
		DB   01H             ;07F4: 01
		DB   00H             ;07F5: 00
		DB   0FH             ;07F6: 0F
		DB   01H             ;07F7: 01
		DB   00H             ;07F8: 00
		DB   01H             ;07F9: 01
		DB   01H             ;07FA: 01
		DB   01H             ;07FB: 01
		DB   00H             ;07FC: 00
		DB   00H             ;07FD: 00
		DB   00H             ;07FE: 00
		DB   00H             ;07FF: 00
		END
