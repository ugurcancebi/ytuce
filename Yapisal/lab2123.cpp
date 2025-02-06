#include <stdio.h>
#include<stdlib.h>

char son='E';
int N=0,i=0,j=0, oyuncup1, oyuncup2, uzunluk=0,temp;
int dizi[50][50];

int main()
{
	int a[10]={0};
	int i,j, N=3;
	for(i=1;i<=N;i++)
	{
		for(j=1;j<=N;j++)
		{
			if(i%j==0)
			{
				a[j-1]=((a[j-1]%2)==0);
			}
			
		}
		for(j=0;j<N;j++)
		{
			printf("%d",a[j]);
		}
		printf("\n");
	}
	
	
	
	
	return 0;
}
