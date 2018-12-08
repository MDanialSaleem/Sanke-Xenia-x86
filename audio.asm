file: db 262, 1, 262, 1, 294, 2, 262, 2, 349, 2, 330, 4, 262, 1, 262, 1, 294, 2
db 262, 2, 349, 2, 330, 4, 262, 1, 262, 1, 523, 2, 440, 2, 349, 2, 330, 2, 294, 6, 466, 1, 466, 1, 440, 2, 349, 2, 392, 2, 349, 4



musicCountDown:dw 0


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
