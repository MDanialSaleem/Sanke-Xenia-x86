makeArena:
;takes no paramters and makes the arena of the game depending upon level.
call makeBoundary
call initializeHurdlePositions
call makeHurdleLevel1

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
level2hurdle2row: dw 19
level2hurdle2col: dw 9  

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
    push word [level2hurdle2row]
    push word [level2hurdle2col]
    call calLocation
    pop ax ;address of 20th row 10th column.
    mov [level1hurdle2], ax

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
level2portalLE: dw 0
level2portalLL: dw 0
level2portalRE: dw 0
level2portalRL: dw 0