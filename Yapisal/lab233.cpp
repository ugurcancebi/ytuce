#include <stdio.h>
#include<stdlib.h>
#include <time.h>
#define MAX 50

char son='E';
int N=0,i=0,j=0,k=0, altsira, oyuncup1, oyuncup2,temp;
int dizi[MAX][MAX];

int main()
{
	do{
		oyuncup1, oyuncup2=0;
		srand(time(NULL));
		printf("\nKare dizinin bir boyut uzunlugunu giriniz:");
		scanf("%d", &N);
		printf("\n");
		for(i=0;i<N;i++)
		{
			for(j=0;j<N;j++)
			{
				dizi[i][j] = rand()%(N*N+1)+1;
				printf("%d ",dizi[i][j]);
			}
			printf("\n");
		}
		printf("\n");
		for(k=0; k<5;k++){
			for(i=0;i<N;i++)
			{
				for(j=0;j<N;j++)
				{
					temp = dizi[i][j];
					dizi[i][j] = dizi [j][i];
					dizi[j][i] =temp;
				}
			}
			for(i=0;i<N;i++)
			{
				for(j=0;j<N/2;j++)
				{
					temp = dizi[i][j];
					dizi[i][j] = dizi [N-j-1][i];
					dizi[N-j-1][i] =temp;
				}
			}
			for(i=0;i<N;i++)
			{
				for(j=0;j<N;j++)
				{
					printf("%d ",dizi[i][j]);
				}
				printf("\n");
			}
			
			for(altsira=0;altsira<N;altsira++)
			{
				if(k%2==0)
				{
					oyuncup1=oyuncup1+dizi[N-1][altsira];
				}
				else
				{
					oyuncup2=oyuncup2+dizi[N-1][altsira];
				}
			}
			printf("\nOyuncu 1 %d, Oyuncu 2 %d \n",oyuncup1,oyuncup2);
			
		}
		
		printf("\nOyuncu 1'in puani = %d", oyuncup1);
		printf("\nOyuncu 2'nin puani = %d", oyuncup2);
		if(oyuncup1>oyuncup2)
		{
			printf("\nOyuncu 1 kazandi");
		}
		else if(oyuncup1==oyuncup2)
		{
			printf("\nBerabere");
		}
		else
		{
			printf("\nOyuncu 2 kazandi");
		}
		printf("\nOyunu yine oynamak ister misiniz?");
		scanf("%c",son);
	}while(son!=('E'||'e'));
return 0;
}
