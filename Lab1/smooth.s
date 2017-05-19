; Advanced Computer Architecture Laboratory 1
; Pablo-Andres Ardila-Bernal 387484, Levente Zsolt, Pap 387522  Tolga, Varol  386962
; smooth.s for MIPS64

				.data											; format: 'name:	storage_type	value(s)
N_COEFFS: 		.word 3
coeff: 			.double 0.5 ,1.0 ,0.5
N_SAMPLES: 		.word 10
sample: 		.double 1 ,2 ,3 ,4 ,5 ,6 ,7 ,8 ,9 ,10
result: 		.double 0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0

INV:			.double 1.0

				.text
main:
				lw		$t0, N_SAMPLES($zero)					; load content of RAM location into $t0: $t0 = N_SAMPLES			$t0 = R8
				mtc1 	$zero, F1								; $f1(norm) = 0.0
				mtc1	$zero, F10								; zero FP register
				slti	$t1, $t0, 3								; set $t1 True, if $t0 < 3 (immediate value) : N_SAMPLES < 3 ?		$t1 = R9
				daddi	$t3, $zero, 0							; NORMLOOP															$t3 = R11
				daddi	$t4, $zero, 3							; NORMLOOP, $t4 = N_COEFFS											$t4 = R12
				and		$t5, $t5, $zero							; set an integer register to zero to use for aligning				$t5 = R13
				l.d		F2, coeff($zero)						; load double, $f2 = coeff[0]
				bne		$t1, $zero, exit						; in order not to have the branch stall we just continue with normer after decoding this
normer:			
				c.le.d	F10, F2									; set FP flag if 0 =< coeff[i]
				beq		$t3, $t4, setresult						; a more elegant method is needed since we check condition 3 times..
				nop												; PROGRAM WAS CRASHING BECAUSE OF JUMPS
				bc1t	coeffT									; coeff[i] > 0; bc1f imm: branch to address if FP flag is TRUE       
				bc1f	coeffF									; coeff[i] =<0; bc1t imm: branch to address if FP flag is FALSE 
coeffF:															; coeff[0] =< 0, so : norm += -coeff[0] => norm = -coeff[0]
				sub.d	F1, F1, F2								; norm = norm - coeff[0]
				l.d		F2, coeff($t5)
				daddi	$t5, $t5, 8								; next coefficient
				daddi	$t3, $t3, 1								; NORMLOOP
				j 		normer									; jump back to normer
				nop
coeffT:															; coeff[0] > 0, so : norm += coeff[0] => norm = coeff[0]
				add.d	F1, F1, F2								; norm = norm + coeff[0]
				l.d		F2, coeff($t5)
				daddi	$t5, $t5, 8								; next coefficient
				daddi	$t3, $t3, 1								; NORMLOOP t3 = t3 + 1;
				j		normer
				nop
setresult:		
				l.d 	F2, INV($zero)
				div.d	F1,	F2, F1 								; F1 = 1 / norm
				l.d		F3, sample($zero)						; load sample[0] to F3
				and		$t5, $t5, $zero							; reset register to zero, to be used as index
				s.d		F3, result($zero)						; store result[0] = sample[0]
				l.d		F4, coeff($zero)						; coeff[0]
				l.d		F5, coeff+8($zero)						; coeff[1]
				l.d		F6, coeff+16($zero)						; coeff[2]
				and		$t2, $t2, $zero							; Loop Counter
				or		$t8, $zero, $t0							;for reducing index
				daddi	$t8, $t8, -1							;for reducing index
forloop:
				l.d		F10, sample($t5)						; F10 = sample[i-1]	in this case sample[i-1] starts with sample[0]
				nop												; to avoid Load Use Hazard
				mul.d	F7, F10, F4								; temp1 = sample[i-1] * coeff[0]
				l.d		F11, sample+8($t5)						; F10 = sample[i]
				nop
				mul.d   F8, F11, F5								; temp2 = sample[i] * coeff[1]
				l.d		F12, sample+16($t5)						; F11 = sample[i+1]
				nop
				mul.d	F9, F12, F6								; temp3 = sample[i+1] * coeff[2]
				add.d	F13, F7, F8								; temp = temp1 + temp2
				daddi	$t2, $t2, 1									; Loop Counter
				add.d 	F13, F13, F9							; temp = temp + temp3
				lw		$t7, N_SAMPLES($zero)					; FOR LOOP n-1
				mul.d	F13, F13, F1							; temp = temp * 1 / norm
				daddi	$t5, $t5, 8
				beq		$t2, $t8, finish
nop
				s.d		F13, result($t5)						; result[i] = temp[i]
				bne		$t2, $t8, forloop	;for reducing index
finish:				
				l.d		F14, sample($t5)
				nop
				s.d		F14, result($t5)
exit:
				nop
				halt