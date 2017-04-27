        PROGRAM TSTTIME
        INTEGER*2 IYR,IDAY,IHR,IMIN,ISEC,ITEMP
c        iyr = 2012
c        iday = 125
c        ihr = 15
c        imin= 35
c        isec = 0
10      CONTINUE
        PRINT *, 'INPUT IYR'
        READ (*,*) IYR
        PRINT *, 'INPUT IDAY'
        READ (*,*) IDAY
        PRINT *, 'INPUT IHR'
        READ (*,*) IHR
        PRINT *, 'INPUT IMIN'
        READ (*,*) IMIN 
        PRINT *, 'INPUT ISEC'
        READ (*,*) ISEC
        print 1,IYR,IDAY,IHR,IMIN,ISEC
        CALL SETSGTIME (IYR,IDAY,IHR,IMIN,ISEC)
C READ BACK THE TIME
        DO I=-32000,32000,1        !CREATE A SHORT DELAY
           ITEMP = (I/1000)*(I/1000)
        ENDDO
20      CONTINUE
        CALL GETSGTIME (IYR,IDAY,IHR,IMIN,ISEC)
        PRINT 1,IYR,IDAY,IHR,IMIN,ISEC 
        PRINT *, 'READ TIME AGAIN ? 1 = YES'
        READ (*,*) ITEMP
        IF (ITEMP .EQ. 1) GOTO 20
        PRINT *, 'SET A NEW TIME ?  1 = YES'
        READ (*,*) ITEMP
        IF (ITEMP .EQ. 1) GOTO 10
1       FORMAT(I6,4(':',I4))
        END
c ******************** GETSGTIME *************************
C GETS MAJOR TIME AND YEAR ON THE SG GPS BOARD
        SUBROUTINE GETSGTIME (IYR,IDAY,IHR,IMIN,ISEC)
        INTEGER*1 TB(0:8)       !TIME BYTE
        INTEGER*2 IYR,IDAY,IHR,IMIN,ISEC,SGBASE,I,ITEMP
        PARAMETER (SGBASE=#02A0)
C READ BOARD 
        DO I=#0F,#07,-1
           CALL FETCH (SGBASE+I,ITEMP)
           TB(I-#07) = ITEMP
C           print*, 'get', i,itemp
        ENDDO
C INTERPRET RESULTS IN TB
        IYR = (TB(0).AND.#0F) + ISHFT(TB(0),-4)*10
        IDAY=ISHFT(TB(1),-4)*100 +(TB(1).AND.#0F)*10 +ISHFT(TB(2),-4)
        IHR =  (TB(2).AND.#0F)*10 + ISHFT(TB(3),-4)
        IMIN = (TB(3).AND.#0F)*10 + ISHFT(TB(4),-4)
        ISEC = (TB(4).AND.#0F)*10 + ISHFT(TB(5),-4)
        RETURN
        END
c ******************** SETSGTIME *************************
C SETS MAJOR TIME AND YEAR ON THE SG GPS BOARD
        SUBROUTINE SETSGTIME (IYR,IDAY,IHR,IMIN,ISEC)
        INTEGER*2 IYR,IDAY,IHR,IMIN,ISEC,ITEMP
        INTEGER*2 ID10,ID1,IH1,IM1,IS1,IY1,IY100,ISETMAJ,ICMD,ISETYR
        PARAMETER (ID10=#94,ID1=#93,IH1=#92,IM1=#91,IS1=#90)
        PARAMETER (ICMD=#FF,ISETMAJ=2,ISETYR=4,IY1=#95,IY100=#96)
C LOAD PARAMETERS
        ITEMP = IDAY/100              !GET FIRST DIGIT OF DAY
        CALL SETDPRAM (ID10,ITEMP)
        ITEMP = IDAY - ITEMP*100      !GET LAST TWO DIGITS
        ITEMP = INTBCD(ITEMP)
        CALL SETDPRAM (ID1,ITEMP)
        ITEMP = INTBCD(IHR)
        CALL SETDPRAM (IH1,ITEMP)
        ITEMP = INTBCD(IMIN)
        CALL SETDPRAM (IM1,ITEMP)
        ITEMP = INTBCD(ISEC)
        CALL SETDPRAM (IS1,ITEMP)
        ITEMP = IYR/100
        ITEMP = INTBCD(ITEMP)
        CALL SETDPRAM (IY100,ITEMP)
        ITEMP = IYR-(IYR/100)*100
        ITEMP = INTBCD(ITEMP)
        CALL SETDPRAM (IY1,ITEMP)
C START CLOCK
        CALL SETDPRAM (ICMD,ISETMAJ)
        CALL SETDPRAM (ICMD,ISETYR)
        RETURN
        END
C *********************** INTBCD **************************
C CONVERTS A TWO DIGIT INTEGER NUMBER TO BCD
        FUNCTION INTBCD (INPUT)
        INTEGER*2 INPUT
        INTEGER*1 HEXVAL,I1,I2
        I2 = INPUT/10
        I1 = INPUT - I2*10
        HEXVAL = I2
        HEXVAL = ISHFT(HEXVAL,4)   !SHIFT 4 BITS LEFT
        HEXVAL = HEXVAL + I1
        INTBCD = HEXVAL
        RETURN
        END
C********************* SETDPRAM ***************************
C  SET VALUES IN DUAL PORT RAM
C  IADD = ADDRESS IN DUAL PORT RAM
C  IVAL = VALUE TO SET IN DUAL PORT RAM
C  CALL SETDPRAM (IADD,IVAL) IADD AND IVAL INTERGER*2
C  READS AND RETURNS SET VALUE IN IVAL. SHOULD EQUAL INPUT
C  RESPONSE READY MASK = #02
C  EXTENDED STATUS PORT ADDRESS= #03
C  DUAL RAM DATA PORT ADDRESS = #02
C  DUAL RAM ADDRESS PORT ADDRESS = #06
C
        SUBROUTINE SETDPRAM (IADD,IVAL)
        INTEGER*2 IADD,IVAL,IRES,I
        INTEGER*2 SGBASE,MSK,STA,DAT,ADR
        PARAMETER (SGBASE=#02A0,MSK=#02,STA=#03,DAT=#02,ADR=#06)
C
        CALL FETCH (SGBASE+DAT,IRES)    !CLEAR RESPONSE FLAG
        CALL OUTPUT(SGBASE+ADR,IADD)    !SET ADDRESS TO WRITE TO
        DOWHILE (IRES .EQ. 0)           !MAKE SURE VALUE IS SET
            CALL FETCH(SGBASE+STA,IRES)
            IRES = IRES .AND. MSK       !RESPONSE READY MASK
        ENDDO
        DO I=1,200                      !DELAY TO ASSURE SPACING
            CALL FETCH(SGBASE+STA,IRES)
        ENDDO
        CALL FETCH(SGBASE+DAT,IRES)     !DISCARD OLD VALUE
        CALL OUTPUT(SGBASE+DAT,IVAL)    !SET NEW VALUE
        DOWHILE (IRES .EQ. 0)           !MAKE SURE VALUE IS SET
            CALL FETCH(SGBASE+STA,IRES)
            IRES = IRES .AND. MSK       !RESPONSE READY MASK
        ENDDO
        DO I=1,200                      !DELAY TO ASSURE SPACING
            CALL FETCH(SGBASE+STA,IRES)
        ENDDO
        ival = 0
        CALL FETCH(SGBASE+DAT,IVAL)     !READ AND RETURN NEW VALUE
c        print *, ival
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END

