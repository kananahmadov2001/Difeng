  .org 0 		; Program starts at address 0
	la r31,TOP	; r31 holds the loop address
	la r30,PINS 	; r30 points to the address of the PINS module
	la r29,LOOP0 	; Polling loops
	la r28,LOOP1
	la r27,LOOP2
	la r26,LOOP3
	la r25,LOOP4
	la r24,LOOP5
	la r23,LOOP6
	la r22,LOOP7
	la r21, ROOTS 	; Roots

	la r1,1		; Initialize for 4,194,304-491,520x+17,920x^2-240x^3+x^4
	shl r1,r1,22
	lar r2,-473839
	la r3,34414
	la r4,-1404
	la r5,24
	
	la r6,0 	; Initialize for x
	la r7,4		; Initialize for RootCounter
	la r8,4096	; SRAM memory address 
	la r9,-4	; pins address

;-------------------------------------------------------------------------


TOP: 	add r1,r1,r2 	; Update DE
	add r2,r2,r3
	add r3,r3,r4
	add r4,r4,r5
	addi r6,r6,1	; incrementing the x by 1
	brzr r21,r1	; if f(x)=0, then root is found 
	brnz r31,r7

;-------------------------------------------------------------------------


ROOTS:		st r6,0(r8)	; storing x in SRAM
		addi r7,r7,-1	; decreasing the counter
		addi r8,r8,4
		brnz r31,r7

;-------------------------------------------------------------------------


LOOP0: 	ld r20,0(r30) 	; Poll for falling edge
	brnz r29,r20

LOOP1: 	ld r20,0(r30) 	; Poll for rising edge
	brzr r28,r20
	ld r10,4096	; loading the SRAM into Register
	st r10,0(r30)

LOOP2: ld r20,0(r30) 	; Poll for falling edge
	brnz r27,r20

LOOP3: 	ld r20,0(r30) 	; Poll for rising edge
	brzr r26,r20
	ld r10,4100	; loading the SRAM into Register
	st r10,0(r30)

LOOP4: ld r20,0(r30) 	; Poll for falling edge   
	brnz r25,r20

LOOP5: ld r20,0(r30) 	; Poll for rising edge  
	brzr r24,r20
	ld r10,4104     ; loading the SRAM into Register
	st r10,0(r30)

LOOP6: ld r20,0(r30) 	; Poll for falling edge   
	brnz r23,r20

LOOP7: ld r20,0(r30) 	; Poll for rising edge  
	brzr r22,r20
	ld r10,4108    	; loading the SRAM into Register
	st r10,0(r30)

	br r29 		; Loop forever
	stop 		; This instruction is never executed!
	.org -4 	; The pins module is located at address -4

;-------------------------------------------------------------------------

PINS: .dw 1
