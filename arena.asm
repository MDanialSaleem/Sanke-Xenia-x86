makeArena:
;takes no paramters and makes the arena of the game depending upon level.
call initializeHurdlePositions
cmp word[level], 1
jne noDisplayLevel1Hurdles
    call makeHurdleLevel1
noDisplayLevel1Hurdles:

cmp word[level], 2
jne noDisplayLevel2Hurdles
    call makeHurdleLevel2
noDisplayLevel2Hurdles:

ret

makeBoundary:
;creates the boundary around the snake
pusha
push es

    push word 0xb800
    pop es

    ;draw upper boundary
    mov di, 0 ;es:di = b800: 0
    mov ax, 0x1720 ;space with blue background.
    mov cx, 80
    rep stosw

    ;draw lower boundary
    mov di, 4000 - 160 ;es:di = b800:start of last row.
    mov cx, 80
    rep stosw

    ;draw left boundary
    mov bx, 0
    mov cx, 25

    whileDrawLeftBoundary:

        mov [es:bx], ax
        add bx, 160

    loop whileDrawLeftBoundary

    ;draw right boundary
    mov bx, 158 ;end of first row.
    mov cx, 25

    whileDrawRightBoundary:

        mov [es:bx], ax
        add bx, 160

    loop whileDrawRightBoundary

popa
pop es
ret

collisionCheckBoundary:
;checks if the snake has collided with the boundary, if so, then it print a spot at that point else does nothing.

pusha
push es

    push word 0
    push word 0
    push word[snake]
    call calRowAndColumn
    pop ax ;col
    pop bx ;row

    cmp ax, 0
    je collisionWithBoundary
    cmp ax, 79
    je collisionWithBoundary
    cmp bx, 0
    je collisionWithBoundary
    cmp bx, 24
    jne noCollisionWithBoundary

    collisionWithBoundary:

        mov ax, 0xb800
        mov es, ax
        mov bx, [snake]
        mov word[es:bx], 0x0720
        call updateLives
    noCollisionWithBoundary:
pop es
popa
ret

;check logic of initializeHurdlePositions for reasons of these memory declarations.
level1hurdle1: dw 0
level1hurdle2: dw 0 
level1hurdle1row: dw 5
level1hurdle1col: dw 9
level1hurdle2row: dw 19
level1hurdle2col: dw 9  

initializeHurdlePositions:
;initalizes the values of hurdles and portals that are used by the functions of level 1 and level2. The reason for not hardcoding
;these values was to be flexible. The reason for not having the level1 and level2 calculate these themselves was optimization.
push ax

    push word 0
    push word [level1hurdle1row]
    push word [level1hurdle1col]
    call calLocation
    pop ax ;address of 10th row, 10th column
    mov [level1hurdle1], ax

    push word 0 
    push word [level1hurdle2row]
    push word [level1hurdle2col]
    call calLocation
    pop ax ;address of 20th row 10th column.
    mov [level1hurdle2], ax

    push word 0
    push word[level2hurlderow]
    push word[level2hurldecol]
    call calLocation
    pop ax
    mov [level2hurdle], ax


    push word 0
    push word 4
    push word 4 ;row 2 col 2
    call calLocation
    pop ax
    mov [portalLE], ax

    push word 0
    push word 19
    push word 4 ;row 24 col 2
    call calLocation
    pop ax
    mov [portalLL], ax

    push word 0
    push word 4
    push word 67 ;row 2 col 79
    call calLocation
    pop ax
    mov [portalRE], ax

    push word 0
    push word 19
    push word 67 ;row 24, col 79
    call calLocation
    pop ax
    mov [portalRL], ax


pop ax
ret

makeHurdleLevel1:
;makes hurdles for level1. It has two horizontal bars.
pusha
push es

    push word 0xb800
    pop es

    cld 
    mov ax, 0x6720 ;blank color.

    mov di, [level1hurdle1] ;es:di
    mov cx, 60
    rep stosw

    mov di, [level1hurdle2]
    mov cx, 60
    rep stosw
    
pop es
popa
ret

level2hurdle: dw 0
level2hurldecol: dw 39
level2hurlderow: dw 0

portals: ;extra label for iteration. 
portalLE: dw 0
portalLL: dw 0
portalRE: dw 0
portalRL: dw 0

makeHurdleLevel2:
pusha
push es

    push word 0xb800
    pop es
    mov bx, [level2hurdle]
    mov cx, 25
    mov ax, 0x3720

    whilePrintingHurdleLevel2

        mov word[es:bx], ax
        add bx, 160

    loop whilePrintingHurdleLevel2


    mov bx, [portalLE]
    mov ax, [portalLEColor]
    mov word[es:bx], ax

    mov bx, [portalLL]
    mov ax, [portalLLColor]
    mov word[es:bx], ax

    mov bx, [portalRE]
    mov ax, [portalREColor]
    mov word[es:bx], ax

    mov bx, [portalRL]
    mov ax, [portalRLColor]
    mov word[es:bx], ax

pop es
popa
ret


generalCollisionWithLevel1Hurdles:
;takes an address on video memory in stack, and returns 1 if it collides with any of level1 hurdles.
;returns 0 otherwise
push bp 
mov bp, sp
pusha

    mov word[bp + 6], 0 ;return spot.

    push word 0
    push word 0
    push word[bp + 4]
    call calRowAndColumn ;gets the rows and column corresponding to the position of food on screen for easy comparison with boundary.
    pop ax ;col
    pop bx ;row

    mov cx, [level1hurdle1col]
    add cx, 59

    cmp bx, [level1hurdle1row]
    jne generalCollisionL1H2Check
    cmp ax, [level1hurdle1col]
    jl generalCollisionL1H2Check
    cmp ax, cx
    jg generalCollisionL1H2Check

        mov word[bp + 6], 1 ;in case it has collided with hurdle 1 of level 1.
        jmp generalCollisionWithLevel1HurdlesEnd

    generalCollisionL1H2Check:
    
    mov cx, [level1hurdle1col]
    add cx, 59

    cmp bx, [level1hurdle2row]
    jne generalCollisionWithLevel1HurdlesEnd
    cmp ax, [level1hurdle2col]
    jl generalCollisionWithLevel1HurdlesEnd
    cmp ax, cx
    jg generalCollisionWithLevel1HurdlesEnd

        mov word[bp + 6], 1 ;collided with hurdle 2 of level 1

    generalCollisionWithLevel1HurdlesEnd:

            
popa
mov sp, bp
pop bp
ret 2


generalCollisionWithLevel2Hurdles:
;takes address of a memory as its input paramter. returns 1 if i collides with the center bar, 0 otherwise.
push bp
mov bp, sp
pusha

    mov word[bp + 6], 0 ;return spot.

    push word 0
    push word 0
    push word[bp + 4]
    call calRowAndColumn ;gets the rows and column corresponding to the position of food on screen for easy comparison with boundary.
    pop ax ;col
    pop bx ;row

    cmp ax, [level2hurldecol]
    jne generalCollisionWithLevel2HurdlesEnd

        mov word[bp + 6], 1

    generalCollisionWithLevel2HurdlesEnd:


popa
mov sp, bp
pop bp
ret 2

generalCollisionWithPortals:
;takes an address on video memory as input. returns 0 if no collision with portal has occured otherwise returns the word present
;at the portal with which it collided.
push bp
mov bp, sp
pusha

    mov word[bp + 6], 0 ;return value.

    mov ax, [bp + 4] ;input address.
    mov cx, 4
    mov bx, portals

    whileCheckingPortals:

        cmp ax, [bx]
        jne portalNotCollided

            mov dx, [bx]
            mov [bp + 6], dx

        portalNotCollided:
        add bx, 2
    loop whileCheckingPortals

popa
mov sp, bp
pop bp
ret 2