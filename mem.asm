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

; mem_alloc
; mem_free
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

; Allocate one block of memory. Returned segment is stored in ax
; on error, CF is set and ax contains 0
mem_alloc:
	mac_push es, si, cx, dx
	; Find unallocated block
	mov es, [data_dynmem_seg]
	mov si, 0
.find_free_byte_loop:
	cmp byte [es:si], 0xff
	jne .free_byte_found
	; Byte is 0xff -> full
	inc si
	mov ax, si
	shl ax, 3
	cmp ax, [data_dynmem_no_blocks]
	; If si * 8 < data_dynmem_no_blocks -> loop
	jb .find_free_byte_loop
	; We didn't found free byte -> error
	jmp .ret_not_found

.free_byte_found:
	mov cx, 0
.find_free_bit_loop:
	mov al, [es:si]
	shr al, cl
	and al, 0x01
	jz .free_bit_found
	inc cl
	jmp .find_free_bit_loop

.free_bit_found:
	; Set bit full
	mov al, 0x01
	shl al, cl
	or byte [es:si], al
	; Compute segment
	mov ax, si
	shl ax, 3
	add ax, cx
	mov dx, (MEM_BLOCK_SIZE / 16)
	mul dx
	add ax, [data_dynmem_seg]
	add ax, (MEM_BLOCKS_OFFSET / 16)
	clc
	jmp .ret
.ret_not_found:
	mov ax, 0
	stc
.ret:
	mac_pop es, si, cx, dx
ret

; Free one block of memory. AX contains segment of allocated memory.
mem_free:
	mac_push es, ax, cx, dx, si

	mov es, [data_dynmem_seg]
	sub ax, (MEM_BLOCKS_OFFSET / 16)
	sub ax, [data_dynmem_seg]
	; ax is segment to set
	mov cx, (MEM_BLOCK_SIZE / 16)
	xor dx, dx
	div cx
	; ax is bit to set
	mov si, ax
	shr si, 3
	; si is byte to set
	mov cx, ax
	and cx, 0x07
	; cx (cl) is bit in byte to set
	mov al, 0x01
	shl al, cl
	not al
	; al is mask to and
	and byte [es:si], al

	mac_pop es, ax, cx, dx, si
ret

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
