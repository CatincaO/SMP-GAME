# SMP-GAME
**TITLU: Skip the danger**

**SCURSTA PREZENTARE:**

Am incercat sa fac un joc one player cu un jucator care sa se fereasca de diferite obstacole si sa atace alte obstacole pentru a se apara. Jucatorul vor avea posibilitatea de a se misca in diferite directii si de a se ataca. Scopul lui este de a se feri de atacurile adversarului si de obstacole. Va trebui sa conturam si avatarii si obstacolele 
Jocul este scris folosid limbajul assembley, compilat folosim NASM iar pentru interfata grafica am folosit QEMU.


**INSTRUCTIUNI DE COMPILARE/INSTALARE:**

Pentru a putea descarca si juca acest joc este nevoie sa detineti o masina virtuala de linux(de preferat Ubuntu) sau Ubuntu sa fie instalat pe masina fizica. Ulterior fisisrul game.asm se va compila cu ajutorul compilatorului de NASM folosim comanda: nasm -f bin game.asm -o game.bin, iar fisisrul binar obtinut in urma acestei rulari va fi introdus in comanda qemu-system-i386 -drive format=raw,file=game.bin, pentru a ne afisa grafica pe ecran.
Toate aceste comenzi le am introdus in interiorul unui Makefile pentru simplitatea utilizatorului, deasemenea in Makefile este prezenta si o regula de clear, care ca sterge fisierul binar generat de prima regula (de build).

Deci, intr-un terminat se va rula comanda make, ulterior comanda make run si asfel pe ecran se va afisa in QUEMU interfata jocului.(vezi imaginile de mai jos)

![Screenshot from 2022-06-01 18-13-06](https://user-images.githubusercontent.com/102541743/171438656-7f718032-4a73-42a6-9d04-75566ea60850.png)

**REGULILE JOCULUI:**

Din fereastra de QUMU, in care ne este afisata interfata jocului, folosim butoanele SHIFT- RIGHT si SHIFT-LEFT pentru a ne deplasa jucatorului stanga si dreapta, iar butonul ALT pentru a trage cu munitie in adversari.
Vom castiga in momentul cand reusim sa ne eliminam toti adversari (cu munitia galbena), iar daca vom fi atinsi de adversari si de munitia acestora(cea albastra) vom pierde. Astfel, pentru a putea sa rejucam jocul, va trebuie sa apasam orice tasta de la tastatura pentru a aduce totul in starea initiala.

![Screenshot from 2022-06-01 18-20-21](https://user-images.githubusercontent.com/102541743/171440215-7c67b23a-7e9e-49b7-ba45-48565b4a42db.png)

**DETALII DE IMPLEMENTARE:**

Am lasat si in codul sursa cateva comentarii cu referire la codul sursa.
Am construit codul din mai multe functii precum: 

<sub>_DESENARE - folosita pentru a contura pixeli, astfel conturand personajele jocului nostru_ 

<sub>_DEPLASARE-JUCATORI  - care ne permine deplasarea jucatoului stanga, dreapta_
  
<sub>_CREARE-MUNITIE - folosita pentru a crea munitita jucatorului_
  
<sub>_CREARE-MUNITIE-ADVERSARI - folosita pentru a crea munitia adversarilor_
  


**BIBLIOGRAFIE:**

Link NASM: https://nasm.us/

Link QUEMU:  https://www.qemu.org/

Link-uri inspiratie:
https://github.com/nanochess/Invaders

https://www.youtube.com/watch?v=TVvTDjMph1M

AM folosit aceste link-uri ca sursa de invatare si inspiratie, reusind in final sa creez o versiune proprie si simplificata :))


