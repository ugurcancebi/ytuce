#include <stdio.h>
#include<stdlib.h>
#define MAX 50


int main()
{
	int N,i,j,head;
	int matris[MAX][3];
	printf("Is sayisini giriniz: \n");
	scanf("%d",&N);
	
	iskodlari(N,matris);
	printf("\n");
	issureleri(N,matris);
	do 
	{
        printf("Head sayisini giriniz: ");
        scanf("%d", &head);
    } while ((head <= N-1)&&(head>0));
    
    printf("Link siralarini giriniz: ");
    for(i=0;i<N;i++)
    {
    	scanf("%d", &matris[i][2]);
	}
	printf("\n");
    headfonk(N, matris, head);
    
	
}

void issureleri(int N, int matris[MAX][3])
{
	int num,i;
	for(i=0;i<N;i++)
	{
		do 
		{
        	printf("\n%c isinin suresini giriniz: ", &matris[N][0]);
        	scanf("%d", &num);
    	} while (num > 0);
    	matris[i][1]=num;
	}
}

void iskodlari(int N, int matris[MAX][3])
{
	int i,j;
	int kabuledilmez;
	char iskodu;
	
	for(i=0;i<N;i++)
	{
		do
		{
			kabuledilmez=0;
			printf("\nIs kodunu giriniz: ");
			scanf("%c",&iskodu);
			for(j=0;j<i;j++)
			{
				if (matris[(int)(j)][0]==(int)(iskodu)) kabuledilmez=1;
			}
		}while  (kabuledilmez!=1);
		matris[i][0]=iskodu;
	}
}

void headfonk(int N, int matris[MAX][3], int head)
{
	int i,j,limit,baslangic;
	baslangic=head;
	for(i=0;i<N;i++)
	{
		for(j=0;j<matris[baslangic][1];j++)
		{
			printf("%c ",matris[baslangic][0]);
		}
		baslangic=matris[baslangic][2];
	}
			
}





