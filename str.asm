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
; str_len

; Definitions

; Get length of C format string. ds:si is address of string.
; Returned value is stored in cx
str_len:
	mac_push si

	xor cx, cx
.loop:
	cmp byte [si], 0
	je .ret

	inc si
	inc cx
	jmp .loop
.ret:
	mac_pop si
ret
