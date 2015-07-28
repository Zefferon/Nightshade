/***********************************************************************************************;
;***********************     SHALLIZAR.COM  >>>  THE NASM COLLECTION     ***********************;
;***********************************************************************************************;
;>>>>> MakePad.c		<CONSOLE APP>
;################################################################;
;		THE SHALLIZAR LINUX APPLICATIONS		#;
;################################################################;
;========================================;
;=	Encrypt COLLECTION		=;
;========================================;
;
;############	LICENSE   ############;
;PROGARM: MakePad.c ; TYPE: CONSOLE APP ; PURPOSE: C DEMO PROGRAM FOR Padmake MODULE
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
; MakePad.c
; 1.00
;
; DEMO CALLING THE Padmake MODULE FROM C
;
;
; DEVELOPMENT ENVIRONMENT:
;	***** gcc *****
;
; PLATFORM:
;	GENERIC PENTIUM 6
;	openSUSE : KDE : Kate, Kdebug
;
; CURRENT DIR:
;	cd ~/nasm/Linux/Shallizar/Apps/Encrypt
;
; COMPILE & LINK:
;	DEBUG:
;		gcc -g MakePad.c ProcEcho.o -o MakePad
;	RELEASE:
;		gcc MakePad.c ProcEcho.o -o MakePad
;
;
; COMMANDS:
;	./MakePad padfile size
;
;DEPENDENCIES:
; TEXT
;  stdio.h
;  string.h
; LIBRARIES
;  standard c libs
;  Padmake.o

//MakePad.c

/*
 TEST PROGRAM WRITTEN IN C TO TEST
 THE Padmake MODULE. IN A CONSOLE, TYPE
	MakePad padfilename size
 WHERE padfilename IS THE NAME OF THE PAD FILE YOU
 WANT TO MAKE AND size IS THE SIZE OF IT.
 EXAMPLE:
	MakePad Spreadsheets.pad 1048576
 WILL MAKE THE 1-MEGABYTE PAD Spreadsheets.pad.
*/

/*
	COMPILE:
		DEBUG:
			nasm -f elf -F stabs Padmake.asm -o Padmake.o
			gcc -g MakePad.c Padmake.o -o MakePad
		RELEASE:
			nasm -f elf Padmake.asm -o Padmake.o
			gcc MakePad.c Padmake.o -o MakePad
*/

#include <stdio.h>

	extern int _Padmake_MakePadFile(char *stg, long long size, int roundup);
	extern char* _Padmake_PropErrMsg(void);

int main(int argc, char *argv[])
{
	long long PadSize;	//INT64 READ FROM COMMAND LINE
	int ReturnCode;		//RETURN CODE FROM Padmake MODULE

	char *MsgPtr;	//MESSAGE POINTER RETURNED FROM Padmake MODULE

//TEST _Padmake_PropErrMsg
	char test1[16] = "/home/junk/mmm";	//DIR junk DOESN'T EXIST
	ReturnCode = _Padmake_MakePadFile(test1, 1000, 0);
	if (ReturnCode < 0) {MsgPtr = _Padmake_PropErrMsg();
			     printf("   Padmake ERROR: %s\n", MsgPtr);
			     }

	if (argc<3)
		{printf("   ERROR: COMMAND LINE: MISSING SIZE\n\n");
		 printf("   USAGE:\n      PadMake padfilename size\n");
		 return 0;
		 }

	PadSize = atoi(argv[2]);
	printf("   MakePad:  %s   OF SIZE: %i\n", argv[1], PadSize);

	ReturnCode = _Padmake_MakePadFile(argv[1], PadSize, 0);
	if (ReturnCode < 0) {MsgPtr = _Padmake_PropErrMsg();
			     printf("   ERROR MAKING PAD: %i\n", ReturnCode);
			     printf("Padmake ERROR: %s\n", MsgPtr);
			     }
	else {printf("   PAD MADE: %s - %i BYTES\n", argv[1], PadSize);}

	return 0;
}
