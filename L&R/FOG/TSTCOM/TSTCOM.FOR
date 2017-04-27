c TEST COM1 OUTPUT
           IOLD = #41
           IS = 0
           CALL FETCH (INT2(#03FD),IS)         !GET STATUS
           IF (BTEST(IS,0)) THEN
              CALL FETCH (INT2(#03F8),IOLD)
           ENDIF
           CALL OUTPUT (INT2(#03F8),IOLD)       !CHAR A
