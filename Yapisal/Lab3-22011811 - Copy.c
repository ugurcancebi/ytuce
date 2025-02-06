#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct {
	char urunAdi[10];
	int urunKodu;
	float birimFiyat;
	float kiloFiyat;
}Urun;

void listele(Urun urunler[])
{
	int i;
	for (i = 0; i < 6; ++i) 
	{
        printf("%d \t %s \t %f \t %f \t", urunler[i].urunKodu, urunler[i].urunAdi,urunler[i].birimFiyat,urunler[i].kiloFiyat);
        printf("\n");
    }
}

float alisverisTutari(Urun urunler[], int urunKodu, int alisTipi, int miktarkilo)
{
	float toplam;
	if (alisTipi==1)
	{
		toplam=urunler[urunKodu].birimFiyat*miktarkilo;
	}
	else
	{
		toplam=urunler[urunKodu].kiloFiyat*miktarkilo;
	}
	return toplam;
}

float indirimHesapla(int toplamTutar)
{
	if (toplamTutar>=100)
	{
		toplamTutar=toplamTutar*9/10;
	}
	else if (toplamTutar>=50)
	{
		toplamTutar=toplamTutar*19/20;
	}
	return toplamTutar;
}

int main()
{
	int urunKod,alisTipi, miktarkilo;
	float toplamTutar=0.0;
	char bitbas='E';
	Urun urunler[6]={{"domates",1,8.25,23.75},{"biber",2,6.25,29.5},{"sut",3,15.85,27.15},{"peynir",4,23.0,95.5},{"muz",5,13.45,45.5},{"armut",6,5.5,20.15}};
	
	do
	{
		printf("\n");
		printf("Kod \t Urun Adi \t Birim Fiyat \t Kilo Fiyat\n");
		listele(urunler);
		printf("\n");
		do
		{
			printf("Urun kodunu giriniz: ");
			scanf("%d", &urunKod);
			printf("\n ");
		}while((urunKod>7)&&(urunKod<0));
		
		do
		{
			printf("Alis tipini giriniz(1:Birim, 2:Kilo): ");
			scanf("%d", &alisTipi);
			printf("\n ");
		}while((alisTipi!=1)&&(alisTipi!=2));
		
		if(alisTipi==1)
		{
			printf("Miktar giriniz: ");
			scanf("%d", &miktarkilo);
			printf("\n ");
		}
		else
		{
			printf("Kilo giriniz: ");
			scanf("%d", &miktarkilo);
			printf("\n ");
		}
		toplamTutar=toplamTutar+alisverisTutari(urunler, urunKod, alisTipi,miktarkilo);
		printf("Toplam tutar: %f",toplamTutar );
		printf("\nDevam etmek istiyor musunuz? (E/H): ");
		scanf("%c", &bitbas);
		
	}while((bitbas=='E')||(bitbas=='e'));
	printf("\nToplam tutar: %f",toplamTutar);
	if (toplamTutar>=50)
	{
		toplamTutar=indirimHesapla(toplamTutar);
		printf("\nIndirimli tutar: %f",toplamTutar);		
	}
	return 0;	
}
