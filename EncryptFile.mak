#***********************************************************************************************#
#***********************     SHALLIZAR.COM  >>>  THE NASM COLLECTION     ***********************#
#***********************************************************************************************#
#>>>>> EncryptFile.mak
#===============================================#
#		Linux RUNTIME			#
#===============================================#
#+++++++++++++++++++++++++++++++#
#	Encryption LIBRARY	#
#+++++++++++++++++++++++++++++++#
#
#############	LICENSE   #############
#PROGARM: EncryptFile.mak ; TYPE: bash SCRIPT ; PURPOSE: ASSEMBLE MODULES & COMPILE & LINK EncryptFile.c
#	Copyright (C) 2015 Shallizar.com
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Encryption.mak
# command: ./Encryption.mak
# make this file executable: chmod u+x Encryption.mak
#
# EncryptFile.mak
#command line:	./EncryptFile.mak
nasm -f elf Padmake.asm -l Padmake.lst
nasm -f elf EncryptSSE.asm -l EncryptSSE.lst
nasm -f elf FileStat.asm -l FileStat.lst
gcc -g EncryptFile.c Padmake.o EncryptSSE.o FileStat.o -o EncryptFile
