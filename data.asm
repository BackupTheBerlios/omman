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

; Defined labels, macros

; data_addr_base
; data_resb
; data_resw
; data_stack

; Constants
DATA_STACK_ITEMS	equ 128

; Macros

; Define data_%1 equ data_addr_base + DATA_POS (starting 0, incremented by %2)
%macro data_resb 2
	%ifndef DATA_POS
		%assign DATA_POS 0
	%endif

	data_%1 equ data_addr_base + DATA_POS
	%assign DATA_POS (DATA_POS + %2)
%endmacro

; Define data_%1 equ data_addr_base + DATA_POS (starting 0, incremented by
; 2 * %2)
%macro data_resw 2
	%ifndef DATA_POS
		%assign DATA_POS 0
	%endif

	data_%1 equ data_addr_base + DATA_POS
	%assign DATA_POS (DATA_POS + (%2 * 2))
%endmacro

; Definitions

data_addr_base:
; Segment of dynamic memory
data_resw	dynmem_seg, 1
; Size in paragraphs (16 bytes) of dynamic memory
data_resw	dynmem_size, 1
; Number of allocated blocks of dynamic memory
data_resw	dynmem_no_blocks, 1
; Start of stack
data_resw	stack_start, DATA_STACK_ITEMS
; End of stack (begin of sp)
data_resb	stack, 0
