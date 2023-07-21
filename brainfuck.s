.data
    tape: .zero 8000
    instructions: .zero 310000
    output: .zero 25000

.text
    .include "parse.s"

.global brainfuck

brainfuck:
    pushq %rbp
    movq %rsp, %rbp

    #%rdi -> initial instructions
    #%rsi -> parsed instructions
    movq $instructions, %rsi
    call parse
    
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movq $instructions, %rbx
    subq $8, %rbx
    movq $tape, %r12
    addq $100, %r12
    movq $output, %r15

    loopBrainfuck: 
        addq $8, %rbx
        movq (%rbx), %r13
        cmpq $0, %r13
        je endBrainfuck

        movb %r13b, %r14b
        shr $8, %r13

        cmpb $62, %r14b #>
        je isRightArrow
        cmpb $60, %r14b #<
        je isLeftArrow
        cmpb $43, %r14b #+
        je isPlus
        cmpb $45, %r14b #-
        je isMinus
        cmpb $46, %r14b #.
        je isDot
        cmpb $91, %r14b #[
        je isOpenBracket
        cmpb $93, %r14b #]
        je isClosedBracket
        cmpb $44, %r14b #, 
        je isComma

        isPlus:
            addb %r13b, (%r12)
            jmp loopBrainfuck
        isMinus:
            subb %r13b, (%r12)
            jmp loopBrainfuck
        isDot:
            loopDot:
                cmpq $0, %r13
                je loopBrainfuck
                decq %r13

                movzb (%r12), %rax
                movb %al, (%r15)
                incq %r15

                jmp loopDot
        isComma:
            loopCommma:
                cmpq $0, %r13
                je loopBrainfuck
                decq %r13

             
                leaq    (%r12), %rsi
                movq    $0, %rdi        
                movq    $0, %rax               
                movq    $1, %rdx                
                syscall 

                jmp loopCommma
        isOpenBracket:
            cmpq $0, %r13
            je isPattern1
            cmpq $1, %r13
            je isPattern2
            cmpq $2, %r13
            je isPattern3
            jne isGeneralPattern

            isPattern1: #[-]
                movb $0, (%r12)
                addq $16, %rbx
                jmp loopBrainfuck
            isPattern2: #[-<+>]
                movzb (%r12), %r9
                movb $0, (%r12)

                movq 16(%rbx), %rax
                shrq $8, %rax
                subq %rax, %r12

                addb %r9b, (%r12)

                addq %rax, %r12

                addq $40, %rbx
                jmp loopBrainfuck
            isPattern3: #[->+<]
                movzb (%r12), %r9
                movb $0, (%r12)

                movq 16(%rbx), %rax
                shrq $8, %rax
                addq %rax, %r12

                addb %r9b, (%r12)

                subq %rax, %r12

                addq $40, %rbx
                jmp loopBrainfuck
            isGeneralPattern:
                movb (%r12), %al
                cmpb $0, %al
                jne isNonZeroOpenBracket
                movq %r13, %rbx
                isNonZeroOpenBracket:
                    jmp loopBrainfuck
        isClosedBracket:
            movb (%r12), %al
            cmpb $0, %al
            je isZeroClosedBracket
            movq %r13, %rbx
            isZeroClosedBracket:
                jmp loopBrainfuck
        isLeftArrow:
            subq %r13, %r12
            jmp loopBrainfuck
        isRightArrow:
            addq %r13, %r12
            jmp loopBrainfuck

endBrainfuck:
    movq $1, %rax
    movq $1, %rdi
    movq $output, %rsi
    movq $25000, %rdx
    syscall

    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx

    movq %rbp, %rsp
    popq %rbp
    
    movq $60, %rax
    movq $0, %rdi
    syscall
