        PROGRAM TSTCMOS
        INTEGER*4 NSTEPS
        ST_SCALE = 0.1
        CALL GTST(NSTEPS)      !GET ST FROM CMOS CLOCK
c        DATA = NSTEPS*ST_SCALE
        print *, NSTEPS
        NSTEPS = 10500
C        IF (DATA .GT. 20000. .OR. DATA .LE. 0) THEN
C            DATA = 10000.
C            NSTEPS = DATA/ST_SCALE + 0.5
            CALL STST(NSTEPS)   !PUT ST TO CMOS CLOCK
C        ENDIF
        print*, NSTEPS
        NSTEPS = 0
        CALL GTST(NSTEPS)
        PRINT *, NSTEPS
        END
        SUBROUTINE HZ_200
        RETURN
        END
