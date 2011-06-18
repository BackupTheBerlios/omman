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

; Constants

; Maximal length of path + trailing 0
LIM_MAXPATH	equ 80
; Maximal length of drive definition (including trailing : and 0)
LIM_MAXDRIVE	equ  3
; Maximum length of directory (including starting and trailing \ and 0)
LIM_MAXDIR	equ 66
; Maxfimum length of file name (including trailing 0)
LIM_MAXFILE	equ  9
; Maximum length of file extension (including starting . and trailing 0)
LIM_MAXEXT	equ  5
