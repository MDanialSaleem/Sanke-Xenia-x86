[org 0x0100]

jmp main



;each word of array is the position of that part of snake on screen.
snake: times 240 dw 0
size: dw 0			;curr size of the snake array.
direction: dw 0     ;0 for right, 1 for down, 2 for left, 3 for up.

foodGreen: dw 0 ;position of the fruit on screen.
bonusFood: dw 0
bonusFoodCountdown: dw 0
bombFood: dw 0
bombFoodCountdown: dw 0

lives: dw 3
level: dw 0


hitSound: dw 4536
eatSound: dw 1569
soundDuration: dw 2;in half seconds.

resetMessageCountdown: dw 0

int0divisor: dw 0xffff ;initial divisor.
int0frequency: dw 0 
halfSeconds: dw 0
seconds: dw 0
minutes: dw 0
tickCount: dw 0


delayCount: dw 4 ;initially starts with 4 second delay at the slowest possible frequency of 18.2.
currCount: dw 0 ;the purpose is almost same as tickCount defined above, but that variable is used for maintaining time and music.
controlWord: dw 0


WelcomeMsg: db 'Welcoe to Snake Xenia', 0
stage1Msg: db 'Press 1 for stage 1',0
stage2Msg: db 'Press 2 for stage 2',0
stage3Msg: db 'Press 3 for stage 3',0



%include "snake.asm"
%include "arena.asm"
%include "food.asm"
%include "utility.asm"
%include "audio.asm"




zeroHandler:
;just to make the screen red if some div by zero occurs.
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


timer:
pusha
push ds

    push cs 
    pop ds 

    
    inc word[tickCount]
    inc word[currCount]

    call updateTime 
    call playMusic
    call updateSpeed 		  ;these functions maintain the system.

    mov ax, [delayCount]	;controls the speed.
    cmp [currCount], ax
    jl endTimerIsr

        call makeArena
        call drawFood
        call moveSnake
        call makeSnake
        call eatFood
        call foodManager
        call collisionCheckMaster
        call checkTimePassed

        mov word[currCount], 0
    endTimerIsr:


    call diplayLives 		;actually only displayTime needs to be outputted on every tick, this is just to group related logic.
    call displayLength
    call displayTime
    call displayResetMessage

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


printMessages:

    push word WelcomeMsg
    push word 0x00c0
    push word 8
    push word 10
    call printStr

    push word stage1Msg
    push word 0x0040
    push word 10
    push word 10
    call printStr

    push word stage2Msg
    push word 0x0040
    push word 11
    push word 10
    call printStr

    push word stage3Msg
    push word 0x0040
    push word 12
    push word 10
    call printStr


ret 

main:

call clearScreen
call printMessages

takeInputAgain:
mov ah, 0
int 16h
sub al, 48
dec al

cmp al, 2
ja takeInputAgain

mov ah, 0
mov [level], ax


xor ax, ax
mov es, ax

call initializeSnake
call speakerOn
call makeArena
call foodManager

push word [int0divisor]
call updateTimerFrequency

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
push word 0
call terminationCondition
pop dx
cmp dx, 0
je notDead






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

cmp dx, 1
jne loseCheck

    call winGameScreen
    jmp endGameCheck

loseCheck:

    call loseGameScreen

endGameCheck:

call speakerOff

mov ah, 0ch
int 21h
mov ah, 0
int 16h ;waits for input.

call clearScreen


mov ax, 0x4c00
int 21h