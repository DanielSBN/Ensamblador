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
	Dijkstra PROC, graph: DWORD, dists: DWORD, conf: DWORD, start: DWORD
		LOCAL x: REAL4, j: DWORD, zer: REAL4 ; Creamos variables locales para el procedimiento
		
		finit
		
		; Inicializamos la distancia del nodo de partida en 0
		mov esi, dists
		mov eax, start
		imul eax, TYPE REAL4
		push 0
		pop [esi + eax]
		
		; Iteramos para obtener las distancias minimas
		mov ebx, 0
wM:			cmp ebx, n
			jge ewM
			
			; Seleccionamos el menor nodo
			mov x, 7F800000h
			mov ecx, 0
f1:				cmp ecx, n
				jge ef1
				mov edi, dists
				mov edx, ecx
				imul edx, TYPE REAL4
				fld REAL4 PTR [edi + edx]
				fcomp x
				fnstsw ax
				sahf
				jnb less
					mov esi, conf
					mov eax, [esi + edx]
					cmp eax, 0
					jne less
						mov j, ecx
						push [edi + edx]
						pop x
less:			inc ecx
				jmp f1
ef1:		mov esi, conf
			mov edx, j
			imul edx, TYPE REAL4
			push 1
			pop [esi + edx]
			inc ebx
			
			mov ecx, 0
f2:				cmp ecx, n
				jge ef2
				mov esi, graph
				mov edx, j
				imul edx, n
				imul edx, TYPE REAL4
				add esi, edx
				mov edx, ecx
				imul edx, TYPE REAL4
				add esi, edx

				mov zer, 0
				fld REAL4 PTR [esi]
				fcom zer
				je is1
					mov edi, dists
					mov edx, j
					imul edx, TYPE REAL4
					fadd REAL4 PTR [edi + edx]
					mov edx, ecx
					imul edx, TYPE REAL4
					fcom REAL4 PTR [edi + edx]
					fnstsw ax
					sahf
					jnb is1
						fst REAL4 PTR [edi + edx]
is1:			fstp REAL4 PTR[esi]
				inc ecx
				jmp f2
ef2:		jmp wM		
ewM:		
		mov esi, dists
		mov ecx, 0
pr:			cmp ecx, n
			jge epr
				mov edx, OFFSET res
				call WriteString
				mov eax, ecx
				inc eax
				call WriteDec
				mov edx, OFFSET p
				call WriteString
				
				mov esi, dists
				mov edx, ecx
				imul edx, TYPE REAL4
				fld REAL4 PTR [esi + edx]
				call WriteFloat
				call Crlf
				fstp REAL4 PTR [esi + edx]
				
				inc ecx
				jmp pr
epr:	

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
		mov distancias, eax

		; Inicializamos el arreglo de distancias con mas infinito
		mov esi, distancias
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
		; Inicializamos un arreglo para comprobar luego en el algoritmo los nodos que ya han sido visitados
		mov ebx, n
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, ebx
		cmp eax, NULL
		je nAlloc
		mov boo, eax
		
		; Llamamos al procedimiento para ejecutar el algoritmo
		invoke Dijkstra, grafo, distancias, boo, partida

		; Si el programa termina con exito, liberamos la memoria ocupada por la matriz de adyacencia
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