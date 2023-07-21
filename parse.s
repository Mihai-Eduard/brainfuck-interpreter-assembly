parse:
    pushq %rbp
    movq %rsp, %rbp
    
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movq %rdi, %r12 #intial instructions
    movq %rsi, %r13 #parsed instrucitons
 
    movzb (%r12), %r14 #previous character
    movq $1, %r15 #counter
 
    startWithValid:
        cmpb $62, %r14b #>
        je loopParse
        cmpb $60, %r14b #<
        je loopParse
        cmpb $43, %r14b #+
        je loopParse
        cmpb $45, %r14b #-
        je loopParse
        cmpb $46, %r14b #.
        je loopParse
        cmpb $44, %r14b #,
        je loopParse
        cmpb $91, %r14b #[
        je loopParse
        cmpb $93, %r14b #]
        je loopParse

        cmpb $0, %r14b #null
        je endParse

        incq %r12
        movzb (%r12), %r14
        jmp startWithValid

    loopParse:
        #get the character
        incq %r12
        movzb (%r12), %rax
 
        cmpb $62, %al #>
        je validCharacter
        cmpb $60, %al #<
        je validCharacter
        cmpb $43, %al #+
        je validCharacter
        cmpb $45, %al #-
        je validCharacter
        cmpb $46, %al #.
        je validCharacter
        cmpb $44, %al #,
        je validCharacter
        cmpb $91, %al #[
        je validCharacter
        cmpb $93, %al #]
        je validCharacter
        cmpb $0, %al #null
        je validCharacter

        jmp loopParse

        validCharacter:
            cmpb $91, %r14b #[
            je openBracket
            cmpb $93, %r14b #]
            je closedBracket

            cmpb %r14b, %al
            jne unequalsCharacter

            equalsCharacters:
                inc %r15
                jmp loopParse
            unequalsCharacter:
    
                plus_minus_dots_commas_arrows:
                    movq %r15, %rcx
                    shlq $8, %rcx
                    movb %r14b, %cl
    
                    movq %rcx, (%r13)
                    addq $8, %r13
                    movq $1, %r15
                    jmp continueLoopParse
                brackets:
                    cmpb $93, %r14b
                    je closedBracket
    
                    openBracket:
                        pushq %r13
                        add $8, %r13
                        jmp continueLoopParse
                    closedBracket:
                        popq %rdx

                        movq %r13, %r8
                        subq %rdx, %r8
                        cmpq $16, %r8
                        je pattern1
                        cmpq $40, %r8
                        je pattern2
                        jne generalPattern
                        
                        pattern1:
                            movq %r13, %r8
                            subq $8, %r8
                            movq (%r8), %r9
                            movb %r9b, %r10b
                            cmpb $45, %r10b
                            jne generalPattern

                            movq $0, %rcx
                            movb $91, %cl
                            movq %rcx, (%rdx)

                            movq $1, %rcx
                            shlq $8, %rcx
                            movb $93, %cl
                            movq %rcx, (%r13)

                            add $8, %r13
                            jmp continueLoopParse

                        pattern2:
                            movq %rdx, %r8

                            addq $8, %r8
                            movq (%r8), %r9
                            movb %r9b, %r10b
                            shrq $8, %r9
                            cmpb $45, %r10b #-
                            jne generalPattern
                            cmpq $1, %r9
                            jne generalPattern

                            addq $16, %r8
                            movq (%r8), %r9
                            movb %r9b, %r10b
                            shrq $8, %r9 
                            cmpb $43, %r10b #+
                            jne generalPattern
                            cmpq $1, %r9
                            jne generalPattern

                            subq $8, %r8
                            movq (%r8), %r9
                            movb %r9b, %r10b
                            shrq $8, %r9 
                            movq %r9, %r11
                            cmpb $62, %r10b
                            je pattern3
                            cmpb $60, %r10b #<
                            jne generalPattern
                            
                            addq $16, %r8
                            movq (%r8), %r9
                            movb %r9b, %r10b
                            shrq $8, %r9 
                            cmpb $62, %r10b #>
                            jne generalPattern
                            cmpq %r9, %r11
                            jne generalPattern

                            movq $1, %rcx
                            shlq $8, %rcx
                            movb $91, %cl
                            movq %rcx, (%rdx)

                            movq $1, %rcx
                            shlq $8, %rcx
                            movb $93, %cl
                            movq %rcx, (%r13)

                            add $8, %r13
                            jmp continueLoopParse

                        pattern3:
                            addq $16, %r8
                            movq (%r8), %r9
                            movb %r9b, %r10b
                            shrq $8, %r9 
                            cmpb $60, %r10b #<
                            jne generalPattern
                            cmpq %r9, %r11
                            jne generalPattern

                            movq $2, %rcx
                            shlq $8, %rcx
                            movb $91, %cl
                            movq %rcx, (%rdx)

                            movq $1, %rcx
                            shlq $8, %rcx
                            movb $93, %cl
                            movq %rcx, (%r13)

                            add $8, %r13
                            jmp continueLoopParse

                        generalPattern:
                            movq %rdx, %rcx
                            shlq $8, %rcx
                            movb $93, %cl
                            movq %rcx, (%r13)
        
                            movq %r13, %rcx
                            shlq $8, %rcx
                            movb $91, %cl
                            movq %rcx, (%rdx)
        
                            add $8, %r13
                            jmp continueLoopParse
    
            continueLoopParse:
                movb %al, %r14b
                cmpb $0, %al
                jne loopParse

endParse:
    pop %r15
    pop %r14
    pop %r13
    pop %r12
    pop %rbx

    movq %rbp, %rsp
    popq %rbp
    ret
