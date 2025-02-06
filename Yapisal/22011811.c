#include <stdio.h>
#define UZN 50

char dizi[UZN],son='a';
int i=0,j=0, uzunluk=0,temp;

int main()
{
	do{
		printf("Lutfen bir kelime giriniz: \n");
		scanf("%s",dizi);
		printf("\nKelime:%s",dizi);
		do{
			uzunluk++;
			i++;
		}while(dizi[i]!='\0');
		i=1;
		do{
			j=i;
			printf("\n%d.Adim: ",i);
			do{
				printf("%c",dizi[j]);
				j++;
			}while(j<uzunluk);/*
			temp=i;
			do
			{
				printf("%c",dizi[--temp]);
			}while(temp<uzunluk-j);*/
			i=i+1;			
		}while(i<=uzunluk);
		printf("\nYeni bir kelime girmek istiyor musunuz?");
		scanf("%c",son);
	}while(son!=('E'||'e'));
		
	
}
