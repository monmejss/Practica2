	.text
	.global	array
	.bss
	.align	2
	.type	array, %object
	.size	array, 24
    .size   read, 8
read:
	.space 8
array:
	.space	24
	.global	size
	.data
	.align	2
	.type	size, %object
	.size	size, 4
size:
	.word	6
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.type	main, %function


@ r0=buffer en el que se escribira
@ r1= numero de bytes a escribir
Input:
    @prologo
	push {r7}  
	sub sp, sp, #12
    add r7, sp, #0
	@ 16-bytes tamanio funcion input      
	str r0, [r7]
	str r1, [r7, #4]
	@cuerpo de funcion
	ldr r2, [r7, #4]  
	ldr r1, [r7]
	mov r0, #0x0
	mov r7, #0x3  @llamada al sistema para leer
	svc 0x0
	mov r3, r0
    add r7, sp, #0
	@epilogo
	mov r0, r3
	adds r7, r7, #12
	mov	 sp, r7
	pop	{r7}
	bx lr

@ r0=puntero a la entrada de numeros en ascii
AtoI:
    @prologo
	push {r7}  
	sub sp, sp, #28
    add r7, sp, #0
    @ 16-bytes tamanio bloque 
    str r0, [r7, #24] @guarda la direccion de read
	mov r1, #0 @ Contador del tamano de la cadena
	str r1, [r7, #8] 
	mov r2, #0 @ valor final del numero
	str r2, [r7, #12] 
	mov r3, #1 @Multiplicador dependiendo la posicion
	str r3, [r7, #16] 
	mov r4, #10 @constante para aumentar el multiplicador
	str r4, [r7, #20]

	@cuerpo funcion
	ldr r0, [r7, #24] @carga la direccion de read
    @bucle longitud string
E1: 
    ldrb r5, [r0] @carga el primer bit
	cmp r5, #10 @Compara para encontrar el fin de la cadena
	beq E2
	add r0, r0, #1 @ Va a la siguiente posicion de la cadena
	ldr r1, [r7, #8]
	add r1, r1, #1 @ contador de la cadena, para saber cuantos caracteres hay
	str r1, [r7, #8]
	b E1
    @contar
E2: 
    sub r0, r0, #1
	ldrb r5, [r0] @carga el ultimo bit
	ldr r3, [r7, #16]
	sub r5, r5, #0x30 
	mul r4, r5, r3 @ multiplica por 10 a la n, dependiendo de la posicion del numero
	mov r5, r4
	ldr r4, [r7, #20]
	mul r4, r3, r4 @ incrementar el valor de n
	mov r3, r4
	str r3, [r7, #16]
	ldr r6, [r7, #12]
	add r6, r6, r5 @ Sumar los valores obtenidos
	str r6, [r7, #12]
	ldr r1, [r7, #8]
	sub r1, r1, #1 @ decrementar el contador de la cadena
	str r1, [r7, #8]
	cmp r1, #0
	beq E3
	b E2
    @return
E3: 
	ldr r6, [r7, #12]
	mov r0, r6
    @epilogo
	adds r7, r7, #28
	mov	 sp, r7
	pop	{r7}
	bx lr

//:r0=valor a imprimir(suponemos <10000)
ItoA:
    @prologo
	push {r7}  
	sub sp, sp, #28
    add r7, sp, #0
    @ 32-bytes tamanio bloque 	
	mov r1, #0x0   @contador de tamanio
	str r1, [r7, #8]
	mov r2, #1000   @posicion actual
	str r2, [r7, #12]
	mov r3, #10 @constante para aumentar el multiplicador
	str r3, [r7, #16]
    @loop
E4:
    mov r4, #0x0   
	udiv r4, r0, r2
	add r4, r4, #0x30 @convierte a ascii

	ldr r5, =read   @guarda el ascii
	add r5, r5, r1  @obtener la dirrecion de donde se almacena
	strb r4, [r5]   @almacena el valor ya convertido a ascii y lo almacena en la direccion anterior
	add r1, r1, #1

	sub r4, r4, #0x30 @resta 30 por el valor del ascii
	mul r6, r4, r2 
	sub r0, r0, r6

	udiv r6, r2, r3@divide 
	mov r2, r6
	cmp r2, #0
	beq E5
	b   E4
    @Salida itoA
E5: 
    mov r4, #0xa
	ldr r5, =read
	add r5, r5, r1
	add r5, r5, #1
	strb r4, [r5]
    @epilogo
	adds r7, r7, #28
	mov	 sp, r7
	pop	{r7}
	bx lr



Imprimir:
	@funcion hoja
	@prologo
	push {r7}  
	sub sp, sp, #12
    add r7, sp, #0
    @16-bytes tamanio bloque 
	str r0, [r7]
	str r1, [r7, #4]
	@cuerpo funcion
	ldr r2, [r7, #4]
	ldr r1, [r7]
	mov r0, #0x1
	mov r7, #0x4 	 	 	 
	svc 0x0 		 @llamada al sistema
	mov r3, r0		 @mover lo de r0 a r3
	add r7, sp, #0	 @recupera valor de r7
	@epilogo
	adds r7, r7, #12
	mov	 sp, r7
	pop	{r7}
	bx lr


main:
	@Prologo
	push {r7}
	sub	sp, sp, #28 @Reserva memoria para las variables "size" y "i"
	add	r7, sp, #0
    @ 32-bytes tamanio main 
    @cuerpo de la funcion
	movs r3, #0 @variable "i"
	str	r3, [r7, #8]
	movs r3, #12 @variable "target"
	str	r3, [r7, #12]
	mov	r3, #-1 @variable "targetLocation"
	str	r3, [r7, #16]
	b	.L2
.L3: @dentro del for
	ldr r0, =read @carga la direccion del buffer"
	ldr r1, =0x6
	bl Input

	ldr r0, =read
	bl AtoI
	mov r2, r0

	ldr r4, .L10+4 @carga la direccion base del arreglo
	ldr	r3, [r7, #8] @carga "i" en r3
	str r0, [r4, r3, lsl #2] @guarda el valor en la posicion inicial del arreglo + 4i

	ldr r3, [r7, #8]
	adds r3, r3, #1 @se aumenta el contador
	str	r3, [r7, #8] @guarda el nuevo valor de "i"
.L2: @bucle for
	ldr	r3, [r7, #8] @carga "i" en r3
	cmp	r3, #5
	ble	.L3
	movs r3, #0 @variable "left"
	str	r3, [r7, #28]
	ldr	r3, .L10 @carga la direccion de "size"
	ldr	r3, [r3] @carga el valor de size
	subs r3, r3, #1
	str	r3, [r7, #4] @variable "right"
	b	.L4
.L8: @dentro del while
	ldr	r2, [r7, #28] @carga "left" en r2
	ldr	r3, [r7, #4] @carga "right" en r3
	add	r3, r3, r2 @left + right
	lsrs r2, r3, #31 
	add	r3, r3, r2
	asrs r3, r3, #1
	str	r3, [r7, #20] @variable "middle"
	ldr	r2, .L10+4 @carga la direccion del arreglo
	ldr	r3, [r7, #20] @carga "middle"
	ldr	r3, [r2, r3, lsl #2] @carga el valor del arreglo en la posicion "middle"
	ldr	r2, [r7, #12] @carga "target"
	cmp	r2, r3 @if(array[middle]==target)
	bne	.L5 
	ldr	r3, [r7, #20] @carga "middle"
	str	r3, [r7, #16] @guarda el valor de "middle" en "targetLocation"
	b	.L6
.L5:
	ldr	r2, .L10+4 @carga la direccion del arreglo
	ldr	r3, [r7, #20] @carga "middle"
	ldr	r3, [r2, r3, lsl #2] @carga el valor del arreglo en la posicion "middle"
	ldr	r2, [r7, #12] @carga "target"
	cmp	r2, r3 @if(array[middle]<target) en codigo c, aqui lo hace al reves (target<=array[middle])
	ble	.L7
	ldr	r3, [r7, #20] @carga "middle"
	adds r3, r3, #1 @middle+1
	str	r3, [r7, #28] @guarda el valor en "left"
	b	.L4
.L7:
	ldr	r3, [r7, #20] @carga "middle"
	subs r3, r3, #1 @middle-1
	str	r3, [r7, #4] @guarda el valor en "right"
.L4: @ bucle while
	ldr	r2, [r7, #28] @carga "left" en r2
	ldr	r3, [r7, #4] @carga "right" en r3
	cmp	r2, r3 
	ble	.L8
.L6:
	@Aqui debemos convertir el entero a ascii con la funcion ItoA
	ldr r0, [r7, #16]
	bl ItoA
	
	@Aqui debemos imprimir
	ldr r0, =read
	mov r1, #0x8
    bl Imprimir
	mov r0, #0x0
	mov r7, #0x1
	svc 0x0
	@epilogo
	adds r7, r7, #12
	mov	 sp, r7
	pop	{r7}

.L11:
	.align	2
.L10:
	.word	size
	.word	array
	.size	main, .-main


