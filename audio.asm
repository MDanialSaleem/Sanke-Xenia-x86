file: dw 262, 1, 262, 1, 294, 2, 262, 2, 349, 2, 330, 4, 262, 1, 262, 1, 294, 2
file2: dw 262, 2, 349, 2, 330, 4, 262, 1, 262, 1, 523, 2, 440, 2, 349, 2, 330, 2, 294, 6, 466, 1, 466, 1, 440, 2, 349, 2, 392, 2, 349, 4



musicCountDown:dw 0
musicIndex: dw 0

speackerConfig: db 0
speakerOn:
push ax

    in al, 61h ;get the current setting of port b
    mov [speackerConfig], al ;save it
    or al, 00000011b ;make bit 0 and 1 one
    out 61h, al ;turn the speaker on

pop ax
ret


speakerOff:
push ax

    mov al, [speackerConfig] ;get original setting of port b
    out 61h, al ;turn the speaker off.

pop ax
ret

getOutputFrequency:
;gets the input freunecy of the note as paramter, and returns the output frequency that needs to be put on port.
push bp
mov bp, sp 
pusha

    mov ax, 0x34dc
    mov dx, 12h
    mov bx, [bp + 4]
    div bx ;ax now has required output frequency.
    mov [bp + 6], bx

popa
mov sp, bp
pop bp
ret 2

playMusic:
pusha

    cmp word[musicCountDown], 0
    jne noteSwitchNotNeeded


        mov bx, file
        mov dx, [musicIndex]
        shl dx, 2
        add bx, dx
        mov ax, [bx] ;frequency.
        mov dx, [bx + 2] ;duration.


        push word 0
        push ax
        call getOutputFrequency
        pop bx

        mov al, 0b6h ;control byte.
        out 43h, al ;send control byte to control reg
        mov ax, bx ;frequency of note.
        out 42h, al
        mov al, ah
        out 42h, al

        mov word[musicCountDown], dx


        inc word[musicIndex]
        cmp word[musicIndex], 25
        jne trackNotFinished

            mov word[musicIndex], 0

        trackNotFinished:
    noteSwitchNotNeeded:
popa
ret


generateGeneralSound:
;takes two paramters. 1-note frequency, 2-note duration
push bp
mov bp, sp
pusha

        push word 0
        push word[bp + 6] ;input frequency.
        call getOutputFrequency
        pop bx

        mov al, 0b6h ;control byte.
        out 43h, al ;send control byte to control reg
        mov ax, bx ;frequency of note.
        out 42h, al
        mov al, ah
        out 42h, al

        mov ax, [bp + 4]
        mov [musicCountDown], ax


popa
mov sp, bp
pop bp
ret 4
