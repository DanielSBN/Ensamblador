; PROYECTO DE LENGUAJE ENSAMBLADOR
; ARQUITECTURA DE COMPUTADORES, SEMESTRE 2017-II
; Integrantes: Kewin Evers Yagari, Daniel Sanchez Buitrago, Daniel Velez Santamaria
; Docente: Hugo de Jesus Mesa Yepes

INCLUDE Irvine32.inc

.DATA
	; Mensaje de bienvenida para el programa
	bienvenida BYTE "BIENVENIDO USUARIO", 0dh, 0ah,
					"Este programa calcula el camino mas corto en un grafo desde el nodo de partida hasta todos los demas nodos.", 0

	; Mensaje para pedir la cantidad de nodos
	nodos BYTE "Ingrese la cantidad de nodos del grafo: ", 0

	; Mensajes para pedir las conexiones en el grafo
	con1 BYTE "Ingrese la cantidad de conexiones del nodo ", 0
	con2 BYTE ": ", 0
	con3 BYTE "Ingrese el nodo con el que esta conectado: ", 0
	con4 BYTE "Ingrese la distancia de la conexion: ", 0

	; Mensaje para pedir el nodo inicial
	ini BYTE "Ingrese el nodo de partida: ", 0

	; Mensaje para informar que la asignacion de memoria fallo
	fail BYTE "Error: La asignacion de memoria fallo.", 0

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
	
	;------------------------------------------------------------------------------------------
	CompararFlotantes PROC USES ax,
		fc1: REAL4,		; Valor del lado izquierdo de la comparacion
		fc2: REAL4		; Valor del lado derecho de la comparacion
	; Compara dos valores de punto flotante y refleja el resultado en el registro de banderas
	; Devuelve: Resultado de la comparacion en eflags
	;------------------------------------------------------------------------------------------
		fld fc1
		fcomp fc2
		fnstsw ax
		sahf
	CompararFlotantes ENDP

	;----------------------------------------------------------------------------------------------------------------------------
	Dijkstra PROC USES eax ebx ecx esi edi,
		graph: DWORD,	; Apuntador a la matriz de adyacencia
		no: DWORD,		; Numero de nodos
		dists: DWORD,	; Apuntador al arreglo de distancias
		conf: DWORD,	; Apuntador al arreglo de visitados
		start: DWORD	; Numero del nodo incial
	; Calcula los caminos mas cortos en un grafo desde el nodo de partida al resto de los nodos usando el algoritmo de Dijkstra
	; Devuelve: Caminos mas cortos a cada nodo en el arreglo de distancias
	;----------------------------------------------------------------------------------------------------------------------------
		LOCAL vis: BYTE,	; Variable local para verificar si todos los nodos fueron explorados
			x: DWORD,		; Variable local para obtener el nodo con la distancia mas pequena
			d: REAL4,		; Variable local para obtener la distancia mas pequena
			auxC: REAL4		; Variable local para almacenar temporalmente valores reales
		
		; Para cada nodo del grafo, inicializamos las distancias iniciales
		mov ecx, 0
wInit:	cmp ecx, n
		;jge ewInit
			invoke IndexarArreglo, dists, ecx, TYPE REAL4
			mov edi, esi
			invoke IndexarMatriz, graph, no, start, ecx, TYPE REAL4

			mov auxC, 0
		
			invoke CompararFlotantes, [esi], auxC
		COMMENT @
			je if0
				push [esi]	; Si existe conexion entre el nodo inicial y el nodo actual,
				pop [edi]	; hacemos la distancia inicial igual a la distancia de su conexion
				jmp e0
if0:			push 7F800000h	; Si no existe conexion entre los nodos,
				pop [edi]		; la distancia inicial es igual a infinito
e0:			
			inc ecx
			jmp wInit
ewInit: 
		; Inicializamos la distancia minima del nodo inicial en 0
		invoke IndexarArreglo, dists, start, TYPE REAL4
		push 0
		pop [esi]
		
		; Marcamos como visitado el nodo inicial
		invoke IndexarArreglo, conf, start, TYPE BYTE
		push 1
		pop [esi]

wMin:	mov vis, 1
		
		; Iteramos para verificar si todos los nodos estan explorados
		mov ebx, 0
wVis:	cmp ebx, n
		jge ewVis
			invoke IndexarArreglo, conf, ebx, TYPE BYTE
			mov al, [esi]
			cmp al, 0
			jne brv
				mov vis, 0
				jmp ewVis
brv:			inc ebx
				jmp wVis
ewVis: 
		; Si aun no se han explorado todos los nodos, calculamos las distancias minimas para esta iteracion
		cmp vis, 0
		jne emin
			mov d, 7F800000h
			
			; Seleccionamos el nodo no-explorado con la distancia minima
			mov ecx, 0
exp:		cmp ecx, n
			jge eexp
				invoke IndexarArreglo, dists, ecx, TYPE REAL4
				mov edi, esi
				invoke IndexarArreglo, conf, ecx, TYPE BYTE
				mov al, [esi]
				cmp al, 0
				jne nd
					invoke CompararFlotantes, REAL4 PTR [edi], d
					jnb nd
						push [edi]
						pop d
						mov x, ecx
nd:				inc ecx
				jmp exp
eexp:
			; Marcamos el nodo obtenido como explorado
			invoke IndexarArreglo, conf, x, TYPE BYTE
			push 1
			pop [esi]
			
			; Iteramos a traves de las conexiones del nodo
			mov ecx, 0
wfD:		cmp ecx, n
			jge ewfD
				invoke IndexarMatriz, graph, no, x, ecx, TYPE REAL4
				fld REAL4 PTR [esi]
				invoke IndexarArreglo, dists, x, TYPE REAL4
				fadd REAL4 PTR [esi]
				fstp auxC
				invoke IndexarArreglo, dists, ecx, TYPE REAL4
				invoke CompararFlotantes, auxC, REAL4 PTR [esi]
				jnb men
					push auxC
					pop [esi]
men:			inc ecx
				jmp wfD
ewfD:
			jmp wMin
emin:	@
		ret
	Dijkstra ENDP
	
	main PROC
		finit
		
		; Imprimimos el mensaje de bienvenida
		mov edx, OFFSET bienvenida
		call WriteString
		call Crlf
		call Crlf

		; Pedimos la cantidad de nodos del grafo
		mov edx, OFFSET nodos
		call WriteString
		call ReadDec
		call Crlf
		mov n, eax
		
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
			
			mov edx, OFFSET con1
			call WriteString
			mov eax, ebx
			inc eax
			call WriteDec
			mov edx, OFFSET con2
			call WriteString
			call ReadDec
			call Crlf
			mov aux1, eax
			
			; Ciclo interno, para pedir las distancias de las conexiones de cada nodo
			mov ecx, 0
wD:				cmp ecx, aux1
				jge ewD
				
				; Pedimos el nodo con el cual esta conectado el nodo actual
				mov edx, OFFSET con3
				call WriteString
				call ReadDec
				dec eax
				mov aux2, eax
				
				; Pedimos la distancia de la conexion actual
				mov edx, OFFSET con4
				call WriteString
				call ReadFloat
				call Crlf
				
				; Calculamos la coordenada de la conexion en la matriz de adyacencia y la introducimos
				invoke IndexarMatriz, grafo, n, ebx, aux2, TYPE REAL4
				fstp auxF
				push auxF
				pop [esi]
				
				inc ecx
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

		; Inicializamos en el heap un arreglo para comprobar luego en el algoritmo los nodos que ya han sido visitados
		mov ebx, n
		imul ebx, TYPE BYTE
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, ebx
		cmp eax, NULL
		je nAlloc
		mov boo, eax
		
		; Llamamos al procedimiento para ejecutar el algoritmo
		invoke Dijkstra, grafo, n, distancias, boo, partida

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