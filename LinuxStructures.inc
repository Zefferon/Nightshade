;***********************************************************************************************;
;***********************     SHALLIZAR.COM  >>>  THE NASM COLLECTION     ***********************;
;***********************************************************************************************;
;>>>>> LinuxStructures.inc		<ASM INCLUDE FILE>
;################################################################;
;		THE SHALLIZAR LINUX RUNTIME			#;
;################################################################;
;===============================================;
;		Linux SYSTEM STRUCTURES		;
;===============================================;
;
;############	LICENSE   ############;
;PROGARM: LinuxStructures.inc ; TYPE: ASM INCLUDE FILE ; PURPOSE: DEFINITIONS FOR Linux STRUCTURES
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
; LinuxStructures.inc
;
; 2.00
;

;MACROS
;===============================================================;
;			DATA STRUCTURES				;
;===============================================================;
;********************************;
;	stat64_structure	*;
;********************************;
;THIS MACRO WILL SET UP A stat64 STRUCTURE IN SECTION bss
;TO BE PASSED TO THE stat64 FUNCTION
;
;REF: usr/include/asm/stat.h
;
;*************** DERIVED FROM: 
%macro	Stat64_Structure 0-1
;THIS MACRO MUST BE USED IN SECTION .bss
	%ifdef __SECT__
		%ifnidni __SECT__, [SECTION .bss]	;ASSEMBLE THIS IN .bss SECTION
			%fatal Stat64_Structure MACRO MUST BE IS SECTION .bss
		%endif
	%else
		%fatal "Stat64_Structure MACRO MUST BE USED IN A SECTION = MISSING __SECT__ macro"
	%endif
	%if %0=1
		%1:
	%else
		Stat64struc:
	%endif
		.Device			resd 2	;st_dev		OFFSET	0
		.padding0		resb 4	;			8
		.Inode			resd 1	;st_ino;		12
		.FileType		resd 1	;st_mode;		16
		.Links			resd 1	;st_nlink;		20
		.UserID			resd 1	;st_uid;		24
		.GroupID		resd 1	;st_gid			28
		.DeviceID		resd 2	;st_rde			32
		.padding1		resb 4	;			40
		.FileSize		resd 2	;st_size		44
		.BlockSize		resd 1	;st_blksize		52
		.BlockCount		resd 2	;st_blocks		56
		.DateLastAccessed	resd 2	;st_atime		64
		.DateLastModified	resd 2	;st_mtime		72
		.DateLastStatus		resd 2	;st_ctime		80
		.endpadding		resd 4	;			88
%endmacro



;DERIVED FROM /usr/include/asm-generic/statfs.h
%macro	StatFS64_Structure 0-1
;THIS MACRO MUST BE USED IN SECTION .bss
	%ifdef __SECT__
		%ifnidni __SECT__, [SECTION .bss]	;ASSEMBLE THIS IN .bss SECTION
			%fatal Stat64_Structure MACRO MUST BE IS SECTION .bss
		%endif
	%else
		%fatal "Stat64_Structure MACRO MUST BE USED IN A SECTION = MISSING __SECT__ macro"
	%endif
	%if %0=1
		%1:
	%else
		StatFS64struc:
	%endif
		.Type		resd 1
		.BlockSize	resd 1
		.TotalBlocks	resq 1
		.FreeBlocks	resq 1
		.Available	resq 1
		.TotalNodes	resq 1
		.FreeNodes	resq 1
		.FsysID		resd 1
		.NamelenMax	resd 1
		.FragmentSize	resd 1
		.Spare		resd 6
%endmacro
;.Type
;EXT3_SUPER_MAGIC 0xEF53
;EXT4_SUPER_MAGIC 0xEF53
;REISERFS_SUPER_MAGIC 0x52654973
