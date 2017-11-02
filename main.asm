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
		mov n, eax
		
		; Inicializamos las variables dim y siz
		mov eax, n
		imul eax, n
		mov dim, eax
		imul eax, TYPE DWORD
		mov siz, eax
		
		; Inicializamos la matriz de adyacencia en la pila como un arreglo
		mov eax, siz
		push esp ; Introducimos el valor de esp a la pila para conservarlo al final del programa
		sub esp, eax ; Ahora, esp apunta al elemento inicial del arreglo
		
		; PEDIMOS LAS CONEXIONES DEL GRAFO
		
		mov ebx, 0 ; Iterador para filas
		mov ecx, 0 ; Iterador para columnas
		
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
		
		pop esp
		exit
	main ENDP
	END main