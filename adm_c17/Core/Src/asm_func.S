.syntax unified
.thumb
.text

@ Simbolos exportados
.global asm_svc
.global asm_sum
.global asm_zeros
.global asm_productoEscalar32
.global asm_productoEscalar16
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
	.asm_productoEscalar32_loop:
	ldr r5,[r0],#4 	@r5 -> contenido apuntado por ro en r5, y luego r0 = r0+4
	mul r5,r3		@ -> no pude hacer la saturaciòn porque no produce ovf en valores "altos 0xffff"
	str r5,[r1],#4
	subs r2,1
	bne .asm_productoEscalar32_loop
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
	mul r4,r3			@ -> no pude hacer la saturaciòn porque no produce ovf en valores "altos 0xffff"
	subs r5,r4
	bpl .nosatura_16
	mov r4,r5
	@mov r4,#0x0ffff
	.nosatura_16:
	strh r4,[r1],#2
	subs r2,1
	bne .asm_productoEscalar16_loop
	pop {r5}
	pop {r4}
	bx lr





