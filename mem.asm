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

; mem_init
; mem_int_clear
; mem_int_malloc
; mem_sysmem_realloc

; Constants

; Dynamic memory block size
MEM_BLOCK_SIZE		equ 1024
; Minimal system memory to alloc
MEM_SYSMEM_MIN		equ MEM_BLOCK_SIZE * 16
; Prefered system memory to alloc
MEM_SYSMEM_PREF		equ MEM_BLOCK_SIZE * 64 * 4
; Number of blocks
MEM_NO_BLOCKS		equ MEM_SYSMEM_PREF / MEM_BLOCK_SIZE
; Size of bitmap with allocated blocks
MEM_BITMAP_SIZE		equ MEM_NO_BLOCKS / 8
; Offset of bitmap
MEM_BITMAP_OFFSET	equ 0
; Offset of fist block
MEM_BLOCKS_OFFSET	equ MEM_BITMAP_SIZE

; Definitions

; Initialize memory
mem_init:
	call mem_int_malloc
	mov [data_dynmem_seg], ax
	mov [data_dynmem_size], bx

	; Divide data_dynmem_size by mem_block_size to get number of really
	; allocated blocks
	xor dx, dx
	mov ax, bx
	sub ax, (MEM_BITMAP_SIZE / 16)
	mov bx, (MEM_BLOCK_SIZE / 16)
	div bx
	mov [data_dynmem_no_blocks], ax

	call mem_int_clear
ret

; Clear allocated memory
mem_int_clear:
	xor ax, ax
	mov es, [data_dynmem_seg]
	mov bx, [data_dynmem_size]

.loop:
	xor di, di
	mov cx, 8

	rep stosw

	; inc es
	mov cx, es
	inc cx
	mov es, cx

	dec bx
	jnz .loop
ret

; Malloc memory. After successful allocation, ax contains segment of
; memory and bx allocated memory
mem_int_malloc:
	mov bx, (MEM_SYSMEM_PREF + MEM_BITMAP_SIZE) / 16
	call dos_malloc
	jnc .ret
	; Allocation was unsuccessful
	; bx now contains largest block to alloc
	cmp bx, (MEM_SYSMEM_MIN + MEM_BITMAP_SIZE) / 16
	; If allocatable block < MIN -> exit
	jb .error_exit
	; alloc maximum possible <MEM_SYSMEM_MIN, MEM_SYSMEM_PREF)
	call dos_malloc
	; If alloc is sucesfull, ret
	jnc .ret

.error_exit:
	mov al, 1
	call dos_exit
	; NOTREACHED
.ret:
ret

; Reallocate system memory to minimal working size
mem_sysmem_realloc:
	mov ax, cs
	mov es, ax
	mov bx, ((data_stack - $$ + 0x100) / 16) + 1
	call dos_realloc
ret
