#include <stdio.h>

#define N_SAMPLES	5
#define N_COEFFS	3

double	sample[N_SAMPLES] = {1, 2, 1, 2, 1};
double	coeff[N_COEFFS]= {0.5, 1, 0.5};
double	result[N_SAMPLES];

void smooth(double sample[], double coeff[], double result[], int n)
{
	int i;
	double norm=0.0;

	norm+= coeff[0]>0 ? coeff[0] : -coeff[0];
	norm+= coeff[1]>0 ? coeff[1] : -coeff[1];
	norm+= coeff[2]>0 ? coeff[2] : -coeff[2];

	result[0] = sample[0];
	for (i=2; i<n-1; i++){
		result[i] = 0.0;
		result[i] += sample[i-1]*coeff[0];				//some sort of windowing
		result[i] += sample[i]*coeff[1];
		result[i] += sample[i+1]*coeff[2];
		result[i] /= norm;
	}
	result[1] = 0.0;									//unrolled for 1 less branch
	result[1] += sample[0]*coeff[0];
	result[1] += sample[1]*coeff[1];
	result[1] += sample[2]*coeff[2];
	result[1] /= norm;
	result[n-1] = sample[n-1];
}

int main(int argc, char *arvg[])
{
	int i;

	if (N_SAMPLES>=3)									//N_SAMPLES is always > 3
		smooth(sample, coeff, result, N_SAMPLES);		//so n is always > 3

	for (i=0; i<N_SAMPLES; i++)
		printf("%f\n", result[i]);
}
