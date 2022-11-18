section	.text
global  exec_turtle, _exec_turtle

return_error_2:
    mov eax, 2 ;zwrócenie kodu
	pop	ebp ;błędu nadmiarowej wspórzędnej
	ret

return: ;powrót do pliku C
    mov eax, 0
    mov	esp, ebp
	pop	ebp
	ret

exec_turtle:
_exec_turtle:
	push ebp
	mov	ebp, esp
	sub esp, 52 ;rezerwacja miejsca do
    mov eax, [ebp+12] ;zmiennych lokalnych
    mov eax, [eax]
    and eax, 0xc0

    cmp eax, 0x00 ;zdefiniowanie komendy
    je Set_position

    cmp eax, 0xC0
    je Set_pen_state

    cmp eax, 0x80
    je Move

    cmp eax, 0x40
    je Set_direction

    mov eax, 4
	mov	esp, ebp
	pop	ebp
	ret

Move:
    mov eax, [ebp+16]
    mov edx, [eax+16] ;kierunek

    mov ebx, [ebp+12] ; m9-m8
    shl ebx, 8
    and ebx, 0x03
    mov ecx, [ebp+12] ; m7-m0
    mov ecx, [ecx+4]
    or ebx, ecx ; m7-m0 + m9-m8

    cmp edx, 0x01 ;zdefiniowanie wspórzędnej do zmiany
    je y_plus

    cmp edx, 0x00
    je x_plus

    cmp edx, 0x03
    je y_minus

    cmp edx, 0x02
    je x_minus

    mov eax, 3 ;jeżeli kierunek nie został uznany
    mov	esp, ebp ;zwrócenie
	pop	ebp
	ret

x_plus:
    ;zwiększenie wspórzędnej x
    mov ecx, [eax]
    add ebx, ecx
    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [ebp-40], ecx
    mov ecx, [eax+4]
    mov [ebp-52], ecx
    mov [ebp-44], ecx

    mov edx, [ebp+8]
    mov edx, [edx+18]
    cmp ebx, edx ;sprawdzenie czy x
    ja return_error_2 ;nie jest zaduży

    mov [eax], ebx
    mov [ebp-48], ebx

    mov edi, [ebp+16]
    mov ecx, [edi+12]
    cmp ecx, 0 ;jeżeli pióro jest opuśczone -
    jne draw_line ;rysowanie linii

    jmp return ;powrót

y_plus:
    ;zwiększenie wspórzędnej y
    mov ecx, [eax+4]
    add ebx, ecx
    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [ebp-44], ecx
    mov ecx, [eax]
    mov [ebp-40], ecx
    mov [ebp-48], ecx

    mov edx, [ebp+8]
    mov edx, [edx+22]
    cmp ebx, edx ;sprawdzenie czy y
    ja return_error_2 ;nie jest zaduży

    mov [eax+4], ebx
    mov [ebp-52], ebx

    mov edi, [ebp+16]
    mov ecx, [edi+12]
    cmp ecx, 0 ;jeżeli pióro jest opuśczone -
    jne draw_line ;rysowanie linii

    jmp return ;powrót

x_minus:
    mov ecx, [eax]
    ;zmniejszenie wspórzędnej x
    sub ebx, ecx
    neg ebx

    cmp ebx, 0 ;sprawdzenie x
    jb return_error_2

    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [ebp-48], ecx
    mov ecx, [eax+4]
    mov [ebp-52], ecx
    mov [ebp-44], ecx

    mov [eax], ebx
    mov [ebp-40], ebx

    mov edi, [ebp+16]
    mov ecx, [edi+12]
    cmp ecx, 0 ;jeżeli pióro jest opuśczone -
    jne draw_line ;rysowanie linii

    jmp return ;powrót

y_minus:
    mov ecx, [eax+4]
    sub ebx, ecx
    neg ebx
    ;zmniejszenie wspórzędnej y
    mov [ebp-44], ecx
    mov ecx, [eax]
    mov [ebp-40], ecx
    mov [ebp-48], ecx

     cmp ebx, 0 ;sprawdzenie y
     jb return_error_2

    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [eax+4], ebx
    mov [ebp-52], ebx

    mov edi, [ebp+16]
    mov ecx, [edi+12]
    cmp ecx, 0 ;jeżeli pióro jest opuśczone -
    jne draw_line ;rysowanie linii

    jmp return ;powrót

Set_position:
    mov eax, [ebp+16] ;turtle

    mov ebx, [ebp+12] ;y
    mov ebx, [ebx+8]
    shr ebx, 2

    mov edx, [ebp+8]
    mov edx, [edx+22]
    cmp ebx, edx ;sprawdzenie czy y
    ja return_error_2 ;nie jest zaduży
    mov [eax+4], ebx

    mov ebx, [ebp+12] ;x
    mov ecx, [ebx+12]
    mov edx, [ebx+8]
    shl edx, 8
    and edx, 0x0300
    or ecx, edx

    mov edx, [ebp+8]
    mov edx, [edx+18]
    cmp ecx, edx ;sprawdzenie czy x
    ja return_error_2 ;nie jest zaduży
    mov [eax], ecx

    jmp return ;powrót


Set_pen_state:
    mov eax, [ebp+16]

    mov ebx, [ebp+12]
    mov ebx, [ebx]
    shr ebx, 5
    and ebx, 0x01

    mov [eax+12], ebx ;ustawienie nowego stanu pióra

    mov ebx, [ebp+12]
    mov ecx, [ebx+4] ;g3-g0 + r3-r0
    mov edx, [ebx] ;b3-b0
    mov edi, [ebx+4] ;g3-g0 + r3-r0

    and edi, 0x0F
    shl edi, 20 ;r

 	and ecx, 0xF0 ;g
 	shl ecx, 8

	and edx, 0x0F ;b
	shl edx, 4

	or edi, ecx ;r+g
	or edi, edx ;r+g+b

    mov [eax+8], edi ;ustawienie nowego koloru

    jmp return ;powrót

Set_direction:
    mov eax, [ebp+16]
    mov ebx, [ebp+12]
    mov ebx, [ebx+4]

    and ebx, 0x03
    mov [eax+16], ebx ;ustawienie nowego kąta

    jmp return ;powrót

put_pixel:
	push ebp
	mov	ebp, esp
	pushad

	mov	eax, [ebp+8] ; - wskażnik na strukturę obrazu
    mov ebx, [eax+18]
    mov ecx, [ebp+16]

    imul ebx, 3 ; w * 3
    add ebx, 3 ; w * 3 + 3
    and ebx, 0xFFFFFFFC ; (w * 3 + 3) & ~3
    imul ebx, ecx ; ((w * 3 + 3) & ~3) * h
    ;wiersz, w którym będzie piksel
    mov edx, [ebp+12] ; x
    imul edx, 3 ; x * 3
    add ebx, edx ; kolumna, w której będzie piksel
    add ebx, eax
    add ebx, 54 ; adres tablicy pikseli

    mov edx, [ebp+20] ;poprawne rozmieszczenie koloru
    mov [ebx], dx
    shr edx, 16
    mov [ebx+2], dl

    mov eax, [ebp+20]
    popad ;przewrócenie rejestrów
    mov esp, ebp
	pop	ebp
	ret 16 ;powrót uwzględniając podane argumenty

draw_line:
    mov edi, [ebp+16]
    mov esi, [edi+8]
    mov [ebp-8], esi

    mov eax, [ebp-40] ;jeśli współrzędne początku i końca pokrywają się
    cmp eax,[ebp-48] ;rysowany jest jeden punkt
    jnz draw
    mov eax,[ebp-44] ;jeżeli nie - rysowanie linii
    cmp eax,[ebp-52]
    jnz draw

    mov edi, [ebp-8]
    push edi
    mov edi, [ebp-44]
    push edi
    mov edi, [ebp-40]
    push edi
    mov edi, [ebp+8]
    push edi

    call put_pixel
    ;rysowanie jednego piksela
    jmp return ;zakończenie

draw:
    ;ustawianie początkowych inkrementów dla każdej pozycji punktu
    mov  ecx,1       ;inkrement dla osi x
    mov  edx,1       ;inkrement dla osi y
    ;obliczenie odległości pionowej
    mov  edi, [ebp-52] ;odjęcie współrzędnej początkowej
    sub  edi, [ebp-44] ;od koniecznej współrzędnej
    jge  keep_y     ;do przodu, jeśli nachylenie < 0
    neg  edx         ;w przeciwnym razie inkrement wynosi -1
    neg  edi         ;odległość musi być > 0

keep_y:
    mov  [ebp-12], edx
    ;obliczenie odległości poziomej
    mov  esi, [ebp-48]   ;odjęcie współrzędnej początkowej
    sub  esi, [ebp-40] ;od koniecznej współrzędnej
    jge  keep_x     ;do przodu, jeśli nachylenie <0
    neg  ecx         ;w przeciwnym razie inkrement wynosi -1
    neg  esi         ;odległość musi być > 0

keep_x:
    mov  [ebp-16], ecx
    ;badanie, czy segmenty są poziome lub pionowe
    cmp  esi, edi      ;poziome są dłuższe?
    jge  horz_seg   ;jeśli tak, naprzód
    mov  ecx, 0       ;w przeciwnym razie dla linii x nie zmienia się
    xchg esi, edi      ;włożenie większego w ecx
    jmp  save_values ;zapisanie wartości

horz_seg:
    mov  edx, 0       ;teraz dla poziomych linii y nie zmienia się

save_values:
    mov  [ebp-20], edi  ;krótszy dystans
    mov  [ebp-24], ecx  ;jeden z nich 0,
    mov  [ebp-28], edx  ;a drugi - 1.
    ;obliczamy współczynnik wyrównania
    mov  eax, [ebp-20]  ;krótszy dystans w eax
    shl  eax,1       ;podwojenie go
    mov  [ebp-32], eax  ;zapisanie go
    sub  eax, esi
    mov  ebx, eax      ;zapisanie jako liczniku cyklu
    sub  eax, esi
    mov  [ebp-36], eax  ;zapisanie
    ;przygotowanie do rysowania linii
    mov  ecx, [ebp-40] ;współrzędna początkowa x
    mov  edx, [ebp-44] ;współrzędna początkowa y
    inc  esi         ;dodanie 1 dla końca
    ;rysowanie odcinka
main_loop:
    dec  esi      ;licznik na większą odległość
    jz   return ;wyjście po ostatnim punkcie

    push edi ;rysowanie piksela
    mov edi, [ebp-8]
    push edi
    push edx
    push ecx
    mov edi, [ebp+8]
    push edi
    call put_pixel
    pop edi

skip:
    cmp  ebx,0       ;jeśli ebx <0, to segment prosty
    jge  diagonal_line  ;w przeciwnym razie segment przekątny
    ;rysowanie prostych segmentów
    add  ecx, [ebp-24]  ;określamy inkrementy wzdłuż osi
    add  edx, [ebp-28]
    add  ebx, [ebp-32]  ;współczynnik wyrównania
    jmp  main_loop  ;do następnego punktu
    ;rysowanie ukośnych segmentów

diagonal_line:
    add  ecx, [ebp-16]  ;określamy inkrementy wzdłuż osi
    add  edx, [ebp-12]
    add  ebx, [ebp-36]  ;współczynnik wyrównania
    jmp  main_loop  ;do następnego punktu