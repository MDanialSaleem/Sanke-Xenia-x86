[org 0x0100]

jmp main



;each word of array is the position of that part of snake on screen.
snake: times 240 dw 0
size: dw 0;curr size of the snake array.
direction: dw 0;0 for right, 1 for down, 2 for left, 3 for up.
foodGreen: dw 0 ;position of the fruit on screen.

%include "snake.asm"
%include "food.asm"
%include "utility.asm"


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

    cmp word[count], 1
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

    cmp al, 0x48 ;w
    jne checkDownKey

        mov word[direction], 3 ;for up
        jmp keysChecked

    checkDownKey:
    cmp al, 0x50
    jne checkRightKey

        mov word[direction], 1;for down
        jmp keysChecked

    checkRightKey:
    cmp al, 0x4d
    jne checkLeftKey

        mov word[direction], 0;for left
        jmp keysChecked

    checkLeftKey:
    cmp al, 0x4b
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