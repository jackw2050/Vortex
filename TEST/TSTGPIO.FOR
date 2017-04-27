        PROGRAM TSTGPIO
C This program tests the GPIO functions of the vortex board.
c These 16 inputs and outputs are found on connector J13
c Only ports 0 and 1 are available at the connector.
c program sets port 0 to outputs and port 1 to inputs and viceversa
c Test Harness connect pin 3 to pin 4 up to pin 17 to 18
C
        INTEGER*2 IOUT,INP
C        
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#00))  !SET PORT 1 TO INPUT
        DO IOUT=0,15
            CALL OUTPUT(INT2(#78),IOUT)   !WRITE PORT 0
            CALL FETCH(INT2(#79),INP)     !READ PORT 1
            PRINT *, IOUT,INP
        ENDDO
C Reverse in and out and do it again
        PRINT *, 'REVERSE PORTS'
        PAUSE
        CALL OUTPUT(INT2(#99),INT2(#FF))  !SET PORT 1 TO OUTPUT
        CALL OUTPUT(INT2(#98),INT2(#00))  !SET PORT 0 TO INPUT
        DO IOUT=0,15
            CALL OUTPUT(INT2(#79),IOUT)   !WRITE PORT 1
            CALL FETCH(INT2(#78),INP)     !READ PORT 0
            PRINT *, IOUT,INP
        ENDDO
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END
