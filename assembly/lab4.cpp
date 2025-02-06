#define _CRT_SECURE_NO_DEPRECATE
#include <stdio.h>
#include <stdlib.h>

// Function to print a matrix stored in a 1D array
void print_matrix(unsigned* matrix, unsigned rows, unsigned cols, FILE* file);
// Function to read matrix from a file
void read_matrix(const char* filename, unsigned** matrix, unsigned* rows, unsigned* cols);
// Function to read kernel from a file
void read_kernel(const char* filename, unsigned** kernel, unsigned* k);
// Function to write output matrix to a file
void write_output(const char* filename, unsigned* output, unsigned rows, unsigned cols);
// Initialize output as zeros.
void initialize_output(unsigned*, unsigned, unsigned);

int main() {

    unsigned n, m, k;  // n = rows of matrix, m = cols of matrix, k = kernel size
    // Dynamically allocate memory for matrix, kernel, and output
    unsigned* matrix = NULL;  // Input matrix
    unsigned* kernel = NULL;  // Kernel size 3x3
    unsigned* output = NULL;  // Max size of output matrix

    char matrix_filename[30];
    char kernel_filename[30];

    // Read the file names
    printf("Enter matrix filename: ");
    scanf("%s", matrix_filename);
    printf("Enter kernel filename: ");
    scanf("%s", kernel_filename);


    // Read matrix and kernel from files
    read_matrix(matrix_filename, &matrix, &n, &m);  // Read matrix from file
    read_kernel(kernel_filename, &kernel, &k);      // Read kernel from file

    // For simplicity we say: padding = 0, stride = 1
    // With this setting we can calculate the output size
    unsigned output_rows = n - k + 1;
    unsigned output_cols = m - k + 1;
    output = (unsigned*)malloc(output_rows * output_cols * sizeof(unsigned));
    initialize_output(output, output_rows, output_cols);

    // Print the input matrix and kernel
    printf("Input Matrix: ");
    print_matrix(matrix, n, m, stdout);

    printf("\nKernel: ");
    print_matrix(kernel, k, k, stdout);

    /******************* KODUN BU KISMINDAN SONRASINDA DEĞİŞİKLİK YAPABİLİRSİNİZ - ÖNCEKİ KISIMLARI DEĞİŞTİRMEYİN *******************/

    // Assembly kod bloğu içinde kullanacağınız değişkenleri burada tanımlayabilirsiniz. ---------------------->
    // Aşağıdaki değişkenleri kullanmak zorunda değilsiniz. İsterseniz değişiklik yapabilirsiniz.
    // Konvolüsyon için gerekli 1 matrix ve 1 kernel değişkenleri saklanabilir.
    unsigned sum;                           // Konvolüsyon toplamını saklayabilirsiniz.
    unsigned matrix_offset;                 // Input matrisi üzerinde gezme işleminde sınırları ayarlamak için kullanılabilir.
    unsigned tmp_si, tmp_di;                // ESI ve EDI döngü değişkenlerini saklamak için kullanılabilir.
    unsigned kernelRow, kernelCol;
    unsigned inputRow, inputCol;
    unsigned outputRow, outputCol;
    unsigned output_elemanSay = output_rows * output_cols * 4 ;
    unsigned kKare = k * k * 4 ;

    matrix_offset = k / 2;
    sum = 0;
    // Assembly dilinde 2d konvolüsyon işlemini aşağıdaki blokta yazınız ----->
    __asm {
        // Aşağıdaki kodu silerek başlayabilirsiniz ->
        //XOR ESI, ESI
        //XOR EDI, EDI
        //MOV EBX, [matrix]
        //MOV EAX, [matrix + 4]
        //iki for dongusu onun icin satir ve sutun sayi islemleri ile dolu
        XOR ESI, ESI //i=0
L1 :    XOR EDI, EDI //j=0   Dis dongu output matrisi boyunca ilerleyip dolduruyor
        MOV sum, 0   //j'daki sum 0
        XOR EDX, EDX  //div hazirliklari
        MOV EBX, output_cols //kac sutun olacak matrixe gore bulunan sonuc yazildi
        MOV tmp_si, ESI //ESI degeri birer birer değil dorder dorder artacak burada onun hazirliklari yapılıyor
        MOV EAX, ESI //
        MOV ECX, 4 //4er 4er artan si degerini indis olarak kullanmak 4'e bolup icin sonucu EAX'a yazma islemi
        DIV ECX
        //MOV EAX, ESI   //burada da 4 ekliyor
        DIV EBX //EAX bolum, EDX kalan, hangi row ve output kullaniliy
        MOV outputRow, EAX  //EAX bolumu at 
        MOV outputCol, EDX  //EDX kalani at
        MOV ESI, tmp_si
L2 :    XOR EDX, EDX    //Ic dongu
        MOV EBX, k     //kernel dongusu
        MOV tmp_di, EDI  //yine dorder dorder artan EDI'yı teker teker indis olarak kullanmak icin bolme hazirliklari 
        MOV EAX, EDI
        MOV ECX, 4
        DIV ECX
        //MOV EAX, EDI //j / ve % islemleri icin hazirlik   ...4 ekliyor ama index 1 olmali, 4e bolup, ekleyip, 4le carp gibi olmali
        DIV EBX //kernelRow EAX'da, kernelCol EDX'de
        MOV kernelRow, EAX
        MOV kernelCol, EDX
        MOV EDI, tmp_di
        ADD EAX, outputRow //inputRow = outputRow + kernelRow;
        ADD EDX, outputCol //inputCol = outputCol + kernelCol;
        MOV inputRow, EAX
        MOV inputCol, EDX
        MOV EDX, m//inputCols
        MUL EDX //Sonuc EDX;EAX'de inputRow * inputCols
        MOV EBX, matrix
        ADD EAX, inputCol //inputRow * inputCols + inputCol
        MOV ECX, 4
        MUL ECX //EA
        MOV ECX, [EBX+EAX] //input[inputRow * inputCols + inputCol]
        MOV EBX, kernel
        MOV EDX, [EBX+EDI] //kernel[j]'dakini EDX'e at
        MOV EAX, ECX
        MUL EDX //EAX = EDX*EAX input[inputRow * inputCols + inputCol] * kernel[j]
        ADD sum, EAX
        ADD EDI, 4 //4 byte ileri gir
        MOV EAX, kKare
        CMP EDI, EAX
        JNE L2
        MOV EBX, output
        MOV EAX, sum
        MOV [EBX+ESI], EAX
        ADD ESI, 4
        MOV EAX,output_elemanSay
        CMP ESI, EAX
        JNE L1


    }

    /******************* KODUN BU KISMINDAN ÖNCESİNDE DEĞİŞİKLİK YAPABİLİRSİNİZ - SONRAKİ KISIMLARI DEĞİŞTİRMEYİN *******************/


    // Write result to output file
    write_output("./output.txt", output, output_rows, output_cols);

    // Print result
    printf("\nOutput matrix after convolution: ");
    print_matrix(output, output_rows, output_cols, stdout);

    // Free allocated memory
    free(matrix);
    free(kernel);
    free(output);

    return 0;
}

void print_matrix(unsigned* matrix, unsigned rows, unsigned cols, FILE* file) {
    if (file == stdout) {
        printf("(%ux%u)\n", rows, cols);
    }
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            fprintf(file, "%u ", matrix[i * cols + j]);
        }
        fprintf(file, "\n");
    }
}

void read_matrix(const char* filename, unsigned** matrix, unsigned* rows, unsigned* cols) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        printf("Error opening file %s\n", filename);
        exit(1);
    }

    // Read dimensions
    fscanf(file, "%u %u", rows, cols);
    *matrix = (unsigned*)malloc(((*rows) * (*cols)) * sizeof(unsigned));

    // Read matrix elements
    for (int i = 0; i < (*rows); i++) {
        for (int j = 0; j < (*cols); j++) {
            fscanf(file, "%u", &(*matrix)[i * (*cols) + j]);
        }
    }

    fclose(file);
}

void read_kernel(const char* filename, unsigned** kernel, unsigned* k) {
    FILE* file = fopen(filename, "r");
    if (!file) {
        printf("Error opening file %s\n", filename);
        exit(1);
    }

    // Read kernel size
    fscanf(file, "%u", k);
    *kernel = (unsigned*)malloc((*k) * (*k) * sizeof(unsigned));

    // Read kernel elements
    for (int i = 0; i < (*k); i++) {
        for (int j = 0; j < (*k); j++) {
            fscanf(file, "%u", &(*kernel)[i * (*k) + j]);
        }
    }

    fclose(file);
}

void write_output(const char* filename, unsigned* output, unsigned rows, unsigned cols) {
    FILE* file = fopen(filename, "w");
    if (!file) {
        printf("Error opening file %s\n", filename);
        exit(1);
    }

    // Write dimensions of the output matrix
    fprintf(file, "%u %u\n", rows, cols);

    // Write output matrix elements
    print_matrix(output, rows, cols, file);

    fclose(file);
}

void initialize_output(unsigned* output, unsigned output_rows, unsigned output_cols) {
    int i;
    for (i = 0; i < output_cols * output_rows; i++)
        output[i] = 0;
    
}

