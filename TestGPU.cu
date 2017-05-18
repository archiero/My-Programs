/* To compile: nvcc TestGPU.cu -o temp -lcudart -run
*/
#include <sys/time.h>
#include <stdio.h>
#include <math.h>

#define N (unsigned int)(1000000000)
unsigned char *A_CPU, *B_CPU, *C_CPU; 

unsigned char *A_GPU, *B_GPU, *C_GPU; 

dim3 dimBlock; 
dim3 dimGrid;

void AllocateMemory()
{	
	cudaMalloc(&A_GPU,N*sizeof(unsigned char));
	cudaMalloc(&B_GPU,N*sizeof(unsigned char));
	cudaMalloc(&C_GPU,N*sizeof(unsigned char));

	A_CPU = (unsigned char*)malloc(N*sizeof(unsigned char));
	B_CPU = (unsigned char*)malloc(N*sizeof(unsigned char));
	C_CPU = (unsigned char*)malloc(N*sizeof(unsigned char));
}

void Innitialize()
{
	dimBlock.x = 1024;
	int blocks = (N+1023)/1024;
	dimGrid.x = (int)pow(blocks,1.0/3.0) + 1;
	dimGrid.y = (int)pow(blocks,1.0/3.0) + 1;
	dimGrid.z = (int)pow(blocks,1.0/3.0) + 1; 
	int i;
	
	for(i = 0; i < N; i++)
	{		
		A_CPU[i] = (unsigned char)1;	
		B_CPU[i] = (unsigned char)1;
		C_CPU[i] = (unsigned char)0;
	}
}

unsigned long int Additup(unsigned char *C_CPU)
{
	unsigned long int temp = 0;
	for(int i =0; i<N; i++)
	{
		temp += C_CPU[i];
	}
	return(temp);
}

void CleanUp(unsigned char *A_CPU,unsigned char*B_CPU,unsigned char *C_CPU,unsigned char*A_GPU,unsigned char *B_GPU,unsigned char *C_GPU)  //free
{
	free(A_CPU); free(B_CPU); free(C_CPU);
	cudaFree(A_GPU); cudaFree(B_GPU); cudaFree(C_GPU);
}

__global__ void Addition(unsigned char *A, unsigned char *B, unsigned char *C)
{

	unsigned int id = threadIdx.x + blockDim.x*blockIdx.x + blockDim.x*gridDim.x*blockIdx.y +blockDim.x*gridDim.x*blockDim.y*gridDim.y*blockIdx.z;
	if(id < N)
	{
		C[id] = A[id]*B[id];
	}
}

int main()
{
	unsigned long int total;
	int i;
	timeval start, end;
	cudaError_t err;
	
	AllocateMemory();

	Innitialize();
	
	gettimeofday(&start, NULL);

	cudaMemcpyAsync(A_GPU, A_CPU, N*sizeof(unsigned char), cudaMemcpyHostToDevice);
	cudaMemcpyAsync(B_GPU, B_CPU, N*sizeof(unsigned char), cudaMemcpyHostToDevice);
		
	Addition<<<dimGrid,dimBlock>>>(A_GPU, B_GPU, C_GPU);
		
	cudaMemcpyAsync(C_CPU, C_GPU, N*sizeof(unsigned char), cudaMemcpyDeviceToHost);
	total = Additup(C_CPU);

	gettimeofday(&end, NULL);

	float time = (end.tv_sec * 1000000 + end.tv_usec) - (start.tv_sec * 1000000 + start.tv_usec);
	
	printf("Time in milliseconds= %.15f\n", (time/1000.0));	
	
	for(i = 0; i < N; i++)		
	{		
		//clearprintf("C[%d] = %d", i, C_CPU[i]);
	}
	int blocks = (N+1023)/1024;

	printf("Here she is %d %li %d\n",(int)pow(blocks,1.0/3.0) + 1 ,total, N);
	
	CleanUp(A_CPU,B_CPU,C_CPU,A_GPU,B_GPU,C_GPU);	
	
	return(0);
}
