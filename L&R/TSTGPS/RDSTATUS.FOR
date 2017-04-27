        PROGRAM RDSTATUS
c retrieves normal status
        CALL GTSTATUS
        END
c ********************** GTSTATUS ************************
        SUBROUTINE GTSTATUS
        INTEGER*2 SGBASE,STA,IVAL
        PARAMETER (SGBASE=#02A0,STA=#01)
        CALL FETCH (SGBASE+STA,IVAL)
        PRINT *, 'STATUS BYTE   ',IVAL
        PRINT *, 'HEARTBIT      ',BTEST(IVAL,4)
        PRINT *, '1PPS SYNCH    ',BTEST(IVAL,1)
        RETURN
        END
c ***********************  HZ_200 *************************
        SUBROUTINE HZ_200
        RETURN
        END
