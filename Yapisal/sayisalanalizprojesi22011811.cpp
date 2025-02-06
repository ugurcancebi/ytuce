#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define TOL 1e-6
void matrisYazdir(float** matrix,int size)
{
	int i,j;
	printf("\nMatris:\n");
	for (i = 0; i<size; i++) 
	{
        for (j = 0; j<size; j++) 
		{
            printf("%f ", matrix[i][j]);
        }
        printf("\n");
    }
}

void inverse(float **matrix, float **inv, int N);

void GaussSeidel()
{
	float A[3][4];
    float x[3] = {0, 0, 0};//ilk tahminler
    int iter,iterasyonlar,i,j;

    printf("\n3 denklemin 3 katsayilarini ve sonuclarini sirasi ile giriniz:\n");
    for (i=0; i < 3; i++)
	{
        for (j=0; j < 4; j++) 
		{
            scanf("%f", &A[i][j]);
        }
    }

    printf("\nIterasyon sayisini giriniz: ");
    scanf("%d", &iterasyonlar);
	float x_guncel[3], toplam;
    
    for (i = 0; i < 3; i++) 
	{
        x_guncel[i] = x[i];
    }

    for (iter = 0; iter < iterasyonlar; iter++) 
	{
        for (i = 0; i < 3; i++) 
		{
            toplam = A[i][3];
            for (j = 0; j < 3; j++) 
			{
                if (j != i) 
				{
                    toplam -= A[i][j]*x_guncel[j];
                }
            }
            x_guncel[i] = toplam/A[i][i];
        }

        float error = 0.0;
        for (i = 0; i < 3; i++) 
		{
            error = error + fabs(x_new[i] - x[i]);
            x[i] = x_guncel[i];
        }

        if (error<TOL) 
		{
            return;
        }
        
        printf("Cozum:\n");
    	for (i=0; i<3; i++) 
		{
        	printf("x[%d] = %f\n", i, x[i]);
    	}
    	
    }
	
	return;
}

void matrisTersi()
{
	int N,i,j;
	float **matrix,**inv;
	float determinant;
	printf("\nNxN'lik matrisin boyutunu giriniz: ");
	scanf("%d",&N);
	matrix = (float**)malloc(N*sizeof(float*));
	if (matrix == NULL) 
	{
        printf("Memory allocation failed!\n");
        return;
    }
	float *data = (float*)malloc(N*N*sizeof(int));
	if (data == NULL) 
	{
        printf("Memory allocation failed!\n");
        free(matrix);
        return;
    }
	for (i = 0; i < N; i++) 
	{
        matrix[i] = data + i * N;
    }
    
    inv = (float **)malloc(N * sizeof(float *));
    for (i = 0; i < N; i++) 
	{
        inv[i] = (float *)malloc(N * sizeof(float));
    }
    
	printf("\nMatrisin elemanlarini giriniz: ");
	for(i=0;i<N;i++)
	{
		for(j=0;j<N;j++)
		{
			scanf("%f",&matrix[i][j]);
		}
	}
	
	inverse(matrix,inv,N);
	printf("Matrisin tersi:\n");
	matrisYazdir(inv,N);
	for (i = 0; i < N; i++) {
        free(matrix[i]);
        free(inv[i]);
    }
    free(matrix);
    free(inv);
	
}

void matrisCofactor(float **matrix, float **temp, int p, int q, int N) 
{
    int i = 0, j = 0;
    int sira,sutun;
    for (sira = 0; sira< N; sira++) 
	{
        for (sutun = 0; sutun < N; sutun++) 
		{
            if (sira != p && sutun != q) 
			{
                temp[i][j++] = matrix[sira][sutun];
                if (j == N - 1) 
				{
                    j = 0;
                    i++;
                }
            }
        }
    }
}

float determinant(float **matrix, int N) 
{
	int i,f;
    if (N == 1)
        return matrix[0][0];

    float det = 0;
    float **temp = (float **)malloc(N * sizeof(float *));
    for ( i = 0; i < N; i++) 
	{
        temp[i] = (float *)malloc(N * sizeof(float));
    }

    int sign = 1;
    for (f = 0; f < N; f++) 
	{
        matrisCofactor(matrix, temp, 0, f, N);
        det = det+sign*matrix[0][f]*determinant(temp, N - 1);
        sign = -sign;
    }

    for (i = 0; i < N; i++) 
	{
        free(temp[i]);
    }
    free(temp);

    return det;
}

void matrisEk(float **matrix, float **adj, int N) {
	int i,j;
    if (N == 1) 
	{
        adj[0][0] = 1;
        return;
    }

    int sign = 1;
    float **temp = (float **)malloc((N - 1) * sizeof(float *));
    for (i = 0; i < N - 1; i++) 
	{
        temp[i] = (float *)malloc((N - 1) * sizeof(float));
    }

    for (i = 0; i < N; i++) 
	{
        for (j = 0; j < N; j++) 
		{
            matrisCofactor(matrix, temp, i, j, N);
            sign = ((i + j) % 2 == 0) ? 1 : -1;
            adj[j][i] = sign * determinant(temp, N - 1);
        }
    }

    for (i = 0; i < N - 1; i++) 
	{
        free(temp[i]);
    }
    free(temp);
}

void inverse(float **matrix, float **inv, int N) 
{
	int i,j;
    float det = determinant(matrix, N);
    if (det == 0) 
	{
        printf("Matrisin tersi yok!\n");
        return;
    }

    float **adj = (float **)malloc(N * sizeof(float *));
    for (i = 0; i < N; i++) 
	{
        adj[i] = (float *)malloc(N * sizeof(float));
    }

    matrisEk(matrix, adj, N);

    for (i = 0; i < N; i++)
	{
        for (j = 0; j < N; j++) 
		{
            inv[i][j] = adj[i][j] / det;
        }
    }

    for (i = 0; i < N; i++) 
	{
        free(adj[i]);
    }
    free(adj);
}

int main()
{
	int secenek=1;
	
	do
	{
		printf("\n1. NxN'lik bir matrisin tersi\n");
		printf("\n2. Gauss Seidel\n");
		printf("\nYapmak istediginiz islemi seciniz: ");
		scanf("%d", &secenek);
	}while((secenek<0)||(secenek>2));
	
	if(secenek == 1)
	{
		matrisTersi();
	}
	else if(secenek == 2)
	{
		GaussSeidel();
	}
	return 0;	
}

