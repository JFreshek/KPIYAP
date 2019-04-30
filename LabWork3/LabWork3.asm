.model	small
.stack	100h
.data
            
MAX_ARRAY_LENGTH    equ 30            
array               db  MAX_ARRAY_LENGTH dup (0)             
arrayLength         db  ?
inputArrayLengthMsg db  0Dh,'Input array length: $'
                                
errorMsg            db  0Dh,'Incorrect value!',0Ah, '$' 
errorArrayLengthMsg db  0Dh,'Array length should be from 0 to 30!', 0Ah, '$'
                                
inputMsg            db  0Dh,'Input'          
currentElement      db  2 dup(0)
inputMsgEnding      db  ' element (-127..127) : $'
enter               db  0Ah, 0Dh, '$'

result              db  2 dup(0)
resultMsg           db  0Dh, '      $'

                                 
buffer              db  ?
                                                              
maxNumLen           db  5     
len                 db  ?               
buff                db  5 dup (0)          
                                
minus               db  0  

                             
.code      
start:                       
    mov	ax,@data                   
    mov	ds,ax
    mov es, ax                  
                               
    xor	ax,ax                                                  
    call inputArrayLength       
    call inputArray
    lea si, array
    xor cx, cx
    mov cl, arrayLength 
    call BubbleSort           
    call checkArray                                    
    call findMedian
    xor ax, ax                             
    mov	ah,4ch                   
    int	21h
                    
                                                            
inputArrayLength proc  
    mov cx, 1
              
    inputArrayLengthCycle:
    
       lea dx, inputArrayLengthMsg
       call print
                   
       call inputElement          
       
       test ah, ah
       jnz inputArrayLengthCycle 
       
       cmp buffer, MAX_ARRAY_LENGTH
       jg inputArrayLengthError   
       
       cmp buffer, 0
       jg inputArrayLengthSuccess   
       
       inputArrayLengthError:
            lea dx, errorArrayLengthMsg
            call print
            jmp inputArrayLengthCycle
       
        inputArrayLengthSuccess:
            mov bl, buffer 
            mov arrayLength, bl
                         
    loop inputArrayLengthCycle
         
    ret      
inputArrayLength endp 


inputArray proc
    xor di,di                                                                
    mov cl,arrayLength
                
    inputElementsCycle:            
        mov ax, di         
        mov bl, 10
        div bl          
              
        push di
        
        xor di, di    
        inc di
        mov currentElement[di], ah
        add currentElement[di], '0'
    
        test al, al 
        jz parsed
    
        dec di
        mov currentElement[di], al                      
        add currentElement[di], '0'           
           
       parsed:                                
            lea dx, inputMsg                    
            call print  
    
        pop di
                     
        call inputElement      
       
        test ah, ah
        jnz inputElementsCycle
       
        mov bl, buffer 
        mov array[di], bl
        inc di                     
    loop inputElementsCycle           
    ret      
inputArray endp      
 
 
inputElement proc                
    push cx                      
    mov buffer, 0          

    lea dx, maxNumLen
    call input       
                             
    mov dl,10     
    mov ah,2              
    int 21h              
                               
    cmp len,0               ;if empty              
    je inputElementError            
                             
    mov minus,0     
    xor bx,bx          
                             
    mov bl,len                 
    lea si,len                
                              
    add si,bx              
    mov bl,1             
                                                      
    xor cx,cx               
    mov cl,len
                  
    inputElementCycle:         
            std          
            lodsb                 ;байт по адресу DS:SI в AL
            call checkDigit 
                             
            cmp ah,1            
            je inputElementError     
                                 
            cmp ah,2             
            je nextDigit       
                                 
            sub al,'0'      
            mul bl                                
                                 
            add buffer,al  
                                  
            jo inputElementError  ;проверка на переполнение   
                                 
            mov al,bl            
            mov bl,10            
            mul bl       
                                  
            test ah,ah    
            jz checkNextElement      
                                  
                                  
            cmp ah,3                    ;10^4
            jne inputElementError    
                                  
                                 
            checkNextElement:        
                mov bl,al         
                jmp nextDigit       
                                 
                                 
            inputElementError:
                mov ah, 1
                lea dx, errorMsg
                call print          
                jmp inputElementExit       
                                  
            nextDigit:              ;&&&&&&&&&
            xor ah, ah            
        loop inputElementCycle    
                                  
    cmp minus,0                  
    je inputElementExit                
    neg buffer                    
                                  
    inputElementExit:                 
    pop cx                        
    ret                           
inputElement endp 
        
                                 
checkDigit proc                     
    cmp al,'-'            
    je checkMinus                   
                                 
    cmp al,'9'                   
    ja checkDigitError           
                                  
    cmp al,'0'                    
    jb checkDigitError              
                                  
    jmp checkDigitSuccess    
                                  
    checkMinus:                     
        cmp si, offset len        
        je saveMinus        
                                  
    checkDigitError:                 
        mov ah,1                  ;ah = 1 Incorrect symbol
        jmp checkDigitExit         
                                 
    saveMinus:          
        mov ah,2                 
        mov minus, 1             
        cmp len, 1               
        je checkDigitError  
                                  
        jmp checkDigitExit          
                                  
    checkDigitSuccess:              
        xor ah,ah                 ;ah = 0 
                                  
    checkDigitExit:                
        ret                      
checkDigit endp                              
                                                        

input proc
    push ax
    push dx
    
    mov ah,0Ah
    int 21h  
    
    pop dx
    pop ax
    ret
input endp
 
            
print proc
    push ax
    push dx

    mov ah, 09h
    int 21h

    pop dx
    pop ax
    ret
print endp   
                   
                             
findMedian proc                    
    xor ax, ax
    
    lea dx, resultMsg
    call print
    
    mov al, arrayLength
    mov dl, 2
    div dl
    
    xor ah, ah
    mov si, ax
    
    xor ax, ax        
    mov al, array[si]
    mov di, 4
    mov bl, 128
    
    push ax
        
    div bl
    cmp al, 1
    je negNumber
    
    pop ax 
     
    l11:         
    mov bl, 10
    div bl
                  
    mov result[di], ah
    add result[di], '0'
    
    test al, al 
    jz lessThanTen1
    
    dec di
    xor ah, ah
    jmp l11                              
    
    
    negNumber:
        pop ax
        neg al
        mov result[0], '-'
        jmp l11 
           
    lessThanTen1:                      
    
    lea dx, result
    call print      
    
    lea dx, enter
    call print                      
    ret                           
findMedian endp                             


checkArray proc 
    push ax
    push bx
    push dx
    push si
    push di
    push cx
    
    xor dx, dx
    xor bx, bx
    lea si, array
    lea di, array
    
    mov cl, arrayLength
    findCycle:
        xor ax, ax
        mov al, [si]
        mov bl, 128
        div bl
        cmp al, 0
        jne finded
        
        inc dh
        inc si
    loop findCycle
    jmp chekArrayExit
    
    finded:
        mov cl, arrayLength
        sub cl, dh
          
    shiftCycle:
        push cx
        
        mov cl, dh
        mov al, [si]
        
        push si
        
        mov di, si
        dec si
        std
        rep movsb
        
        inc si
        
        mov [si], al
        
        pop si
        
        inc si
       
        pop cx
        loop shiftCycle
    
    chekArrayExit:    
        pop cx    
        pop di
        pop si
        pop dx
        pop bx
        pop ax    
    ret
checkArray endp


bubbleSort proc
    push ax
    push bx
    push cx
    push dx
    push si
    push di
 
    mov bx, si
    mov dx, cx
    dec dx
    dec cx                           
    mov si, 0
    
    forI:
        mov di, dx                   
        forJ:              
            mov al, [bx+di-1]       
            cmp al, [bx+di]      
            jbe nextJ             
            xchg al, [bx+di]    
            xchg al, [bx+di-1]      
            xchg al, [bx+di]       
            nextJ:                 
                dec di         
                cmp di, si     ;j<=i
                ja forJ
                inc si 
                loop forI

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
bubbleSort endp

end	start