#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_NODES 50

typedef struct {
    int edges[MAX_NODES][MAX_NODES]; //kenarlari tanimlayan komsuluk matrisi
    int n; //kenarlar
} Graph; //Graf tanimlayan struct

/*typedef struct {
    int count;
    int paths[MAX_NODES][MAX_NODES];
} PathInfo; //yollarin ara kesici degerlerini saklayan struct

typedef struct {
    int source;
    int destination;
    int weight;
} Edge; //iki dugum arasi ara kesici degerlerini saklayacak struct
*/

void initializeGraph(Graph *g, int nodes) //graphi kuran fonksiyon
{
    g->n = nodes; //boyutunu ve dugum sayisini belirtiyor
    int i,j;
    for (i = 0; i < nodes; i++) 
	{
        for (j = 0; j < nodes; j++) 
		{
            g->edges[i][j] = 0; //dugumler arasi butun kenarlari komsuluk matrisinde 0'a esitliyor
        }
    }
}

int getNodeIndex(char node) 
{
    return node - 'A'; //dügümlerin A karakteri ile baslasdigini varsayiyoruz, char olan indislerini integer haline ceviriyor
}

void addEdge(Graph *g, char u, char v) //U ve V dugumlerinin baglantisini g grafina ekliyor
{
    int uIndex = getNodeIndex(u);
    int vIndex = getNodeIndex(v);
    g->edges[uIndex][vIndex] = 1;
    g->edges[vIndex][uIndex] = 1; //yonsuz ve agirliksiz bir graf oldugu icin U ve V nodelari iki yonlu ve agirliklari ayni
}

void BFS(Graph *g, int startNode) //BFS araciligi ile ziyaret edilen butun dugumleri 
{
    int visited[MAX_NODES] = {0};
    int queue[MAX_NODES], front = 0, rear = 0;
    int i;
    visited[startNode] = 1;  //Baslangic dugumunu ziyaret edilmis olarak belliyor
    queue[rear++] = startNode; // Siraya yerlestirme
    while (front < rear) 
	{
        int currentNode = queue[front++]; // Siradan cikarma
        printf("%c ", currentNode + 'A');
        for (i = 0; i < g->n; i++) 
		{
            if (g->edges[currentNode][i] && !visited[i]) 
			{
                visited[i] = 1;
                queue[rear++] = i; // Bitisik dugumu siraya yerlestiriyor
            }
        }
    }
}

int main() 
{
    FILE *file = fopen("input.txt", "r");//Dosyayi acma
    if (file == NULL) {
        perror("Unable to open the file.");
        return 1;
    }
    Graph g;
    char line[100];
    int maxNode = -1;
    int i,j;
    int activeNodes[MAX_NODES] = {0};
    //int k,t /*kullanilmadi*/
    while (fgets(line, sizeof(line), file)) //ilk dongu, grafin boyutunu bulmaya yariyor
	{
        char node = line[0];//input.txt'deki dügüm her zaman satirin ilk elemani
        int nodeIndex = getNodeIndex(node);//char degerinden sayisal degeri aliniyor
        activeNodes[nodeIndex] = 1;//olmayan dügümleri ayiklamak icin, ilerde ekrana yazmada lazim olacak
        if (nodeIndex > maxNode) 
		{
            maxNode = nodeIndex; //karsilasilan en buyuk indisi buluyor
        }

        char *token = strtok(line + 2, ",;");//input.txt formatindaki gibi 3.karakterden itibaren eklemeye basliyor ve , ve ; ile dugumlerin ayrildigini belirtiyor
        while (token && token[0] != '\n') 
		{
            addEdge(&g, node, token[0]);
            token = strtok(NULL, ",;");
        }
    }
    
    initializeGraph(&g, maxNode + 1);//komsuluk matrisinin boyutlarini belirliyor 0'dan maxNode'a kadar boyutta olacak neden +1 olmasi gerekiyor tam anlamadim ama obur turlu calismiyor
    fseek(file, 0, SEEK_SET); // Reset file pointer to beginning
    
    while (fgets(line, sizeof(line), file)) //Dosyanin her satirini okuyan dongu
	{
        char node = line[0];
        char *token = strtok(line + 2, ",;"); //^
        while (token && token[0] != '\n') //satir sonuna gelene kadar dugumleri almaya devam ediyor
		{
            addEdge(&g, node, token[0]);
            token = strtok(NULL, ",;");
        }
    }

    fclose(file);
    printf("BFS Traversal starting from each node:\n");
    for (i = 0; i < g.n; i++) //n defa dugumleri geziyor n dugum olmasa dahi
	{
		if (activeNodes[i])//olmayan dugumler yazilmiyor
		{
        	printf("BFS starting from node %c:\n", 'A' + i); //dügümlerin A karakteri ile baslasdigini varsayiyoruz
        	BFS(&g, i);
        	printf("\n");//duzenli gozukmesi icin
    	}
    }
    return 0; //program bitti
}

