initializeSnake:
;meant to print the initial snake at the beginning of the game or if life is lost.
pusha
push es

    push ds
    pop es
    mov di, snake ;es:di == start of snake.
    mov ax, 0
    mov cx, 240
    rep stosw

    mov word[size], 20
    mov cx, 20
    mov bx, snake
    mov ax, 560 ;randomly chosen.
    whileInitialize:

        mov [bx], ax
        add bx, 2
        sub ax, 2

    loop whileInitialize

    mov word[direction], 0
pop es
popa
ret

makeSnake:
pusha

    mov cx, [size]
    mov bx, snake ;head
    push word 0xb800
    pop es
    whileMakeSnake

        mov di, [bx]
        mov word[es:di], 0x4820
        add bx, 2
    loop whileMakeSnake

    mov bx, [snake]
    mov word[es:bx], 0x1820
popa
ret


moveSnake:
pusha
push es

    push ds
    pop es
    mov di, snake
    mov bx, [size]
    dec bx
    add bx, bx
    add di, bx ;es:di

    mov si, di
    sub si, 2 ;ds:si

    mov cx, [size]
    dec cx 

    std
    rep movsw

    cmp word[direction], 0 ;for right.
    jne checkDownDirection

        add word[snake], 2
        jmp directionChecked

    checkDownDirection:
    cmp word[direction], 1 ;for down
    jne checkLeftDirection

        add word[snake], 160
        jmp directionChecked

    checkLeftDirection:
    cmp word[direction], 2 ;for left
    jne checkUpDirection

        sub word[snake], 2
        jmp directionChecked

    checkUpDirection:
        sub word[snake], 160
    directionChecked:

pop es
popa
ret

collisionCheckItself:
;takes no parameter and makes a red spot at the spot of collision esle does nothing.
pusha
push es

    mov ax, [snake] ;head in ax.
    mov cx, [size]
    dec cx
    mov bx, snake
    add bx, 2 ;starts checking after the head.
    mov dx, -1 ;collision place.
    
    whileCheckingCollision:

        mov si, [bx]
        cmp ax, si
        jne notCollided

            mov dx, si

        notCollided:
        add bx, 2
    loop whileCheckingCollision

    cmp dx, -1
    je endCollisionCheck

        push word 0xb800
        pop es
        mov si, dx
        mov word[es:si], 0x0720
        call updateLives

    endCollisionCheck:
pop es
popa
ret

elongateLeft:
;elongates the snake on left.
pusha

    mov bx, snake
    add bx, [size] 
    add bx, [size] ;bx now points off-the-tail.
    mov ax, [bx - 2] ;tail in ax.
    mov cx, 4

    whileElongatingLeft:

        sub ax, 2
        mov [bx], ax
        add bx, 2

    loop whileElongatingLeft
    add word[size], 4
popa
ret

elongateRight:
;elongates the snake on right
pusha

    mov bx, snake
    add bx, [size] 
    add bx, [size] ;bx now points off-the-tail.
    mov ax, [bx - 2] ;tail in ax.
    mov cx, 4

    whileElongatingRight:

        add ax, 2
        mov [bx], ax
        add bx, 2

    loop whileElongatingRight
    add word[size], 4
popa
ret

elongateUp:
;elongates the snake on right
pusha

    mov bx, snake
    add bx, [size] 
    add bx, [size] ;bx now points off-the-tail.
    mov ax, [bx - 2] ;tail in ax.
    mov cx, 4

    whileElongatingUp:

        sub ax, 160
        mov [bx], ax
        add bx, 2

    loop whileElongatingUp
    add word[size], 4
popa
ret


elongateDown:
;elongates the snake on right
pusha

    mov bx, snake
    add bx, [size] 
    add bx, [size] ;bx now points off-the-tail.
    mov ax, [bx - 2] ;tail in ax.
    mov cx, 4

    whileElongatingDown:

        add ax, 160
        mov [bx], ax
        add bx, 2

    loop whileElongatingDown
    add word[size], 4
popa
ret


elongateSnake:
pusha

    cmp word[size], 240
    je endElongateSnake
    mov bx, snake
    add bx, [size]
    add bx, [size] ;bx poines off-the-end
    mov ax, [bx - 2] ;tail
    mov dx, [bx - 4] ;second to tail.

    mov bx, ax
    add bx, 2
    cmp bx, dx ;if equal second to tail is at the right of tail, elongation should be on left.
    jne checkRightElongation

        call elongateLeft
        jmp endElongateSnake

    checkRightElongation:
    mov bx, ax
    sub bx, 2
    cmp bx, dx ;if equal, second-to0tail is at the left of tail, elongation should be on right.
    jne checkDownElongation

        call elongateRight
        jmp endElongateSnake
    
    checkDownElongation:
    mov bx, ax
    sub bx, 160
    cmp bx, dx ;if equal second-toital is above the tail, elongation should be downwards.
    jne checkUpElongation

        call elongateDown
        jmp endElongateSnake
    checkUpElongation:
    mov bx, ax
    add bx, 160
    cmp bx, dx ;if equal second-to-tail is below the tail, elongation should be upwards.
    jne endElongateSnake

        call elongateUp
    
    endElongateSnake:
popa
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

diplayLives:
pusha
push es

    push word 0xb800
    pop es
    mov di, 158 ;top right corner of screen.
    mov cx, [lives]
    std 
    mov ax, 0x0703
    rep stosw


pop es
popa
ret

updateLives:
push ax
pushf
    cmp word[lives], 0
    je snakeAlreadyDed

        dec word[lives]
        call clearScreen
        call initializeSnake
        
    snakeAlreadyDed:
popf
pop ax
ret

