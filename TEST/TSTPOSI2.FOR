        PROGRAM TSTGPIO
C Tests the POSITAL shaft encoder. 
C Connect CLK to port GP00 (J13 pin 3)
C Connect DATA to port GP10 (J13 pin 4)
C The lower 25 bits of I4RES contains the data.
c The rightmost 12 contains number of turns and the upper
c contains the angle.
C Modified to take two readings to check for errors.
C
        INTEGER*2 I,J,IOUT,INP,ICTL,IANG,ICNT
        INTEGER*4 I4RES(2)
c        REAL*4 ST
        REAL ST
C        
C INITIALIZE PORTS
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#00))  !SET PORT 1 TO INPUT
c        IOUT = IBSET(IOUT,0)
        IOUT = 1
        CALL OUTPUT(INT2(#78),IOUT)      !SET CLK HIGH
10      CONTINUE
        PRINT*, 'TAKE A READING ? (1=YES,2=STOP)'
        READ(*,*) ICTL
        IF (ICTL .NE. 1) STOP
        ICNT = 0
11      CONTINUE
        DO J=1,2
          ICNT = ICNT+1
          I4RES(J) = 0
          DO I=0,25
              IOUT = IBCLR(IOUT,0)
              CALL OUTPUT(INT2(#78),IOUT)     !CLK LOW-LATCH DATA
              I4RES(J) = ISHFT (I4RES(J),1)   !SHIFT PREVIOUS 1 BIT LEFT
              CALL FETCH(INT2(#79),INP)       !READ DATA GP1
              IOUT = IBSET(IOUT,0)
              CALL OUTPUT(INT2(#78),IOUT)     !CLK HIGH-CLK IN NEW BIT
              IF(BTEST(INP,0)) I4RES(J)=I4RES(J)+1
C              PRINT *, IOUT,INP
          ENDDO
        ENDDO
C separate and scale data
        IF (I4RES(1) .NE. I4RES(2)) THEN
           IF (ICNT .GT. 4) THEN
             PRINT *, 'READ FAILED AFTER 5 TRYS'
             GOTO 10
           ENDIF
           GOTO 11
        ENDIF
        print*, i4res(1)
        IANG = IAND(I4RES(1),INT4(#0FFF))      !MASK BOTTOM 12 BITS 
        I4RES(1) = ISHFT(I4RES(1),-12)         !SHIFT RIGHT 12 BITS
        ITURNS = IAND(I4RES(1),INT4(#1FFF))    !MASK BOTTOM 13 BITS
        ST = REAL(ITURNS)*10.+(REAL(IANG)*10./4096.)
        PRINT*, ITURNS,IANG,ST
        print*
        GOTO 10
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END

