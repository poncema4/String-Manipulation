%include "io.inc"

section .data
;; Reserve bytes for the 3 variables in order to be used limiting the user to 20 characters
input db 21 dup(0)
reversed_input db 21 dup(0)
input_size db 1 dup(0)

section .text
global main
main:
    ;; Prompt the user for their input
    PRINT_STRING "Enter a string - up to 20 characters: "
    GET_STRING input, 20 ;; Up to 20 characters long are considered by the user's input
    PRINT_STRING input ;; Print the user's input to visually see it 
    NEWLINE
    xor ecx, ecx ;; Clear counter register and set it to 0 to find the length of the string
    
;; Contract: -> integer
;; Purpose: Compute the length of the string by going through each character 
;; until it hits the null terminator
find_length:    
    mov al, [input + ecx]   ;; Load byte from 'input' at ecx index
    cmp al, 0   ;; Check if it has reached the end of the string
    je  done_length    ;; If yes, we have reached the end of the string and jump to done_length
    inc ecx    ;; Increment counter register (ecx), moves onto the next character (index)
    jmp find_length
    
;; Contract: string -> void
;; Purpose: Modify the string in many ways to get all the outputs expected: reversing, check if it
;; is a palindrome, coverts it to uppercase, and extracts the middle character from the string
done_length:
    mov [input_size], ecx  ;; Stores the length of the string in 'input_size'
    ;; Reverses the string 
    call reverse_string  
    ;; Checks if the string is a palindrome
    call check_palindrome
    ;; Converts the string into uppercase
    call convert_to_uppercase
    ;; Extracts the middle character or characters depending if its odd or even
    call extract_middle
    ;; Jump to exit to terminate the program properly
    jmp exit

;; Contract: -> string
;; Purpose: Prints the prompt indicating the start of reversing the 
;; string process from index 0
reverse_string:
    PRINT_STRING "Reversing the string..."
    NEWLINE
    mov ecx, [input_size]   ;; The size of the string gets stored in th ecx register
    mov esi, 0      ;; Start at the beginning of the string
    mov edi, reversed_input   ;; Point to the reversed string

;; Contract: integer -> stack
;; Purpose: Pushes each character of the string into a stack in reverse
;; order (Last In, First Out)
reverse_loop:
    movzx eax, byte [input + esi]  ;; Load characters into eax register
    push eax    ;; Push each character into a stack
    inc esi    ;; Increments the string's index
    loop reverse_loop   ;; Loops until all characters of the string are pushed in the stack
    mov ecx, [input_size]   ;; Determines what the size of the reversed_input should be
    mov esi, 0    ;; Starts storing the characters from the first index 0, from reversed_input
    
;; Contract: stack -> string
;; Purpose: Pops each characters from the stack into reversed_input and get the string
;; reversed and return that string value
reverse_pop:
    pop eax    ;; Pop the first character, the 0 index of the string
    mov [reversed_input + esi], al  ;; Stores each popped character into reversed_input
    inc esi     ;; Increments to the next index in the string
    loop reverse_pop    ;; Loops until all characters of the string are popped
    PRINT_STRING "Reversed string: "
    PRINT_STRING reversed_input
    ret

;; Contract: string string integer -> boolean
;; Purpose: Compares inputted string with reversed string to determined if it can be
;; considered a palindrome
check_palindrome:
    mov ecx, [input_size]   ;; Loads the length of the string to ecx register
    mov esi, 0    ;; Starting index for both strings
    mov edi, 1    ;; If it is a palindrome then flag it 1, if not it will be set to 0
    
;; Contract: string string integer -> boolean
;; Purpose: Goes through the original and reversed string and compares each
;; character, if a mismatch is found jump to no_palindrome, if they all match
;; set edi to 1 and jump to palindrome_done
compare_loop:
    mov al, [input + esi]
    mov bl, [reversed_input + esi]
    cmp al, bl
    jne no_palindrome  ;; If all characters do not match, jne to not_palindrome
    inc esi     ;; Jumps to the next index in the string
    loop compare_loop   ;; Loops ove the compare_loop function to consider each character
    mov edi, 1    ;; Set flag to 1, if it is a palindrome
    jmp palindrome_done  ;; When the whole string is compared, jump to palindrome_done
    
;; Contract: -> boolean
;; Purpose: Sets the edi flag to 0 meaning that the string is not a palindrome
no_palindrome:
    mov edi, 0    ;; Set flag to 0, if it not a palindrome
    
;; Contract: -> string
;; Purpose: Prints the prompt determing if it is a palindrome or not based
;; on the value of edi (0 = no, 1 = yes)
palindrome_done:
    NEWLINE
    PRINT_STRING "The string is "
    cmp edi, 1  ;; Compares edi register with 1 meaning the string is a palindrome
    je yes_palindrome
    PRINT_STRING "not " ;; If not equal to 1, then the printed output will include "not"
    
;; Contract: -> string
;; Purpose: The ending part of the prompt that just prints out the remaining
;; part for the user to see
yes_palindrome:
    PRINT_STRING "a palindrome!"
    NEWLINE
    ret

;; Contract: string integer -> string
;; Purpose: Goes through the string and converts characters a-z to become
;; uppercase letters, already uppercase letters are left unchanged and the result
;; is stored in the input string
convert_to_uppercase:
    PRINT_STRING "Converting to uppercase..."
    NEWLINE
    mov ecx, [input_size]   ;; Gets the size of the inputted string
    mov esi, 0     ;; Start at the beginning of the string

;; Contract: string integer -> string
;; Purpose: If the character is lowercase, subtract 32 to its ASCII value
;; converting it to uppercase, if not skip the character and store in the input string
convert_loop:
    mov al, [input + esi]   ;; Load the first character of the string
    cmp al, 'a'   ;; If it is less than 'a', this means its not a lowercase letter
    jl skip_to_next_char
    cmp al, 'z'   ;; If it is greater than 'z', this means its not a lowercase letter
    jg skip_to_next_char
    push 1   ;; Push 1 into the stack meaning that a character is lowercase and needs to be converted
    sub al, 32   ;; Converts to uppercase but subtracting 32 to the ASCII value of the character
    mov [input + esi], al   ;; Store converted character (uppercase) back into the string
    jmp check_and_pop

;; Contract: -> void
;; Purpose: If the character in the string is not lowercase, push 0 into the stack and
;; ignore it so it does not get revaluated again
skip_to_next_char:
    push 0

;; Contract: stack -> void
;; Purpose: Pops the flag from the stack and moves to the next
;; character that is in the string and moves onto the next index
check_and_pop:
    pop eax     ;; Pop the flag from the stack
    inc esi
    loop convert_loop
    PRINT_STRING "Uppercase string: "
    PRINT_STRING input
    NEWLINE
    ret

;; Contract: string integer -> character
;; Purpose: Extracts and prints the middle character or characters
;; depending if the string length is odd or even
extract_middle:
    PRINT_STRING "Extracting the middle character..."
    NEWLINE
    mov ecx, [input_size]  ;; Gets the length of the string
    mov esi, 0     ;; The start of the index, 0, for the string
    mov edi, 0     ;; The start of the flag determing if the length is even or odd
    test ecx, 1      ;; Checks if the length is odd, if so jnz to odd_length
    jnz odd_length

    mov eax, ecx   ;; If the string is even then that means there are 2 middle characters
    shr eax, 1   ;; Divides the string character by 2, to get the middle value
    dec eax   ;; Eax now points to the first middle character (index length/2 - 1)
    mov esi, eax  ;; Sets esi to the first middle character index
    inc esi  ;; Sets esi to the second middle character index
    push 1  ;; Push 1 to the stack to indicate its an even length of string

    PRINT_STRING "Middle characters: "
    mov al, [input + eax]   ;; The first middle character is loaded
    PRINT_CHAR al
    mov al, [input + esi]   ;; The second middle character is loaded
    PRINT_CHAR al
    NEWLINE
    jmp middle_done

;; Contract: string integer -> character
;; Purpose: Computes the middle index by dividing the length by 2 which means
;; this is the index of the middle character of the string
odd_length:
    shr ecx, 1   ;; Divide the length of the string by 2 to get the middle index
    mov esi, ecx    ;; Set esi to the middle character index
    push 0    ;; Push 0 to the stack to indicate its an odd length of string
    PRINT_STRING "Middle character: "
    mov al, [input + esi]  ;; Loads the middle character of the string
    PRINT_CHAR al
    NEWLINE

;; Contract: -> void
;; Purpose: Pops the flag to clean up the stack and for purpose of resetting the stack
;; after all conditionals are passed and executed
middle_done:
    pop eax
    ret
  
;; Contract: -> void
;; Purpose: Terminates the program and sets every register to 0 to avoid
;; any bugs or errors from happening and ret
exit:
    xor eax, eax
    xor ebx, ebx    
    xor ecx, ecx
    xor edx, edx
    xor esi, esi
    xor edi, edi
    ret
