@START
CLS
ACLS
CLEAR
COLOR 0
INPUT "Insert an EAN-13 (13 digits): "; UPCA$
CLS
ACLS
IF LEN(UPCA$) != 13 THEN
    PRINT "Invalid EAN-13 length"
    STOP
END IF

COLOR 1
DIM UPC_ARRAY$(13), UPC_ARRAY(13)

' Parse input into arrays
FOR I = 0 TO 12
    UPC_ARRAY$(I) = MID$(UPCA$, I, 1)
    UPC_ARRAY(I) = VAL(MID$(UPCA$, I, 1))
NEXT I

' Calculate the checksum
ODDSUM = 0
EVENSUM = 0

FOR I = 1 TO 11 STEP 2
    ODDSUM = ODDSUM + UPC_ARRAY(I)
NEXT I
ODDSUM = ODDSUM * 3

FOR I = 0 TO 10 STEP 2
    EVENSUM = EVENSUM + UPC_ARRAY(I)
NEXT I

ALLSUM = ODDSUM + EVENSUM
CHECKSUM = ALLSUM % 10
IF CHECKSUM > 0 THEN CHECKSUM = 10 - CHECKSUM

' Update the last digit of the EAN-13 if the checksum is incorrect
IF CHECKSUM != UPC_ARRAY(12) THEN
    UPCA$ = SUBST$(UPCA$, 12, 1, STR$(CHECKSUM))
    UPC_ARRAY$(12) = STR$(CHECKSUM)
    UPC_ARRAY(12) = CHECKSUM
END IF

' Draw the barcode
GFILL 0, 0, 113, 62, 15
GCOLOR 14
GLINE 9, 10, 9, 54
GLINE 11, 10, 11, 54

' Prepare color arrays for the left and right parts of the barcode
DIM LEFTCOLOR(7), LEFTCOLORL(7), LEFTCOLORG(7)

FOR C1START = 1 TO 6
    LINESIZE = 48  ' Set default line size

    ' Reset left color arrays for each digit
    LEFTCOLORL = [0, 0, 0, 0, 0, 0, 0]
    LEFTCOLORG = [0, 0, 0, 0, 0, 0, 0]

    ' Determine left-side colors based on the digit
    SELECT CASE VAL(UPC_ARRAY$(C1START))
        CASE 0: LEFTCOLORL = [0, 0, 0, 1, 1, 0, 1]
                LEFTCOLORG = [0, 1, 1, 1, 1, 0, 1]
        CASE 1: LEFTCOLORL = [0, 0, 1, 1, 0, 0, 1]
                LEFTCOLORG = [0, 1, 1, 0, 0, 1, 1]
        CASE 2: LEFTCOLORL = [0, 0, 1, 0, 1, 0, 1]
                LEFTCOLORG = [0, 1, 1, 0, 1, 0, 1]
        CASE 3: LEFTCOLORL = [0, 1, 1, 1, 1, 0, 1]
                LEFTCOLORG = [1, 1, 1, 0, 0, 0, 1]
        CASE 4: LEFTCOLORL = [0, 1, 0, 0, 0, 1, 1]
                LEFTCOLORG = [1, 0, 0, 1, 1, 0, 1]
        CASE 5: LEFTCOLORL = [0, 1, 1, 0, 0, 1, 1]
                LEFTCOLORG = [1, 1, 1, 0, 0, 1, 1]
        CASE 6: LEFTCOLORL = [0, 1, 0, 1, 1, 1, 1]
                LEFTCOLORG = [1, 0, 1, 1, 0, 0, 1]
        CASE 7: LEFTCOLORL = [0, 1, 1, 1, 0, 1, 1]
                LEFTCOLORG = [1, 0, 1, 1, 0, 1, 1]
        CASE 8: LEFTCOLORL = [0, 1, 1, 0, 1, 1, 1]
                LEFTCOLORG = [1, 1, 0, 0, 1, 1, 1]
        CASE 9: LEFTCOLORL = [0, 0, 0, 1, 0, 1, 1]
                LEFTCOLORG = [1, 1, 1, 0, 1, 1, 0]
    END SELECT

    ' Copy left color array into main LEFTCOLOR array
    LEFTCOLOR = LEFTCOLORL

    ' Draw lines for the left side of the barcode
    LINESTART = 12 + (C1START * 7)
    FOR INC1START = 0 TO 6
        IF LEFTCOLOR(INC1START) == 1 THEN
            GCOLOR 14
        ELSE
            GCOLOR 15
        END IF
        GLINE LINESTART + INC1START, 10, LINESTART + INC1START, LINESIZE
    NEXT INC1START
NEXT C1START

' Middle guard lines
GCOLOR 14
GLINE 55, 10, 55, 54
GLINE 57, 10, 57, 54

' Prepare and draw right-side colors
DIM RIGHTCOLOR(7)
FOR C2START = 7 TO 12
    LINESIZE = 48

    ' Determine right-side colors based on the digit
    SELECT CASE VAL(UPC_ARRAY$(C2START))
        CASE 0: RIGHTCOLOR = [1, 1, 1, 0, 0, 1, 0]
        CASE 1: RIGHTCOLOR = [1, 1, 0, 0, 1, 1, 0]
        CASE 2: RIGHTCOLOR = [1, 1, 0, 1, 0, 1, 0]
        CASE 3: RIGHTCOLOR = [1, 0, 0, 0, 0, 1, 0]
        CASE 4: RIGHTCOLOR = [1, 0, 1, 1, 1, 0, 0]
        CASE 5: RIGHTCOLOR = [1, 0, 0, 1, 1, 0, 0]
        CASE 6: RIGHTCOLOR = [1, 0, 1, 0, 0, 0, 0]
        CASE 7: RIGHTCOLOR = [1, 0, 0, 0, 1, 0, 0]
        CASE 8: RIGHTCOLOR = [1, 0, 0, 1, 0, 0, 0]
        CASE 9: RIGHTCOLOR = [1, 1, 1, 0, 1, 0, 0]
    END SELECT

    ' Draw lines for the right side of the barcode
    LINESTART = 59 + ((C2START - 6) * 7)
    FOR INC2START = 0 TO 6
        IF RIGHTCOLOR(INC2START) == 1 THEN
            GCOLOR 14
        ELSE
            GCOLOR 15
        END IF
        GLINE LINESTART + INC2START, 10, LINESTART + INC2START, LINESIZE
    NEXT INC2START
NEXT C2START

' Final guard lines
GCOLOR 14
GLINE 101, 10, 101, 54
GLINE 103, 10, 103, 54

' Display the EAN-13 and Checksum
PRINT " "
PRINT "EAN-13: "; UPCA$
PRINT "Checksum: "; CHECKSUM
INPUT "Press Enter to continue"; RESTART$
IF RESTART$ == "Y" OR RESTART$ == "y" THEN GOTO @START
