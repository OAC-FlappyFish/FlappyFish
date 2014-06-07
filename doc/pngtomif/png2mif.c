/*
 * png2mif by Antonio Martino
 * based on code by Guillaume Cottenceau
 *
 * This software may be freely redistributed under the terms
 * of the X11 license.
 *
 */

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#define PNG_DEBUG 3
#include <png.h>

void abort_(const char * s, ...)
{
    va_list args;
    va_start(args, s);
    vfprintf(stderr, s, args);
    fprintf(stderr, "\n");
    va_end(args);
    abort();
}

unsigned int mask(int depth)
{
    unsigned int mask = 0x1;
    mask <<= depth;
    mask -= 0x1;
    return ~mask;
}

int x, y, r, g, b;

int width, height;
png_byte color_type;
png_byte bit_depth;

png_structp png_ptr;
png_infop info_ptr;
int number_of_passes;
png_bytep * row_pointers;

void read_png_file(char* file_name)
{
    char header[8]; /* 8 is the maximum size that can be checked */

    /* open file and test for it being a png */
    FILE *fp = fopen(file_name, "rb");
    if (!fp)
        abort_("[read_png_file] File %s could not be opened for reading", file_name);
    
    fread(header, 1, 8, fp);
    if (png_sig_cmp(header, 0, 8))
        abort_("[read_png_file] File %s is not recognized as a PNG file", file_name);
    
    /* initialize stuff */
    png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    
    if (!png_ptr)
        abort_("[read_png_file] png_create_read_struct failed");
    
    info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr)
        abort_("[read_png_file] png_create_info_struct failed");
    
    if (setjmp(png_jmpbuf(png_ptr)))
        abort_("[read_png_file] Error during init_io");
    
    png_init_io(png_ptr, fp);
    png_set_sig_bytes(png_ptr, 8);
    
    png_read_info(png_ptr, info_ptr);
    
    width = png_get_image_width(png_ptr, info_ptr);
    height = png_get_image_height(png_ptr, info_ptr);
    color_type = png_get_color_type(png_ptr, info_ptr);
    bit_depth = png_get_bit_depth(png_ptr, info_ptr);
    
    number_of_passes = png_set_interlace_handling(png_ptr);
    png_read_update_info(png_ptr, info_ptr);
    
    /* read file */
    if (setjmp(png_jmpbuf(png_ptr)))
        abort_("[read_png_file] Error during read_image");
    
    row_pointers = (png_bytep*) malloc(sizeof(png_bytep) * height);
    for (y=0; y<height; y++)
        row_pointers[y] = (png_byte*) malloc(png_get_rowbytes(png_ptr,info_ptr));
    
    png_read_image(png_ptr, row_pointers);
    
    fclose(fp);
}

void write_png_file()
{
    /* create file */
    FILE *fp = fopen("output.png", "wb");
    if (!fp)
        abort_("[write_png_file] File output.png could not be opened for writing");
    
    /* initialize stuff */
    png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    
    if (!png_ptr)
        abort_("[write_png_file] png_create_write_struct failed");
    
    info_ptr = png_create_info_struct(png_ptr);
    if (!info_ptr)
        abort_("[write_png_file] png_create_info_struct failed");
    
    if (setjmp(png_jmpbuf(png_ptr)))
        abort_("[write_png_file] Error during init_io");
    
    png_init_io(png_ptr, fp);
    
    /* write header */
    if (setjmp(png_jmpbuf(png_ptr)))
        abort_("[write_png_file] Error during writing header");
    
    png_set_IHDR(png_ptr, info_ptr, width, height, bit_depth, color_type, 
     PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_BASE, PNG_FILTER_TYPE_BASE);
    
    png_write_info(png_ptr, info_ptr);
    
    /* write bytes */
    if (setjmp(png_jmpbuf(png_ptr)))
        abort_("[write_png_file] Error during writing bytes");
    
    png_write_image(png_ptr, row_pointers);
    
    /* end write */
    if (setjmp(png_jmpbuf(png_ptr)))
        abort_("[write_png_file] Error during end of write");
    
    png_write_end(png_ptr, NULL);
    
    /* cleanup heap allocation */
    for (y=0; y<height; y++)
        free(row_pointers[y]);
    free(row_pointers);
    
    fclose(fp);
}


void process_file(void)
{
    int channels;
    
    if (png_get_color_type(png_ptr, info_ptr) == PNG_COLOR_TYPE_RGB)
        channels = 3;
    
    if (png_get_color_type(png_ptr, info_ptr) == PNG_COLOR_TYPE_RGBA)
        channels = 4;
    
    if (channels != 3 && channels != 4)
        abort_("[process_file] color_type of input file must be PNG_COLOR_TYPE_RGB (%d) or PNG_COLOR_TYPE_RGBA (%d) (is %d)",
         PNG_COLOR_TYPE_RGB, PNG_COLOR_TYPE_RGBA, png_get_color_type(png_ptr, info_ptr));
    
    FILE * fp = fopen("output.mif", "w");
    if (fp == NULL)
        abort_("[process_file] Could not create output.mif file");
    
    fprintf(fp, "DEPTH = %d;\n", width*height);
    fprintf(fp, "WIDTH = %d;\n", r + g + b);
    fprintf(fp, "ADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n");
    
    unsigned int word;
    
    for (y = 0; y < height; y++) {
        fprintf(fp, "\n%05X :", y*x);
        png_byte* row = row_pointers[y];
        for (x = 0; x < width; x++) {
            png_byte* ptr = &(row[x*channels]);
            
            /*         [ b ][ g ][ r ] */
            /* [31 - 8][7-6][5-3][2-0] */
            
            ptr[0] = ptr[0] & mask(r);
            ptr[1] = ptr[1] & mask(g);
            ptr[2] = ptr[2] & mask(b);
            word = (ptr[2] >> (bit_depth - b)) << (g + r);
            word += (ptr[1] >> (bit_depth - g)) << r;
            word += (ptr[0] >> (bit_depth - r));
            
            fprintf(fp, " %02X", word);
        }
        fprintf(fp, ";");
    }
    
    fprintf(fp, "\nEND\n");
    
    fclose(fp);
}

int main(int argc, char **argv)
{
    char input[30];
    
    if (argc != 5)
    {
        printf("Usage: png2mif <input file> <red channel depth> <green channel depth> <blue channel depth>\n\n");
        
        printf("Input file: ");
        scanf("%[^\n]s", input);
        getchar();
        
        FILE * fp = fopen(input, "rb");
        if (fp == NULL)
            abort_("File not found");
        else
            fclose(fp);
            
        printf("Red channel depth: ");
        scanf("%d", &r);
        getchar();
        if (r < 1)
            abort_("Channel depth must be a positive integer");
            
        printf("Green channel depth: ");
        scanf("%d", &g);
        getchar();
        if (g < 1)
            abort_("Channel depth must be a positive integer");
            
        printf("Blue channel depth: ");
        scanf("%d", &b);
        getchar();
        if (b < 1)
            abort_("Channel depth must be a positive integer");
        
        read_png_file(input);
    }
    else {
        r = atoi(argv[2]);
        g = atoi(argv[3]);
        b = atoi(argv[4]);
        
        if (r < 1 || g < 1 || b < 1)
            abort_("Channel depth must be a positive integer");
        
        read_png_file(argv[1]);
    }
    
    process_file();
    write_png_file();
    
    return 0;
}

