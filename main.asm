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
	dists DWORD ?

	; Nodo de partida
	partida DWORD ?

.CODE
	Dijkstra PROC, graph: DWORD, distances: DWORD, start: DWORD
		LOCAL x: DWORD, d: REAL4 ; Creamos variables locales para el procedimiento

		
		; Movemos a registros los apuntadores
		mov esi, graph
		mov edi, distances
		
		; Inicializamos la distancia del nodo de partida en 0
		mov eax, start
		imul eax, TYPE REAL4
		push 0
		pop [esi + eax]
		
		; Iteramos para obtener las distancias minimas
		
		
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
		invoke GetProcessHeap ; Obtenemos el manejador del heap actual, el cual es guardado en eax
		cmp eax, NULL ; Si no se obtuvo correctamente el manejador,
		je nAlloc	  ; detenemos el programa
		mov hhm, eax
		
		; Inicializamos la matriz de adyacencia en el heap
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, siz ; Asignamos dinamicamente la memoria para almacenar la matriz de adyacencia (retorna en
													 ; eax un puntero al bloque de memoria), inicializando todos los valores con 0
		cmp eax, NULL ; Si no se asigno correctamente el puntero,
		je nAlloc	  ; detenemos el programa
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
				mov esi, grafo
				mov eax, ebx
				imul eax, n
				imul eax, TYPE REAL4
				add esi, eax
				mov eax, aux2
				imul eax, TYPE REAL4
				add esi, eax
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

		; Inicializamos el arreglo para almacenar las distancias de la misma manera que la matriz de adyacencia
		mov ebx, n
		imul ebx, TYPE REAL4
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, ebx
		cmp eax, NULL
		je nAlloc
		mov dists, eax

		; Inicializamos el arreglo de distancias con mas infinito
		mov esi, dists
		mov ecx, 0
wN2:		cmp ecx, n
			jge ewN2
			mov ebx, ecx
			imul ebx, TYPE REAL4
			push 7F800000h ; Representacion de mas infinito
			pop [esi + ebx]
			inc ecx
			jmp wN2
ewN2:


		; Si el programa termina con exito, liberamos la memoria ocupada por la matriz de adyacencia
		invoke HeapFree, hhm, 0, grafo
		jmp en
		
		; En caso de que la asignacion de memoria fallase, le informamos al usuario
nAlloc:	mov edx, OFFSET fail
		call WriteString
		
en:		
		exit
	main ENDP
	END main