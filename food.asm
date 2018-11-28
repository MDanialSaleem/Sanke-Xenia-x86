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