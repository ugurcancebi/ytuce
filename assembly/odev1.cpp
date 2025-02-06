#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#define _CRT_SECURE_NO_WARNINGS
#include "stb_image.h"
#include "stb_image_write.h"
#include <iostream>

#define pixel_max(a) ((a) <= 255 ? (a) : 255)
#define pixel_min(a) ((a) >= 0 ? (a) : 0)

// Function to read an image in grayscale
unsigned char* readImage(const char* filename, int& width, int& height, int& channels) {
    unsigned char* image = stbi_load(filename, &width, &height, &channels, 1); // Load as grayscale
    if (!image) {
        std::cerr << "Failed to load image: " << stbi_failure_reason() << std::endl;
        return nullptr;
    }
    std::cout << "Image loaded successfully!" << std::endl;
    std::cout << "Width: " << width << ", Height: " << height << ", Channels: " << channels << std::endl;
    return image;
}

// Function to write an image to a PNG file
bool writeImage(const char* filename, unsigned char* image, int width, int height) {
    if (!image) {
        std::cerr << "Image data is null before writing!" << std::endl;
        return false;
    }
    if (width <= 0 || height <= 0) {
        std::cerr << "Invalid image dimensions: width = " << width << ", height = " << height << std::endl;
        return false;
    }
    // For grayscale images, stride is the same as the width
    int stride = width;
    if (stbi_write_png(filename, width, height, 1, image, stride) == 0) {
        std::cerr << "Failed to write the image to file: " << filename << std::endl;
        return false;
    }
    std::cout << "Image written successfully to: " << filename << std::endl;
    return true;
}

int main() {
    // Input and output file paths
    const char* inputFilename = "input_image3.png";
    const char* outputFilename1 = "output_image1.png";
    const char* outputFilename2 = "output_image2.png";

    // Image data variables
    int width, height, channels; // channels = 1 (grayscale)
    unsigned int number_of_pixels;

    // Read the input image
    unsigned char* image = readImage(inputFilename, width, height, channels);
    if (!image) 
        return -1; // Exit if the image failed to load

    // Allocate memory for the output image
    unsigned char* outputImage = new unsigned char[width * height];
    if (!outputImage) {
        std::cerr << "Failed to allocate memory for output image!" << std::endl;
        stbi_image_free(image);
        return -1;
    }

    // image is 1d array 
    // with length = width * height
    // pixels can be used as image[i] 
    // pixels can be updated as image[i] = 100, etc.
    // a pixel is defined as unsigned char
    // so a pixel can be 255 at max, and 0 at min.

    /* -------------------------------------------------------- QUESTION-1 -------------------------------------------------------- */
    
    /* Q-1 Inverse the colors of image. 
    Inverse -> pixel_color = 255 - pixel_color */

    number_of_pixels = width * height; 
    __asm { //renklerin tersi
        MOV ECX, number_of_pixels
        MOV EBX, image
        MOV ESI, outputImage
L1:     MOV AL, 255  
        SUB AL, [EBX + ECX - 1] //255 - pixel_color, ECX yanlis yere erismesin diye bir eksiltiliyor
        MOV [ESI + ECX - 1], AL //outputImage'a aktar
        LOOP L1
    }

    // Write the modified image as output_image1.png
    if (!writeImage(outputFilename1, outputImage, width, height)) {
        stbi_image_free(image);
        return -1;
    }
    stbi_image_free(outputImage); // Clear the outputImage.

    /* -------------------------------------------------------- QUESTION-2 -------------------------------------------------------- */
    /* Histogram Equalization */

    outputImage = new unsigned char[width * height];
    if (!outputImage) {
        std::cerr << "Failed to allocate memory for output image!" << std::endl;
        stbi_image_free(image);
        return -1;
    }

    unsigned int* hist = (unsigned int*)malloc(sizeof(unsigned int) * 256);
    unsigned int* cdf = (unsigned int*)malloc(sizeof(unsigned int) * 256);

    // Check if memory allocation succeeded
    if (hist == NULL) {
        std::cerr << "Memory allocation for hist failed!" << std::endl;
        return -1;
    }
    if (cdf == NULL) {
        std::cerr << "Memory allocation for cdf failed!" << std::endl;
        free(hist);
        return -1;
    }

    // Both hist and cdf are initialized as zeros.
    for (int i = 0; i < 256; i++) {
        hist[i] = 0;
        cdf[i] = 0;
    }

    // You can define new variables here... As a hint some variables are already defined.
    unsigned int min_cdf, range;
    number_of_pixels = width * height;

    // Q-2 (a) - Compute the histogram of the input image.
    __asm {
        MOV EBX, hist  //hist 4 bytelik yer kapliyor
        MOV ESI, image
        XOR ECX, ECX //dongu icin ECX sifirlandi
   L2 : XOR EAX, EAX
        MOV AL, [ESI + ECX]  //input[i] EAX'a aktarildi
        SHL EAX, 2   //indis olarak kullanilacagindan 4 ile carpildi
        MOV EDX, [EBX + EAX] //hist[input[i]]
        INC EDX //hist degeri arttirildi
        MOV [EBX + EAX], EDX //hist[input[i]]ye yazildi
        INC ECX //dongu
        CMP ECX, number_of_pixels
        JNE L2
        
    }

    /* Q-2 (b) - Compute the Cumulative Distribution Function cdf
                    and save it to cdf array which is defined above. */

    // CDF Calculation (cdf[i] = cdf[i-1] + hist[i])
    
    __asm {
        MOV EDI, cdf //cdf ve hist 4er byte artiyor
        MOV ESI, hist
        MOV EAX, [ESI]
        MOV [EDI], EAX //cdf[0] = hist[0] oldu
        ADD EDI, 4 //cdf[1]deyiz su anda
        ADD ESI, 4//hist[1]
        XOR ECX, ECX // cdf[i] = cdf[i - 1] + hist[i]; islemi olmali
L3:     MOV EAX, ECX
        SHL EAX, 2 //i degeri olan ECX EAX'a aktarildi indis gorevi goreceginden 4er byte arttigi icin 4 ile carpildi
        MOV EDX, [EDI+EAX-4] //cdf[i-1]
        ADD EDX, [ESI+EAX] //hist[i]
        MOV [EDI+EAX], EDX //sonucu cdf[i]ye aktar
        XOR EDX, EDX //EDXi temizle
        INC ECX //dongu
        CMP ECX, 256
        JNE L3
        
    }

    /* Q-2 (c) - Normalize the Cumulative Distribution Funtion 
                    that you have just calculated on the same cdf array. */

    // Normalized cdf[i] = ((cdf[i] - min_cdf) * 255) / range
    // range = (number_of_pixels - min_cdf)

    __asm {
        // Your assembly code here...
        MOV EDI, cdf
        XOR ECX, ECX // min cdf bulma islemleri 0 olmayan ilk degerden baslayacak
L4:     MOV EAX, ECX
        SHL EAX, 2//4 ile carpildi cdf erisimi icin
        MOV EBX, [EDI+EAX] //cdf[i] EBXe aktarildi
        CMP EBX, 0 
        JNE L5 //0 olmayan bir deger bulununca donguden cik
        INC ECX
        CMP ECX, 256
        JNE L4
L5:     MOV min_cdf, EBX //0 olmayan ilk deger min_cdfye aktarildi
        MOV EDX, number_of_pixels //range hesabi hazirliklari
        SUB EDX, min_cdf //range EDX'da
        MOV range, EDX //minimum sifir olmayan degeri bulma islemleriydi min_cdf ve range bulundu


        XOR ECX, ECX //normalizasyon icin ECX sifirlandi
L6:     MOV EAX, ECX //bu islem yapilacak cdf[i] = ((cdf[i] - min_cdf) * 255) / range
        SHL EAX, 2// 4 ile carpildi indis gorevi gormeye hazir
        MOV EBX, [EDI+EAX] //cdf[i] EBX'de
        PUSH EAX //EAX islemlerde kullanilacagi icin saklandi
        SUB EBX, min_cdf //(cdf[i] - minCDF) oldu
        MOV EAX, EBX //255 ile carpma hazirliklari
        MOV EDX, 255 //(cdf[i] - min_cdf) * 255
        MUL EDX //sonuc EAXda
        MOV EBX, range //   / range olacak
        XOR EDX, EDX //bolme islemi icin EDX bosaltiliyor
        DIV EBX //normalize olmus cdf[i]nin range'e bolumu
        MOV EBX, EAX
        POP EAX // tutulan EAX degeri geri cekildi
        //XOR EBX, 255
        MOV [EDI+EAX], EBX //normalize olmus degeri cdf[i]'ye aktar

        INC ECX
        CMP ECX, 256
        JNE L6
    }

    /* Q-2 (d) - Apply the histogram equalization on the image.
                    Write the new pixels to outputImage. */
	// Here you only need to get a pixel from image, say the value of pixel is 107
	// Then you need to find the corresponding cdf value for that pixel
	// The output for the pixel 107 will be cdf[107]
	// Do this for all the pixels in input image and write on output image.
    __asm {
        // Your assembly code here...
        XOR ECX, ECX
        MOV EDI, outputImage
        MOV ESI, image
        MOV EBX, cdf //cdfdeki degerleri output imagea aktarma
L7:     XOR EAX, EAX
        MOV AL, [ESI+ECX] //image[i]=AL
        SHL EAX, 2 //4 ile carpildi cdfe erismek icin
        MOV EDX, [EBX+EAX] //cdf[image[i]]
        MOV [EDI+ECX], DL //sonuc outputImage'e yaziliyor
        INC ECX //dongu
        CMP ECX, number_of_pixels
        JNE L7
        
    }

    // Write the modified image
    if (!writeImage(outputFilename2, outputImage, width, height)) {
        stbi_image_free(image); 
        return -1;
    }

    // Free the image memory
    stbi_image_free(image);
    stbi_image_free(outputImage);

    return 0;
}
