#include <stdio.h>
#include <string.h>
#include <stdint.h> // używa się dla dokładnej definicji rozmiarów artybutów struktury nadgłówka obrazu
#include <stdlib.h>

/****************************************************************************************/
#pragma pack(push, 1)
typedef struct //struktura nagłówka obrazu
{
    unsigned char bfSig0;
    unsigned char bfSig1;
    uint32_t bfSize;
    uint32_t bfReserved;
    uint32_t  bfOffBits;
    uint32_t  biSize;
    uint32_t  biWidth;
    uint32_t  biHeight;
    uint16_t biPlanes;
    uint16_t biBitCount;
    uint32_t  biCompression;
    uint32_t  biSizeImage;
    uint32_t biXPelsPerMeter;
    uint32_t biYPelsPerMeter;
    uint32_t  biClrUsed;
    uint32_t  biClrImportant;
} bmpHdr;
#pragma pack(pop)
typedef struct //struktura żółwia
{
    int cX, cY; //"aktualne wspolrzedne"
    uint32_t col; //"aktualny kolor"
    uint32_t penState; //stan pióra
    uint32_t cDirection; //kierunek żółwia
} turtleInfo;

typedef struct //struktura instrukcji
{
    int byte_1; // pierwszy bajt instrukcji
    int byte_2; // drugi bajt instrukcji
    int byte_3; // trzeci bajt instrukcji
    int byte_4; // czwarty bajt instrukcji
} instruction;

void InitBmpHdr(bmpHdr* hdr){ //inicjalizacja nagłówka obrazu
    hdr->bfSig0 = 'B';
    hdr->bfSig1 = 'M';
    hdr->bfReserved = 0;
    hdr->bfOffBits = 54;
    hdr->biSize = 40;
    hdr->biPlanes = 1;
    hdr->biBitCount = 24;
    hdr->biCompression = 0;
    hdr->biSizeImage = 0;
    hdr->biXPelsPerMeter = 11811;
    hdr->biYPelsPerMeter = 11811;
    hdr->biClrUsed = 0;
    hdr->biClrImportant = 0;
}

turtleInfo* InitImgInfo(turtleInfo *trt){ //inicjalizacja struktury żółwia
    trt->cX = 0;
    trt->cY = 0;
    trt->col = 0x00000000;
    trt->penState = 0;
    trt->cDirection = 0;
    return trt;
}

void InitInstructionLong(instruction *ins, int b_1, int b_2, int b_3, int b_4){ //inicjalizacja struktury żółwia
    ins->byte_1 = b_1;
    ins->byte_2 = b_2;
    ins->byte_3 = b_3;
    ins->byte_4 = b_4;
}

void InitInstructionShort(instruction *ins, int b_1, int b_2){ //inicjalizacja struktury żółwia
    ins->byte_1 = b_1;
    ins->byte_2 = b_2;
    ins->byte_3 = 0;
    ins->byte_4 = 0;
}

extern int exec_turtle(unsigned char *dest_bitmap, instruction *command, turtleInfo *trt);
/****************************************************************************************/

unsigned char *InitScreen(unsigned int w, unsigned int h, size_t *size) //inicjalizacja struktury obrazu
{
    unsigned int rowSize = (w * 3 + 3) & ~3;
    *size = rowSize * h + 54;
    unsigned char *bitMap = (unsigned char *) malloc(*size);
    bmpHdr hdr;
    InitBmpHdr(&hdr);
    hdr.bfSize = *size;
    hdr.biWidth = w; // szerokosc obrazu
    hdr.biHeight = h; // wysokosc obrazu
    memcpy(bitMap, &hdr, 54);
    for (int i = 54; i < *size; ++i){
        bitMap[i] = 0xFF;
    }
    return bitMap;
}

void saveBMP(unsigned char *imageBuffer, size_t size, char *picture_name) //zapis obrazu
{
    FILE *file;
    file = fopen(picture_name, "wb");
    if (file == NULL) {
        printf("Error while opening file");
        exit(-1);
    }
    fwrite(imageBuffer, 1, size, file);
    fclose(file);
}

int main(int argc, char* argv[])
{
    FILE *fp;
    if((fp= fopen("config.txt", "r"))==NULL) //czytanie pliku
    {
        printf("Error occured while opening file");
        return 1;
    }
    int sizes[2]; //rozmiary
    char read_string[256];
    for (int i = 0; i < 2; i++){ //wczytanie rozmiarów
        sizes[i] = (int)strtol(fgets(read_string, 256, fp), NULL, 10);
    }

    size_t sizeBMP = 0;
    unsigned char *imgStruct = InitScreen(sizes[0], sizes[1], &sizeBMP); //inicjalizacja obrazu

    turtleInfo turtle; //inicjalizacja struktury żółwia
    turtleInfo *pTurtle = InitImgInfo(&turtle);

    int command_1, command_2, command_3, command_4;
    FILE *input;
    input = fopen("input.bin", "rb");
    if (input == NULL){
        printf("Error occured while opening file");
        return 1;
    }
    instruction instruct;
    int result;
    while ((command_1 = fgetc(input)) != EOF){
        command_2 = fgetc(input);
        // inicjalizacja instrukcji
        if ((command_1 & 0xC0) == 0){
            command_3 = fgetc(input);
            command_4 = fgetc(input);
            InitInstructionLong(&instruct, command_1, command_2, command_3, command_4);
            result = exec_turtle(imgStruct, &instruct, pTurtle);
            if (result != 0){
            exit(result);
            }
        }
        else{
            InitInstructionShort(&instruct, command_1, command_2);
            result = exec_turtle(imgStruct, &instruct, pTurtle);
            if (result != 0){
            exit(result);
            }
        }
    }
    fclose(input);
    saveBMP(imgStruct, sizeBMP, "output.bmp"); //zapisanie obrazu
    free(imgStruct); //zwolnienie pamięci
    return 0;
}
