PUBLIC  run
PUBLIC  _run

PUBLIC  adcvrt
PUBLIC  _adcvrt

PUBLIC  read_temperature
PUBLIC  _read_temperature

run:
_run:
    call    subcpu_on
    ld      de,packet
    call    subcpu_call
    ld      de,draw_cmd
    ld      (packet),de
    ld      hl,packsz
    ld      (hl),4
    exx
    ld      de,packet
    exx
    ld      b,0
    ld      d,64
.redraw
    ld      a,(ycoord)
    inc     a
    cp      42
    jp      nz,inc_ok
    ld      a,0
.inc_ok
    ld      (ycoord),a
    exx
    call    subcpu_call
    exx
    djnz    redraw
    dec     d
    jp      nz,redraw
    call    subcpu_off
    ret

subcpu_on:
    ld      hl,(1)
    ld      bc,$f358
    ld      a,$eb           ; Overseas version ?  ( HC-80 should be $E7, HC-88 is probably $C1)
    cp      h
    jr      z,european
    ld      bc,$f080
.european
    ld      a,$ff       ; SLVFLAG, enable all the communications with the slave CPU
    ld      (bc),a
    ret

subcpu_off:
    ld      hl,(1)
    ld      bc,$f358
    ld      a,$eb           ; Overseas version ?  ( HC-80 should be $E7, HC-88 is probably $C1)
    cp      h
    jr      z,european1
    ld      bc,$f080
.european1
    ld      a,$00       ; SLVFLAG, disable all the communications with the slave CPU
    ld      (bc),a
    ret

subcpu_call:
    ld      hl,(1)          ; Use WBOOT address to find the first entry in the BIOS jp table
    ld      a,$72           ; slave BIOS call offset
    add     l
    ld      l,a
    jp      (hl)
    ret

.conin
    ld      de,6   ; CONIN offset
    jr      console
.const
    ld      de,3   ; CONST offset
    jr      console
.conout
    ld      de,9    ; CONOUT offset
.console
    ld      hl,(1) ; WBOOT (BIOS)
    add     hl,de
    jp      (hl)

adcvrt:
_adcvrt:
    ld      c,l
    ld      hl,retaddr
    push    hl
    ld      hl,(1)
    ld      de,0x6F
    add     hl,de
    jp      (hl)
.retaddr
    ld      l,a
    ld      h,0
    ret

read_temperature:
_read_temperature:
    ; Disable interrupts
    di
    ; Send command to 7508
    in      a,(005h)    ; Status register, bit 3 carries the control signal for the serial bus to the 7508
    and     008h
    jr      z,read_temperature
    ld      a,1Ch       ; read temperature command
    out     (006h),a    ; send data to the 7508
    ld      a,2
    out     (001h),a    ; reset the control signal
    ; Receive result from 7508
.wait_7508
    in      a,(005h)
    and     008h
    jr      z,wait_7508
    in      a,(006h)    ; receive data from 7508
    ; Store the result
    ld      l,a
    ld      h,0
    ; Reset the control signal
    ld      a,2
    out     (001h),a
    ; Enable interrupts
    ei
    ret

.packet
    defw    spr_cmd
.packsz
    defw    73
    defw    result
    defw    1

.draw_cmd
    defb    0x23
    defb    2
.ycoord
    defb    0
    defb    1

.spr_cmd
    defb    0x20
    defb    1
    defb    3
    defb    23
    defb    %"--------", %"--------", %"--------"
    defb    %"--------", %"-------#", %"#######-"
    defb    %"--------", %"------##", %"-#######"
    defb    %"--------", %"------##", %"########"
    defb    %"--------", %"------##", %"########"
    defb    %"--------", %"------##", %"########"
    defb    %"--------", %"------##", %"###-----"
    defb    %"--------", %"------##", %"######--"
    defb    %"----#---", %"-----###", %"##------"
    defb    %"----#---", %"---#####", %"##------"
    defb    %"----##--", %"--######", %"####----"
    defb    %"----###-", %"-#######", %"##-#----"
    defb    %"----####", %"########", %"##------"
    defb    %"----####", %"########", %"##------"
    defb    %"-----###", %"########", %"#-------"
    defb    %"------##", %"########", %"#-------"
    defb    %"-------#", %"########", %"--------"
    defb    %"--------", %"#######-", %"--------"
    defb    %"--------", %"-###-##-", %"--------"
    defb    %"--------", %"-##---#-", %"--------"
    defb    %"--------", %"-#----#-", %"--------"
    defb    %"--------", %"-##---##", %"--------"
    defb %"--------", %"--------", %"--------"

.result
    defw    0