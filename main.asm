[org 0x0100]

jmp main



;each word of array is the position of that part of snake on screen.
snake: times 240 dw 0
size: dw 0;curr size of the snake array.
direction: dw 0;0 for right, 1 for down, 2 for left, 3 for up.
foodGreen: dw 0 ;position of the fruit on screen.
lives: dw 3

%include "snake.asm"
%include "food.asm"
%include "utility.asm"

updateLives:
push ax

    cmp word[lives], 0
    je snakeAlreadyDed

        dec word[lives]
        call clearScreen
        call initializeSnake

    snakeAlreadyDed:


pop ax
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

    cmp word[count], 1
    jne incrementTimer

        call clearScreen
        call makeBoundary
        call drawFood
        call moveSnake
        call makeSnake
        call eatFood
        call collisionCheckItself
        call collisionCheckBoundary
        
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

        cmp word[direction], 1 ;if going down then it can't go up.
        je keysChecked
        mov word[direction], 3 ;for up
        jmp keysChecked

    checkDownKey:
    cmp al, 0x50
    jne checkRightKey

        cmp word[direction], 3 ;if going up, cannot go down.
        je keysChecked
        mov word[direction], 1;for down
        jmp keysChecked

    checkRightKey:
    cmp al, 0x4d
    jne checkLeftKey

        cmp word[direction], 2 ;if left,can't go right
        je keysChecked
        mov word[direction], 0;for right.
        jmp keysChecked

    checkLeftKey:
    cmp al, 0x4b
    jne keysChecked

        cmp word[direction], 0 ;if right, can't go left
        je keysChecked
        mov word[direction], 2;for left.

    keysChecked:

pop ds
popa
jmp far [cs:oldKbIsr]


oldKbIsr: dd 0
oldTimerIsr: dd 0
oldZeroIsr: dd 0

main:

xor ax, ax
mov es, ax

call initializeSnake
call makeBoundary
push word foodGreen
call generateNewFood


xor ax, ax
mov es, ax

mov ax, [es:0x9*4]
mov [oldKbIsr], ax
mov ax, [es:0x9*4 + 2]
mov [oldKbIsr + 2], ax

mov ax, [es:0x8*4]
mov [oldTimerIsr], ax
mov ax, [es:0x8*4 + 2]
mov [oldTimerIsr + 2], ax

mov ax, [es:0]
mov [oldZeroIsr], ax
mov ax, [es:2]
mov [oldZeroIsr + 2], ax


cli
mov word[es:0], zeroHandler
mov word[es:2], cs

mov word[es:0x8*4], timer
mov word[es:0x8*4 + 2], cs

mov word[es:0x9*4], kbisr
mov word[es:0x9*4+ 2], cs
sti


notDead:
cmp word[lives], 0
jne notDead

call clearScreen

xor ax, ax
mov es, ax

cli


mov ax, [oldKbIsr]
mov [es:0x9*4], ax
mov ax, [oldKbIsr + 2]
mov [es:0x9*4 + 2], ax

mov ax, [oldTimerIsr]
mov [es:0x8*4], ax
mov ax, [oldTimerIsr + 2]
mov [es:0x8*4 + 2], ax

mov ax, [oldZeroIsr]
mov [es:0], ax
mov ax, [oldZeroIsr + 2]
mov [es:2], ax



sti



mov ax, 0x4c00
int 21h