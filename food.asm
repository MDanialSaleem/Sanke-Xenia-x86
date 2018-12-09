
checkFoodCollisionWithSnakeAndBoundary:
;takes the position of food on video memory as input in stack, returns 1 if it matches with some position of snake or boundary
;or some other food or some hurdle. returns -1 otherwise.
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

    cmp word[level], 1
    jne foodLevel1ChecksNotNecessary

        push word 0
        push word [bp + 4] ;the value received.
        call generalCollisionWithLevel1Hurdles
        pop si
        cmp si, 0
        je foodLevel1ChecksNotNecessary
            mov dx, 1

    foodLevel1ChecksNotNecessary:


    cmp word[level], 2
    jne foodLevel2ChecksNotNecessary

        push word 0
        push word [bp + 4] ;the value received.
        call generalCollisionWithLevel2Hurdles
        pop si
        cmp si, 0
        je foodLevel2PortalChecks
            mov dx, 1
        foodLevel2PortalChecks:
        push word 0
        push word[bp + 4]
        call generalCollisionWithPortals
        pop si
        cmp si, 0
        je foodLevel2ChecksNotNecessary
            mov dx, 1

    foodLevel2ChecksNotNecessary:

    mov ax, [bp + 4] ;address of food.
    cmp ax, [foodGreen]
    jne foodNotCollidedWithGreenFood

        mov dx, 1

    foodNotCollidedWithGreenFood:

    cmp ax, [bonusFood]
    jne foodNotCollidedWithBonusFood

        mov dx, 1

    foodNotCollidedWithBonusFood:

    cmp ax, [bombFood]
    jne foodNotCollidedWithBombFood

        mov dx, 1

    foodNotCollidedWithBombFood:

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


bombFoodCell: dw 0x780f
greenFoodCell: dw 0x7e06
bonusFoodCell: dw 0x7c15

drawFood:
pusha
push es

    mov ax, 0xb800
    mov es, ax

    mov bx, [foodGreen]
    mov dx, [greenFoodCell]
    mov word[es:bx], dx

    mov bx, [bonusFood]
    mov dx, [bonusFoodCell]
    mov word[es:bx], dx

    mov bx, [bombFood]
    mov dx, [bombFoodCell]
    mov word[es:bx], dx

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

        push word [eatSound]
        push word [soundDuration]
        call generateGeneralSound

    greenFoodNotEaten:


    cmp ax, [bonusFood]
    jne bonusFoodNotEaten

        
        push word [eatSound]
        push word [soundDuration]
        call generateGeneralSound

        call elongateSnake
        call elongateSnake
        call elongateSnake
        call elongateSnake 
        call elongateSnake ;to add 20 characters to the length.
        mov word[bonusFood], 8000 ;to move it out of screen.
        ;the strategy of normal food cannot be applied here because the bonus food generates after some time.
    bonusFoodNotEaten:


    cmp ax, [bombFood]
    jne bombFoodNotEaten

        mov word[bombFood], 8000
        call updateLives

    bombFoodNotEaten:
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
    ;this prevents the bonus food from ebing regenerated multiple time in the 10th second.

        push word bonusFood
        call generateNewFood
        mov word[bonusFoodCountdown], 5

    notTimeForBonusFood:

    cmp word[bonusFoodCountdown], 0
    jg bonusFoodAvailable

        mov word[bonusFood], 8000 ;a value outside of visible screen.
        ;so that whenever time is up, the location of bonus food is outside of screen.
    
    bonusFoodAvailable:


    cmp word[seconds], 10
    jne notTimeForBombFood
    cmp word[minutes], 0
    je timeForBombFood 
    cmp word[minutes], 3
    jne notTimeForBombFood ;if(seconds == 30 && (minutes == 0 || minutes == 3))
    timeForBombFood:

        cmp word[bombFoodCountdown], 0
        jg notTimeForBombFood ;see the logic for bonus food.

            push word bombFood
            call generateNewFood
            mov word[bombFoodCountdown], 10

    notTimeForBombFood:


    cmp word[bombFoodCountdown], 0
    jg bombFoodAvailable

        mov word[bombFood], 8000 ;outside the screen.

    bombFoodAvailable:
popa
ret