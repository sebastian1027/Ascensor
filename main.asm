;--------------------------------
list p=16f887
include "P16F887.INC"
;---------------------Declaracion de...------------  
 pisoactual equ 0x20
 proximopiso equ 0x21
 control equ 0x22
 conta equ 0x23
 CONTA_1 equ 0x24
 CONTA_2 equ 0x25
 CONTA_3 equ 0x26
;----------------------...las variables -------------
 ;****************************************-------***********
org 0x00 
    bsf STATUS,RP0  ;ingreso al banco 1
    bcf STATUS,RP1
    clrf TRISA	    ;limpiamos y declaramos el puerto A como salidas
    clrf TRISD	    ;limpiamos y declaramos el puerto D como salidas
    movlw b'11111111'	;Declaramos como entradas...
    movwf TRISB		;... el puerto B
    clrf TRISC		;PUERTO C COMO SALIDA
    bcf STATUS,RP0	;regresamos el banco 0
    bcf STATUS,RP1 
;**********----------------------**********
    
;INTERRUPCIONES 
    ;bsf INTCON, GIE	;habilita todas las interrupciones
    ;bsf INTCON, RBIE	;habilita las interrupciones de RB0
    ;bsf INTCON, INTE	;habilita las interrupciones de RB4 a RB7
    
;;**********-------------**********  
    clrf TRISA	    ;limpiamos el puerto A 
    movlw b'00000001'	;
    movwf pisoactual    
    movlw B'00000110'	;"imprimimos" el numero 1...
    movwf TRISD		;...en el dipslay, ya que por defecto el ascensor empieza en 1
bucle 
    movlw b'00000001';PRIMER PISO
    subwf PORTB,W
    btfsc STATUS,Z
    goto PISO1    
    movlw b'00000010';SEGUNDO PISO 
    subwf PORTB,W
    btfsc STATUS,Z
    goto PISO2    
    movlw b'00000100';TERCER PISO
    subwf PORTB,W
    btfsc STATUS,Z
    goto PISO3
    goto bucle    
PISO1
    movlw b'00000001';
    subwf pisoactual,W
    btfsc STATUS,Z
    goto mismopiso    
    movlw b'00000010';SEGUNDO PISO
    subwf pisoactual,W
    btfsc STATUS,Z
    goto pp1    
    movlw b'00000100';TERCER PISO
    subwf PORTB,W
    btfsc STATUS,Z
    goto pp1    
PISO2
    movlw b'00000001';
    subwf pisoactual,W
    btfsc STATUS,Z
    goto pp2    
    movlw b'00000010';SEGUNDO PISO
    subwf pisoactual,W
    btfsc STATUS,Z
    goto mismopiso    
    movlw b'00000100';TERCER PISO
    subwf PORTB,W
    btfsc STATUS,Z
    goto pp2        
PISO3
    movlw b'00000001';
    subwf pisoactual,W
    btfsc STATUS,Z
    goto pp3    
    movlw b'00000010';SEGUNDO PISO
    subwf pisoactual,W
    btfsc STATUS,Z
    goto pp3    
    movlw b'00000100';TERCER PISO
    subwf PORTB,W
    btfsc STATUS,Z
    goto mismopiso                
mismopiso    
    bsf PORTA,2
    call retardo
    bcf PORTA,2
    goto bucle
pp1
    movlw b'00000001'
    movwf proximopiso
    movlw pisoactual
    subwf proximopiso,control
    btfss PORTB, 0 ;verifica que se haya presionado el pin 0 del puerto B
    goto pp1	    ;de no ser asi regresa a pp1
    subwf PORTB, w  ;hace la resta (w-PORTB)
    btfsc STATUS, Z ;verifica que el resultado de Z sea 0 para saltar linea
    goto _piso2	    ;va a la subrrutina _piso2
    goto _piso3	    ;va a la subrrutina _piso3
    
    _piso2	;subrrutina _piso2
    bsf PORTA, 2    ;enciende el led ubicado en el pin 2 del puerto A
    call retardo    ;llama al retardo
    movlw B'01011011'	;imprime el numero 2 ...
    movwf PORTD	    ;en el display  
    call retardo    ;llama al retardo
    movlw B'00000110'	;imprime el numero 1...
    movwf PORTD	    ;... en el display
    call retardo    ;llama al retardo
    bcf PORTA, 2    ;apaga el led ubicado en el pin 2 del puerto A
    call retardo    ;llama al retardo
    movlw b'00000000'	;apaga todos los leds...
    movwf PORTA	    ;...del puerto A ...
    call retardo    ;... durante 5 segundos 
    bsf PORTA, 1    ;enciende el led ubicado en el pin 1 del puerto A, indicando que las puertas estan abiertas...
    call retardo    ;...durante 5 segundos
    bcf PORTA, 1    ;... apaga led ubicado en el pin 1 del puerto A
    goto mover	    ;va a la subrrutina mover
    
    _piso3	    ;subrrutina _piso3
    bsf PORTA, 2    ;enciende el led ubicado en el pin 2 del puerto A
    call retardo    ;llama al retard0
    movlw B'00000110'	;"imprime" el numero 1 
    movwf PORTC	    ;en el display...
    call retardo    ;..5 segundos despues...
    bcf PORTA, 2    ;... enciende el led ubicado en el pin 2 del puerto A
    call retardo    ;llama al retardo
    movlw b'00000000'	;apaga todos los leds ...
    movwf PORTA	    ;... del puerto A...
    call retardo    ;por 5 segundos
    bsf PORTA, 1    ;enciende el led ubicado en el pin1 del puerto A, indicando que se abre la puerta...
    call retardo    ;... por 5 segundos
    bsf PORTA, 1    ;apaga el led ubicado en el pin1 del puerto A
    call retardo    ;llama al retardo
    goto mover	    ;va a la subrrutina mover
    
    
    ;****en esta seccion vamos a ver hacia donde se mueve el ascensor, ya que hay 2 posibilidades, 
    ;que suba o que baje ****
pp2
    movlw b'00000010'
    movwf proximopiso
    movlw pisoactual
    subwf proximopiso,control
    BTFSS PORTB, 4  ;verificamos que se presiono el pin 4 del puerto A
    goto pp2	    ;de no ser asi vuelve a pp2
    subwf PORTB, W  ;hace la resta entre PORTB y el valor de w
    btfsc STATUS, Z ;si el resultado de z en 0 salta linea, si no sigue
    goto _pisoo3	    ;al no ser 0 va a _subir
    goto _pisoo1	    ;al z ser 0 va a bajar
    
    _pisoo3	    ;subrrutina subir
    bsf PORTA, 0    ;enciende el led que esta ubicado en el pin 0 del puerto a
    call retardo    ;lo enciende por 5 segundos    
    movlw B'01001111'	;3  mueve el valor de 3...
    movwf PORTD	    ;... al display
    bsf PORTA, 1    ;enciende un led ubicado en el pin 1 del puerto A, indicando que se abrio la puerta del ascensor 
    call retardo    ;lo enciende por 5 segundos
    bcf PORTA, 1    ;apaga el led ubicado en el pin 1 del puerto A, indicando que se abrio la puerta del ascensor 
    call retardo    ;llama al retardo
    goto mover	    ;vuelve a mover
    
    _pisoo1	    ;subrrutina bajar
    bsf PORTA, 2    ;enciende un led ubicado en el pin 2 del puerto A
    call retardo    ;durante 5 segundos
    bcf PORTA, 2    ;despues lo apaga
    movlw B'00000110'	;"imprime el valor de 1"...
    movwf PORTD	    ;... en el display ubicado en el puerto D
    call retardo    ;llama al retardo
    bcf PORTA, 0    ;apaga el led que esta ubicado en el pin 0 del puerto a
    call retardo    ;llama al reatardo
    movlw b'00000000'	;apaga todos los leds...
    movwf PORTA	    ;... ubicados en el puerto A 
    call retardo    ;durante 5 segundos
    bsf PORTA, 1    ;enciende un led ubicado en el pin 1 del puerto A 
    call retardo    ;durante 5 segundo, indicando que se abre la puerta
    bcf PORTA, 1    ;pasados los 5 segundos lo apaga
    call retardo    ;llama al retardo
    goto mover	    ;regresa a mover
    
pp3
    movlw b'00000100'
    movwf proximopiso
    movlw pisoactual
    subwf proximopiso,control    
    btfss PORTB, 7  ;verifica que se haya presionado el pin 7 del puerto B
    goto pp3	;de no ser asi, va a pp3
    subwf PORTB, w  ;hace la resta de (w-PORTB)
    btfsc STATUS, Z ;verifica que Z sea 0 para saltar linea
    goto _pisooo1   ;de no serlo va a la subrrutina _pisooo1
    goto _pisooo2   ;de serlo va a la subrrutina _pisooo2
    
    _pisooo1	    ;subrrutina _pisooo1, indica que va a bajar 2 pisos (al 2 y al 1)
    bsf PORTA, 2    ;enciende el led ubicado en el pin 2 del puerto A
    call retardo    ;llama al retardo
    movlw B'01011011'	;"imprime" el numero 2 ...
    movwf PORTC		;...en el display... 
    call retardo	;...5 segundos despues...
    movlw B'01001111'	;..."imprime" el numero 3... 
    movwf PORTC		;...en el display
    call retardo	;pasados 5 segundos...
    bcf PORTA, 2	;...apaga el led ubicado en el pin 2 del puerto A
    call retardo	;llama a retardo
    movlw b'00000000'	;apaga todos los leds...
    movwf PORTA	    ;...ubicados en el puerto A...
    call retardo    ;... durante 5 segundos
    bsf PORTA,1	    ;enciende un led durante 5 segundos...
    call retardo    ;indicando que se abrio las puertas...
    bcf PORTA,1    ;... despues de 5 segundos apaga el led
    goto mover	    ;va a la subrrutina mover
    
    _pisooo2	    ;indica que va a bajar un piso (al 2)
    bsf PORTA, 2    ;enciende el led ubicado en el pin 2 del puerto A    
    call retardo    ;5 segundos depsues
    movlw B'01001111'	;"imprime" el numero 3...
    movwf PORTC	    ;... en el display 7 segmentos
    call retardo    ;llama al retardo
    bcf PORTA, 2    ; apaga el led ubicado en el pin 2 del puerto A    
    call retardo    ;5 segundos despues...
    movlw b'00000000'	;apaga todos los leds...
    movwf PORTA	    ;... del puerto A
    call retardo    ;llama al retardo
    bsf PORTA, 1    ;y enciende un led ubicado en el pin 1 del puerto A
    call retardo    ;indicando que se abren las puertas
    bcf PORTA, 1    ;5 segundos despues apaga el led ubicado en el pin 1 del puerto A	    
    goto mover	    ;va a la subrrutina mover
mover
    btfss STATUS,C
;    goto _bajar
;    goto _subir
;    
;_bajar    
;   
;_subir   


retardo ;vamos a generar un retardo de 5 segundos
    movlw d'20'		;movemos el valor 20
    movwf CONTA_3	;movemos el valor a CONTA_3
    movlw d'250'	;movemos el valor 250
    movwf CONTA_2	;movemos el valor a CONTA_2
    movlw d'250'		;movemos el valor 250
    movwf CONTA_1	;movemos el valor a CONTA_1
    nop			;retardo de 1 uS
    decfsz CONTA_1, f	;decrementa CONTA_1 en 1,(CONTA_1 - 1) si es 0 salta
    goto $-.2		;se devuleve 2 lineas
    decfsz CONTA_2, F	;decrementa CONTA_2 en 1,(CONTA_2 - 1) si es 0 salta
    goto $-.6		;Se devuelve 6 lineas
    decfsz CONTA_3, F	;decrementa CONTA_3 en 1,(CONTA_3 - 1) si es 0 salta
    goto $-.10		;Se devuelve 10 lineas
    retlw 00

    
    
    
    end
; NUMEROS PARA CATODO COMUN
; 
;  B'00111111'	;0
;  B'00000110'	;1 
;  B'01011011'	;2
;  B'01001111'	;3
;  B'01100110'	;4
;  B'01101101'	;5 
;  B'01111101'	;6
;  B'00000111'	;7
;  B'01111111'	;8
;  B'01101111'	;9