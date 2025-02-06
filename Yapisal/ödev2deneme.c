#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>
#include <time.h>

typedef struct node 
{
    int weight;
    int hp;
    struct node* left;
    struct node* right;
} Node;

typedef struct nodestack
{
	Node data;
	Node* point;
} Stack;



void push (Stack *sp,int value)
{
	
}


Node* createNode(int weight) 
{
    Node* newNode = (Node*)malloc(sizeof(Node));
    newNode->weight = weight;
    newNode->hp = weight;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

Node* insert(Node* root, int weight) 
{
    if (root == NULL) 
	{
        return createNode(weight);
    } 
	else if (weight < root->weight) 
	{
        root->left = insert(root->left, weight);
    } 
	else 
	{
        root->right = insert(root->right, weight);
    }
    return root;
}

void inOrderTraversal(Node* root) 
{
    if (root != NULL) 
	{
        inOrderTraversal(root->left);
        printf("%d ", root->weight);
        inOrderTraversal(root->right);
    }
}

void postOrderTraversal(Node* root) 
{
    if (root != NULL) 
	{
        inOrderTraversal(root->left);
        inOrderTraversal(root->right);
        printf("%d ", root->weight);
    }
}

void preOrderTraversal(Node* root) 
{
    if (root != NULL) 
	{
        printf("%d ", root->weight);
        inOrderTraversal(root->left);
        inOrderTraversal(root->right);
    }
}
/*
struct node* minValueNode(struct node* node)
{
    struct node* current = node;
    while (current && current->left != NULL)
	    current = current->left;
    return current;
}*/


Node* findnode(Node* root, int k) 
{
	Node* parent=NULL;
    if (root == NULL||root->weight==k) 
	{
		return root;
	}
	if (root->weight>k)
	{
		return findnode(root->left, k);
	}
	else
	{
		return findnode(root->right, k);
	}
}





void deleteNode(Node* root, Node* parent)
{
	Node* successor;
	Node* parent=NULL;
	Node* current=root;
	parent=current;
	if(((current->left)==NULL)&&((current->right)==NULL))
	{
		root=NULL;
		return;
	}
	else if((root->left!=NULL)&&(root->right==NULL))
	{
		root=root->left;
		return;	
	}
	else if((root->right!=NULL)&&(root->left=NULL))
	{
		root=root->right;
		return;
	}
	else if((root->left!=NULL)&&(root->right!=NULL))
	{
		successor = current->right;
		parent=current;
		while(successor->left!=NULL)
		{
			parent=successor;
			successor->left;
		}
		current->weight=successor->weight;
		current->hp=successor->hp;
	}
	
}


int hitfruit(Node* root,int k,int p)
{
	root=findnode(root,k);
	root->hp=root->hp-p;
	if (root->hp<0)
	{
		deleteNode(root);
		printf("\ndeleted %d \n",k);
		return 1;
	}
}



int N, orgM, M,i,j,k,p,flag,target,sayac,bayrak;



int main()
{
	flag=1;
	printf("\nPlease enter upper limit of a fruits weight in the tree: ");
	scanf("%d",&N);
	printf("\nPlease enter amount of fruits in the tree: ");
	scanf("%d",&M);
	
	int *array =(int*) calloc(M,sizeof(int)); //Stack
	
	for(i=0; i<M;i++)
	{
		Node* newNode = (Node*)malloc(sizeof(Node));
	}
	
	Node* root = NULL;
	
	for(i=0; i<M;i++)
	{
		root = insert(root,(rand()%N +1));
	}
	
	
	inOrderTraversal(root);
	sayac=0;
	do
	{
		printf("\nPlease enter the weight of which fruit you want to hit in the tree: ");
		scanf("%d",&k);
		printf("\nPlease enter how hard the tree should be hit: ");
		scanf("%d",&p);
		bayrak=hitfruit(root,k,p);
		if(bayrak==1)
		{
			array[sayac]=k;
			sayac++;
		}
		preOrderTraversal(root);
		printf("\n");
		for(i=0;i<M;i++)
		{
			
		}
		
	}while (sayac<M);
	
	
	inOrderTraversal(root);
	
	
	return 0;
}




/*
Node* createNode(int data) {
    Node* newNode = (Node*)malloc(sizeof(Node));
    newNode->data = data;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

Node* insert(Node* root, int data) {
    if (root == NULL) {
        return createNode(data);
    } else if (data < root->data) {
        root->left = insert(root->left, data);
    } else {
        root->right = insert(root->right, data);
    }
    return root;
}

void inOrderTraversal(Node* root) {
    if (root != NULL) {
        inOrderTraversal(root->left);
        printf("%d ", root->data);
        inOrderTraversal(root->right);
    }
}

int main() {
    Node* root = NULL;
    root = insert(root, 8);
    root = insert(root, 3);
    root = insert(root, 1);
    root = insert(root, 6);
    root = insert(root, 7);
    root = insert(root, 10);
    root = insert(root, 14);
    root = insert(root, 4);

    printf("In-order traversal: ");
    inOrderTraversal(root);
    printf("\n");

    return 0;
}
*/

//node silmede sorun var buraya bak
/*
struct Node* deleteNode(struct Node* root, int weight)
{
    if (root == NULL)
        return root;
 
    if (weight < root->weight)
    {
        root->left = deleteNode(root->left, weight);
    }
    else if (weight > root->weight)
    {
        root->right = deleteNode(root->right, weight);
	}   
    else 
	{
        if (root->left == NULL) 
		{
            struct node* temp = root->right;
            free(root);
            return temp;
        }
        else if (root->right == NULL) 
		{
            struct node* temp = root->left;
            free(root);
            return temp;
        }
 
        struct node* temp = minValueNode(root->right);
        root->weight = temp->weight;
        root->right = deleteNode(root->right, temp->weight);
    }
    return root;
}

void hitfruit(Node* root,int k, int p) 
{
    if (root != NULL) 
	{
        if (root->weight==k)
        {
        	root->hp=root->hp-p;
        	if (root->hp<=0)
        	{
        		deleteNode(root, root->weight);
			}
		}
        inOrderTraversal(root->left);
        inOrderTraversal(root->right);
    }
}


struct node* minValueNode(struct node* node)
{
    struct node* current = node;
    while (current && current->left != NULL)
	    current = current->left;
    return current;
}

/*
void treeprint(Node* root, int even) 
{
	int i,
    if (root != NULL) 
	{
        printf("%d", root->weight);
        treeprint(root->left);
        printf("\n");
        treeprint(root->right);
    }
}*/

/*
int powerof(int powerof, int power)
{
	int i,result=1;
	for(i=0;i<power;i++)
	{
		result=result*powerof;
	}
	return result;
}*/
//	number = (rand() % (upper - 1 + 1)) + 1


