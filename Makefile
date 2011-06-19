# Copyright (c) 2011, Jan Friesse <jfriesse@users.berlios.de>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
#

SRC = const.asm data.asm dirm.asm dos.asm err.asm mac.asm main.asm mem.asm str.asm
ASM = nasm

omman.com: $(SRC)
	$(ASM) -f bin main.asm -o omman.com

clean:
	rm -rf omman.com *~

# Run program inside sandbox directory in dosbox
run: omman.com
	mkdir -p sandbox
	cp omman.com sandbox
	dosbox -c "mount c sandbox" -c "c:" -c "omman.com" -c "exit"

# Debug program inside sandbox directory in dosbox and insight debugger
run-debug: omman.com
	mkdir -p sandbox
	cp omman.com sandbox
	dosbox -c "mount c sandbox" -c "c:" -c "insight.com omman.com" -c "exit"
