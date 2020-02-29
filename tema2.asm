%include "include/io.inc"

extern atoi
extern printf
extern exit

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height


; size of the longest decrypted message using lsb_decode algorithm
; not exact -> it's rounded up to the next multiple of 4 since 
; it's used to increase/decrease the stack pointer
%define MAX_LSB_ENCODED_SIZE 32


section .data
    use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1

section .rodata
    needle dd 'r', 'e', 'v', 'i', 'e', 'n', 't'
    needle_len equ $-needle
    message dd 'C',0x27,'e','s','t',' ','u','n',' ','p','r','o','v','e','r','b','e',' ','f','r','a','n','c','a','i','s','.', 0
    message_len equ $-message

    morse_A dd ".-",    0
    morse_B db "-...",  0
    morse_C db "-.-.",  0
    morse_D db "-..",   0
    morse_E db ".",     0
    morse_F db "..-.",  0
    morse_G db "--.",   0
    morse_H db "....",  0
    morse_I db "..",    0
    morse_J db ".---",  0
    morse_K db "-.-",   0
    morse_L db ".-..",  0
    morse_M db "--",    0
    morse_N db "-.",    0
    morse_O db "---",   0
    morse_P db ".--.",  0
    morse_Q db "--.-",  0
    morse_R db ".-.",   0
    morse_S db "...",   0
    morse_T db "-",     0
    morse_U db "..-",   0
    morse_V db "...-",  0
    morse_W db ".--",   0
    morse_X db "-..-",  0
    morse_Y db "-.--",  0
    morse_Z db "--..",  0
    morse_0 db "-----", 0
    morse_1 db ".----", 0
    morse_2 db "..---", 0
    morse_3 db "...--", 0
    morse_4 db "....-", 0
    morse_5 db ".....", 0
    morse_6 db "-....", 0
    morse_7 db "--...", 0
    morse_8 db "---..", 0
    morse_9 db "----.", 0
    morse_space db "|", 0
    morse_comma db "--..--", 0
; lookup table
    morse_letters dd morse_A, morse_B, morse_C, morse_D, morse_E, morse_F, morse_G, morse_H, morse_I, morse_J, morse_K, morse_L, morse_M, morse_N, morse_O, morse_P, morse_Q, morse_R, morse_S, morse_T, morse_U, morse_V, morse_W, morse_X, morse_Y, morse_Z
    morse_digits dd morse_0, morse_1, morse_2, morse_3, morse_4, morse_5, morse_6, morse_7, morse_8, morse_9

section .text
global main
main:
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
    mov [task], eax

    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done

solve_task1:
    mov ebx, [img]

    push ebx
    call bruteforce_singlebyte_xor
    add esp, 4

; extract row and xor_key from EAX
    mov dl, al       ; xor_key
    shr eax, 8
    push eax         ; save row idx for later use

; compute image size (number of elements)
    imul eax, [img_width]
    mov ecx, eax
    add ecx, [img_width]

.print_char:
    PRINT_CHAR [ebx + 4*eax]
    inc eax

    cmp BYTE [ebx + 4*eax], 0
    jz .done_printing ; found NULL terminator
    cmp eax, ecx
    jz .done_printing ; end of image
    jmp .print_char

.done_printing:
    NEWLINE
    PRINT_DEC 1, dl
    NEWLINE

    pop eax
    PRINT_DEC 4, eax
    NEWLINE

    jmp done

solve_task2:
    push DWORD [img]
    call insert_message
    add esp, 4

    push DWORD [img_height]
    push DWORD [img_width]
    push DWORD [img]
    call print_image
    add esp, 12

    jmp done

solve_task3:
    mov ebx, [ebp + 12]
    
    push DWORD [ebx + 16]
    call atoi

    mov [esp], eax
    push DWORD [ebx + 12]
    push DWORD [img]
    call morse_encrypt 
    add esp, 12

    push DWORD [img_height]
    push DWORD [img_width]
    push DWORD [img]
    call print_image
    add esp, 12    

    jmp done

solve_task4:
    mov ebx, [ebp + 12]
    
    push DWORD [ebx + 16]
    call atoi

    mov [esp], eax
    push DWORD [ebx + 12]
    push DWORD [img]
    call lsb_encode 
    add esp, 12

    push DWORD [img_height]
    push DWORD [img_width]
    push DWORD [img]
    call print_image
    add esp, 12    

    jmp done

solve_task5:
    mov ebx, [ebp + 12]
    
    push DWORD[ebx + 12]
    call atoi

    mov [esp], eax
    push DWORD [img]
    call lsb_decode 
    add esp, 8

    jmp done

solve_task6:
    push DWORD [img]
    call blur 
    add esp, 4  

    ; Free the memory allocated for the image.
done:
    push DWORD [img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret
    

; int bruteforce_singlebyte_xor(int *img)
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp
    sub esp, 12
    
    push ebx

    mov ebx, [ebp + 8] 
    mov eax, [img_width]
    imul eax, [img_height]
    
    mov DWORD [ebp - 4], eax ; image size (number of elements)
    mov DWORD [ebp - 8], 0   ; current xor key
    mov BYTE [ebp - 12], 0   ; should reencode?

.key_loop:
    inc BYTE [ebp - 8]

.decode_encode:
    push DWORD [ebp - 8]     ; key
    push DWORD [ebp - 4]     ; size (elements)
    push ebx                 ; buffer
    call FUNC_XorBuffer
    add esp, 12

    cmp BYTE [ebp - 12], 0
    jz .search_needle

    mov BYTE [ebp - 12], 0
    cmp BYTE [ebp - 8], 0xFF
    jne .key_loop

; no key found
    xor eax, eax
    jmp .return

.search_needle:
    mov eax, [ebp - 4]
    shl eax, 2

    push needle_len
    push needle
    push eax
    push ebx
    call FUNC_memmem
    add esp, 16

    test eax, eax
    jnz .found

    mov BYTE [ebp - 12], 1
    jmp .decode_encode

.found:
; offset = (found_addr - img_base)/4
    sub eax, ebx
    shr eax, 2

; row = offset/img_width
    cdq
    div DWORD [img_width]

; lowest byte: xor key
; next 3 bytes: line idx  
    shl eax, 8
    or eax, [ebp - 8]

.return:
    pop ebx
    leave
    ret


; void insert_message(int *img)
insert_message:
    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov ebx, [ebp + 8] ; img

; bruteforce the image
    push ebx
    call bruteforce_singlebyte_xor
    add esp, 4

; old xor key
    movzx edx, al

; compute the index of the destination row
    shr eax, 8
    inc eax
    imul eax, [img_width]

; insert the message
    lea edi, [ebx + 4*eax]
    mov esi, message
    mov ecx, message_len
    shr ecx, 2
    rep movsd

; xor the buffer with our key
    push edx
    call FUNC_ComputeNewKey
    add esp, 4

    push eax ; key
    mov eax, [img_width]
    imul eax, [img_height]
    push eax ; size (number of elements)
    push ebx ; buffer
    call FUNC_XorBuffer
    add esp, 12

.return:
    pop edi
    pop esi
    pop ebx
    leave
    ret 

; void morse_encrypt(int* img, char* msg, int byte_id)
morse_encrypt:
    push ebp
    mov ebp, esp

    push ebx
    push esi
    push edi

    mov ebx, [ebp + 8]       ; img
    mov edi, [ebp + 16]      ; byte_id
    xor esi, esi

.msg_loop:
    mov edx, [ebp + 12]      ; msg
    mov al, BYTE [edx + esi] ; current ch
    test al, al
    jz .msg_end
    
; get the 1-byte char representation of current ch in Morse code
    push eax
    call FUNC_CharToMorse

    mov [esp], eax           ; for strlen
    call FUNC_strlen
; no stack cleanup because [esp] (Morse representation) is needed for the next function call

; copy the 4-byte char representation into the image
    lea ecx, [ebx + 4*edi]
    push ecx
    add edi, eax
    call FUNC_CharStrToIntStr
    add esp, 8

; add a space after a Morse character
    mov DWORD [ebx + 4*edi], ' '
    
    inc edi
    inc esi
    jmp .msg_loop

.msg_end:
; NULL terminator
    mov DWORD [ebx + 4*edi - 4], 0

    pop edi
    pop esi
    pop ebx
    leave
    ret


; void lsb_encode(int* img, char* msg, int byte_id)
lsb_encode:
    push ebp
    mov ebp, esp
    push ebx

    mov edx, [ebp + 8]  ; img
    mov ebx, [ebp + 12] ; msg
    mov eax, [ebp + 16] ; byte_id
    lea edx, [edx + 4*eax - 4] ; &img[byte_id-1]

.msg_loop:
    mov al, BYTE[ebx]
    mov ecx, 8

.bit_loop:
    test al, 0x80 ; is MSB set?
    jnz .set_bit

.unset_bit:
    and BYTE[edx], 0xFE ; unset LSB bit of destination
    jmp .next 

.set_bit:
    or BYTE[edx], 1 ; set LSB bit of destination
    
.next:
; process next bit of the current character representation
    add edx, 4
    shl al, 1
    loop .bit_loop

; was this last bit a NULL terminator?
    cmp BYTE[ebx], 0
    jz .msg_end

; process next 8-bit character
    inc ebx
    jmp .msg_loop

.msg_end:
    pop ebx
    leave
    ret


; void lsb_decode(int* img, int byte_id)
lsb_decode:
    push ebp
    mov ebp, esp
    sub esp, MAX_LSB_ENCODED_SIZE
    push ebx

    mov ebx, [ebp + 8]                    ; img
    mov eax, [ebp + 12]                   ; byte_id
    lea ebx, [ebx + 4*eax - 4]            ; &img[byte_id-1]
    lea edx, [ebp - MAX_LSB_ENCODED_SIZE] ; buffer for decoded data

.new_byte:
    mov cl, 8

.fill_byte:
; prepare the mask
; AL: set (CL-1) bit on, others off (CL is in range: [1, 8])
    xor al, al
    inc al
    shl ax, cl
    shr ax, 1

; is LSB of the encoded character set?
    test BYTE[ebx], 1
    jnz .set_bit

.unset_bit:
    not al ; invert mask
    and BYTE [edx], al ; set bit (CL-1) off in the destination buffer
    jmp .next

.set_bit:
    or BYTE [edx], al  ; set bit (CL-1) on in the destination buffer

.next:
; process next encoded character
    add ebx, 4
    loop .fill_byte

; we just processed an 8-bit block
; is the last processed byte a NULL terminator?
    cmp BYTE [edx], 0
    jz .print
    
; proceed to the next 8-bit block
    inc edx
    jmp .new_byte

.print:
    PRINT_STRING [ebp - MAX_LSB_ENCODED_SIZE]
    NEWLINE

    pop ebx
    leave
    ret


; void blur(int* img)
blur:
    push ebp
    mov ebp, esp

    mov eax, [img_width]
    imul eax, [img_height]
    shl eax, 2
    sub esp, eax ; make room for a blured copy of image on the stack

    push ebx
    push esi
    push edi

    mov ebx, ebp
    sub ebx, eax ; ebx = pointer to new image allocated on the stack
    
    xor esi, esi ; loop index for height
    xor edi, edi ; loop index for width

.row_loop:
    cmp edi, [img_width]
    je .increase_height

    push edi ; width
    push esi ; height
    push DWORD [ebp + 8]
    call FUNC_ComputeBlurForPixel
    add esp, 12

    push eax
    push edi
    push esi
    push ebx
    call FUNC_SetPixel
    add esp, 16

    inc edi
    jmp .row_loop

.increase_height:
    xor edi, edi
    inc esi
    cmp esi, [img_height]
    jne .row_loop

    push DWORD [img_height]
    push DWORD [img_width]
    push ebx
    call print_image
    add esp, 12

    pop edi
    pop esi
    pop ebx
    leave
    ret


;int FUNC_ComputeBlurForPixel(int *img, int height, int width)
FUNC_ComputeBlurForPixel:
    push ebp
    mov ebp, esp
    sub esp, 8

    mov ecx, [ebp + 12] ; height
    mov edx, [ebp + 16] ; width

    mov BYTE [ebp - 4], 0 ; is pixel inside the borders?

; test pixel position (is inside the borders?)
    test ecx, ecx
    jz .same_value

    test edx, edx
    jz .same_value

    mov eax, [img_height]
    dec eax
    cmp ecx, eax
    jz .same_value

    mov eax, [img_width]
    dec eax
    cmp edx, eax
    jz .same_value

    mov BYTE [ebp - 4], 1

.same_value:
; center pixel
    push DWORD [ebp + 16]
    push DWORD [ebp + 12]
    push DWORD [ebp + 8]
    call FUNC_GetPixel
    add esp, 12

    cmp BYTE [ebp - 4], 0
    jz .return ; pixel is on the border. do not continue the algo

    mov [ebp - 8], eax ; sum of pixels

; down pixel  
    push DWORD [ebp + 16] ; width
    mov eax, [ebp + 12]
    inc eax    
    push eax              ; height
    push DWORD [ebp + 8]  ; base img
    call FUNC_GetPixel
    add esp, 12
    add [ebp - 8], eax

; right pixel
    mov eax, [ebp + 16]
    inc eax    
    push eax              ; width
    push DWORD [ebp + 12] ; height
    push DWORD [ebp + 8]  ; base img
    call FUNC_GetPixel
    add esp, 12
    add [ebp - 8], eax

; up pixel
    push DWORD [ebp + 16] ; width
    mov eax, [ebp + 12]
    dec eax    
    push eax              ; height
    push DWORD [ebp + 8]  ; base img
    call FUNC_GetPixel
    add esp, 12
    add [ebp - 8], eax

; left pixel
    mov eax, [ebp + 16]
    dec eax    
    push eax              ; width
    push DWORD [ebp + 12] ; height
    push DWORD [ebp + 8]  ; base img
    call FUNC_GetPixel
    add esp, 12

; final
    add eax, [ebp - 8]
    xor edx, edx
    mov ecx, 5
    div ecx

.return:
    leave
    ret


; int FUNC_GetPixel(int *img, int height, int width)
FUNC_GetPixel:
    mov ecx, [esp + 8]  ; height
    mov edx, [esp + 12] ; width

    mov eax, [img_width]
    imul eax, ecx
    add eax, edx
    mov ecx, [esp + 4]
    mov eax, [ecx + 4*eax]
    ret


; void FUNC_SetPixel(int *img, int height, int width, int val)
FUNC_SetPixel:
    mov ecx, [esp + 8]  ; height
    mov edx, [esp + 12] ; width

    mov eax, [img_width]
    imul eax, ecx
    add eax, edx
    mov ecx, [esp + 4]
    mov edx, [esp + 16]
    mov [ecx + 4*eax], edx
    ret


; int FUNC_ComputeNewKey(int old_key)
FUNC_ComputeNewKey:
; key = floor((2 * old_key + 3) / 5) - 4
    mov eax, [esp + 4] ; old_key
    shl eax, 1
    add eax, 3
    mov ecx, 5
    xor edx, edx
    div ecx
    sub eax, 4
    ret


; void FUNC_XorBuffer(void *buffer, unsigned size, unsigned char xor_key)
FUNC_XorBuffer:
    mov edx, [esp + 4]       ; buffer
    mov ecx, [esp + 8]       ; buffer size
    mov  al, BYTE [esp + 12] ; key

.loop:
    xor BYTE [edx + 4*ecx - 4], al
    loop .loop
    ret


; void FUNC_CharStrToIntStr(int *dst, const char *src)
FUNC_CharStrToIntStr:
    mov ecx, [esp + 4] ; dst
    mov edx, [esp + 8] ; src

.loop:
    movzx eax, BYTE [edx]
    mov [ecx], eax
    
    inc edx
    add ecx, 4

    test eax, eax
    jnz .loop    

    ret


; int FUNC_strlen(const char *buffer)
FUNC_strlen:
    push edi
    
    mov edi, [esp + 8]
    or ecx, 0xFFFFFFFF ; keep going
    xor al, al
    repnz scasb

    mov eax, edi
    sub eax, [esp + 8]
    dec eax

    pop edi
    ret


; bool FUNC_compare(const void *source1, const void *source2, size_t len)
FUNC_compare:
    mov ecx, [esp + 12] ; len

.loop:
    mov eax, [esp + 4]
    mov al, BYTE [eax]  ; *source1

    mov edx, [esp + 8]
    mov dl, BYTE [edx]  ; *source2

    cmp al, dl
    jne .not_equal

    inc DWORD [esp + 4]  ; source1++
    inc DWORD [esp + 8]  ; source2++
    loop .loop

    mov eax, 1
    jmp .return

.not_equal:
    xor eax, eax

.return:
    ret


; void *FUNC_memmem(const void *haystack, size_t haystacklen, const void *needle, size_t needlelen)
FUNC_memmem:
    push ebp
    mov ebp, esp
    
.loop:
    mov eax, [ebp + 12]   ; haystacklen
    mov ecx, [ebp + 20]   ; needlelen

    cmp eax, ecx          ; must: haystacklen <= needlelen
    jb .not_found

    push ecx              ; len
    push DWORD [ebp + 16] ; needle
    push DWORD [ebp + 8]  ; haystack
    call FUNC_compare
    add esp, 12

    test eax, eax
    jnz .found

    dec DWORD [ebp + 12]  ; haystack++
    inc DWORD [ebp + 8]   ; haystacklen--
    jmp .loop

.not_found:
    xor eax, eax
    jmp .return

.found:
    mov eax, [ebp + 8]    ; start address of needle in haystack

.return:
    leave
    ret

; const char* FUNC_CharToMorse(char ch)
FUNC_CharToMorse:
    movzx eax, BYTE [esp + 4] ; ch

    cmp al, ' '
    jz .space
    cmp al, ','
    jz .comma
    cmp al, '0'
    jb .invalid
    cmp al, '9'
    jbe .digit
    cmp al, 'A'
    jb .invalid
    cmp al, 'Z'
    jbe .letter

.space:
    mov eax, morse_space
    jmp .return

.comma:
    mov eax, morse_comma
    jmp .return

.digit:
    sub al, '0'
    mov eax, [morse_digits + 4*eax]
    jmp .return

.letter:
    sub al, 'A'
    mov eax, [morse_letters + 4*eax]
    jmp .return

.invalid:
    xor eax, eax

.return:
    ret
