;***********************************************************************************************;
;***********************     SHALLIZAR.COM  >>>  THE NASM COLLECTION     ***********************;
;***********************************************************************************************;
;>>>>> Padmake.asm		<LIBRARY MODULE>
;################################################################;
;		THE SHALLIZAR LINUX RUNTIME			#;
;################################################################;
;========================================;
;=	Encryption LIBRARY		=;
;========================================;
;
;############	LICENSE   #############
;PROGARM: Padmake.asm ; TYPE: LIBRARY MODULE ; PURPOSE: MAKE & SAVE AN ENCRYPTION ONE-TIME PAD
;	Copyright (C) 2015 Shallizar.com
;
;This program is free software: you can redistribute it and/or modify
;it under the terms of the GNU General Public License as published by
;the Free Software Foundation, either version 3 of the License, or
;(at your option) any later version.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;
; Padmake.asm
; 1.00
;
;
; DEVELOPMENT ENVIRONMENT:
;	***** NASM *****
;
; PLATFORM: generic pentium 6
;           openSUSE : KDE : Kate, Kdebug
;
;
; ASSEMBLE:
;	nasm -f elf Padmake.asm -l Padmake.lst
;
; LIBRARY:
;	ar rcs Encryption.lib Padmake.o
;
; MAKE:
;	make -f Encryption.make
;
;DEPENDENCIES:
; none
;
;
;
;PUBLIC FUNCTIONS
; Padmake.MakePadFile:	 - MAKE & SAVE A PAD
; _Padmake._MakePadFile: - C ENTRY POINT FOR Padmake.MakePadFile
;


SECTION .bss
alignb 4
	PADBUFF		resb 1048592	;1 MEG +16 BYTES FOR ALIGNMENT
	PADSTART	resd 1		;ADDRESS INTO PADBUFF STARTING AT 16-BIT PAGE BOUNDARY
	PADSIZE		resq 1		;SIZE OF PAD - 64-BIT INT

	MegCount	resd 1	;# OF MEGS OF PAD SIZE
	RemCount	resd 1	;# OF REMAINING BYTES OF PAD SIZE

	PadFile		resd 1	;POINTER TO ASCII-Z STRING OF PAD FILE PASSED BY CALLER
	PadFileID	resd 1	;HANDLE RETURNED BY FILE_OPEN

	SAVE_EBP	resd 1

	cnt0		resd 1
	cnt1		resd 1
	

SECTION .data
;LINUX CONSTANTS
%define SysOpen		5	;__NR_open
%define SysRead		3	;__NR_read
%define SysWrite	4	;__NR_write
%define SysClose	6	;__NR_close
%define Kill		10	;__NR_unlink
%define ReadOnly	0	;O_RDONLY
%define WriteOnly	1	;O_WRONLY
%define ReadWrite	2	;O_RDWR
%define CreateNew	100q	;O_CREAT
%define PERMISSION_OWNER_READ	400q
%define PERMISSION_OWNER_WRITE	200q


align 4
;CONSTANTS
	Meg		dd 1048576	;A MEGABYTE
	PAGE_SIZE	dd 16384	;ROUND UP PAD SIZE TO NEAREST 16K

;FPU CONTROL WORD
	FPU_CTRL	dw 0000_11_11_01_111111b, 0	;ROUND: TRUNCATE
							;PRECISION: 64 BITS
							;BIT 6: ? - IS SET BY FNINIT
							;EXCEPTIONS: MASK ALL

;ASCII-Z STRING OF FILE /dev/urandom
;USE TO READ FROM LINUX RANDOM # GENERATOR
	LINUX_DEV_URANDOM	db "/dev/urandom", 0
align 4
	RNDMid			dd 0

;CALLBAKS
	Progress	dd PROGRESS_DUMMY
	ProgessCnt	dd 0

;ERRORS
	ERROR_CODE	dd 0

;ERROR MESSAGES
	ERROR_PTR		dd ERRMSG_NONE
	ERRMSG_NONE		db "no_error", 0
	ERRMSG_INVALID		db "Padmake.MakePadFile: ERROR PAD SIZE IS INVALID NUMBER", 0
	ERRMSG_NEGATIVE		db "Padmake.MakePadFile: ERROR PAD SIZE IS NEGATIVE", 0
	ERRMSG_ZERO		db "Padmake.MakePadFile: ERROR PAD SIZE IS ZERO", 0
	ERRMSG_DIR_NOT_FOUND	db "Padmake.MakePadFile: ERROR FILE_OPEN: DIR NOT FOUND", 0
	ERRMSG_ERR_OPEN_PAD	db "Padmake.MakePadFile: ERROR FILE_OPEN", 0
	ERRMSG_OPEN_RANDOM	db "Padmake.MakePadFile: ERROR OPEN_RANDOM", 0
	ERRMSG_READ_RANDOM	db "Padmake.MakePadFile: ERROR READ_RANDOM", 0
	ERRMSG_WRITE_PAD	db "Padmake.MakePadFile: ERROR WRITE_PAD", 0

SECTION .text

	global	Padmake.MakePadFile
Padmake.MakePadFile:
;ADJUST POINTERS TO BUFFERS TO 16-BYTE PAGE BOUNDARYS
;
;CALLER:
; EBX: PATH OF NEW PAD FILE
; ECX: PTR TO SIZE OF NEW PAD FILE
; EDX: BOOLEAN - TRUE IF ROUND UP SIZE
;

	MOV	dword [ERROR_CODE], 0
	MOV	dword [ERROR_PTR], ERRMSG_NONE
	MOV	dword [ProgessCnt], 0
	MOV	[PadFile], EBX

;POINT TO 16-BYTE PAGE BOUNDARY WITHIN BUFFER
	MOV	EAX, PADBUFF+16
	AND	EAX, 0FFFFFFF0h
	MOV	[PADSTART], EAX

	FNINIT
	FLDCW	[FPU_CTRL]	;SET ROUNDING TO TRUNCATE
;LOAD PAD SIZE
	FILD	qword [ECX]
	FTST			;MAKE SURE PAD SIZE IS > 0
	FSTSW	AX
	TEST	AH, 4		;IS ST UNCOMPARABLE?
	JNZ	ERROR_INVALID
	TEST	AH, 1		;IS ST NEGATIVE?
	JNZ	ERROR_NEGATIVE
	TEST	AH, 40h		;IS ST ZERO?
	JNZ	ERROR_ZERO

;IF ADDUP (EDX) IS FALSE, SKIP TO NORMAL LOOP INIT
	OR	EDX, EDX
	JZ	SKIP
;ADD PAGE_SIZE (16384) TO PADSIZE
	FIADD	dword [PAGE_SIZE]

SKIP:
	FISTP	qword [PADSIZE]
	FILD	dword [Meg]	;LOAD CONSTANT 1 MEGABYTE
	FILD	qword [PADSIZE]
	FLD	ST0
;DIVIDE BY 1 MEG
	FDIV	ST0, ST2
	FIST	dword [MegCount]	;STORE QUOTIENT WITH TRUNCATION INTO PAD MEG SIZE
	FISTP	dword [cnt1]		;STORE QUOTIENT WITH TRUNCATION INTO COUNTER

;MODULO BY 1 MEG
	FPREM1			;GET REMAINDER
	FTST			;IS REMAINDER NEGATIVE?
	FSTSW	AX
	TEST	AH, 1
	JZ	POSITIVE_REMAINDER
	FADD	ST0, ST1
POSITIVE_REMAINDER:
	FISTP	dword [RemCount]


;OPEN PAD FILE FOR READING-WRITING
	MOV	EAX, SysOpen
	MOV	EBX, [PadFile]
	MOV	ECX, ReadWrite + CreateNew
	MOV	EDX, PERMISSION_OWNER_READ + PERMISSION_OWNER_WRITE
	INT	80h
	BT	EAX, 31
	JC	ERR_OPEN_PAD
	MOV	[PadFileID], EAX

;OPEN DEVICE /dev/urandom
	MOV	EAX, SysOpen
	MOV	EBX, LINUX_DEV_URANDOM	;THE Linux RANDOM # COLLECTION
	MOV	ECX, ReadOnly
	MOV	EDX, PERMISSION_OWNER_READ
	INT	80h
	BT	EAX, 31
	JC	ERR_OPEN_RANDOM
	MOV	[RNDMid], EAX

;************* MEGABYTES LOOP
	BSF	EAX, [MegCount]
	JZ	REMAINDER
	MOV	dword [cnt0], 1048576
MEG_LOOP:
	CALL	SCOOP
	;PROGRESS
	INC	dword [ProgessCnt]
	PUSH	dword [MegCount]
	PUSH	dword [ProgessCnt]
	CALL	[Progress]
	ADD	ESP, 8
	DEC	dword [cnt1]
	JNZ	MEG_LOOP
REMAINDER:
	MOV	EAX, [RemCount]
	OR	EAX, EAX
	JZ	FINISH
	MOV	[cnt0], EAX
	CALL	SCOOP

FINISH:
	MOV	EAX, SysClose
	MOV	EBX, [RNDMid]
	INT	80h
	MOV	EAX, SysClose
	MOV	EBX, [PadFileID]
	INT	80h
	MOV	EDX, [PADSIZE+4]
	MOV	EAX, [PADSIZE]
	MOV	EBX, ERRMSG_NONE
	CLC
	RET

SCOOP:
;GET SCOOP OF RANDOM NUMS
	MOV	EAX, SysRead
	MOV	EBX, [RNDMid]
	MOV	ECX, [PADSTART]
	MOV	EDX, [cnt0]
	INT	80h
	BT	EAX, 31
	JC	ERR_READ_RANDOM
;WRITE THE SCOOP TO THE PAD
	MOV	EAX, SysWrite
	MOV	EBX, [PadFileID]
	MOV	ECX, [PADSTART]
	MOV	EDX, [cnt0]
	INT	80h
	BT	EAX, 31
	JC	ERR_WRITE_PAD
	RET



;ERRORS
ERROR_INVALID:
	MOV	dword [ERROR_CODE], -55
	MOV	EBX, ERRMSG_INVALID
	MOV	[ERROR_PTR], EBX
	STC
	RET

ERROR_NEGATIVE:
	MOV	dword [ERROR_CODE], -56
	MOV	EBX, ERRMSG_NEGATIVE
	MOV	[ERROR_PTR], EBX
	STC
	RET

ERROR_ZERO:
	MOV	dword [ERROR_CODE], -57
	MOV	EBX, ERRMSG_ZERO
	MOV	[ERROR_PTR], EBX
	STC
	RET

ERR_OPEN_PAD:
	MOV	[ERROR_CODE], EAX
	CMP	EAX, -2
	JNE	.L0
	MOV	EBX, ERRMSG_DIR_NOT_FOUND
	MOV	[ERROR_PTR], EBX
	JMP	.L1
.L0:
	MOV	EBX, ERRMSG_ERR_OPEN_PAD
	MOV	[ERROR_PTR], EBX
.L1:
	STC
	RET

ERR_OPEN_RANDOM:
	MOV	[ERROR_CODE], EAX	;SAVE ERROR CODE
	MOV	EAX, SysClose		;CLOSE PAD
	MOV	EBX, [PadFileID]
	INT	80h
	MOV	EAX, Kill
	MOV	EBX, [PadFile]
	INT	80h
	MOV	EBX, ERRMSG_OPEN_RANDOM
	MOV	[ERROR_PTR], EBX
	MOV	EAX, [ERROR_CODE]
	STC
	RET


ERR_READ_RANDOM:
	MOV	[ERROR_CODE], EAX
	POP	EAX	;THROW AWAY RETURN ADDRESS ON STACK
;CLOSE SYS RANDOM
	MOV	EAX, SysClose
	MOV	EBX, [RNDMid]
	INT	80h
;CLOSE PAD
	MOV	EAX, SysClose
	MOV	EBX, [PadFileID]
	INT	80h
	MOV	EBX, ERRMSG_READ_RANDOM
	MOV	[ERROR_PTR], EBX
	MOV	EAX, [ERROR_CODE]
	STC
	RET

ERR_WRITE_PAD:
	MOV	[ERROR_CODE], EAX
	POP	EAX	;THROW AWAY RETURN ADDRESS ON STACK
;CLOSE SYS RANDOM
	MOV	EAX, SysClose
	MOV	EBX, [RNDMid]
	INT	80h
;CLOSE PAD
	MOV	EAX, SysClose
	MOV	EBX, [PadFileID]
	INT	80h
	MOV	EBX, ERRMSG_WRITE_PAD
	MOV	[ERROR_PTR], EBX
	MOV	EAX, [ERROR_CODE]
	STC
	RET




;************************************************;
;*						*;
;*		C ENTRY POINTS			*;
;*						*;
;************************************************;
;
;	FUNCTION WRAPPERS FOR C PROGRAMS
;

;*************	MakePadFile
;MACRO:
;	Padmake "Spreadsheets.pad" , PadSize [, True]
;
;CALLER:
; [ESP+12]: TRUNCATE UP (BOOLEAN)  OPTIONAL, DEFAULT IS TRUE
; [ESP+8]:  PAD SIZE
; [ESP+4]:  FILENAME (PTR TO ASCII-Z STRING)
; [ESP]:    RETURN ADDRESS
;
	global	_Padmake_MakePadFile
_Padmake_MakePadFile:
	MOV	[SAVE_EBP], EBP

	MOV	EBX, [ESP+4]
	LEA	ECX, [ESP+8]
	MOV	EDX, [ESP+16]
	CALL	Padmake.MakePadFile

	MOV	[ERROR_PTR], EBX
	MOVSX	EAX, byte [ERROR_CODE+3]
	MOV	EBP, [SAVE_EBP]
	RET


;****************************************;
;*		CALLBAKS		*;
;****************************************;
;SetCallbak
; DECLARE:
;	extern int _EncryptSSE_SetCallbak(const char *Src, const char *Pad, const char *Crypt );
; USAGE:
;	ReturnCode = _EncryptSSE_SetCallbak( Sourcefile, Padfile, Encryptedfile );
;
;CALLER:
; [ESP+4]: PTR TO Callbak FUNCTION
;
	global	_Padmake_SetCallbak
_Padmake_SetCallbak:
	MOV	EAX, [ESP+4]
	MOV	[Progress], EAX
	RET


;PROGRESS DUMMY FUNCTION
PROGRESS_DUMMY:
	RET


;****************************************;
;*		PROPERTIES		*;
;****************************************;
	global	_Padmake_PropErrMsg
_Padmake_PropErrMsg:
	MOV	EAX, [ERROR_PTR]
	RET

	global	_Padmake_PropErrCode
_Padmake_PropErrCode:
	MOV	EAX, [ERROR_CODE]
	RET
