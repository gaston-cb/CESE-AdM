.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
.global asm_productoEscalar12
.global asm_max
.global asm_corr
.global asm_invertir
.global	asm_filtroVentana10
 
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   void asm_svc (void)
@
.thumb_func
    asm_svc:
        svc 0
        bx lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Prototipo en "C":
@   uint32_t asmSum (uint32_t firstOperand, uint32_t secondOperand)
@
@ Parametros recibidos:
@   r0: firstOperand
@   r1: secondOperand
@
@ Valor de retorno:
@   r0: resultado de la suma de firstOperand y secondOperand
@
.thumb_func
    asm_sum:
        add r0, r1  @ r0 = r0 + r1
        bx lr       @ vuelve adonde fue llamada (especificamente, si "pc"
                    @ es la direccion, en el codigo del programa, de la
                    @ instruccion "bl asm_sum" usada para saltar a
                    @ esta funcion, entonces "lr" contiene ese "pc" + 4).
                    @ el valor de retorno debe quedar en el registro r0.
                    @ En este caso, r0 es el resultado de r0 + r1.

        @ Otras alternativas para el retorno
        @ mov pc,lr
        @ bx lr
        @ push {lr} ... pop {pc}
.thumb_func
    asm_zeros:
        @ Registros usados
        @   r2: valor cero
        mov r2, 0           @ constante cero
    .asm_zeros_loop:
        str r2, [r0], 4     @ sizeof(uint32_t) == 4, *vector++ = r2
        subs r1, 1          @ --longitud
        bne .asm_zeros_loop
        bx lr

@ ro = vector_in, r1:vector_out ; r2 = longitud , r3 = escalar ;
.thumb_func
	asm_productoEscalar32:
	push {r5}
	push {r6}
	mov r6,0xFFFFFFFF
	.asm_productoEscalar32_loop:
	ldr r5,[r0],#4 	@r5 -> contenido apuntado por ro en r5, y luego r0 = r0+4
	muls r5,r3		@ -> no pude hacer la saturaciòn porque no produce ovf en valores "altos 0xffff"
	cmp r5,r6		@ r5 < r6
	IT CS
	movcs r5,r6		@ -> saturaciòn a 32bits, arm no pude generar ovf¿?
	str r5,[r1],#4
	subs r2,1
	bne .asm_productoEscalar32_loop
	pop {r6}
	pop {r5}
	bx lr @; devuelve el contexto de ejecución


@ ro = vector_in, r1:vector_out ; r2 = longitud , r3 = escalar ;
.thumb_func
	asm_productoEscalar16:
	push {r4}
	push {r5}
	mov r5,0xffff       @
	.asm_productoEscalar16_loop:
	ldrh r4,[r0],#2 	@r4 almacena los valores del array
	muls r4,r3
	cmp r4,r5		@
	IT CS
	movcs r4,r5		@ -> saturaciòn a 16bits, arm no pude generar ovf, siempre trabaja con signed int32??
	str r4,[r1],#2
	subs r2,1		    		@ -> saturaciòn a 32 bits
	bne .asm_productoEscalar16_loop
	pop {r5}
	pop {r4}
	bx lr

@ ro = vector_in, r1:vector_out ; r2 = longitud , r3 = escalar ;
.thumb_func
	asm_productoEscalar12:
	push {r4-r5}
	mov r5,0x0FFF
	.asm_productoEscalar12_loop:
	ldrh r4,[r0],#2
	muls r4,r3
	IT CS
	movcs r4,r5
	subs r2,1
	bne .asm_productoEscalar12_loop
	pop {r4-r5}
	bx lr


@r0 -> int32, r1 -> cant de elementos(uint32_t)
.thumb_func
	asm_max:
	push {r4}
	push {r5}
	push {r6}
	ldr r4,[r0],#4
	subs r1,1
	IT EQ		@ POR SI EL VECTOR ES DE UN SOLO ELEMENTO
	beq .end_asm_max
	.asm_max_loop:
		ldr r5,[r0]
		cmp r5,r4
		ITT HI 		@no soporta dos movhi, por eso se opta por usar bhi
		movhi r4,r5
		movhi r6,r1
		add r0,#4
		subs r1,1
		bne .asm_max_loop
	.end_asm_max:
	mov r0,r6
	pop {r6}
	pop {r5}
	pop {r4}
	bx lr



@ r0 -> vectorX, r1, vectorY, r2->vectorCorr, r3, numero de elementos
@ se asume que se tiene la misma cantidad de elementos
@ no se contempla el caso de cantX != cantY ni el caso de un elemento,
@ se asume que la cantidad de elementos es mayor a dos.
.thumb_func
	asm_corr:
	push {r4}  @vector de x[n]
	push {r5}  @vector de y[n]
	push {r6}  @contador de L
	push {r7}  @acumulador
	push {r8}  @offset de x
	push {r9}  @offset de y
	push {r10} @contador de N (sumatoria)
	sub r3,1   @ llevo a N-1 la cantidad de vectores de salida
	mov r6,#0  @ contador de cantidad de datos de salida (L, de 0 a N-1 o R3 actual)
	mov r7,#0  @ acumulador de convolución
	mov r10,#0
	.asm_corr_loop:
	@ offset de x
	ldrh r4,[r0,r8]
@ rutina para y(n-l)
	cmp r6,r10 @l>n -> INSTRUCCIONES CON LS !
	ITTTE LS @ cuatro instrucciones !
	subls r9,r10,r6 @ (n-l>0)
	lslls r9,1 		@ multiplicar x2 para el offset
	ldrhls r5,[r1,r9]
	movhi r5,0
@ RUTINA DE MULTIPLICACION Y ACUMULACION
	MLA   R7,R4,R5,r7 @r4*r5 + resultado anterior
@ RUTINA DE COMPARACION PARA SALTAR
	cmp r10,r3
	ITTEE EQ
	moveq r10,0
	moveq r8,0
	addne r10,1
	addne r8,2

	cmp r10,#0
	bne .asm_corr_loop
@ equivale al segundo for !
	strh r7, [r2],#2 @guardar corr
	mov r7,0 	@volver acumulador a cero
	add r6,1
	cmp r6,r3
	IT LS @ reseteo el contador antes de iniciar
	bLS .asm_corr_loop
	@strh r7, [r2,2]
	pop  {r10}
	pop  {r9}
	pop  {r8}
	pop  {r7}
	pop  {r6}
	pop  {r5}
	pop  {r4}
	bx lr


@ stand by ! -> consultar 
@ r0 debe incrementarse en 2, r1 incrementarse en uno
@	.asm_corr: @ aca vuelvo a empezar
@	ldm r0,{r4} @ cargo x[i] parte L y x[i+1] en la parte alta
@	ldm r1,{r5} @ cargo y[i] parte L y y[i+1] en la parte alta
@	smuad r5, r4,r5


@ r0 -> vector de entrada (puntero uint16_t)
@ r1 -> size de vector de entrada (cant de elementos)
.thumb_func:
	asm_invertir:
	push {r2} @ N/2
	push {r3} @ registro auxiliar
	push {r4} @ registro contador
	push {r5} @ cargo long - 1 - contador
	push {r6} @ vector [long - 1 - contador]

	mov r4,#0
	asr r2,r1,#1 @ N/2
    .asm_invertir_loop:
		sub r5,r1,1   @ long - 1
		sub r5,r5,r4  @ long - 1 - contador
		ldrh r3,[r0,r4,LSL 1]   @cargo vector[count]
		ldrh r6,[r0,r5,LSL 1] @ R6 = *(RO + R5 * 2)
		strh r3,[r0,r5,LSL 1] @ guardo r3 en *(RO + R5 * 2)
		strh r6,[r0,r4,LSL 1]
		add r4,1
		cmp r4,r2
	bne .asm_invertir_loop
	pop {r6}
	pop {r5}
	pop {r4}
	pop {r3}
	pop {r2}
	bx lr

@r0 -> vector In,
@r1 -> vector Out,
@r2 -> cantidad de elementos
.thumb_func
	asm_filtroVentana10:
	push {r3} @contador indice para el vector in
	push {r4} @contador indice para la ventana
	push {r5} @acumulador para avg
	push {r6} @ windows % longitud
	push {r7} @ uso para (index + ventana % L)%L
	push {r8} @ uso para almacenar los datos de ldrh
	mov r5,0
	mov r8,0
	mov r3,0
	mov r4,0
	.asm_filtroVentana10_loop:
		@              VENTANA % LONGITUD
		udiv r6,r4,r2   	@ r6 = r4/r2
		mls r6,r2,r6 ,r4	@ r6 = r6 %r2
		@ index + ventana %longitud (R7 = R3 + R6)
		add r7,r6,r3
		@ (index + ventana %longitud)%longitud
		udiv r6,r7,r2 @ r7 = r4/r2 (ventana/ longitud)
		mls r7,r2,r6 ,r7	@ r6 = r6 %r2
		add r4,r4,1	 @for ventana=1 hasta 10 !
		ldrh r8,[r0,r7,LSL 1]
		add r5,r5,r8
		cmp r4,#10
	bne .asm_filtroVentana10_loop
		strh r5,[r1],#2
		mov r4,0
		mov r5,0
		add r3,r3,1
		cmp r3,r2
	bne .asm_filtroVentana10_loop
	pop {r8}
	pop {r7}
	pop {r6}
	pop {r5}
	pop {r4}
	pop {r3}
	bx lr
