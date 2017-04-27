        PROGRAM TSTADC
C Tests the AD7606 ADC. 
C GPIO J13 pins 3 & 4 reserved for Posital Shaft Encoder
c CS,CONVST,RESET combined with 74HC139
C Outputs: CS,CONVST,SCLK,RESET  J13--5,7,9    BITS 1   ,2,3
C                                                   SCLK,A,B
C Init:    hi,hi    ,hi  ,lo
c Inputs:  DOUTA,DOUTB,BUSY      J13--6,8,10
C
        IMPLICIT NONE
        INTEGER*2 I,J,IOUT,ICTL,INP,IRAW(1:4)
        REAL  DATA(1:4)
C        
C INITIALIZE PORTS
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#C0))  !PORT 1 0-5 IN 6,7 OUT
        IOUT = #0F                        !00001111
        CALL OUTPUT(INT2(#78),IOUT)
C        PAUSE
        IOUT = IBCLR (IOUT,2)              !PULSE RESET
        IOUT = IBCLR (IOUT,3)
        CALL OUTPUT(INT2(#78),IOUT)       !SHORT DELAY
        CALL OUTPUT(INT2(#78),IOUT)
        CALL OUTPUT(INT2(#78),IOUT)
        IOUT = IBSET (IOUT,2)              !UNPULSE RESET
        IOUT = IBSET (IOUT,3)
        CALL OUTPUT(INT2(#78),IOUT)
c        goto 11
10      CONTINUE
        PRINT*, 'TAKE A READING ? (1=YES,2=STOP)'
        READ(*,*) ICTL
        IF (ICTL .NE. 1) STOP
c11      continue
C START CONVERSION
        IOUT = IBCLR (IOUT,3)              !NEG PULSE ON CONVST
        CALL OUTPUT(INT2(#78),IOUT)
        CALL OUTPUT(INT2(#78),IOUT)
        CALL OUTPUT(INT2(#78),IOUT)
        IOUT = IBSET (IOUT,3)              !UNPULSE CONVST
        CALL OUTPUT(INT2(#78),IOUT)       !SHORT DELAY
        CALL OUTPUT(INT2(#78),IOUT)
c        pause
        CALL FETCH(INT2(#79),INP)         !SHORT DELAY 
12      CONTINUE
        CALL FETCH(INT2(#79),INP)        
        IF(BTEST(INP,3)) GOTO 12          !WAIT FOR BUSY TO GO LO 
        IOUT = IBCLR (IOUT,2)              !DROP CS
        CALL OUTPUT(INT2(#78),IOUT)       !SHORT DELAY
        CALL OUTPUT(INT2(#78),IOUT)
C
        DO J=1,2                          !READ FOUR CHANNELS
          IRAW(J)=0
          IRAW(J+2)=0
          DO I=1,16                       !TOGGLE IN A BYTE
          IOUT = IBCLR (IOUT,1)
          CALL OUTPUT(INT2(#78),IOUT)     !CLK LOW-LATCH DATA
          IRAW(J) = ISHFT (IRAW(J),1)     !SHIFT PREVIOUS 1 BIT LEFT
          IRAW(J+2) = ISHFT (IRAW(J+2),1) !SHIFT PREVIOUS 1 BIT LEFT
          CALL FETCH(INT2(#79),INP)       !READ DATA 
          CALL FETCH(INT2(#79),INP)       !READ DATA 
          CALL FETCH(INT2(#79),INP)       !READ DATA 
          IOUT = IBSET (IOUT,1)           !SCLK HI  UNLATCH
          CALL OUTPUT(INT2(#78),IOUT)     !CLK HIGH-CLK IN NEW BIT
          IF(BTEST(INP,1)) IRAW(J)=IRAW(J)+1        !DOUTA
          IF(BTEST(INP,2)) IRAW(J+2)=IRAW(J+2)+1    !DOUTB
          ENDDO
        ENDDO
        IOUT = IBSET (IOUT,2)              !RAISE CS
        CALL OUTPUT(INT2(#78),IOUT)
C SCALE DATA AND PRINT
        DO J=1,4
          DATA(J) = REAL(IRAW(J))/3276.8        !+/- 10V RANGE
        ENDDO
        PRINT *, DATA
        GOTO 10
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END

