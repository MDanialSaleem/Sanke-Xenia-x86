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

printnum: 
;takes two paramters, 1-the number to be printed 2-address from where to start printing.
push bp
mov bp, sp
push es
pusha


mov ax, 0xb800
mov es, ax ; point es to video base

mov ax, [bp+6] ; load number in ax
mov bx, 10 ; use base 10 for division
mov cx, 0 ; initialize count of digits

mov di, [bp + 4]

nextdigit: 
    mov dx, 0 ; zero upper half of dividend
    div bx ; divide by 10
    add dl, 0x30 ; convert digit into ascii value
    push dx ; save ascii value on stack
    inc cx ; increment count of values
    cmp ax, 0 ; is the quotient zero
jnz nextdigit ; if no divide it again

nextpos: 
    pop dx ; remove a digit from the stack
    mov dh, 0x07 ; use normal attribute
    mov [es:di], dx ; print char on screen
    add di, 2 ; move to next screen location
loop nextpos ; repeat for all digits on stack


popa
pop es
mov sp, bp
pop bp
ret 4

updateTime:
pusha
push es

    mov ax, [int0frequency]
    cmp word[tickCount], ax
    jl secondNotPassed

        mov word[tickCount], 0
        inc word[seconds]
        cmp word[seconds], 60
        jl minuteNotPassed

            mov word[seconds], 0
            inc word[minutes]

        minuteNotPassed:

        dec word[bonusFoodCountdown]
        
    secondNotPassed:
    call displayTime
pop es
popa
ret

displayTime:
push es
push ax

    mov ax, 3
    sub ax, [minutes]
    push ax
    push word 0
    call printnum

    push word 0xb800
    pop es

    mov word[es:02], 0x073a

    mov ax, 60
    sub ax, [seconds]
    push ax
    push word 4
    call printnum

pop ax
pop es  
ret

updateTimerFrequency:
;takes the new divisor as parmater. changes the frequency on ports and also the frequency saved in memory so that 
;the second counter works okay.
push bp
mov bp, sp
push ax
push bx

    cli

    mov ax, [bp + 4]
    out 0x40, al
    mov al, ah
    out 0x40, al

    mov ax, 3752h
    mov dx, 12h
    mov bx, [bp + 4]
    div bx ;ax now has ticks/second.
    mov [int0frequency], ax

    sti

pop bx
pop ax
mov sp, bp
pop bp
ret 2