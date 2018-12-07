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
    call calRowAndColumn ;gets the rows and column corresponding to the position of food on screen for easy comparison with boundary.
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


    mov ax, [bp + 4] ;address of food.
    cmp ax, [foodGreen]
    jne foodNotCollidedWithGreenFood

        mov dx, 1

    foodNotCollidedWithGreenFood:

    cmp ax, [bonusFood]
    jne foodNotCollidedWithBonusFood

        mov dx, 1

    foodNotCollidedWithBonusFood:
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

    mov bx, [bonusFood]
    mov word[es:bx], 0x4720

pop es
popa
ret

eatFood:
;takes no paramters. checks if the snake's head is at the same position as the food. if so, then it removes the food, elongates snake
;and makes the food appear on a different position.
pusha

    mov ax, [snake] ;head
    cmp ax, [foodGreen] ;cmp head's position with fruit's position.
    jne greenFoodNotEaten

        call elongateSnake
        push word foodGreen
        call generateNewFood

    greenFoodNotEaten:


    cmp ax, [bonusFood]
    jne bonusFoodNotEaten

        call elongateSnake
        call elongateSnake
        call elongateSnake
        call elongateSnake 
        call elongateSnake ;to add 20 characters to the length.
        mov word[bonusFood], 8000 ;to move it out of screen.
        ;the strategy of normal food cannot be applied here because the bonus food generates after some time.
    bonusFoodNotEaten:
popa
ret


foodManager:
;takes no parameters. It initialies the greenFood at the start of game. It also controls the appearence and disappearence
;of bonus food.
pusha

    cmp word[foodGreen], 0
    jne greenFoodAlreadyGenerated

        push word foodGreen
        call generateNewFood

    greenFoodAlreadyGenerated:

    mov ax, [seconds]
    mov bl, 10
    div bl

    cmp ah, 0 ;for generating food every 10 seconds.
    jne notTimeForBonusFood
    cmp word[bonusFoodCountdown], 0
    jg notTimeForBonusFood ;this means that the bonus food was already generated in the current second.
    ; ;this prevents the bonus food from ebing regenerated multiple time in the 10th second.

        push word bonusFood
        call generateNewFood
        mov word[bonusFoodCountdown], 5

    notTimeForBonusFood:

    cmp word[bonusFoodCountdown], 0
    jg bonusFoodAvailable

        mov word[bonusFood], 8000 ;a value outside of visible screen.
        ;so that whenever time is up, the location of bonus food is outside of screen.
    
    bonusFoodAvailable:

popa
ret