        PROGRAM TSTDAC
c Modified for ZLS_018 REV 7
C Permits setting output pins as desired to exercise GPIO
c IOUT is put in common because its bits are the settings
c for other devices as well. We must be careful not to
c alter the bits for other devices.
C Pins 0 to 7 are port 0 and pins 8&9 are port 1
        IMPLICIT NONE
        INTEGER*2 IOUT,IDAT,IPIN,ITEMP
        COMMON IOUT
C        
C INITIALIZE PORTS
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#C0))  !PORT 1 0-5 IN  6,7 OUT
C        IOUT = IBSET(IOUT,4)    !SCLK HI
C        IOUT = IBSET(IOUT,5)    !SYNCH HI
C        IOUT = IBCLR(IOUT,6)    !DATA LO
        IOUT = 0
        CALL OUTPUT(INT2(#78),IOUT)
10      CONTINUE
        PRINT *, 'INPUT PIN (0-9) AND VALUE (0-1) IPIN=99 TO END'
        READ (*,*) IPIN,IDAT
        IF (IPIN .EQ. 99) STOP
        IF (IDAT .EQ. 1) IOUT = IBSET(IOUT,IPIN)
        IF (IDAT .EQ. 0) IOUT = IBCLR(IOUT,IPIN)
        ITEMP = IAND(IOUT,#0FF)  !MASK OFF HIGH BYTE
        CALL OUTPUT(INT2(#78),ITEMP)
        ITEMP = ISHFT(IOUT,-2)     !WE DO NOT WANT TO CHANGE IOUT
        ITEMP = IAND(ITEMP,#C0)
        CALL OUTPUT(INT2(#79),ITEMP)
          PRINT *, IOUT, ITEMP
        GOTO 10
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END

