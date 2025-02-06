#include <stdio.h>
#include<stdlib.h>
#define MAX 50

char son='E';
int N=0,i=0,j=0, oyuncup1, oyuncup2, uzunluk=0,temp;
int dizi[50][50];

int main()
{
	do{
		printf("\nKare dizinin bir boyut uzunlugunu giriniz:")
		scanf("%d", N);
		for(i=0;i<N;i++)
		{
			for(j=0;j<N;j++)
			{
				dizi[i][j] = rand()%(N*N)+1;
				printf("%d ",dizi[i][j]);
			}
			printf("\n");
		}
		rand();
		printf("\nOyunu yine oynamak ister misiniz?");
		scanf("%c",son);
	}while(son!=('E'||'e'));
return 0;
}
