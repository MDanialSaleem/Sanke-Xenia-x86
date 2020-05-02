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

    mov ax, 560 
    mov si, 2 

    cmp word[level], 2
    jne notInitializeLevel2
    
    push word 0
    push word 20
    push word 41
    call calLocation
    pop ax ;21st row, 42nd column.
    mov si, 160 


    notInitializeLevel2:
    whileInitialize:

        mov [bx], ax
        add bx, 2
        sub ax, si

    loop whileInitialize

    mov word[direction], 0
pop es
popa
ret

snakeHeadCell: dw 0x3c02
snakeBodyCell: dw 0x3c04
makeSnake:
pusha

    mov cx, [size]
    mov bx, snake ;head
    push word 0xb800
    pop es
    whileMakeSnake

        mov di, [bx]
        mov ax, [snakeBodyCell]
        mov word[es:di], ax
        add bx, 2
    loop whileMakeSnake

    mov bx, [snake]
    mov ax, [snakeHeadCell]
    mov word[es:bx], ax
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



collisionCheckMaster:
push ax

    call collisionCheckItself
    call collisionCheckBoundary


    cmp word[level], 1
    jne snakeCollisionWithLevel1NotNeeded

        push word 0
        push word[snake] ;pushes head.
        call generalCollisionWithLevel1Hurdles
        pop ax
        cmp ax, 1
        jne snakeCollisionWithLevel1NotNeeded
            call updateLives

    snakeCollisionWithLevel1NotNeeded:
    
    cmp word[level], 2
    jne snakeCollisionWithLevel2NotNeeded

        push word 0
        push word[snake] ;head
        call generalCollisionWithLevel2Hurdles
        pop ax
        cmp ax, 1
        jne snakeCollisionWithPortalsCheck
            call updateLives

        snakeCollisionWithPortalsCheck:
        push word 0
        push word[snake]
        call generalCollisionWithPortals
        pop ax
        cmp ax, 0
        je snakeCollisionWithLevel2NotNeeded
            push ax
            call handlePortals

    snakeCollisionWithLevel2NotNeeded:
pop ax
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




handlePortals:
;takes one paramter. the address of the portal on video memory.
;it makes amends only for LL and RL portals. Collidision of snake with LE and RE is inconsequential.
push bp
mov bp, sp
pusha

    mov bx, [bp + 4]
    cmp bx, [portalLL]
    jne handleRL

        mov di, [portalRE]
        sub di, 2 ;snake enters at one step to the left of RE portal.
        mov [snake], di ;moves head to new positon.
        mov word[direction], 2 ;for moving to left.
        jmp handlePortalsEnd

    handleRL:
    cmp bx, [portalRL]
    jne handlePortalsEnd

        mov di, [portalLE]
        add di, 2 ;snake enters at one step to the right of LE portal
        mov [snake], di
        mov word[direction], 0 ;move left.

    handlePortalsEnd:

popa
mov sp, bp
pop bp
ret 2

diplayLives:
pusha
push es

    push word 0xb800
    pop es
    mov di, 158 ;top right corner of screen.
    mov cx, [lives]
    std 
    mov ax, 0x0403 ;red hearts.
    rep stosw

    mov cx, 3 ;uses di from where it was left off.
    sub cx, [lives]
    mov ax, 0x0703 ;white hearts.
    rep stosw


pop es
popa
ret


updateLives:
push ax
pushf
    cmp word[lives], 0
    je snakeAlreadyDed

        push word [hitSound]
        push word [soundDuration]
        call generateGeneralSound

        dec word[lives]
        call resetTime
        call resetSpeed
        call displayTime

        call clearScreen
        call makeBoundary
        call initializeSnake
        
    snakeAlreadyDed:
popf
pop ax
ret

displayLength:

    push word [size]
    push word 120 ;somewhere in the second half of first row.
    call printnum

ret