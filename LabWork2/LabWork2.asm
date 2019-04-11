.MODEL small 
.STACK 100h 
.DATA 
msg1 DB "Enter first string: $" 
msg2 DB 0Ah, 0Dh, "Enter second string: $" 
msg3 DB 0Ah, 0Dh, "Result: $" 

str1ml DB 200 
str1l DB '$' 
str1 DB 200 dup('$') 

str2ml DB 200 
str2l DB '$' 
str2 DB 200 dup('$') 

.CODE 
begin: 
    mov ax, @data 
    mov ds, ax 
    mov es, ax 
    xor ax, ax 

    lea dx, msg1 
    call strout 

    lea dx, str1ml 
    call strin 

    lea dx, msg2 
    call strout 

    lea dx, str2ml 
    call strin 
    cld 
    lea di, str2 
    lea si, str1 
    xor ax, ax
    xor cx, cx
    xor dx, dx 
    
    
    cmp str1l, 0
    je _end
     cmp str2l, 0
    je _end
    
    call dell_duplicate
    call dell_space 
    call dell
     
    _end:
    lea dx, msg3
    call strout
    lea dx, str1
    call strout
    mov ah, 4ch 	
    int 21h

dell_space proc
    push si
    push di
    push cx
    mov cl, str2l
    mov si, di
    find_space:
        cmp [si], 20h
        je _shift1
        inc si
    loop find_space
    pop cx
    pop di
    pop si
    ret
    
    _shift1:
    push di
    push si
    push cx
    mov di,si
    inc si   
    rep movsb
    mov [di],"$"
    sub str2l, 1 
    pop cx
    pop si
    pop di
    
    pop cx
    pop di
    pop si
    ret
        
dell_space endp    
    
dell proc
    push si
    push di
    push cx
    push ax
    mov dh, 1
    mov cl, str1l
    skip_space:
        cmp str1l, dh
        je _end
        xor bx, bx
        cmp [si], 20h
        jne _comparison
        inc si
        inc dh 
    loop skip_space
     
_comparison:
    push dx
    push si
    push di
    push cx
    push ax
    mov cl, str2l 
    for_di1:
        push dx
        push si
        push cx
        mov cl, str1l
        sub cl, dh
        inc cl 
        for_si1:
            mov al, [si]
            mov ah, [di] 
            cmp ah, al
            je _inc_cntr
            cmp [si], 20h
            je _end_word
            inc si
            inc dh 
        loop for_si1
        pop cx
        pop si
        pop dx
        inc di
    loop for_di1
    pop ax        
    pop cx
    pop di
    pop si
    pop dx
    cmp bl, str2l
    je _shift2
    inc si
    inc dh
    dec cl
    jmp skip_space

_shift2:
    push si
    push di
    push cx
    push ax
    push dx 
    mov cl, str1l
    sub cl, dh
    mov di,si
    inc si 
    rep movsb
    mov [di],"$"
    lea dx, str1
    call strout
    sub str1l, 1
    pop dx       
    pop ax        
    pop cx
    pop di
    pop si
    cmp dh, str1l
    ja _end
    cmp [si], 20h
    jne _shift2
    inc si
    inc dh
    dec cl
    jmp skip_space
    
_inc_cntr:
    inc bl

_end_word:
    pop cx
    pop si
    pop dx
    inc di
    dec cl
    cmp cl, 0
    jne for_di1
    pop ax        
    pop cx
    pop di
    pop si
    cmp bl, str2l
    je _shift2
    inc si
    inc dh
    jmp skip_space 
    
    pop ax        
    pop cx
    pop di
    pop si
    ret             
dell endp

   

dell_duplicate proc 
    push di 
    push si
    push cx
    push ax    
    mov cl, str2l
    dec cl   
    for_di:
        push cx
        mov si, di 
        inc si  
        for_si:
            mov al, [si]
            mov ah, [di]          
            cmp ah, al
            je _shift
            inc si  
        loop for_si
        pop cx
        inc di
    loop for_di  
    pop ax      
    pop cx     
    pop si 
    pop di
    ret
    
    _shift:
    push di
    push si
    push cx
    mov di,si
    inc si   
    rep movsb
    mov [di],"$"
    sub str2l, 1
    pop cx
    pop si
    pop di
    dec cl
    cmp cl, 0
    jne for_si
    pop cx
    inc di
    dec cl
    cmp cl, 0
    jne for_di 
    pop ax      
    pop cx     
    pop si 
    pop di
    ret
     
dell_duplicate endp 
  
strin proc 
    mov ah, 0Ah 
    int 21h 
    ret 
strin endp 

strout proc 
    mov ah, 09h 
    int 21h 
    ret 
strout endp 

end begin