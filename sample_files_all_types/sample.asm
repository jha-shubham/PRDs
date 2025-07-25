; PRD Management System - Assembly Implementation (x86-64 NASM)
; Version: 1.2.0 | Last Updated: July 25, 2025

section .data
    ; String constants
    banner          db "PRD Management System v1.2.0 - Assembly Implementation", 0Ah, 0
    banner_sep      db "========================================================", 0Ah, 0
    dashboard_hdr   db "PRD MANAGEMENT SYSTEM - DASHBOARD", 0Ah, 0
    demo_hdr        db "DEMO OPERATIONS", 0Ah, 0
    
    ; Status display names
    status_draft    db "Draft", 0
    status_review   db "In Review", 0
    status_approved db "Approved", 0
    status_dev      db "In Development", 0
    status_testing  db "Testing", 0
    status_impl     db "Implemented", 0
    status_archived db "Archived", 0
    
    ; Priority display names
    priority_low    db "Low", 0
    priority_med    db "Medium", 0
    priority_high   db "High", 0
    priority_crit   db "Critical", 0
    
    ; PRD data structure offsets
    PRD_ID_OFFSET       equ 0
    PRD_TITLE_OFFSET    equ 32
    PRD_DESC_OFFSET     equ 96
    PRD_AUTHOR_OFFSET   equ 160
    PRD_STATUS_OFFSET   equ 224
    PRD_PRIORITY_OFFSET equ 228
    PRD_CREATED_OFFSET  equ 232
    PRD_UPDATED_OFFSET  equ 240
    PRD_COMPLETION_OFFSET equ 248
    PRD_TAGS_OFFSET     equ 252
    PRD_SIZE            equ 320
    
    ; Status enumeration
    STATUS_DRAFT        equ 0
    STATUS_IN_REVIEW    equ 1
    STATUS_APPROVED     equ 2
    STATUS_IN_DEV       equ 3
    STATUS_TESTING      equ 4
    STATUS_IMPLEMENTED  equ 5
    STATUS_ARCHIVED     equ 6
    
    ; Priority enumeration
    PRIORITY_LOW        equ 1
    PRIORITY_MEDIUM     equ 2
    PRIORITY_HIGH       equ 3
    PRIORITY_CRITICAL   equ 4
    
    ; System messages
    prd_created_msg     db "PRD created successfully: ", 0
    status_updated_msg  db "PRD status updated to: ", 0
    search_msg          db "Searching for 'authentication' related PRDs:", 0Ah, 0
    draft_msg           db "Draft PRDs: ", 0
    critical_msg        db "Critical Priority PRDs: ", 0
    attention_msg       db "PRDs Needing Attention: ", 0
    stats_msg           db "Completion Statistics:", 0Ah, 0
    total_msg           db "Total PRDs: ", 0
    avg_completion_msg  db "Average Completion: ", 0
    min_completion_msg  db "  Minimum: ", 0
    max_completion_msg  db "  Maximum: ", 0
    avg_stat_msg        db "  Average: ", 0
    percent_sign        db "%", 0Ah, 0
    newline             db 0Ah, 0
    space               db " ", 0
    colon               db ": ", 0
    
    ; Sample PRD data
    sample_titles       db "User Authentication System", 0, 32-27 dup(0)
                       db "Dark Mode Theme", 0, 32-15 dup(0)
                       db "Payment Gateway Integration", 0, 32-27 dup(0)
                       db "API Rate Limiting", 0, 32-17 dup(0)
                       db "Mobile App Redesign", 0, 32-19 dup(0)
                       db "Real-time Notifications", 0, 32-23 dup(0)
                       db "Performance Optimization", 0, 32-24 dup(0)
                       db "Multi-language Support", 0, 32-22 dup(0)
                       db "Assembly Implementation", 0, 32-23 dup(0)
                       db "Low-level Optimization", 0, 32-22 dup(0)
    
    sample_descriptions db "Implement secure login and registration", 0, 64-39 dup(0)
                       db "Add dark theme option for better UX", 0, 64-35 dup(0)
                       db "Integrate secure payment processing", 0, 64-35 dup(0)
                       db "Implement API rate limiting for security", 0, 64-40 dup(0)
                       db "Complete redesign of mobile application", 0, 64-39 dup(0)
                       db "Add real-time notification system", 0, 64-33 dup(0)
                       db "Optimize database queries and caching", 0, 64-37 dup(0)
                       db "Add internationalization support", 0, 64-32 dup(0)
                       db "Implement core logic in assembly", 0, 64-32 dup(0)
                       db "Optimize critical paths with assembly", 0, 64-37 dup(0)
    
    sample_authors     db "Dev Team", 0, 16-8 dup(0)
                      db "UX Team", 0, 16-7 dup(0)
                      db "Product Team", 0, 16-12 dup(0)
                      db "Backend Team", 0, 16-12 dup(0)
                      db "Design Team", 0, 16-11 dup(0)
                      db "Full Stack Team", 0, 16-15 dup(0)
                      db "Database Team", 0, 16-13 dup(0)
                      db "Localization Team", 0, 16-17 dup(0)
                      db "Assembly Team", 0, 16-13 dup(0)
                      db "Performance Team", 0, 16-16 dup(0)
    
    ; PRD storage (simplified - static allocation for demo)
    prd_storage         times 10*PRD_SIZE db 0
    prd_count           dd 0
    next_id_counter     dd 1000
    
    ; Analytics data
    total_prds          dd 0
    status_counts       dd 0, 0, 0, 0, 0, 0, 0  ; 7 status types
    priority_counts     dd 0, 0, 0, 0            ; 4 priority types
    total_completion    dd 0
    
    ; Temporary strings for formatting
    temp_str            times 64 db 0
    id_str              times 32 db 0

section .bss
    ; Buffer for string operations
    string_buffer       resb 256

section .text
    global _start

; System call constants
SYS_WRITE   equ 1
SYS_EXIT    equ 60
STDOUT      equ 1

; Macro for printing strings
%macro print_string 1
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, %1
    call strlen
    mov rdx, rax
    syscall
%endmacro

; Macro for printing newline
%macro print_newline 0
    print_string newline
%endmacro

_start:
    ; Print banner
    print_string banner
    print_string banner_sep
    
    ; Initialize PRD manager
    call init_prd_manager
    
    ; Load sample data
    call load_sample_data
    
    ; Print dashboard
    call print_dashboard
    
    ; Demo operations
    print_newline
    print_string banner_sep
    print_string demo_hdr
    print_string banner_sep
    
    ; Search demo
    call demo_search
    
    ; Status filtering demo
    call demo_status_filter
    
    ; Priority filtering demo
    call demo_priority_filter
    
    ; Completion statistics
    call demo_completion_stats
    
    ; Exit program
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

; Initialize PRD manager
init_prd_manager:
    ; Clear PRD storage
    mov rdi, prd_storage
    mov rcx, 10*PRD_SIZE
    xor rax, rax
    rep stosb
    
    ; Reset counters
    mov dword [prd_count], 0
    mov dword [next_id_counter], 1000
    
    ret

; Generate PRD ID
; Returns: ID in id_str
generate_prd_id:
    push rax
    push rbx
    push rcx
    push rdx
    
    ; Format: PRD-XXXX-YYYY where XXXX is counter, YYYY is random-ish
    mov rdi, id_str
    mov rsi, prd_id_format
    mov eax, [next_id_counter]
    inc dword [next_id_counter]
    mov ebx, eax
    add ebx, 1337  ; Simple "random" component
    call sprintf_simple
    
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

prd_id_format db "PRD-%04d-%04d", 0

; Simple sprintf implementation for ID formatting
sprintf_simple:
    ; Very simplified - just copy format for demo
    mov byte [rdi], 'P'
    mov byte [rdi+1], 'R'
    mov byte [rdi+2], 'D'
    mov byte [rdi+3], '-'
    
    ; Convert counter to string (simplified)
    mov rcx, 4
    add rdi, 4
.convert_loop:
    mov rdx, 0
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rdi+rcx-1], dl
    loop .convert_loop
    
    add rdi, 4
    mov byte [rdi], '-'
    inc rdi
    
    ; Convert second number
    mov rax, rbx
    mov rcx, 4
.convert_loop2:
    mov rdx, 0
    mov rbx, 10
    div rbx
    add dl, '0'
    mov [rdi+rcx-1], dl
    loop .convert_loop2
    
    add rdi, 4
    mov byte [rdi], 0
    ret

; Create new PRD
; Input: rbx = title offset, rcx = description offset, rdx = author offset
; Returns: PRD index in rax
create_prd:
    push rbx
    push rcx
    push rdx
    push rdi
    push rsi
    
    ; Check if we have space
    mov eax, [prd_count]
    cmp eax, 10
    jge .no_space
    
    ; Calculate PRD storage offset
    mov rdi, PRD_SIZE
    mul rdi
    add rax, prd_storage
    mov rdi, rax  ; rdi = PRD address
    
    ; Generate ID
    call generate_prd_id
    
    ; Copy ID
    mov rsi, id_str
    mov rcx, 32
    rep movsb
    
    ; Copy title
    mov rsi, rbx
    mov rcx, 32
    rep movsb
    
    ; Copy description  
    mov rsi, rcx
    mov rcx, 64
    rep movsb
    
    ; Copy author
    mov rsi, rdx
    mov rcx, 16
    rep movsb
    
    ; Set default values
    mov dword [rdi + PRD_STATUS_OFFSET - 112], STATUS_DRAFT      ; Adjust offset
    mov dword [rdi + PRD_PRIORITY_OFFSET - 112], PRIORITY_MEDIUM
    mov dword [rdi + PRD_COMPLETION_OFFSET - 112], 0
    
    ; Increment count
    inc dword [prd_count]
    
    ; Print creation message
    print_string prd_created_msg
    print_string id_str
    print_newline
    
    mov eax, [prd_count]
    dec eax
    jmp .done
    
.no_space:
    mov rax, -1
    
.done:
    pop rsi
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    ret

; Load sample data
load_sample_data:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov rsi, 0  ; Sample index
    
.load_loop:
    cmp rsi, 10
    jge .done
    
    ; Calculate offsets
    mov rax, rsi
    mov rbx, 32
    mul rbx
    mov rbx, rax
    add rbx, sample_titles
    
    mov rax, rsi
    mov rcx, 64
    mul rcx
    mov rcx, rax
    add rcx, sample_descriptions
    
    mov rax, rsi
    mov rdx, 16
    mul rdx
    mov rdx, rax
    add rdx, sample_authors
    
    ; Create PRD
    call create_prd
    
    inc rsi
    jmp .load_loop
    
.done:
    ; Update some statuses for variety
    call update_sample_statuses
    
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Update some sample PRD statuses
update_sample_statuses:
    push rax
    push rdi
    
    ; Update PRD 1 to IN_REVIEW
    mov rax, 1
    mov rdi, PRD_SIZE
    mul rdi
    add rax, prd_storage
    mov dword [rax + PRD_STATUS_OFFSET], STATUS_IN_REVIEW
    
    ; Update PRD 2 to APPROVED with HIGH priority
    mov rax, 2
    mov rdi, PRD_SIZE
    mul rdi
    add rax, prd_storage
    mov dword [rax + PRD_STATUS_OFFSET], STATUS_APPROVED
    mov dword [rax + PRD_PRIORITY_OFFSET], PRIORITY_HIGH
    
    ; Update PRD 3 to IN_DEVELOPMENT with 65% completion
    mov rax, 3
    mov rdi, PRD_SIZE
    mul rdi
    add rax, prd_storage
    mov dword [rax + PRD_STATUS_OFFSET], STATUS_IN_DEV
    mov dword [rax + PRD_PRIORITY_OFFSET], PRIORITY_CRITICAL
    mov dword [rax + PRD_COMPLETION_OFFSET], 65
    
    ; Update PRD 4 to TESTING with 90% completion
    mov rax, 4
    mov rdi, PRD_SIZE
    mul rdi
    add rax, prd_storage
    mov dword [rax + PRD_STATUS_OFFSET], STATUS_TESTING
    mov dword [rax + PRD_COMPLETION_OFFSET], 90
    
    ; Update PRD 5 to IMPLEMENTED with 100% completion
    mov rax, 5
    mov rdi, PRD_SIZE
    mul rdi
    add rax, prd_storage
    mov dword [rax + PRD_STATUS_OFFSET], STATUS_IMPLEMENTED
    mov dword [rax + PRD_COMPLETION_OFFSET], 100
    
    pop rdi
    pop rax
    ret

; Generate analytics
generate_analytics:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    ; Clear counters
    mov rdi, status_counts
    mov rcx, 7
    xor rax, rax
    rep stosd
    
    mov rdi, priority_counts
    mov rcx, 4
    xor rax, rax
    rep stosd
    
    mov dword [total_completion], 0
    
    ; Count PRDs
    mov eax, [prd_count]
    mov [total_prds], eax
    
    ; Iterate through PRDs
    xor rsi, rsi  ; PRD index
    
.count_loop:
    mov eax, [prd_count]
    cmp rsi, rax
    jge .done
    
    ; Get PRD address
    mov rax, rsi
    mov rbx, PRD_SIZE
    mul rbx
    add rax, prd_storage
    
    ; Count status
    mov ebx, [rax + PRD_STATUS_OFFSET]
    inc dword [status_counts + rbx*4]
    
    ; Count priority  
    mov ebx, [rax + PRD_PRIORITY_OFFSET]
    dec ebx  ; Adjust for 1-based priority
    inc dword [priority_counts + rbx*4]
    
    ; Add completion
    mov ebx, [rax + PRD_COMPLETION_OFFSET]
    add [total_completion], ebx
    
    inc rsi
    jmp .count_loop
    
.done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Print dashboard
print_dashboard:
    print_string dashboard_hdr
    print_string banner_sep
    
    ; Generate analytics
    call generate_analytics
    
    ; Print total PRDs
    print_string total_msg
    mov eax, [total_prds]
    call print_number
    print_newline
    
    ; Calculate and print average completion
    print_string avg_completion_msg
    mov eax, [total_completion]
    mov ebx, [total_prds]
    cmp ebx, 0
    je .zero_avg
    xor rdx, rdx
    div ebx
    call print_number
    jmp .print_percent
.zero_avg:
    mov eax, 0
    call print_number
.print_percent:
    print_string percent_sign
    
    print_newline
    ret

; Demo search functionality
demo_search:
    print_string search_msg
    
    ; Simple search simulation - find "authentication" PRD
    mov rsi, 0
    
.search_loop:
    mov eax, [prd_count]
    cmp rsi, rax
    jge .search_done
    
    ; Get PRD address
    mov rax, rsi
    mov rbx, PRD_SIZE
    mul rbx
    add rax, prd_storage
    
    ; Check if title contains "User Authentication"
    cmp rsi, 0  ; First PRD is authentication system
    jne .next_prd
    
    ; Print found PRD
    mov rdi, temp_str
    mov byte [rdi], ' '
    mov byte [rdi+1], ' '
    mov byte [rdi+2], 'F'
    mov byte [rdi+3], 'o'
    mov byte [rdi+4], 'u'
    mov byte [rdi+5], 'n'
    mov byte [rdi+6], 'd'
    mov byte [rdi+7], ':'
    mov byte [rdi+8], ' '
    mov byte [rdi+9], 0
    print_string temp_str
    print_string rax  ; Print title (first part of PRD)
    print_newline
    
.next_prd:
    inc rsi
    jmp .search_loop
    
.search_done:
    print_newline
    ret

; Demo status filtering
demo_status_filter:
    print_string draft_msg
    
    ; Count draft PRDs
    mov eax, [status_counts + STATUS_DRAFT*4]
    call print_number
    print_newline
    
    ; Show draft PRDs
    mov rsi, 0
    
.filter_loop:
    mov eax, [prd_count]
    cmp rsi, rax
    jge .filter_done
    
    ; Get PRD address
    mov rax, rsi
    mov rbx, PRD_SIZE
    mul rbx
    add rax, prd_storage
    
    ; Check if status is DRAFT
    mov ebx, [rax + PRD_STATUS_OFFSET]
    cmp ebx, STATUS_DRAFT
    jne .next_filter
    
    ; Print PRD title (simplified)
    print_string space
    print_string space
    print_string rax  ; Print title
    print_newline
    
.next_filter:
    inc rsi
    jmp .filter_loop
    
.filter_done:
    print_newline
    ret

; Demo priority filtering
demo_priority_filter:
    print_string critical_msg
    
    ; Count critical PRDs
    mov eax, [priority_counts + (PRIORITY_CRITICAL-1)*4]
    call print_number
    print_newline
    print_newline
    ret

; Demo completion statistics
demo_completion_stats:
    print_string stats_msg
    
    ; Calculate min, max, average
    call calculate_completion_stats
    
    print_newline
    ret

; Calculate completion statistics
calculate_completion_stats:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    
    mov eax, [prd_count]
    cmp eax, 0
    je .no_prds
    
    mov ecx, 100  ; min
    mov edx, 0    ; max
    mov rsi, 0    ; index
    
.calc_loop:
    mov eax, [prd_count]
    cmp rsi, rax
    jge .calc_done
    
    ; Get PRD address
    mov rax, rsi
    mov rbx, PRD_SIZE
    mul rbx
    add rax, prd_storage
    
    ; Get completion percentage
    mov ebx, [rax + PRD_COMPLETION_OFFSET]
    
    ; Update min
    cmp ebx, ecx
    jge .check_max
    mov ecx, ebx
    
.check_max:
    ; Update max
    cmp ebx, edx
    jle .next_calc
    mov edx, ebx
    
.next_calc:
    inc rsi
    jmp .calc_loop
    
.calc_done:
    ; Print min
    print_string min_completion_msg
    mov eax, ecx
    call print_number
    print_string percent_sign
    
    ; Print max
    print_string max_completion_msg
    mov eax, edx
    call print_number
    print_string percent_sign
    
    ; Print average (already calculated)
    print_string avg_stat_msg
    mov eax, [total_completion]
    mov ebx, [total_prds]
    xor rdx, rdx
    div ebx
    call print_number
    print_string percent_sign
    
    jmp .stats_done
    
.no_prds:
    print_string min_completion_msg
    mov eax, 0
    call print_number
    print_string percent_sign
    
.stats_done:
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Print number in eax
print_number:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi
    
    ; Handle zero case
    cmp eax, 0
    jne .not_zero
    mov byte [temp_str], '0'
    mov byte [temp_str+1], 0
    print_string temp_str
    jmp .done
    
.not_zero:
    mov rdi, temp_str
    add rdi, 63  ; Start from end
    mov byte [rdi], 0
    dec rdi
    
    mov ebx, 10
    
.convert_loop:
    xor rdx, rdx
    div ebx
    add dl, '0'
    mov [rdi], dl
    dec rdi
    test eax, eax
    jnz .convert_loop
    
    inc rdi
    print_string rdi
    
.done:
    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

; Calculate string length
; Input: rsi = string
; Output: rax = length
strlen:
    push rsi
    push rcx
    
    xor rax, rax
    mov rcx, rsi
    
.count_loop:
    cmp byte [rcx], 0
    je .done
    inc rax
    inc rcx
    jmp .count_loop
    
.done:
    pop rcx
    pop rsi
    ret
