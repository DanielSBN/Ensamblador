; PROYECTO DE LENGUAJE ENSAMBLADOR
; ARQUITECTURA DE COMPUTADORES, SEMESTRE 2017 - II
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
	con BYTE "Ingrese las distancias del nodo ", 0
	con2 BYTE " al resto de los nodos (si no estan conectados, digite un 0): ", 0

	; Datos auxiliares para obtener las conexiones del grafo
	aux BYTE 255 DUP(?)
	siz DWORD ?
	num BYTE 255 DUP(?)

	; Cantidad de nodos del grafo
	n DWORD ?

	; Matriz de adyacencia del grafo
	grafo DWORD ?

.CODE
	; Procedimiento para separar la cadena de caracteres con las conexiones de un nodo de tal manera que se obtenga cada longitud por separada
	CutString PROC, chain:PTR BYTE, tam:DWORD
		; Ingresamos ecx y eax a la pila para preservar su valor
		push ecx
		push eax

		mov esi, chain
		mov ecx, 0
		mov al, ' '
wc:		cmp ecx, tam
		jge ewc
			cmp [esi], eax
			jne outc
				push 0
				pop [esi]
outc:		add esi, TYPE BYTE
			inc ecx
			jmp wc
ewc:
		; Extraemos los valores originales de ecx y eax de la pila
		pop eax
		pop ecx

		ret
	CutString ENDP
	
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
		
		mov ebx, 1 ; Usamos ebx como contador para pedir las conexiones
		mov esi, OFFSET con
		
		; Para ebx desde 1 hasta n, obtenga las conexiones de los nodos
whc:	cmp ebx, n
		jg ewhc
			; Pedimos las conexiones
			mov edx, OFFSET con
			call WriteString
			
			add ebx, '0' ; Convertimos el numero a ASCII
			mov eax, ebx ; Movemos el numero del nodo actual al mensaje
			call WriteChar
			
			mov edx, OFFSET con2
			call WriteString
			
			mov edx, OFFSET aux
			mov ecx, SIZEOF aux
			call ReadString
			mov siz, eax
			
			; Procesamos las conexiones y las guardamos en la matriz de adyacencia
			invoke CutString, ADDR aux, LENGTHOF aux
			
			mov esi, 0
			mov ecx, 0
w1:			cmp esi, LENGTHOF aux
			jge ew1
				movzx eax, aux[esi]
				call WriteString
				inc esi
				jmp w1
ew1:
			
			sub ebx, '0'
			inc ebx
			jmp whc
ewhc:
		
		exit
	main ENDP

	END main