bits 16
org 7C00h             ; offsetul memoryei, de aici se incepe

;; Definim variabilele
sprites           equ 0FA00h
jucator           equ 0FA08h 
vectorOponenti    equ 0FA20h  
playerX           equ 0FA24h
shotsArr          equ 0FA25h  
oponentY          equ 0FA2Dh
oponentX          equ 0FA2Eh


;; Definim constante
LATIME_ECRAN        equ 320     ;in pixeli
LUNGIME_ECRAN       equ 200     ;in pixeli
MEMORIE_VIDEO       equ 0A000h
TIMER               equ 046Ch   
PLAYERY             equ 93


; Culori
CULOARE_ADVERSAR           equ 0Dh   ; Magenta
CULOARE_JUCATOR            equ 07h   ; Gri
JUCATOR_CULOARE_TRAGERE    equ 0Eh   ; Galben
ADVERSARE_CULOARE_TRAGERE  equ 09h   ; Albastru


;;Setam modul video - VGA mode 13h
mov ax, 0013h
int 10h

;;Setam memoria video 
push MEMORIE_VIDEO
pop es          ; ES -> A0000h

;; SE muta datele inițiale de sprite în memorie
mov di, sprites
mov si, sprite_bitmaps
mov cl, 6
rep movsw

lodsd           
mov cl, 5
rep stosd

;;Setați variabilele inițiale
mov cl, 6       ; vectorOponenti si jucator pe X
rep movsb

xor ax, ax      ; Munitia
mov cl, 4
rep stosw

mov cl, 6      
rep movsb

push es
pop ds          ; DS = ES



;; DESFASURARE JOC
game_loop:
    xor ax, ax      ;pornim cu un ecran negru initial
    xor di, di
    mov cx, LATIME_ECRAN*LUNGIME_ECRAN
    rep stosb       ; mov [ES:DI], al cx # of times

    
    ;; CONSTRUIRE ADVERSARI
    mov si, vectorOponenti
    mov bl, CULOARE_ADVERSAR
    mov ax, [si+14]       ; AL = oponentY, AH = oponentX
    cmp byte [si+19], cl  ; 
    mov cl, 4
    jg construire_adversari_urmatori      
    add di, cx                
    construire_adversari_urmatori :
        pusha
        mov cl, 8             ; numarul de avatari pe linie     
        .verificare_adversar:
            pusha
            dec cx
            bt [si], cx     
            jnc .adversar_urmator 
            mov si, di      ; SI = folosit pentru desenare oponent urmator
            call desenare

            .adversar_urmator:
                popa
                add ah, 6+4
        loop .verificare_adversar

        popa
        add al, 3+2;
        inc si
    loop construire_adversari_urmatori 


    ;; CONSTRUIRE JUCATOR
    lodsb       ; AL = playerX
    push si
    mov si, jucator
    mov ah, PLAYERY
    xchg ah, al 
    mov bl, CULOARE_JUCATOR
    call desenare
     pop si  

    
    ;;Verificați dacă lovitura a lovit ceva
    mov cl, 4
    get_next_shot:
        push cx
        lodsw            
        cmp al, 0        
        jnz verifica_tragere_munitie

        next_shot:
            pop cx
    loop get_next_shot

    jmp creare_munitie_adversar




    creare_munitie:    
        mov bh, JUCATOR_CULOARE_TRAGERE
        mov al, [si-2]      ; se obtine valoare pe Y a munitiei
        dec ax              ; Muta munitia in sus
        cmp cl, 4           
        je .desen            

        mov bh, ADVERSARE_CULOARE_TRAGERE     ; Munitia adversarului
        inc ax
        inc ax                      ; munitie jos
        cmp al, LUNGIME_ECRAN/2     ; Munitia loveste partea de jos a ecranului?
        cmovge ax, bx               

        .desen:
            mov byte [si-2], al     ; Nou Y pentru munitie

            mov bl, bh              ; se pune culoarea in bl
            xchg ax, bx             ;culoare in ax
            mov [di+LATIME_ECRAN *3], ax   ; Desenare  pixeli
            stosw                       

        jmp next_shot


    creare_munitie_adversar:
       sub si, 6            ; valoarea pe Y a munitiei oponentului 
       mov cl, 3           ; munitie tripla de la oponent
       .verifica_tragere_munitie:
            mov di, si      
            lodsw           
            cmp al, 0       
            jg  .urmatoarea_tragere_munitie

            
            mov ax, [CS:TIMER]
            and ax, 0007h           ; mask off lowest 3 bits
            imul ax, ax, 6+4 ; Obține poziția X la care să apară împușcat
            xchg ah, al             
            add ax, [oponentY]       
            stosw                   ; copiaza data din AL in vectorul de munitie 

            jmp deplasare_adversari         ; Continuați după ce faceți 1 lovitură

            .urmatoarea_tragere_munitie:
        loop .verifica_tragere_munitie


    
    deplasare_adversari:
        mov di, oponentX
        inc bp
        cmp bp, [di+3]  
        jl deplasare_jucator   

        ;; Yes, move aliens
        neg byte [di+6]     
        xor bp, bp          
        mov al, [di+2]      ; numarul de pixeli cu care se misca oponentul pe directia X
        
        add byte [di], al   ; Muta oponenetul cu numarul de pixeli de mai sus
        jg .verifica_dreapta    ; Nu a atins partea stanga a ecranului 

        mov byte [di], cl       ; A atins partea stanga a ecranului
        jmp .mutare_jos
        
        .verifica_dreapta:
            mov al, 68
            cmp [di], al        ; A lovit partea dreapta a ecranului
            jle deplasare_jucator       ; Nu, continua
            stosb               ; Da 
            dec di

        .mutare_jos:
            neg byte [di+2]     ; deplasare in directia opusa pe X
            dec di
            add byte [di], 5    ; Adaugam la valoare oponentY pentru deplasare jos
            cmp byte [di], 55h
            jg joc_terminat            ;Daca a atins jucatorul
            dec byte [di+6]         ; Openenti s epot misca mai repede




    verifica_tragere_munitie:
        call pozitie_curenta_ecran    ; Poz curenta
        mov al, [di]

        ;; Lovire jucator
        cmp al, CULOARE_JUCATOR
        je joc_terminat

        xor bx, bx           
        ;; Lovire oponent
        .check_hit_alien:
            cmp cl, 4           ; verificam daca jucatorul a tras
            jne creare_munitie       ; Nu, trage

            cmp al, CULOARE_ADVERSAR; A atins munitia oponentul
            jne creare_munitie      ; Nu, mai trage o data

            mov bx, vectorOponenti
            mov ax, [bx+14]         ; AL = oponentY, AH = oponentX
            add al, 3
            .get_alien_row:
                cmp dl, al          ; Comparați împușcătura Y cu rândul oponentului curent Y
                jg .next_row        ; Nu a atins, verifica randul urmator

                ;; Alege oponentul din randul unde a fost lovit
                mov cl, 8               
                ;add ah, SPRITE_WIDTH   
                add ah, 6
                .get_alien:
                    dec cx
                    cmp dh, ah      
                    ja .next_alien  
                    
                    ;; Am gasit, si acum vrem sa-l stergem
                    btr [bx], cx        ; Resetați bitul din matricea extraterestră pentru a șterge
                    mov byte [si-2], 0  ; Resetati valoarea Y a tragerii din munitie
                    dec byte [si+8]     ; decrementam numarul de oponenti
                    jz joc_terminat       ; Daca am ucis ultimul oponent, joc castigat
                    jmp next_shot

                    .next_alien:
                        add ah, 6+4
                jmp .get_alien

                .next_row:
                    add al, 3+2
                    inc bx
            jmp .get_alien_row



    deplasare_jucator:
        mov si, playerX
        mov ah, 02h         ;Obtinere flag de la tastatura
        int 16h
        test al, 1          ; verificare shift dreapta
        jz .verificare_shift_stanga
        add byte [si], ah   ; mutati la dreapta jucatorul, prin adaugare de biti pe X

        .verificare_shift_stanga:
            test al, 2      ; verificati shift stanga
            jz .verificare_alt
            sub byte [si], ah   ; mutati la stanga jucatorul, prin scadere de biti pe Y

        .verificare_alt:
            test al, 8      ; verificati alt, pentru munitie
            jz delay_timer

            lodsb           ; AL = playerX
            xchg ah, al     ; AH = playerX, AL = 02 from AH above

            
            add ax, 035Ah
            mov [si], ax    ; noi valori pentru munitia primului jucator


    delay_timer:
        mov ax, [CS:TIMER] 
        inc ax
        .wait:
            cmp [CS:TIMER], ax
            jl .wait         



jmp game_loop


;; GAME OVER SI RESETARE
joc_terminat:
    xor ax, ax      ; Apasati o tasta pentru a reincepe
    int 16h
    int 19h         ; Reload de  bootsector

;; DESENARE PE ECRAN
;; Input parameters:
;;   SI = addresa de colorat
;;   AL = valoarea pe Y a liniei de colorat
;;   AH = valoarea pe X a linie de colorat
;;   BL = culoarea


desenare:
    call pozitie_curenta_ecran   ;pozitia actuala pe ecran pe coordonate X/Y
    mov cl, 4 ;pentru grosimea liniei de desen
    .linia_urmatoare:
        push cx
        lodsb                   ; AL = urmatorii octeti de desen
        xchg ax, dx             ; save off sprite data
        mov cl, 8               ; pentru linia de desen 
        .urmatorul_pixel:
            xor ax, ax          ; Daca avem pixel negru
            dec cx
            bt dx, cx           ; Is bit in sprite set? Copy to carry
            cmovc ax, bx        ; Yes bit is set, move BX into AX (BL = color)
            mov ah, al          ; Se copiaza culoare sa se umple AX ul 
            mov [di+LATIME_ECRAN], ax
            stosw  ;Stores a byte, word, or doubleword from the AL, AX, or EAX register, respectively, into the destination operand.                 
        jnz .urmatorul_pixel                             

        add di, LATIME_ECRAN*3 - 16
        pop cx
    loop .linia_urmatoare

    ret



;;Pozitia pe X si pe Y din registrul DI(Destination Index)
;; Input parameters:
;;   AL = valoare pe Y
;;   AH = valoare pe X

;;DX(Data Register) folosit pentru a tine informatia, find un Data Registre

pozitie_curenta_ecran:
    mov dx, ax      ; Save Y/X values
    cbw             ; Converteste octeti in cuvant, extinde AL la AH daca AL < 128
    imul di, ax, LATIME_ECRAN*2  ; DI = valoarea pe Y
    mov al, dh      ; AX = valoarea pe X
    shl ax, 1       ; shiftam val pe X
    add di, ax      ; DI = valoarea pe X + valoarea pe Y

    ret



sprite_bitmaps:
    db 10011001b    ; biti pentru avatari
    db 01011010b
    db 00111100b
    db 01000010b

    db 00011000b    ; biti pentru avatari
    db 01011010b
    db 10111101b
    db 00100100b

    db 00011000b    ; biti pentru jucator
    db 00111100b
    db 00100100b
    db 01100110b

    db 00111100b    
    db 01111110b
    db 11100111b
    db 11100111b

    ;; Valorile variabilelor initiale
    dw 0FFFFh       ; pentru vectorul oponenti
    dw 0FFFFh
    db 70           ; JUcator pe X
    ;; times 8 db 0 ; pentru munitie
    dw 230Ah        
    db 20h          
    db 0FBh         ; Directie -5
    dw 18           ; Move timer



times 510-($-$$) db 0
dw 0AA55h  ;dw = define world size


