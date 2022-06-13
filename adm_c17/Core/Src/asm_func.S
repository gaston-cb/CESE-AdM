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

