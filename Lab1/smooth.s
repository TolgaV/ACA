; Advanced Computer Architecture Laboratory 1
; smooth.s
; Optimized code for 64-bit MIPS Architecture

				.data											; format: 'name:	storage_type	value(s)
N_COEFFS:		.word 3											; single integer variable
coeff: 			.double 0.5, 1.0, 0.5							; array of double variables
N_SAMPLES: 		.word 5
sample: 		.double 1.0, 2.0, 1.0, 2.0, 1.0
result: 		.double 0.0, 0.0, 0.0, 0.0, 0.0

				.text
main:
				lw		$t0, N_SAMPLES							; load content of RAM location into $t0: $t0 = N_SAMPLES
				slti	$t1, $t0, #3							; set $t1 True, if $t0 < 3 (immediate value) : N_SAMPLES < 3 ?
				;mtc1	$zero, $f0								; move data from integer reg to FP reg, we might need a 0 FP reg later
				mtc1 	$zero, $f1								; $f1(norm) = 0.0				
				li		$t3, #0									; NORMLOOP
				li		$t4, #3									; NORMLOOP
				and		$t5, $t5, $zero							; set an integer register to zero to use for aligning
				l.d		$f2, coeff($zero)						; load double, $f2 = coeff[0]
				beq		$t1, $zero, normer						; $t1 == 0 => !(N_SAMPLES > 2)
				li      $v0, 10             					; terminate program run and
				syscall                     					; Exit end or jump to print

normer:			
				c.lt.d	$f1, $f2								; set FP flag if norm < coeff[i]
				beq		$t3, $t4, setresult						; a more elegant method is needed since we check condition 3 times..
				bc1t	coeff1t									; bc1f imm: branch to address if FP flag is FALSE       
				bc1f	coeff1f									; bc1t imm: branch to address if FP flag is TRUE 
				
				
coeffF:															; coeff[0] =< 0, so : norm += -coeff[0] => norm = -coeff[0]
				sub.d	$f1, $f1, $f2							; norm = norm - coeff[0]
				l.d		$f2, coeff($t5)
				daddi	$t5, $zero, #8							; next coefficient
				daddi	$t3, #1									; NORMLOOP
				j 		normer									; jump back to normer
				
				
coeffT:															; coeff[0] > 0, so : norm += coeff[0] => norm = coeff[0]
				add.d	$f1, $f1, $f2							; norm = norm + coeff[0]
				l.d		$f2, coeff($t5)
				daddi	$t5, $zero, #8							; next coefficient
				daddi	$t3, #1									; NORMLOOP
				j		normer									
				
setresult:
				li		$t3, #1									; for i = 1
				l.d		$f3, sample($zero)						; unrolled parts of the loop
				s.d		$f3, result($zero)						; result[0] = sample[0]
				lw		$t6, N_SAMPLES($zero)					; t6 = n for loop
				; in for loop sth like i = 16, (offset of 2) i = i + 8 may work
				; increment the sample pointer in loop and branch exit when next incrementation = address of N_SAMPLES
				bneq 	N_SAMPLES, $t3, forloop
				
				;??? l.d	$f5, sample+N_SAMPLE*8($zero)? for result[n-1] = sample[n-1]
				

				

