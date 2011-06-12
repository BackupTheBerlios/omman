; Copyright (c) 2011, Jan Friesse <jfriesse@users.berlios.de>
;
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted, provided that the above
; copyright notice and this permission notice appear in all copies.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
; WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
; ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
; WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
; ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
; OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
;
; For VIM asmsyntax=nasm
bits 16

; Defined labels

; dos_exit
; dos_malloc
; dos_realloc
; dos_write

; Definitions

; Exit program with exit code al
dos_exit:
	mov ah, 0x4c
	int 0x21
ret

; Allocate new memory
; bx is required memory size in paragraphs (16 bytes)
; function sets CF if allocation was unsuccessful.
; ax is error code or segment of allocated memory
; bx contains largest free block
dos_malloc:
	mov ah, 0x48
	int 0x21
ret

; Reallocate allocated memory
; es is segment of allocated memory
; bx is required memory size in paragraphs (16 bytes)
; function sets CF if reallocation was unsuccessful.
; ax is error code
; bx contains largest free block
dos_realloc:
	mov ah, 0x4a
	int 0x21
ret

; Write buffer pointed by ds:dx with size cx to file handle bx
; Function set's CF on error.
; ax contains number of real written bytes, or if CF is set, error code
dos_write:
	mov ah, 0x40
	int 0x21
ret
