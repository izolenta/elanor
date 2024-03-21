MAX_ARGS:	equ 1

  include "crt.inc"

  macro DEFSPRITE num, file, width, height
    db 23, 0, $A0
    dw num
    db 2
    db 23, 0, $A0
    dw num
    db 0
    dw width * height
    incbin file
    db 23, 27, $20
    dw num
    db 23, 27, $21
    dw width, height
    db 1
    endmacro

;; Here starts our game's code
_main:	
  call vdp_init

  ld hl, PNG_LOGO
  call bmp_select

  ld.sis de, $00
  call bmp_draw

  ld hl, PNG_WALLBLK
  call bmp_select

  ld b, 20
  ld d, 8
  ld e, 0

@loop:
    push bc
    push de
    call bmp_draw
    pop de
    push de
    ld a, 20
    add a, d
    ld d, a
    call bmp_draw
    pop de
    inc e
    inc e
    pop bc
    djnz @loop

  ld b, 11
  ld d, 10
  ld e, 0

@loop2:
    push bc
    push de
    call bmp_draw
    pop de
    push de
    ld a, 38
    add a, e
    ld e, a
    call bmp_draw
    pop de
    inc d
    inc d
    pop bc
    djnz @loop2

  ret

PNG_LOGO:	equ $0000
PNG_WALLBLK: equ $0001

vdp_init:
  ld hl, init_cmd              ;; Setting start address for our VDP commands
  ld bc, init_cmd_end-init_cmd ;; Setting packet lenght
  rst.lil $18                  ;; And sending them to VDP
  ret
init_cmd:
  db 22, 8 	;; Setting video mode 1(similar to "VDU 22,1" command)
  
  ;; Here goes including our sprites "BMP_...." names are constants that we'd set several lines before 
  DEFSPRITE PNG_LOGO, "img/elanor.rgba", 320, 57
  DEFSPRITE PNG_WALLBLK, "img/brick.rgba", 16, 16
  ;; ... skipped a bit ...

  db 12       ;; Cleaning screen
init_cmd_end:

; HL - number
bmp_select:
	ld (@bmp), hl       ;; Labels started with "@" are local. We're storing bitmap number to our packet
	ld hl, @cmd         ;; Setting our command start
	ld bc, @end-@cmd    ;; Setting our command lenght
	rst.lil $18         ;; Sending our packet by one request
	ret
@cmd:
	db 23, 27, $20
@bmp:
	dw 0
@end:

; DE - Coordinates(reg E - x, reg D - y)
bmp_draw:
  ld.lil bc, 0
	ld b, 8
	ld c, e
	mlt bc

	ld a, c
	ld (@c_x), a
	ld a, b
	ld (@c_x+1), a

  ld.lil bc, 0
	ld b, 8
	ld c, d
	mlt bc

  ld a, c
	ld (@c_y), a
	ld a, b
	ld (@c_y+1), a

	ld hl, @cmd
	ld bc, @end-@cmd
  di
	rst.lil $18     ;; Sending command to VDP
  ei
	ret
@cmd: 
  db 23, 27, 3
@c_x: 
  dw 0
@c_y:	
  dw 0
@end:
