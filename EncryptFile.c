/***********************************************************************************************;
 ***********************     SHALLIZAR.COM  >>>  THE NASM COLLECTION     *********************** 
 *********************************************************************************************** 
 >>>>> EncryptFile.c		<CONSOLE APP>
 ################################################################ 
 		THE SHALLIZAR LINUX APPLICATIONS		# 
 ################################################################ 
 ======================================== 
 =	Encrypt COLLECTION		= 
 ======================================== 
 
 ############	LICENSE   ############ 
 PROGARM: EncryptFile.c ; TYPE: CONSOLE APP ; PURPOSE: C DEMO PROGRAM FOR ENCRYPTION MODULES
 	Copyright (C) 2015 Shallizar.com
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 
  EncryptFile.c
  1.00
 
  DEMO CALLING THE Padmake & EncryptSSE MODULES FROM C
 
 
  DEVELOPMENT ENVIRONMENT:
 	***** gcc *****
 
  PLATFORM:
 	GENERIC PENTIUM 6
 	openSUSE : KDE : Kate, Kdebug
 
  CURRENT DIR:
 	cd ~/nasm/Linux/Shallizar/Apps/Encrypt
 
  COMPILE & LINK:
	DEBUG:
		nasm -f elf -F stabs Padmake.asm -o Padmake.o
		nasm -f elf -F stabs EncryptSSE.asm -o EncryptSSE.o
		gcc -g EncryptFile.c Padmake.o EncryptSSE.o -o EncryptFile
	RELEASE:
		nasm -f elf Padmake.asm -o Padmake.o
		nasm -f elf EncryptSSE.asm -o EncryptSSE.o
		gcc EncryptFile.c Padmake.o EncryptSSE.o -o EncryptFile
 
 
  COMMANDS:
 	./EncryptFile padfile size
 
 DEPENDENCIES:
  TEXT
   stdio.h
   string.h
  LIBRARIES
   standard c libs
   Padmake.o
   EncryptSSE.o
*/


/*
 TEST PROGRAM WRITTEN IN C TO TEST
 THE Padmake MODULE. IN A CONSOLE, TYPE
	EncryptFile padfilename size
 WHERE padfilename IS THE NAME OF THE PAD FILE YOU
 WANT TO MAKE AND size IS THE SIZE OF IT.
 EXAMPLE:
	EncryptFile Spreadsheets.pad 1048576
 WILL MAKE THE 1-MEGABYTE PAD Spreadsheets.pad.
*/


#define __USE_LARGEFILE64
#define _LARGEFILE_SOURCE
#define _LARGEFILE64_SOURCE

#include <stdio.h>
#include <string.h>
#include <time.h>
#include <sys/stat.h>

	extern int _Padmake_MakePadFile(const char *stg, long long size, int roundup);
	extern char* _Padmake_PropErrMsg(void);
	extern int _EncryptSSE_EncryptFile(const char *Src, const char *Pad, const char *Crypt );
	extern char* _EncryptSSE_PropErrMsg(void);
	extern char* _EncryptSSE_PropErrDesc(void);

int main(int argc, char *argv[])
{
	char SourceFile[257];
	char PadFile[257];
	char EncryptFile[257];

//ARGS FOR FileStat
	long long FSIZE; __time_t Cdate; __time_t Mdate; int DirFlag;

	int ReturnCode;


	if ( argc == 4 ) {
		strcpy( SourceFile, argv[1] );
		strcpy( PadFile, argv[2] );
		strcpy( EncryptFile, argv[3] );
		if ( _EncryptSSE_EncryptFile( SourceFile, PadFile, EncryptFile ) == -1 )
			{ printf( "ERROR ENCRYPTING FILE: %s%s\n", _EncryptSSE_PropErrMsg(), _EncryptSSE_PropErrDesc() );
			  return -1; }
		else
			{ printf( "ENCRYPTED %s TO %s WITH %s\n", SourceFile, EncryptFile, PadFile );
			  return 0; }
	}

	else if ( argc == 3 ) {
		strcpy( SourceFile, argv[1] );
		strcpy( PadFile, argv[2] );
		strcpy( EncryptFile, SourceFile );
		strcat( EncryptFile, ".enc" );
		if ( _EncryptSSE_EncryptFile( SourceFile, PadFile, EncryptFile ) == -1 )
			{ printf( "ERROR ENCRYPTING FILE: %s%s\n", _EncryptSSE_PropErrMsg(), _EncryptSSE_PropErrDesc() );
			  return -1; }
		else
			{ printf( "ENCRYPTED %s TO %s WITH %s\n", SourceFile, EncryptFile, PadFile );
			  return 0; }
	}

	else if ( argc == 2 )
		{ strcpy( SourceFile, argv[1] );
		  if ( FileStat( argv[1], &FSIZE, &Cdate, &Mdate, &DirFlag ) == -1 )
			{ printf( "CANNOT STAT %s\n", argv[1] );
			  return -1; }
		  if ( DirFlag == 1 ) { printf("ARG IS A DIR"); return -1; }
		  strcpy( PadFile, SourceFile );
		  strcat( PadFile, ".pad" );
		  strcpy( EncryptFile, SourceFile );
		  strcat( EncryptFile, ".enc" );
		printf("SourceFile: %s\nPadFile: %s\nEncryptFile: %s\n", SourceFile, PadFile, EncryptFile );
		  if ( _Padmake_MakePadFile( PadFile, FSIZE, 1 ) == -1 )
			{ printf( "ERRRO MAKING PAD: %s\n", _Padmake_PropErrMsg() );
			  return -1; }
		  if ( _EncryptSSE_EncryptFile( SourceFile, PadFile, EncryptFile ) == -1 )
			{ printf( "ERROR ENCRYPTING FILE: %s%s\n", _EncryptSSE_PropErrMsg(), _EncryptSSE_PropErrDesc() );
			  return -1; }
		  else { printf( "ENCRYPTED %s TO %s WITH %s\n", SourceFile, PadFile, EncryptFile ); }
		}

	return 0;
}


// c VERSION OF FileStat
int FileStat(	char Filename[], \
		long long* Fsize, \
		__time_t* DateCreated, \
		__time_t* DateLastModified, \
		int* IsDir)
{
	struct stat64 Struc64;
	struct tm *MetaDate;

	char TimeStg[20];

	int rtn;

	//INIT DATES TO null
	*DateCreated = 0;
	*DateLastModified = 0;

	rtn = stat64( Filename, &Struc64 );
	if( rtn != 0 )
		{ return -1; }
	else
		{ *Fsize = Struc64.st_size;
		  *DateCreated = Struc64.st_ctime;
		  *DateLastModified = Struc64.st_mtime;
		  *IsDir = Struc64.st_mode & __S_IFDIR;

		  MetaDate = localtime( &Struc64.st_ctime );
		  rtn = strftime( TimeStg, 20, "%Y-%m-%d_%H%M%S\n", MetaDate );
		  printf( "DateCreated: %s", TimeStg );

		  MetaDate = localtime( &Struc64.st_mtime );
		  rtn = strftime( TimeStg, 20, "%Y-%m-%d_%H%M%S\n", MetaDate );
		  printf( "DateLastModified: %s", TimeStg );
		}
	return 0;
}
