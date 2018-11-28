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