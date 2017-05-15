; Advanced Computer Architecture Laboratory 1
; smooth.s
; Optimized code for 64-bit MIPS Architecture

				.data											; format: 'name:	storage_type	value(s)
N_COEFFS:		.word 3											; single integer variable
coeff: 			.double 0.5, 1.0, 0.5							; array of double variables
N_SAMPLES: 		.word 5
sample: 		.double 1.0, 2.0, 1.0, 2.0, 1.0
result: 		.double 0.0, 0.0, 0.0, 0.0, 0.0
INV:			.double 1.0

				.text
main:
				lw		$t0, N_SAMPLES($zero)					; load content of RAM location into $t0: $t0 = N_SAMPLES			$t0 = R8
				mtc1 	$zero, F1								; $f1(norm) = 0.0
				mtc1	$zero, F10								; zero FP register
				slti	$t1, $t0, 3								; set $t1 True, if $t0 < 3 (immediate value) : N_SAMPLES < 3 ?		$t1 = R9
				;slti basically adds 1
				daddi	$t3, $zero, 0							; NORMLOOP															$t3 = R11
				daddi	$t4, $zero, 3							; NORMLOOP, $t4 = N_COEFFS											$t4 = R12
				and		$t5, $t5, $zero							; set an integer register to zero to use for aligning				$t5 = R13
				l.d		F2, coeff($zero)						; load double, $f2 = coeff[0]
				;beq		$t1, $zero, normer					; $t1 == 0 => !(N_SAMPLES > 2)
				bne		$t1, $zero, exit						; in order not to have the branch stall we just continue with normer after decoding this
				;;;;;;OR I CAN JUST ADD ABSOLUTE VALUES OF coeff TO GET NORM INSTEAD OF FOLLOWING BLOCKS
				;;;;;;http://stackoverflow.com/questions/2312543/absolute-value-in-mips branchless variant looks good
normer:			
				;c.lt.d	F1, F2									; set FP flag if norm < coeff[i]
				c.le.d	F10, F2									; set FP flag if 0 =< coeff[i]
				beq		$t3, $t4, setresult						; a more elegant method is needed since we check condition 3 times..
				nop												; PROGRAM WAS CRASHING BECAUSE OF JUMPS
				bc1t	coeffT									; coeff[i] > 0; bc1f imm: branch to address if FP flag is TRUE       
				bc1f	coeffF									; coeff[i] =<0; bc1t imm: branch to address if FP flag is FALSE 
				
				
coeffF:															; coeff[0] =< 0, so : norm += -coeff[0] => norm = -coeff[0]
				sub.d	F1, F1, F2								; norm = norm - coeff[0]
				l.d		F2, coeff($t5)
				;daddi	$t5, $zero, 8							; next coefficient
				daddi	$t5, $t5, 8								; next coefficient
				daddi	$t3, $t3, 1								; NORMLOOP
				j 		normer									; jump back to normer
				nop
				
				
coeffT:															; coeff[0] > 0, so : norm += coeff[0] => norm = coeff[0]
				add.d	F1, F1, F2								; norm = norm + coeff[0]
				l.d		F2, coeff($t5)
				;daddi	$t5, $zero, 8							; next coefficient
				daddi	$t5, $t5, 8								; next coefficient
				daddi	$t3, $t3, 1								; NORMLOOP t3 = t3 + 1;
				j		normer
				nop
setresult:		
				l.d 	F2, INV($zero)
				div.d	F1,	F2, F1 								; F1 = 1 / norm
				l.d		F3, sample($zero)						; load sample[0] to F2
				and		$t5, $t5, $zero							; reset register to zero, to be used as loop counter i
				s.d		F3, result($zero)						; store result[0] = sample[0]
				l.d		F4, coeff($zero)						; coeff[0]
				l.d		F5, coeff+8($zero)						; coeff[1]
				l.d		F6, coeff+16($zero)						; coeff[2]
				andi	$t2, $t2, 0								; Loop Counter
forloop:
				l.d		F10, sample($t5)						; F10 = sample[i-1]
				nop												; to avoid Load Use Hazard
				mul.d	F7, F10, F4								; temp1 = sample[i-1] * coeff[0]
				daddi	$t5, $t5, 8
				l.d		F11, sample($t5)						; F10 = sample[i]
				nop
				mul.d   F8, F11, F5								; temp2 = sample[i] * coeff[1]
				daddi	$t5, $t5, 8
				l.d		F12, sample($t5)						; F11 = sample[i+1]
				nop
				mul.d	F9, F12, F6								; temp3 = sample[i+1] * coeff[2]
				add.d	F13, F7, F8								; temp = temp1 + temp2
				nop
				daddi	$t2, $t2, 1									; Loop Counter
				add.d 	F13, F13, F9							; temp = temp + temp3
				lw		$t7, N_SAMPLES($zero)					; FOR LOOP n-1
				and		$t6, $zero, $zero						; to use as result index
				mul.d	F13, F13, F1							; temp = temp * 1 / norm
				; $t0 contains N_SAMPLES
				daddi	$t6, $t6, 8
				;daddi	$t7, $t7, -1
				nop
				s.d		F13, result($t6)						; result[i] = temp[i]
				bne		$t2, $t0, forloop
				
				daddi 	$t6, $t6, 8
				l.d		F14, sample($t6)
				nop
				s.d		F14, result($t6)
				
				
				;daddi	$t1, $zero, 1							; bitwise or to get as high
				;ori		$t1, $t1, 1
				
				;mtc1	$t1, F1								; F11 = 1
				;nop
				;nop
				;nop
				;div.d 	F1, F11, F1
				;s.d		F10, result($zero)						; result is set to zero for convenience
				;l.d		F2, sample($zero)						; load sample[0] to F2
				;and		$t5, $t5, $zero							; reset register to zero, to be used as loop counter i
				;s.d		F2, result($zero)						; store result[0] = sample[0]

				;mtc1	$t1, F11								; F11 = 1

exit:
