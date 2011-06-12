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

; mem_int_clear
; mem_int_malloc
; mem_sysmem_realloc

; Constants
; Minimal system memory to alloc
MEM_SYSMEM_MIN	equ 1024 * 16
; Prefered system memory to alloc
MEM_SYSMEM_PREF	equ 1024 * 64 * 4

; Definitions

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
	mov bx, MEM_SYSMEM_PREF / 16
	call dos_malloc
	jnc .ret
	; Allocation was unsuccessful
	; bx now contains largest block to alloc
	cmp bx, MEM_SYSMEM_MIN / 16
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
