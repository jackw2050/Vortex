        PROGRAM TSTDAC
c Modified for ZLS_018 REV 7
C Permits setting output pins as desired to exercise GPIO
c IOUT is put in common because its bits are the settings
c for other devices as well. We must be careful not to
c alter the bits for other devices.
C Pins 0 to 7 are port 0 and pins 8&9 are port 1
        IMPLICIT NONE
        INTEGER*2 IDAT,IPIN,IOUT
        LOGICAL TEMP
C        COMMON IOUT
C        
C INITIALIZE PORTS
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#C0))  !PORT 1 0-5 IN  6,7 OUT
        CALL OUTPUT(INT2(#78),IOUT)
10      CONTINUE
        PRINT *, 'INPUT PIN (0-5) IPIN = 99 TO STOP'
        READ (*,*) IPIN
        IF (IPIN .EQ. 99) STOP
        CALL FETCH(INT2(#79),IDAT)     !READ PORT 1
        TEMP = BTEST(IDAT,IPIN)
        PRINT *, IPIN,TEMP
        GOTO 10
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END


