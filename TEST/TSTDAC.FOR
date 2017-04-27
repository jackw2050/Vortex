        PROGRAM TSTDAC
C Tests the AD5764 DAC. 
C Outputs: SCLK,SYNCH,DATA  J13--13,15,17
C Init:    HI,  HI,   LO
c IOUT is put in common because its bits are the settings
c for other devices as well. We must be careful not to
c alter the bits for other devices.
C
        IMPLICIT NONE
        INTEGER*2 IOUT,IDAT,ICH
        COMMON IOUT
        REAL  VOLTS
C        
C INITIALIZE PORTS
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#00))  !SET PORT 1 TO INPUT
        IOUT = IBSET(IOUT,5)    !SCLK HI
        IOUT = IBSET(IOUT,6)    !SYNCH HI
        IOUT = IBCLR(IOUT,7)    !DATA LO
        CALL OUTPUT(INT2(#78),IOUT)
10      CONTINUE
        PRINT *, 'INPUT ICH (1-4) AND VOLTS ICH=9 TO END'
        READ (*,*) ICH,VOLTS
        IF (ICH .EQ. 9) STOP
        IDAT = VOLTS*3276.7
        CALL DACOUT(ICH,IDAT)
        GOTO 10
        END
C *********************** DACOUT *************************
        SUBROUTINE DACOUT (ICH,IDAT)
C  DRIVER FOR THE AD5764 DAC
C ICH IS THE OUT DAC 1-4
C IDAT IS THE 16BIT TWOS COMPLEMENT VOLTAGE VALUE
        IMPLICIT NONE
        INTEGER*2 I,IOUT,ICH,IDAT
        INTEGER*4 IROOT(4),TEMP
        COMMON IOUT
        IROOT(1)=#0100000             !DAC1
        IROOT(2)=#0110000             !DAC2
        IROOT(3)=#0120000             !DAC3
        IROOT(4)=#0130000             !DAC4
C COMBINE ROOT WITH DATA
        TEMP = IAND (INT4(IDAT),#0000FFFF)  !CLEAR TOP TWO BYTES
        TEMP = IOR(TEMP,IROOT(ICH))         !COMBINE WITH ROOT
c        TEMP = IOR(INT4(IDAT),IROOT(ICH))
        IOUT = IBCLR (IOUT,6)    !SYNCH LO
        CALL OUTPUT(INT2(#78),IOUT)
        print '(z)', temp
        DO I=23,0,-1
          IOUT = IBSET(IOUT,5)   !CLOCK HIGH
          CALL OUTPUT(INT2(#78),IOUT)
          IF (BTEST(TEMP,I)) THEN
            IOUT = IBSET(IOUT,7)        !DATA BIT
          ELSE
            IOUT = IBCLR(IOUT,7)
          ENDIF
          CALL OUTPUT(INT2(#78),IOUT)
          IOUT = IBCLR(IOUT,5) !CLOCK LO LOADS BIT
          CALL OUTPUT(INT2(#78),IOUT)
        ENDDO
        IOUT = IBSET(IOUT,5)    !CLOCK HI
        CALL OUTPUT(INT2(#78),IOUT)
        IOUT = IBSET(IOUT,6)    !SYNCH HI
        CALL OUTPUT(INT2(#78),IOUT)
        RETURN
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END

