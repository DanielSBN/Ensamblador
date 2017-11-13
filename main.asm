; PROYECTO DE LENGUAJE ENSAMBLADOR
; ARQUITECTURA DE COMPUTADORES, SEMESTRE 2017-II
; Integrantes: Kewin Evers Yagari, Daniel Sanchez Buitrago, Daniel Velez Santamaria
; Docente: Hugo de Jesus Mesa Yepes

INCLUDE Irvine32.inc

.DATA
	; Valores para comparar con 0
	epsilon REAL4 1.0E-12
	
	; Mensaje de bienvenida para el programa
	bienvenida BYTE "BIENVENIDO USUARIO", 0Dh, 0Ah,
					"Este programa calcula el camino mas corto en un grafo desde el nodo de partida hasta todos los demas nodos.", 0

	; Mensaje para pedir la cantidad de nodos
	nodos BYTE "Ingrese la cantidad de nodos del grafo: ", 0
	negn BYTE "Error: La cantidad de nodos no puede ser nula o negativa. Por favor introduzca de nuevo el dato.", 0

	; Mensajes para pedir las conexiones en el grafo
	con1 BYTE "Ingrese la cantidad de conexiones del nodo ", 0
	con2 BYTE ": ", 0
	con3 BYTE "Ingrese el nodo con el que esta conectado: ", 0
	con4 BYTE "Ingrese la distancia de la conexion: ", 0
	con5 BYTE "Error: Las distancias deben ser positivas. Por favor introduzca de nuevo el dato.", 0
	con6 BYTE "Error: La cantidad de conexiones debe ser no-negativa. Por favor introduzca de nuevo el dato.", 0
	con7 BYTE "Error: El nodo conectado debe estar en un rango desde 1 hasta la cantidad total de nodos. Por favor introduzca de nuevo el dato.", 0

	; Mensaje para pedir el nodo inicial
	ini BYTE "Ingrese el nodo de partida: ", 0

	; Mensaje para informar que la asignacion de memoria fallo
	fail BYTE "Error: La asignacion de memoria fallo.", 0

	; Mensajes para imprimir la tabla de distancias
	resul BYTE "DISTANCIAS MINIMAS", 0Dh, 0Ah,
			   "Nota: Una distancia de 'inf' indica que no se puede llegar a ese nodo desde el nodo de partida", 0Dh, 0Ah, 0
	node BYTE "Nodo ", 0
	infin BYTE "inf", 0

	; Variables auxiliares para guardar datos temporalmente
	aux1 DWORD ?
	aux2 DWORD ?
	auxF REAL4 ?

	; Cantidad de nodos del grafo
	n DWORD ?
	
	; Cantidad total de elementos de la matriz de adyacencia
	dim DWORD ?
	
	; Numero total de bytes que ocupa la matriz de adyacencia
	siz DWORD ?
	
	; Manejador del Heap
	hhm DWORD ?
	
	; Puntero a la matriz de adyacencia
	grafo DWORD ?

	; Arreglo de las distancias
	distancias DWORD ?
	
	; Arreglo para nodos visitados
	boo DWORD ?

	; Nodo de partida
	partida DWORD ?

	; Mensaje para la entrega de resultados
	res BYTE "Nodo ", 0
	p BYTE ":", 9h, 0

	; Variable para verificar si todos los nodos fueron explorados
	vis BYTE ?

	; Variables para obtener el nodo con la distancia mas pequena
	d REAL4 ?
	x DWORD ?

.CODE
	;------------------------------------------------------------------------------------------
	IndexarArreglo PROC USES edx,
		arreglo: DWORD,		; Apuntador al arreglo
		index: DWORD,		; Indice del elemento
		tam: DWORD			; Tamano del tipo de dato almacenado en el arreglo
	; Calcula la direccion de memoria donde se ubica un elemento en un arreglo dado su indice
	; Devuelve: esi = direccion de memoria del elemento indexado
	;------------------------------------------------------------------------------------------
		mov esi, arreglo
		
		mov edx, index
		imul edx, tam
		add esi, edx
		
		ret
	IndexarArreglo ENDP

	;-------------------------------------------------------------------------------------------------------------------------
	IndexarMatriz PROC USES edx,
		matriz: DWORD,		; Apuntador a la matriz
		na: DWORD,			; Dimension de la matriz
		fila: DWORD,		; Fila del elemento
		columna: DWORD,		; Columna del elemento
		tam: DWORD			; Tamano del tipo de dato almacenado en la matriz
	; Calcula la direccion de memoria donde se ubica un elemento en una matriz dadas la fila y la columna donde esta ubicado
	; Devuelve: esi = direccion de memoria del elemento indexado
	;-------------------------------------------------------------------------------------------------------------------------
		mov esi, matriz
		
		mov edx, columna
		imul edx, tam
		add esi, edx
		
		mov edx, fila
		imul edx, na
		imul edx, tam
		add esi, edx
		
		ret
	IndexarMatriz ENDP
	
	main PROC
		finit
		
		; Imprimimos el mensaje de bienvenida
		mov edx, OFFSET bienvenida
		call WriteString
		call Crlf
		call Crlf

		; Pedimos la cantidad de nodos del grafo
nn:		mov edx, OFFSET nodos
		call WriteString
		call ReadInt
		call Crlf
		cmp eax, 0
		jg gn
			mov edx, OFFSET negn
			call WriteString	; Si la cantidad ingresada es negativa o nula,
			call Crlf			; la volvemos a pedir
			jmp nn
gn:		mov n, eax
		
		; Inicializamos las variables dim y siz
		mov eax, n
		imul eax, n
		mov dim, eax
		imul eax, TYPE REAL4
		mov siz, eax
		
		; Preparamos el heap para guardar los datos
		invoke GetProcessHeap	; Obtenemos el manejador del heap actual, el cual es guardado en eax
		cmp eax, NULL	; Si no se obtuvo correctamente el manejador,
		je nAlloc		; detenemos el programa
		mov hhm, eax
		
		; Inicializamos la matriz de adyacencia en el heap
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, siz	; Asignamos dinamicamente la memoria para almacenar la matriz de adyacencia (retorna
														; en eax un puntero al bloque de memoria), inicializando todos los valores con 0
		cmp eax, NULL	; Si no se asigno correctamente el puntero,
		je nAlloc		; detenemos el programa
		mov grafo, eax
		
		; PEDIMOS LAS CONEXIONES DEL GRAFO
		
		; Ciclo externo, para pedir la cantidad de conexiones de cada nodo
		mov ebx, 0
wN:			cmp ebx, n
			jge ewN
			
nc:			mov edx, OFFSET con1
			call WriteString
			mov eax, ebx
			inc eax
			call WriteDec
			mov edx, OFFSET con2
			call WriteString
			call ReadInt
			call Crlf
			cmp eax, 0
			jge gc
				mov edx, OFFSET con6
				call WriteString	; Si la cantidad de conexiones ingresada es negativa,
				call Crlf			; la volvemos a pedir
				jmp nc
gc:			mov aux1, eax
			
			; Ciclo interno, para pedir las distancias de las conexiones de cada nodo
			mov ecx, 0
wD:				cmp ecx, aux1
				jge ewD
				
				; Pedimos el nodo con el cual esta conectado el nodo actual
an:				mov edx, OFFSET con3
				call WriteString
				call ReadInt
				cmp eax, 0
				jle gnn
					cmp eax, n
					jg gnn
						dec eax
						mov aux2, eax
						jmp ann
gnn:					mov edx, OFFSET con7
						call WriteString	; Si el nodo conectado no esta dentro del rango permitido,
						call Crlf			; lo volvemos a pedir
						jmp an
ann:			
				; Pedimos la distancia de la conexion actual
npos:			mov edx, OFFSET con4
				call WriteString
				call ReadFloat
				call Crlf
				
				; Revisamos que la distancia sea positiva (ya que el algoritmo de Dijkstra no funciona con distancias negativas)
				fcom epsilon
				fnstsw ax
				sahf
				jnb pos
					mov edx, OFFSET con5
					call WriteString
					call Crlf
					jmp npos	; En caso de que la distancia introducida sea negativa o nula, la pedimos de nuevo
pos:			
				; Calculamos la coordenada de la conexion en la matriz de adyacencia y la introducimos
				cmp aux2, ebx
				je equa		; Si el nodo con el que esta conectado es el mismo, ignoramos la distancia introducida
					invoke IndexarMatriz, grafo, n, ebx, aux2, TYPE REAL4
					fstp REAL4 PTR [esi]
				
equa:			inc ecx
				jmp wD
ewD:		
			inc ebx
			jmp wN
ewN:	
		; Pedimos el nodo de partida
		mov edx, OFFSET ini
		call WriteString
		call ReadDec
		dec eax
		mov partida, eax

		; Inicializamos en el heap el arreglo para almacenar las distancias de la misma manera que la matriz de adyacencia
		mov ebx, n
		imul ebx, TYPE REAL4
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, ebx
		cmp eax, NULL
		je nAlloc
		mov distancias, eax

		; Inicializamos en el heap un arreglo para comprobar en el algoritmo los nodos que ya han sido visitados
		mov ebx, n
		imul ebx, TYPE BYTE
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, ebx
		cmp eax, NULL
		je nAlloc
		mov boo, eax
		
		; Para cada nodo del grafo, inicializamos las distancias iniciales
		mov ecx, 0
wInit:	cmp ecx, n
		jge ewInit
			invoke IndexarArreglo, distancias, ecx, TYPE REAL4
			mov edi, esi
			invoke IndexarMatriz, grafo, n, partida, ecx, TYPE REAL4

			fld REAL4 PTR [esi]
			fcomp epsilon
			fnstsw ax
			sahf
			jna if0
				fld REAL4 PTR [esi]		; Si existe conexion entre el nodo inicial y el nodo actual,
				fstp REAL4 PTR [edi]	; hacemos la distancia inicial del nodo actual igual a la distancia de dicha conexion
				jmp el0
if0:			push 7F800000h			; Si no existe conexion entre los nodos,
				pop REAL4 PTR [edi]		; la distancia inicial es igual a infinito
el0:		
			inc ecx
			jmp wInit
ewInit:	
		; Inicializamos la distancia minima del nodo inicial en 0
		invoke IndexarArreglo, distancias, partida, TYPE REAL4
		mov aux1, 0
		fild aux1
		fstp REAL4 PTR [esi]

		; Marcamos como visitado el nodo inicial
		invoke IndexarArreglo, boo, partida, TYPE BYTE
		push 1
		pop [esi]

wMin:	mov vis, 1

		; Iteramos para verificar si todos los nodos estan explorados
		mov ebx, 0
wVis:	cmp ebx, n
		jge ewVis
			invoke IndexarArreglo, boo, ebx, TYPE BYTE
			mov al, BYTE PTR [esi]
			cmp al, 0
			jnz brv
				mov vis, 0	; El momento en el que encontremos un nodo no-explorado,
				jmp ewVis	; detenemos el ciclo

brv:			inc ebx
				jmp wVis
ewVis:
		; Si aun no se han explorado todos los nodos, calculamos las distancias minimas para esta iteracion
		cmp vis, 0
		jnz emin
			mov d, 7F800000h

			; Seleccionamos el nodo no-explorado con la distancia minima (lo denominamos nodo minimo)
			mov ecx, 0
exp:		cmp ecx, n
			jge eexp
				invoke IndexarArreglo, distancias, ecx, TYPE REAL4
				mov edi, esi
				invoke IndexarArreglo, boo, ecx, TYPE BYTE
				mov al, BYTE PTR [esi]
				cmp al, 0
				jnz nd
					fld REAL4 PTR [edi]
					fcomp d
					fnstsw ax
					sahf
					jnbe nd
						fld REAL4 PTR [edi]		; Si el nodo no esta explorado y su distancia es menor que la distancia minima encontrada
						fstp d					; hasta el momento, designamos este como el nodo minimo
						mov x, ecx

nd:					inc ecx
					jmp exp
eexp:
			; Marcamos el nodo obtenido como explorado
			invoke IndexarArreglo, boo, x, TYPE BYTE
			push 1
			pop [esi]
			
			; Iteramos a traves de las conexiones del nodo
			mov ecx, 0
wfD:		cmp ecx, n
			jge ewfD
				invoke IndexarMatriz, grafo, n, x, ecx, TYPE REAL4
				fld REAL4 PTR [esi]
				fcomp epsilon
				fnstsw ax
				sahf
				jna is0
					fld REAL4 PTR [esi]
					invoke IndexarArreglo, distancias, x, TYPE REAL4
					fadd REAL4 PTR [esi]
					fst auxF
					invoke IndexarArreglo, distancias, ecx, TYPE REAL4
					fcomp REAL4 PTR [esi]
					fnstsw ax
					sahf
					jnb is0
						fld auxF				; Si la distancia del nodo minimo sumada con la distancia de su conexion con el nodo actual
						fstp REAL4 PTR [esi]	; es menor que la distancia del nodo actual, hacemos el ultimo valor igual al primero
is0:				
				inc ecx
				jmp wfD
ewfD:
			jmp wMin
emin:
		; Iteramos a traves del arreglo de distancias e imprimimos cada una
		call Crlf
		mov edx, OFFSET resul
		call WriteString
		call Crlf

		mov ecx, 0
wpr:	cmp ecx, n
		jge ewpr
			; Imprimimos el nodo al cual pertenece la distancia
			mov edx, OFFSET node
			call WriteString
			mov eax, ecx
			inc eax
			call WriteDec
			mov al, ':'
			call WriteChar
			mov al, 9h
			call WriteChar
			call WriteChar

			; Imprimimos la distancia como tal
			mov auxF, 7F800000h
			invoke IndexarArreglo, distancias, ecx, TYPE REAL4
			fld REAL4 PTR[esi]
			fcom auxF
			fnstsw ax
			sahf
			jne inf
				mov edx, OFFSET infin
				call WriteString	; Si la distancia del nodo es infinito, no se puede llegar a el desde el nodo de partida dado,
				call Crlf			; entonces imprimimos 'inf'
				jmp ninf
inf:			call WriteFloat		; Si la distancia del nodo no es infinito,
				fstp auxF			; la imprimimos
				call Crlf
ninf:
			inc ecx
			jmp wpr
ewpr:
		call Crlf

		; Si el programa termina con exito, liberamos la memoria ocupada por la matriz y los arreglos
		invoke HeapFree, hhm, 0, grafo
		invoke HeapFree, hhm, 0, distancias
		invoke HeapFree, hhm, 0, boo
		jmp en
		
		; En caso de que la asignacion de memoria fallase, le informamos al usuario
nAlloc:	mov edx, OFFSET fail
		call WriteString
		
en:		
		exit
	main ENDP
	END main