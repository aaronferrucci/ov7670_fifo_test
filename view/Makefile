pix.bin: ../PIX.hex tobin.pl
	perl tobin.pl ../PIX.hex
	convert -depth 8 -size 640x102+0 gray:pix.bin out.png
