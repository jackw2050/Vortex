        PROGRAM TSTSLEW
        IMPLICIT NONE
        INTEGER*2 IOADD(0:15),IDAC(4)
        INTEGER*2 IVALUE,I
        REAL TARGET,st
        COMMON /ADD/ IOADD
C

C INITIALIZE IO ADDRESSES
c        print*, 'ioadd'
        DO I = 0,15
        IOADD(I) = #300 + I*2     !SET BOARD BASE ADDRESS HERE
c        print*, i,ioadd(i)
        ENDDO
C INITIALIZE POSITAL ENCODER
        CALL INITPOSI 
C ZERO DACS
c        print*, 'dac'
        DO I=1,4
           IDAC(I) = 0
           CALL OUTPUTW (IOADD(I+7),IDAC(I))    
        ENDDO
C INITIALIZE TIMER 2    ! uDELAY
c        print*, 'timer'
        IVALUE = #B0                        !MODE 0
        CALL OUTPUT (IOADD(7),IVALUE)
C
c        pause
10      CONTINUE
        print*, 'new'
        do i = 1,20
           call udelay (25,1)
           call readst(st)
           print*, st
        enddo
        PRINT *, 'ENTER NEW TARGET, -99 TO STOP' 
        READ (*,*) TARGET
        IF (TARGET .EQ. -99.) STOP
        CALL SLEWST (TARGET)
        CALL UDELAY (25,1)
        GOTO 10
        END
C *********************** SLEWST ***********************
C MOVES ST TO A SPECIFIED VALUE
C WE HAVE TO ADD CODE TO DEAL WITH READST ERROR -99
        SUBROUTINE  SLEWST (TARGET)
        IMPLICIT NONE
        REAL TARGET,ST
        INTEGER*2 IDIR,IOADD(0:15),IDAC,icnt
        COMMON /ADD/ IOADD
C
        ST = 0.
        IDIR = 1                         ! TURN UPSCALE
        CALL READST(ST)
        print*, st,target,ioadd(10)
c        pause
        IF (ABS(TARGET-ST) .LE. 0.05)  RETURN
        IF (ST .GT. TARGET)  IDIR = -1   !TURN DOWNSCALE
        IF (ABS(TARGET-ST) .LE. 100.)  GOTO 15  !LESS THAN 10 TURNS
        IDAC = IDIR*32767                !FULL SPEED 10V
        CALL OUTPUTW (IOADD(10),IDAC)    !WRITE TO DAC 3 
        icnt = 0
        DOWHILE (ABS(TARGET-ST) .GT. 100.)
            CALL UDELAY(25,1)            ! 25 MICROSEC DELAY
            CALL READST(ST)
            icnt = icnt + 1
            if (icnt .gt. 5000) then
                print*, st
                icnt = 0
            endif
        ENDDO
15      CONTINUE
        IDAC = IDIR*6553                !SLOW SPEED 2V
C        IDAC = IDIR*4915                !SLOW SPEED 1.5
C        IDAC = IDIR*2458                 !SLOW SPEED 0.75
        CALL OUTPUTW (IOADD(10),IDAC)    !WRITE TO DAC 3 
        icnt = 0
C        DOWHILE (ABS(TARGET-ST) .GT. 0.05)
        DOWHILE (ABS(TARGET-ST) .GT. 0.5) !ALLOW FOR OVERSHOOT
            CALL UDELAY(25,1)
            CALL READST(ST)
            icnt = icnt + 1
            if (icnt .gt. 5000) then
                print*, st
                icnt = 0
            endif
        ENDDO
C NICE IDEA BUT DID NOT WORK - TOO TOUCHY
C        IDAC = -IDAC/2        !REVERSE TORQUE TO STOP OVERSHOOT
C        CALL OUTPUTW (IOADD(10),IDAC)    !WRITE TO DAC 3 
C        CALL UDELAY(50,100)
C ----------------
        IDAC = 0                        ! STOP MOTOR
        CALL OUTPUTW (IOADD(10),IDAC)    !WRITE TO DAC 3 
        RETURN
        END
c********************** UDELAY **********************
        SUBROUTINE UDELAY(NDEL,ITIC)
C USES THE 82C54 TIMER 2 TO CREATE SHORT ACCURATE DELAYS
C ITIC IS THE TICK LENGTH IN MICROSECONDS
C NDEL IS THE NUMBER OF TICKS TO DELAY
C NDEL AND ITIC ARE INTEGER*4
C ITIC MAY NOT BE LESS THAN 1 OR GREATER THAN 4000
C CLOCK IS 7.16 MHz
c        INCLUDE 'PROLOGUE.INC'
        IMPLICIT INTEGER*2 (I-N)
        INTEGER*4 NDEL,ITIC
        INTEGER*2 IOADD(0:15),ITEMP
        COMMON /ADD/ IOADD
c
        DO I=1,NDEL      
        ICOUNT = 0
C        IPORT = #30C
        IVALUE = INT2(7*ITIC)         !DIVISOR FOR TIC SIZE
        ITEMP = IAND(IVALUE,#FF)
        CALL OUTPUT (IOADD(6),ITEMP)
        ITEMP = ISHFT(IVALUE,-8)
        CALL OUTPUT (IOADD(6),ITEMP)
C       GET STATUS
100     CONTINUE
        ICOUNT = ICOUNT+1
        IF (ICOUNT .GT. 30000) GOTO 200
C        IPORT = #30E
        IVALUE = #E8                            ! LATCH STATUS
        CALL OUTPUT (IOADD(7),IVALUE)
C        IPORT = #30C                            
        CALL FETCH (IOADD(6),IVALUE)            ! READ STATUS
        IF (.NOT.(BTEST(IVALUE,7))) GOTO 100    ! TEST BIT 7
        ENDDO
        RETURN
200     PRINT *, 'TIMED OUT uDELAY',ndel,itic
        RETURN
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END
c *********************** READST **************************
        SUBROUTINE READST (ST)
C READS ST FROM THE POSITAL ENCODER. PERFORMS TWO RAPID READS
C WHICH SHOULD BE IDENTICAL UNLESS TRANSMISSION ERRORS OCCUR.
C AFTER 5 TRYS PROGRAM RETURNS -99 AS ST.
C Connect CLK to port GP00 (J13 pin 3)
C Connect DATA to port GP10 (J13 pin 4)
C The lower 25 bits of I4RES contains the data.
c The rightmost 12 contains number of turns and the upper
c contains the angle.
        IMPLICIT NONE
        INTEGER*2 I,J,IOUT,INP,IANG,ICNT
        INTEGER*4 I4RES(2),ITURNS
        REAL*4 ST
C
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
                ST = -99
                RETURN
           ENDIF
           GOTO 11
        ENDIF
C        print*, i4res(1)
        IANG = IAND(I4RES(1),INT4(#0FFF))      !MASK BOTTOM 12 BITS 
        I4RES(1) = ISHFT(I4RES(1),-12)         !SHIFT RIGHT 12 BITS
        ITURNS = IAND(I4RES(1),INT4(#1FFF))    !MASK BOTTOM 13 BITS
        ST = REAL(ITURNS)*10.+(REAL(IANG)*10./4096.)
C        PRINT*, ITURNS,IANG,ST
        RETURN
        END
C ************************** INITPOSI ********************
        SUBROUTINE INITPOSI
C INITIALIZES POSITAL ENCODER SSI INTERFACE USING
C VORTEX GPIO RESOURCES
        IMPLICIT NONE
        INTEGER*2 IOUT
        CALL OUTPUT(INT2(#98),INT2(#FF))  !SET PORT 0 TO OUTPUT
        CALL OUTPUT(INT2(#99),INT2(#00))  !SET PORT 1 TO INPUT
        IOUT = 1
        CALL OUTPUT(INT2(#78),IOUT)      !SET CLK HIGH
        RETURN
        END

