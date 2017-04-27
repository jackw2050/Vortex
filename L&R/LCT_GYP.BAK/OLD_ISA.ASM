        ;********* STST ***********************************
COMMENT "Stores the spring tension in unused memory in the CMOS
        clock. Memory cells 7c to 7f are used.
        CALL STST(value)
        value is REAL*4"
PUBLIC  stst
stst    PROC far
        PUSH BP
        MOV BP,SP
        les bx,dword ptr [bp+6]         ;load address of argument
        mov dx,es:[bx]                  ;get data
        mov al,7ch                      ;cell for ST first byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        mov al,dh
        out 71h,al                      ;store first byte
        jmp $+2                         ;clr ports,delay
        mov al,7dh                      ;cell for second byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        mov al,dl
        out 71h,al                      ;store second byte
        jmp $+2                         ;clr ports,delay
        mov dx,es:[bx]+2                ;get more data
        mov al,7eh                      ;cell for third byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        mov al,dh
        out 71h,al                      ;store third byte
        jmp $+2                         ;clr ports,delay
        mov al,7fh                      ;cell for fourth byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        mov al,dl
        out 71h,al                      ;store second byte
        jmp $+2                         ;clr ports,delay
        ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        POP BP
        RET 04h
stst    ENDP
        ;********* GTST ***********************************
COMMENT "Retrieves spring tension from CMOS clock memory
        value must be loaded with STST prior to use
        CALL GTST(value)
        value is REAL*4"
PUBLIC  gtst
gtst    PROC far
        PUSH BP
        MOV BP,SP
        les bx,dword ptr [bp+6]         ;load address of argument
        mov al,7ch                      ;cell for first byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        in al,71h                       ;get first byte
        jmp $+2                         ;clr ports,delay
        mov dh,al
        mov al,7dh                      ;cell for second byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        in al,71h                       ;get second byte
        jmp $+2                         ;clr ports,delay
        mov dl,al
        mov es:[bx],dx                  ;return two bytes
        mov al,7eh                      ;cell for third byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        in al,71h                       ;get third byte
        jmp $+2                         ;clr ports,delay
        mov dh,al
        mov al,7fh                      ;cell for fourth byte
        out 70h,al                      ;select it
        jmp $+2                         ;clr ports,delay
        in  al,71h                      ;get fourth byte
        jmp $+2                         ;clr ports,delay
        mov dl,al
        mov es:[bx]+2,dx                ;return two more bytes
        ;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        POP BP
        RET 04h
gtst    ENDP
;
;
cseg    ends
;
        end
