[org 0x0100]

jmp main

;each word of array is the position of that part of snake on screen.
snake: times 240 dw 0
size: dw 0;curr size of the snake array.
direction: dw 0;0 for right, 1 for down, 2 for left, 3 for up.
foodGreen: dw 0 ;position of the fruit on screen.

initializeSnake:
;meant to print the initial snake at the beginning of the game or if life is lost.
pusha

    mov word[size], 20
    mov cx, 20
    mov bx, snake
    mov ax, 560 ;randomly chosen.
    whileInitialize:

        mov [bx], ax
        add bx, 2
        sub ax, 2

    loop whileInitialize

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
        mov word[es:di], 0x4852
        add bx, 2
    loop whileMakeSnake

    mov bx, [snake]
    mov word[es:bx], 0x1844
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
        loopp:
        jmp loopp

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
        infin:
        jmp infin

    noCollisionWithBoundary:
pop es
popa
ret



seed: dw 158; 
increment: dw 1939
multiplier: dw 181
modulus: dw 4000

rand:
;takes no input and returns the random integer in stack.
push bp
mov bp, sp
pusha

    mov ax, [seed]
    mov bx, [multiplier]
    mul bx ;the numbers are small, they will fit in 16 bits.
    add ax, [increment]
    mov bx, [modulus]
    div bx
    mov [seed], dx ;reaminder in dx saved for next use.
    mov [bp + 4], dx ;returned

popa
mov sp, bp
pop bp
ret


checkFoodCollisionWithSnakeAndBoundary:
;takes the position of food on video memory as input in stack, returns 1 if it matches with some position of snake or boundary
;returns -1 otherwise.
push bp
mov bp, sp
pusha

    mov ax, [bp + 4]
    mov bx, snake
    mov cx, [size]
    mov dx, -1

    whileCheckingFoodCollision:

        cmp ax, [bx]
        jne noCollisionWithFood

            mov dx, 1

        noCollisionWithFood:        
        add bx, 2
    loop whileCheckingFoodCollision

    push word 0
    push word 0
    push ax
    call calRowAndColumn
    pop ax ;col
    pop bx ;row

    cmp ax, 0
    je foodCollisionWithBoundary 
    cmp ax, 79
    je foodCollisionWithBoundary
    cmp bx, 0
    je foodCollisionWithBoundary
    cmp bx, 24
    jne noFoodCollisionWithBoundary

    foodCollisionWithBoundary:

        mov dx, 1
    
    noFoodCollisionWithBoundary:
    mov [bp + 6], dx

popa
mov sp, bp
pop bp
ret 2

generateNewFood:
;takes the offset of the food to generate.
push bp
mov bp, sp
pusha

    regenerate:

    mov bx, [bp + 4] ;offset of food.

    push word 0
    call rand
    pop ax
    mov dx, ax
    shr dx, 1
    jnc foodGenAtEven

        dec ax

    foodGenAtEven:

    push word 0
    push word ax
    call checkFoodCollisionWithSnakeAndBoundary
    pop si
    cmp si, 1
    je regenerate
    
    mov [bx], ax


popa
mov sp, bp
pop bp
ret 2


drawFood:
pusha
push es

    mov ax, 0xb800
    mov es, ax
    mov bx, [foodGreen]
    mov word[es:bx], 0x2720
pop es
popa
ret

eatFood:
;takes no paramters. checks if the snake's head is at the same position as the food. if so, then it removes the food, elongates snake
;and makes the food appear on a different position.
pusha

    mov ax, [snake] ;head
    cmp ax, [foodGreen] ;cmp head's position with fruit's position.
    jne foodNotEaten

        call elongateSnake
        push word foodGreen
        call generateNewFood

    foodNotEaten:

popa
ret

calRowAndColumn:
;takes the offset of a point in video memory, and calculates it's col (first return value) and row(second return value) and returns them.
;take note that using this fucntion rows and columns start from zero.
push bp
mov bp, sp
pusha

    mov dx, 0
    mov ax, [bp + 4]
    mov bx, 160
    div bx
    mov [bp + 8], ax ;row
    mov ax, dx
    mov bh, 2
    div bh
    mov [bp + 6], ax ;column

popa
mov sp, bp
pop bp
ret 2

clearScreen:
pusha
push es

    mov cx, 2000
    mov di, 0
    push 0xb800
    pop es
    mov ax, 0x0720
    cld
    rep stosw

pop es
popa
ret


zeroHandler:
;just to make the screen red if some collision occurs.
pusha
push es

    mov ax, 0xb800
    mov es, ax
    mov di, 0 ;es:di = b800:0
    mov ax, 0x4720
    mov cx, 2000
    cli
    rep stosw

pop es
popa
iret


count: dw 0
timer:
pusha
push ds

    push cs 
    pop ds 

    cmp word[count], 3
    jne incrementTimer

        call clearScreen
        call makeBoundary
        call drawFood
        call moveSnake
        call makeSnake
        call collisionCheckItself
        call collisionCheckBoundary
        call eatFood
        
        mov word[count], 0
        jmp endTimerIsr

    incrementTimer:
    
        inc word[count]

    endTimerIsr:
    mov al, 0x20
    out 0x20, al

pop ds 
popa
iret 

kbisr:
pusha
push ds

    push cs
    pop ds

    in al, 0x60

    cmp al, 0x11 ;w
    jne checkDownKey

        mov word[direction], 3 ;for up
        jmp keysChecked

    checkDownKey:
    cmp al, 0x1f
    jne checkRightKey

        mov word[direction], 1;for down
        jmp keysChecked

    checkRightKey:
    cmp al, 0x20
    jne checkLeftKey

        mov word[direction], 0;for left
        jmp keysChecked

    checkLeftKey:
    cmp al, 0x1e
    jne checkEnter

        mov word[direction], 2;for left
        jmp keysChecked

    checkEnter:
    cmp al, 0x1c
    jne keysChecked
        call elongateSnake
    keysChecked:

    mov al, 0x20
    out 0x20, al
pop ds
popa
iret

main:

xor ax, ax
mov es, ax

call initializeSnake
call makeBoundary
push word foodGreen
call generateNewFood

cli
mov word[es:0], zeroHandler
mov word[es:2], cs
mov word[es:0x8*4], timer
mov word[es:0x8*4 + 2], cs

mov word[es:0x9*4], kbisr
mov word[es:0x9*4+ 2], cs
sti

mov ax, 0x4c00
int 21h


; testmain:

; call initializeSnake
; call elongateLeft
; call makeSnake


; mov ax, 0x4c00
; int 21h
