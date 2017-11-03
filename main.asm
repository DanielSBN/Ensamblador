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

	; Mensaje para pedir las conexiones en el grafo
	con1 BYTE "Ingrese la distancia del nodo ", 0
	con2 BYTE " al nodo ", 0
	con3 BYTE ": ", 0

	; Datos auxiliares para obtener las conexiones del grafo
	partida BYTE ?
	destino BYTE ?

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

.CODE
	main PROC
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
		imul eax, TYPE DWORD
		mov siz, eax
		
		; Preparamos el heap para guardar los datos
		invoke GetProcessHeap ; Obtenemos el manejador del heap actual, el cual es guardado en eax
		cmp eax, NULL ; Si no se obtuvo correctamente el manejador, detenemos el programa
		je nAlloc
		mov hhm, eax
		
		; Inicializamos la matriz de adyacencia en el heap
		invoke HeapAlloc, hhm, HEAP_ZERO_MEMORY, siz ; Asignamos dinamicamente la memoria para almacenar la matriz de adyacencia (retorna en
													 ; eax un puntero al bloque de memoria)
		cmp eax, NULL ; Si no se asigno correctamente el puntero, detenemos el programa
		je nAlloc
		mov grafo, eax
		
		; PEDIMOS LAS CONEXIONES DEL GRAFO
		
		mov ebx, 0 ; Iterador para filas
		mov ecx, 0 ; Iterador para columnas
		mov esi, grafo ; Puntero a la matriz de adyacencia
		
		; Ejecutamos un ciclo que recorre la matriz de adyacencia, pidiendo la distancia correspondiente desde el nodo referenciado por ebx
		; al nodo referenciado por ecx
wFila:	cmp ebx, n ; Mientras ebx sea menor a n, iteramos (iteracion de filas)
		jge ewF
wCol:		cmp ecx, n ; Mientras ecx sea menor a n, iteramos (iteracion de columnas)
			jge ewC
				cmp ebx, ecx ; Si ebx y ecx son iguales, saltamos a la siguiente iteracion
				je siFCeq
					
siFCeq:			inc ecx
				jmp wCol
ewC:		inc ebx
			jmp wFila
ewF:
		
		

nAlloc:	
sAlloc:	invoke HeapFree, hhm, 0, grafo; Liberamos la memoria ocupada por la matriz de adyacencia
		
		exit
	main ENDP
	END main