C **************** INITFOG ******************************
        SUBROUTINE INITFOG
        INTEGER*2 IPORT,NPORT
        NPORT = #03F8        !COM1
        IPORT = NPORT+1
        CALL OUTPUT (IPORT,INT2(0))   !TURN OFF INTERRUPTS
        IPORT = NPORT+3
        CALL OUTPUT (IPORT,INT2(#80)) !SET DLAB ON
        IPORT = NPORT
        CALL OUTPUT (IPORT,INT2(#03)) !DIVISOR LOW BYTE FOR 38,400 BPS 
        IPORT = NPORT+1
        CALL OUTPUT (IPORT,INT2(#00)) !DIVISOR HIGH BYTE
        IPORT = NPORT+3
        CALL OUTPUT (IPORT,INT2(#0B)) !8 data,odd parity,one stop bit
        IPORT = NPORT+2
        CALL OUTPUT (IPORT,INT2(#C7)) !FIFO CONTROL
        IPORT = NPORT+4
        CALL OUTPUT (IPORT,INT2(#0B)) !TURN ON DTR, RTS, AND OUT2
C
C        IPORT = NPORT
c        CALL OUTPUT (IPORT,INT2(#01))   !INITIAL SOFTWARE TRIGGER
c        CALL OUTPUT (IPORT,INT2(#FE))   !CHECKSUM
        RETURN
        END
