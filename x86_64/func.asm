section	.text
global  exec_turtle, _exec_turtle

return: ;powrót do pliku C
    mov rax, 0
    mov	rsp, rbp
	pop	rbp
	ret

return_error_2:
    mov rax, 2
    mov	rsp, rbp
	pop	rbp
	ret

exec_turtle:
_exec_turtle:
	push rbp
	mov	rbp, rsp
	sub rsp, 56 ;rezerwacja miejsca do
    mov rax, rsi;[ebp+12] ;zmiennych lokalnych
    mov rax, [rax]
    and rax, 0xc0

    cmp rax, 0x00 ;zdefiniowanie komendy
    je Set_position

    cmp rax, 0xC0
    je Set_pen_state

    cmp rax, 0x80
    je Move

    cmp rax, 0x40
    je Set_direction

    mov rax, 4
	mov	rsp, rbp
	pop	rbp
	ret

Set_position:
    mov rax, rdx ;turtle

    mov rbx, rsi ;y
    mov rbx, [rbx+8]
    shr ebx, 2

    mov rdx, rdi
    mov rdx, [rdx+22]
    cmp ebx, edx ;sprawdzenie czy y
    ja return_error_2 ;nie jest zaduży
    mov [rax+4], ebx

    mov rbx, rsi ;x
    mov rcx, [rbx+12]
    mov rdx, [rbx+8]
    shl rdx, 8
    and rdx, 0x0300
    or rcx, rdx

    mov rdx, rdi
    mov rdx, [rdx+18]
    cmp rcx, rdx ;sprawdzenie czy x
    ja return_error_2 ;nie jest zaduży
    mov [rax], ecx

    jmp return ;powrót

Set_direction:
    mov rax, rdx
    mov rbx, rsi
    mov rbx, [rbx+4]

    and rbx, 0x03
    mov [rax+16], rbx ;ustawienie nowego kąta

    jmp return ;powrót

Set_pen_state:
    mov rax, rdx

    mov rbx, rsi
    mov rbx, [rbx]
    shr rbx, 5
    and rbx, 0x01

    mov [rax+12], ebx ;ustawienie nowego stanu pióra

    mov rbx, rsi
    mov rcx, [rbx+4] ;g3-g0 + r3-r0
    mov rdx, [rbx] ;b3-b0
    mov rdi, [rbx+4] ;g3-g0 + r3-r0

    and rdi, 0xF
    shl rdi, 20 ;r

 	and rcx, 0xF0 ;g
 	shl rcx, 8

	and rdx, 0xF ;b
	shl rdx, 4

	or edi, ecx ;r+g
	or edi, edx ;r+g+b

    mov [rax+8], edi ;ustawienie nowego koloru
    jmp return ;powrót

Move:
    mov rax, rdx
    mov r8, [rax+16] ;kierunek

    mov rbx, rsi ; m9-m8
    shl rbx, 8
    and rbx, 0x03
    mov rcx, rsi ; m7-m0
    mov rcx, [rcx+4]
    or rbx, rcx ; m7-m0 + m9-m8

    cmp r8, 0x01 ;zdefiniowanie wspórzędnej do zmiany
    je y_plus

    cmp r8, 0x00
    je x_plus

    cmp r8, 0x03
    je y_minus

    cmp r8, 0x02
    je x_minus

    mov rax, 3 ;jeżeli kierunek nie został uznany
	mov	rsp, rbp
	pop	rbp
	ret

y_plus:
    ;zwiększenie wspórzędnej y
    mov rcx, [rax+4]
    add rbx, rcx
    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [rbp-44], ecx
    mov rcx, [rax]
    mov [rbp-40], ecx
    mov [rbp-48], ecx

    mov [rax+4], ebx
    mov [rbp-52], ebx

    mov rcx, [rax+12]
    cmp ecx, 1 ;jeżeli pióro jest opuśczone -
    je draw_line ;rysowanie linii

    jmp return ;powrót

x_plus:
    ;zwiększenie wspórzędnej x
    mov rcx, [rax]
    add rbx, rcx
    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [rbp-40], ecx
    mov rcx, [rax+4]
    mov [rbp-52], ecx
    mov [rbp-44], ecx

    mov [rax], bx
    mov [rbp-48], ebx

    mov rcx, [rax+12]
    cmp ecx, 1 ;jeżeli pióro jest opuśczone -
    je draw_line ;rysowanie linii

    jmp return ;powrót

x_minus:
    mov rcx, [rax]
    ;zmniejszenie wspórzędnej x
    sub rbx, rcx
    neg rbx

    cmp ebx, 0 ;sprawdzenie x
    jb return_error_2

    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [rbp-48], ecx
    mov rcx, [rax+4]
    mov [rbp-52], ecx
    mov [rbp-44], ecx

    mov [rax], ebx
    mov [rbp-40], ebx

    mov rcx, [rax+12]
    cmp ecx, 1 ;jeżeli pióro jest opuśczone -
    je draw_line ;rysowanie linii

    jmp return ;powrót

y_minus:
    mov rcx, [rax+4]
    sub rbx, rcx
    neg ebx
    ;zmniejszenie wspórzędnej y
    mov [rbp-44], ecx
    mov rcx, [rax]
    mov [rbp-40], ecx
    mov [rbp-48], ecx

     cmp ebx, 0 ;sprawdzenie y
     jb return_error_2

    ;ustawienie zmiennych lokalnych trzymających wspórzędne
    mov [rax+4], ebx
    mov [rbp-52], ebx

    mov rcx, [rax+12]
    cmp ecx, 1 ;jeżeli pióro jest opuśczone -
    je draw_line ;rysowanie linii

    jmp return ;powrót


put_pixel:
	push rbp
	mov	rbp, rsp

    xchg rcx, rdx
	mov	eax, edi;[ebp+8] ; - wskażnik na strukturę obrazu
    mov ebx, [eax+18]

    imul ebx, 3 ; w * 3
    add ebx, 3 ; w * 3 + 3
    and ebx, 0xFFFFFFFC ; (w * 3 + 3) & ~3
    imul ebx, ecx ; ((w * 3 + 3) & ~3) * h
    ;wiersz, w którym będzie piksel

    imul edx, 3 ; x * 3
    add ebx, edx ; kolumna, w której będzie piksel
    add ebx, eax
    add ebx, 54 ; adres tablicy pikseli


    mov edx, esi;[ebp+20] ;poprawne rozmieszczenie koloru
    mov [ebx], dx
    shr edx, 16
    mov [ebx+2], dl

    mov	rsp, rbp
	pop	rbp ;błędu nadmiarowej wspórzędnej
	ret

change_x:
    mov [rbp-48], ebx
    mov [rbp-40], ecx
    jmp draw_line

change_y:
    mov [rbp-52], ebx
    mov [rbp-44], ecx
    jmp draw_line

draw_line:
    mov ebx, [rbp-40]
    mov ecx, [rbp-48]
    cmp ebx, ecx
    jg change_x

    mov ebx, [rbp-44]
    mov ecx, [rbp-52]
    cmp ebx, ecx
    jg change_y
    mov rcx, rax
    mov rcx, [rcx+8]

    mov r14, rcx ;kolor
    mov r15, rdi ;struktura

    mov rax, [rbp-40] ;jeśli współrzędne początku i końca pokrywają się
    cmp rax,[rbp-48] ;rysowany jest jeden punkt
    jnz draw
    mov rax,[rbp-44] ;jeżeli nie - rysowanie linii
    cmp rax,[rbp-52]
    jnz draw

    mov r8, rax
    mov r9, rbx
    mov r10, rdi
    mov r11, rsi
    mov r12, rdx
    mov r13, rcx

    mov rdi, r15
    mov rsi, r14
    mov rcx, [rbp-40]
    mov rdx, [rbp-44]

    call put_pixel

    mov rax, r8
    mov rbx, r9
    mov rdi, r10
    mov rsi, r11
    mov rdx, r12
    mov rcx, r13

    ;rysowanie jednego piksela

    ;mov ecx, [rbp-48]
    jmp   return

draw:
    ;ustawianie początkowych inkrementów dla każdej pozycji punktu
    mov  rcx,1       ;inkrement dla osi x
    mov  rdx,1       ;inkrement dla osi y

    ;obliczenie odległości pionowej
    mov  rdi, [rbp-52] ;odjęcie współrzędnej początkowej
    sub  rdi, [rbp-44] ;od koniecznej współrzędnej

    jge  keep_y     ;do przodu, jeśli nachylenie < 0

    neg  rdx         ;w przeciwnym razie inkrement wynosi -1
    neg  rdi         ;odległość musi być > 0

keep_y:
    mov  [rbp-12], edx
    ;obliczenie odległości poziomej
    mov  rsi, [rbp-48]   ;odjęcie współrzędnej początkowej
    sub  rsi, [rbp-40] ;od koniecznej współrzędnej

    jge  keep_x     ;do przodu, jeśli nachylenie <0
    neg  rcx         ;w przeciwnym razie inkrement wynosi -1
    neg  rsi         ;odległość musi być > 0

keep_x:
    mov  [rbp-16], ecx
    ;badanie, czy segmenty są poziome lub pionowe
    cmp  esi, edi       ;poziome są dłuższe?
    jge  horz_seg   ;jeśli tak, naprzód
    mov  rcx, 0       ;w przeciwnym razie dla linii x nie zmienia się
    xchg rsi, rdi      ;włożenie większego w ecx
    jmp  save_values ;zapisanie wartości

horz_seg:
    mov  rdx, 0       ;teraz dla poziomych linii y nie zmienia się

save_values:
    mov  [rbp-20], edi  ;krótszy dystans
    mov  [rbp-24], ecx  ;jeden z nich 0,
    mov  [rbp-28], edx  ;a drugi - 1.

    ;obliczamy współczynnik wyrównania
    mov  rax, [rbp-20]  ;krótszy dystans w eax
    shl  rax,1       ;podwojenie go
    mov  [rbp-32], eax  ;zapisanie go
    sub  rax, rsi
    mov  rbx, rax      ;zapisanie jako liczniku cyklu
    sub  rax, rsi
    mov  [rbp-36], eax  ;zapisanie
    mov rax, [rbp-28]

    ;przygotowanie do rysowania linii
    mov  rcx, [rbp-40] ;współrzędna początkowa x
    mov  rdx, [rbp-44] ;współrzędna początkowa y
    inc  rsi         ;dodanie 1 dla końca
    ;rysowanie odcinka

main_loop:
    dec  rsi      ;licznik na większą odległość
    cmp esi, 0
    jl   return ;wyjście po ostatnim punkcie

    ;rysowanie piksela
    mov r8, rax
    mov r9, rbx
    mov r10, rdi
    mov r11, rsi
    mov r12, rdx
    mov r13, rcx

    mov rdi, r15
    mov rsi, r14

    call put_pixel

    mov rax, r8
    mov rbx, r9
    mov rdi, r10
    mov rsi, r11
    mov rdx, r12
    mov rcx, r13

skip:
    cmp  ebx,0       ;jeśli ebx <0, to segment prosty
    jg  diagonal_line  ;w przeciwnym razie segment przekątny
    ;rysowanie prostych segmentów
    add  rcx, [rbp-24]  ;określamy inkrementy wzdłuż osi
    add  rdx, [rbp-28]
    add  rbx, [rbp-32]  ;współczynnik wyrównania

    jmp  main_loop  ;do następnego punktu

diagonal_line:
    ;rysowanie ukośnych segmentów
    add  rcx, [rbp-16]  ;określamy inkrementy wzdłuż osi
    add  rdx, [rbp-12]
    add  rbx, [rbp-36]  ;współczynnik wyrównania

    jmp  main_loop
