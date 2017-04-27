        PROGRAM TSTADC
C Tests the AD7606 ADC. 
C GPIO J13 pins 3 & 4 reserved for Posital Shaft Encoder
c All otputs are inverted to accommodate 74HC14 level conversion
C Outputs: CS,CONVST,SCLK,RESET  J13--5,7,9,11
C Init:    lo,lo    ,lo  ,hi
c Inputs:  DOUTA,DOUTB,BUSY      J13--6,8,10
C
        IMPLICIT NONE
        INTEGER*2 I,J,IOUT,ICTL,INP,IRAW(1:6)
        REAL  DATA(1:6)
C        
C INITIALIZE PORTS
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#00))  !SET PORT 1 TO INPUT
        IOUT = #11                        !00010001
        CALL OUTPUT(INT2(#78),IOUT)
        IOUT = IBCLR (IOUT,4)             !PULSE RESET
c        CALL OUTPUT(INT2(#78),IOUT)       !SHORT DELAY
        CALL OUTPUT(INT2(#78),IOUT)
        IOUT = IBSET (IOUT,4)
        CALL OUTPUT(INT2(#78),IOUT)
10      CONTINUE
        PRINT*, 'TAKE A READING ? (1=YES,2=STOP)'
        READ(*,*) ICTL
        IF (ICTL .NE. 1) STOP
C START CONVERSION
        IOUT = IBSET (IOUT,2)             !NEG PULSE ON CONVST
        CALL OUTPUT(INT2(#78),IOUT)
        IOUT = IBCLR (IOUT,2)                    
c        CALL OUTPUT(INT2(#78),IOUT)       !SHORT DELAY
        CALL OUTPUT(INT2(#78),IOUT)
c        CALL FETCH(INT2(#79),INP)         !SHORT DELAY 
12      CONTINUE
        CALL FETCH(INT2(#79),INP)        
        IF(BTEST(INP,3)) GOTO 12          !WAIT FOR BUSY TO GO LO 
        IOUT = IBSET (IOUT,1)             !DROP CS
c        CALL OUTPUT(INT2(#78),IOUT)       !SHORT DELAY
        CALL OUTPUT(INT2(#78),IOUT)
C
        DO J=1,3                          !READ SIX CHANNELS
          IRAW(J)=0
          IRAW(J+3)=0
          DO I=1,16                       !TOGGLE IN A BYTE
          IOUT = IBSET (IOUT,3)
          CALL OUTPUT(INT2(#78),IOUT)     !CLK LOW-LATCH DATA
          IRAW(J) = ISHFT (IRAW(J),1)     !SHIFT PREVIOUS 1 BIT LEFT
          IRAW(J+3) = ISHFT (IRAW(J+3),1) !SHIFT PREVIOUS 1 BIT LEFT
          CALL FETCH(INT2(#79),INP)       !READ DATA 
          CALL FETCH(INT2(#79),INP)       !READ DATA 
          CALL FETCH(INT2(#79),INP)       !READ DATA 
          IOUT = IBCLR (IOUT,3)
          CALL OUTPUT(INT2(#78),IOUT)     !CLK HIGH-CLK IN NEW BIT
          IF(BTEST(INP,1)) IRAW(J)=IRAW(J)+1        !DOUTA
          IF(BTEST(INP,2)) IRAW(J+3)=IRAW(J+3)+1    !DOUTB
          ENDDO
        ENDDO
        IOUT = IBCLR (IOUT,1)             !RAISE CS
        CALL OUTPUT(INT2(#78),IOUT)
C SCALE DATA AND PRINT
        DO J=1,6
          DATA(J) = REAL(IRAW(J))/3276.8        !+/- 10V RANGE
        ENDDO
        PRINT *, DATA
        GOTO 10
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END

