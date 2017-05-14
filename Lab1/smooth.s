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
				lw		$t0, N_SAMPLES($zero)					; load content of RAM location into $t0: $t0 = N_SAMPLES			$t0 = R8
				mtc1 	$zero, F1								; $f1(norm) = 0.0
				mtc1	$zero, F10								; zero FP register
				slti	$t1, $t0, 3								; set $t1 True, if $t0 < 3 (immediate value) : N_SAMPLES < 3 ?		$t1 = R9
				;slti basically adds 1
				daddi	$t3, $zero, 0							; NORMLOOP															$t3 = R11
				daddi	$t4, $zero, 3							; NORMLOOP															$t4 = R12
				and		$t5, $t5, $zero							; set an integer register to zero to use for aligning				$t5 = R13
				l.d		F2, coeff($zero)						; load double, $f2 = coeff[0]
				;beq		$t1, $zero, normer					; $t1 == 0 => !(N_SAMPLES > 2)
				bne		$t1, $zero, exit						; in order not to have the branch stall we just continue with normer after decoding this
				
normer:			
				;c.lt.d	F1, F2									; set FP flag if norm < coeff[i]
				c.le.d	F10, F2									; set FP flag if 0 =< coeff[i]
				beq		$t3, $t4, setresult						; a more elegant method is needed since we check condition 3 times..
				bc1t	coeffT									; coeff[i] > 0; bc1f imm: branch to address if FP flag is TRUE       
				bc1f	coeffF									; coeff[i] =<0; bc1t imm: branch to address if FP flag is FALSE 
				
				
coeffF:															; coeff[0] =< 0, so : norm += -coeff[0] => norm = -coeff[0]
				sub.d	F1, F1, F2								; norm = norm - coeff[0]
				l.d		F2, coeff($t5)
				;daddi	$t5, $zero, 8							; next coefficient
				daddi	$t5, $t5, 8							; next coefficient
				daddi	$t3, $t3, 1								; NORMLOOP
				j 		normer									; jump back to normer
				nop
				
				
coeffT:															; coeff[0] > 0, so : norm += coeff[0] => norm = coeff[0]
				add.d	F1, F1, F2								; norm = norm + coeff[0]
				l.d		F2, coeff($t5)
				;daddi	$t5, $zero, 8							; next coefficient
				daddi	$t5, $t5, 8							; next coefficient
				daddi	$t3, $t3, 1								; NORMLOOP t3 = t3 + 1;
				j		normer
				nop
setresult:		

exit:
