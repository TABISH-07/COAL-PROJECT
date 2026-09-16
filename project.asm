; =========================================================
; STUDENT INFORMATION SYSTEM | COAL PROJECT
; =========================================================
org 100h
jmp start

; =========================================================
; DATA
; =========================================================
menu    db 13,10,"===== STUDENT INFORMATION SYSTEM =====",13,10
        db "1. Add Student",13,10
        db "2. View All Students",13,10
        db "3. Search Student",13,10
        db "4. Exit",13,10
        db "Choice: $"

msgName  db 13,10,"Enter Name: $"
msgRoll  db 13,10,"Enter Roll No (01-50): $"
msgAtt   db 13,10,"Attendance (P=Present / A=Absent): $"
msgFee   db 13,10,"Fee (P=Paid / U=Unpaid): $"
msgMarks db 13,10,"Marks (0-50): $"
msgStat  db 13,10,"Status (I=InStudy / L=Left / O=PassOut): $"
msgHlth  db 13,10,"Health (F=Fit / D=Disability): $"
msgAdded db 13,10,"Student Added!$"
msgFull  db 13,10,"List Full! Max 10 students.$"
msgAll   db 13,10,"===== ALL RECORDS =====$"
msgSrch  db 13,10,"Enter Roll No to Search (01-50): $"
msgFound db 13,10,"--- Student Found ---$"
msgNF    db 13,10,"Student Not Found!$"

lNm  db 13,10,"Name      : $"
lRl  db 13,10,"Roll No   : $"
lAt  db 13,10,"Attendance: $"
lFe  db 13,10,"Fee       : $"
lMk  db 13,10,"Marks     : $"
lSt  db 13,10,"Status    : $"
lHl  db 13,10,"Health    : $"
nl   db 13,10,"$"

; Full form strings for display
fPresent   db "Present$"
fAbsent    db "Absent$"
fPaid      db "Paid$"
fUnpaid    db "Unpaid$"
fInStudy   db "In-Study$"
fLeft      db "Left$"
fPassOut   db "Pass Out$"
fFit       db "Fit$"
fDisable   db "Disability$"
fUnknown   db "?$"

; =========================================================
; VARIABLES & ARRAYS  (max 10 students)
; =========================================================
stCount  db 0
names    times 200 db 0
rolls    times 10  db 0
att      times 10  db 0
fees     times 10  db 0
marks    times 10  db 0
stat     times 10  db 0
hlth     times 10  db 0

nameBuf  db 20, 0
         times 21 db 0
rollBuf  db 3, 0
         times 4  db 0
markBuf  db 3, 0
         times 4  db 0

; =========================================================
; MAIN MENU
; =========================================================
start:
mainMenu:
    mov dx, menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h

    cmp al, '1'
    je  goAdd
    cmp al, '2'
    je  goView
    cmp al, '3'
    je  goSearch
    cmp al, '4'
    je  goExit
    jmp mainMenu

goAdd:    jmp AddStudent
goView:   jmp ViewStudents
goSearch: jmp SearchStudent
goExit:   jmp ExitProgram

; =========================================================
; ADD STUDENT
; =========================================================
AddStudent:
    mov al, [stCount]
    cmp al, 10
    jl  addOk
    mov dx, msgFull
    mov ah, 09h
    int 21h
    jmp mainMenu

addOk:
    ; NAME
    mov dx, msgName
    mov ah, 09h
    int 21h
    mov dx, nameBuf
    mov ah, 0Ah
    int 21h

    xor ax, ax
    mov al, [stCount]
    mov bl, 20
    mul bl
    mov di, names
    add di, ax
    mov si, nameBuf+2
    mov cx, 20
.copyName:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop .copyName

    xor bx, bx
    mov bl, [stCount]

    ; ROLL (01-50)
    mov dx, msgRoll
    mov ah, 09h
    int 21h
    call readNum        ; AL = number
    mov [rolls+bx], al

    ; ATTENDANCE
    mov dx, msgAtt
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    mov [att+bx], al

    ; FEE
    mov dx, msgFee
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    mov [fees+bx], al

    ; MARKS (0-50)
    mov dx, msgMarks
    mov ah, 09h
    int 21h
    call readNum
    mov [marks+bx], al

    ; STATUS
    mov dx, msgStat
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    mov [stat+bx], al

    ; HEALTH
    mov dx, msgHlth
    mov ah, 09h
    int 21h
    mov ah, 01h
    int 21h
    mov [hlth+bx], al

    inc byte [stCount]
    mov dx, msgAdded
    mov ah, 09h
    int 21h
    jmp mainMenu

; =========================================================
; VIEW ALL STUDENTS
; =========================================================
ViewStudents:
    mov dx, msgAll
    mov ah, 09h
    int 21h

    mov al, [stCount]
    cmp al, 0
    je  mainMenu

    xor bx, bx

viewLoop:
    ; NAME
    mov dx, lNm
    mov ah, 09h
    int 21h
    xor ax, ax
    mov al, bl
    mov dl, 20
    mul dl
    mov di, names
    add di, ax
    mov cx, 20
.vName:
    mov dl, [di]
    cmp dl, 0
    je  .vSkip
    mov ah, 02h
    int 21h
.vSkip:
    inc di
    loop .vName

    ; ROLL
    mov dx, lRl
    mov ah, 09h
    int 21h
    mov al, [rolls+bx]
    call printNum

    ; ATTENDANCE - full form
    mov dx, lAt
    mov ah, 09h
    int 21h
    mov al, [att+bx]
    cmp al, 'P'
    jne .attA
    mov dx, fPresent
    jmp .attShow
.attA:
    mov dx, fAbsent
.attShow:
    mov ah, 09h
    int 21h

    ; FEE - full form
    mov dx, lFe
    mov ah, 09h
    int 21h
    mov al, [fees+bx]
    cmp al, 'P'
    jne .feeU
    mov dx, fPaid
    jmp .feeShow
.feeU:
    mov dx, fUnpaid
.feeShow:
    mov ah, 09h
    int 21h

    ; MARKS
    mov dx, lMk
    mov ah, 09h
    int 21h
    mov al, [marks+bx]
    call printNum

    ; STATUS - full form
    mov dx, lSt
    mov ah, 09h
    int 21h
    mov al, [stat+bx]
    cmp al, 'I'
    jne .stL
    mov dx, fInStudy
    jmp .stShow
.stL:
    cmp al, 'L'
    jne .stO
    mov dx, fLeft
    jmp .stShow
.stO:
    cmp al, 'O'
    jne .stUnk
    mov dx, fPassOut
    jmp .stShow
.stUnk:
    mov dx, fUnknown
.stShow:
    mov ah, 09h
    int 21h

    ; HEALTH - full form
    mov dx, lHl
    mov ah, 09h
    int 21h
    mov al, [hlth+bx]
    cmp al, 'F'
    jne .hlD
    mov dx, fFit
    jmp .hlShow
.hlD:
    mov dx, fDisable
.hlShow:
    mov ah, 09h
    int 21h

    mov dx, nl
    mov ah, 09h
    int 21h

    inc bx
    mov al, bl
    cmp al, [stCount]
    jl  viewLoop
    jmp mainMenu

; =========================================================
; SEARCH STUDENT
; =========================================================
SearchStudent:
    mov dx, msgSrch
    mov ah, 09h
    int 21h
    call readNum
    mov bl, al

    xor si, si
    mov cl, [stCount]
    cmp cl, 0
    je  notFound

searchLoop:
    mov al, [rolls+si]
    cmp al, bl
    je  showFound
    inc si
    dec cl
    jnz searchLoop

notFound:
    mov dx, msgNF
    mov ah, 09h
    int 21h
    jmp mainMenu

; =========================================================
; SHOW FOUND STUDENT  (SI = index)
; =========================================================
showFound:
    mov dx, msgFound
    mov ah, 09h
    int 21h

    ; NAME
    mov dx, lNm
    mov ah, 09h
    int 21h
    mov ax, si
    mov dl, 20
    mul dl
    mov di, names
    add di, ax
    mov cx, 20
.sName:
    mov dl, [di]
    cmp dl, 0
    je  .sSkip
    mov ah, 02h
    int 21h
.sSkip:
    inc di
    loop .sName

    ; ROLL
    mov dx, lRl
    mov ah, 09h
    int 21h
    mov al, [rolls+si]
    call printNum

    ; ATTENDANCE - full form
    mov dx, lAt
    mov ah, 09h
    int 21h
    mov al, [att+si]
    cmp al, 'P'
    jne .sAttA
    mov dx, fPresent
    jmp .sAttShow
.sAttA:
    mov dx, fAbsent
.sAttShow:
    mov ah, 09h
    int 21h

    ; FEE - full form
    mov dx, lFe
    mov ah, 09h
    int 21h
    mov al, [fees+si]
    cmp al, 'P'
    jne .sFeeU
    mov dx, fPaid
    jmp .sFeeShow
.sFeeU:
    mov dx, fUnpaid
.sFeeShow:
    mov ah, 09h
    int 21h

    ; MARKS
    mov dx, lMk
    mov ah, 09h
    int 21h
    mov al, [marks+si]
    call printNum

    ; STATUS - full form
    mov dx, lSt
    mov ah, 09h
    int 21h
    mov al, [stat+si]
    cmp al, 'I'
    jne .sStL
    mov dx, fInStudy
    jmp .sStShow
.sStL:
    cmp al, 'L'
    jne .sStO
    mov dx, fLeft
    jmp .sStShow
.sStO:
    mov dx, fPassOut
.sStShow:
    mov ah, 09h
    int 21h

    ; HEALTH - full form
    mov dx, lHl
    mov ah, 09h
    int 21h
    mov al, [hlth+si]
    cmp al, 'F'
    jne .sHlD
    mov dx, fFit
    jmp .sHlShow
.sHlD:
    mov dx, fDisable
.sHlShow:
    mov ah, 09h
    int 21h

    jmp mainMenu

; =========================================================
; EXIT
; =========================================================
ExitProgram:
    mov ah, 4Ch
    int 21h

; =========================================================
; PROCEDURE: readNum
; DOS buffered input se 1-2 digit number lo
; Uses rollBuf (3 char max)
; Returns: AL = number (0-99)
; =========================================================
readNum:
    push bx
    push cx
    push si

    mov dx, rollBuf
    mov ah, 0Ah
    int 21h

    mov si, rollBuf
    mov al, [si+1]      ; kitne chars type hue
    cmp al, 2
    je  .two

    ; ek digit
    mov al, [si+2]
    sub al, '0'
    jmp .done

.two:
    ; do digits: tens aur units
    mov al, [si+2]
    sub al, '0'
    mov bl, 10
    mul bl              ; AL = tens * 10
    mov cl, [si+3]
    sub cl, '0'
    add al, cl

.done:
    pop si
    pop cx
    pop bx
    ret

; =========================================================
; PROCEDURE: printNum
; AL mein number, screen pe decimal print karo
; =========================================================
printNum:
    push ax
    push cx
    push dx

    xor cx, cx
    mov dl, 10

    cmp al, 0
    jne .divide
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp .done

.divide:
    cmp al, 0
    je  .print
    xor ah, ah
    div dl              ; AL = quotient, AH = remainder
    push ax
    inc cx
    jmp .divide

.print:
    pop ax
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    loop .print

.done:
    pop dx
    pop cx
    pop ax
    ret

