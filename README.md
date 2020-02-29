# Tema 2 - Stegano


## Concepte importante:
### Stack frame
- Nu voi salva EBP pentru functiile mici sau cele care nu lucreaza extensiv cu
  stiva si voi lucra direct cu ESP.
- Exemple: `FUNC_SetPixel`, `FUNC_ComputeNewKey`, `FUNC_CharToMorse`

### Calling convention
- Toate functiile scrise de mine respecta urmatoarele conventii:
  - dupa un apel, caller-ul curata stiva (cdecl)
  - registrii `EAX`, `ECX`, `EDX` pot fi folositi de functia apelata fara a-i salva
  - ceilalti registri trebuie salvati de callee (Intel ABI)


## Explicare task-uri:
### Task 1 - Bruteforce pe XOR cu cheie de un octet

- Logica de gasire a cheii XOR si a mesajului a fost delegata procedurii
  `bruteforce_singlebyte_xor` care primeste ca parametru imaginea si returneaza
  indexul randului si cheia astfel:
  - octetul cel mai nesemnificativ: cheia XOR
  - cei 3 octeti ramasi: indexul randului
- In C, s-ar scrie: `ret = (row_index << 8) | xor_key`.
- Daca ar fi permisa modificarea antetului functiei, as returna acesti parametri
  separat, ca parametri trimisi pe stiva prin referinta.

- Logica functiei:
  1. Se face un loop de la 0->255 care stabileste cheia XOR ce va fi incercata.
  2. Pentru fiecare cheie XOR, se XOR-eaza intreaga imagine (`FUNC_XorBuffer`)
  3. Se cauta mesajul (needle) in imaginea XOR-ata (`FUNC_memmem` - implementare
     naiva in ASM a functiei `memmem` din glibc):
     - daca se gaseste mesajul, se calculeaza indexul randului si se returneaza
       datele cerute in formatul specificat mai sus
     - daca nu se gaseste, se XOR-eaza din nou imaginea (revenind la starea
       initiala si se incrementeaza cheia XOR, revenind la pasul 2.

- Printarea mesajului se face manual, iterand prin fiecare caracter, deoarece
  `printf` nu poate lucra cu string-uri in care caracterele sunt stocate pe DWORD
  in loc de BYTE.

### Task 2 - Criptare folosind XOR cu cheie predefinita

- Logica acestui task a fost delegata procedurii `insert_message` care executa
  urmatorii pasi:

  1. Se apeleaza functia `bruteforce_singlebyte_xor` pentru decodarea imaginii
     si pentru gasirea locatiei mesajului si a cheii XOR folosite.
  2. Se insereaza noul mesaj pe randul urmator.
  3. Se calculeaza noua cheie XOR (`FUNC_ComputeNewKey`)
  4. Se aplica noua cheie pe intreaga imagine (`FUNC_XorBuffer`)

### Task 3 - Criptarea unui mesaj folosind Codul Morse

- Pentru acest task am definit codul fiecarui caracter in sectiunea
  .rodata si am creat un lookup table unde am stocat adresa la care se
  gaseste reprezentarea in cod Morse a fiecarui caracter.
- Task-ul este rezolvat efectiv de procedura `morse_encrypt`:
  1. Pentru fiecare caracter al mesajului se produce reprezentarea in cod Morse
     pe caractere de 1-byte (`FUNC_CharToMorse`)
  2. Se calculeaza lungimea reprezentarii Morse (`FUNC_strlen`)
  3. Se transforma reprezentarea cu caractere 1-byte in reprezentare cu caractere
     4-byte si se salveaza rezultatul in imagine.
  4. Se creste indexul destinatie cu numarul de caractere al reprezentarii Morse
  5. Dupa fiecare cod Morse se adauga separatorul spatiu.
  6. Se reiau pasii pana se termina de procesat mesajul.

### Task 4 - LSB

- Logica functiei `lsb_encode`:
  1. Pentru fiecare byte din mesaj se face un loop pe fiecare bit, de la MSB spre LSB
  2. Se verifica bitul curent daca este setat:
     - daca este setat, se seteaza LSB in DWORD-ul destinatie
     - daca nu este setat, se reseteaza LSB in DWORD-ul destinatie
  3. Se trece la urmatorul bit mesaj si se trece la urmatorul DWORD din destinatie
  4. Daca tocmai s-a terminat de procesat 1 byte din mesaj, se verifica daca acest
     byte a fost 0 (terminator de sir):
     - true  -> s-a terminat encodarea
     - false -> se trece la urmatorul byte din mesaj si se reia de la pasul 1.

### Task 5 - Decriptare LSB

- Logica functiei `lsb_decode`:
  1. Se aloca pe stiva 32 bytes pentru mesajul decodat.
  2. Se calculeaza adresa de la care se va incepe decodarea (`&img[byte_id-1]`)
  3. Pentru fiecare 8 DWORD-uri consecutive, se ia LSB si se pune intr-un byte,
     de la MSB spre LSB.
  4. Dupa procesarea a 8 DWORD-uri consecutive, se verifica daca byte-ul rezultat
     este 0 (terminator de sir):
     - true  -> s-a terminat decodarea
     - false -> se reia de la pasul 3.

### Task 6 - Aplicarea unui filtru pe imagine

- Logica functiei `blur`:
  1. Se calculeaza marimea in bytes a imaginii de input
  2. Se aloca pe stiva spatiul necesar pentru o copie a imaginii
  3. Se itereaza prin fiecare pixel al imaginii
  4. Se calculeaza noul pixel (`FUNC_ComputeBlurForPixel`)
  5. Se seteaza pixelul in noua imagine (`FUNC_SetPixel`)
  6. Afiseaza imaginea (`print_image`)
