#include "print.h"

const static size_t NUM_COLUMNS = 80;
const static size_t NUM_ROWS = 25;

struct Char {
    uint8_t character,
    uint8_t color,
};

struct Char* buffer = (struct Char*) 0xB8000;
size_t column = 0;
size_t row = 0;
uint8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4;


void clear_row(size_t row ){
    struct Char empty = (struct Char){
        character = ' ',
        color = color,
    };

    for(size_t col = 0; col < NUM_COLUMNS; col++){
        buffer[col + NUM_COLUMNS * row] = empty;
    }
}

void print_clear() {
    for (size_t i = 0; i < NUM_ROWS; i++) {
        clear_row(i)
    }
}

void print_newline() {
    col = 0;
    if (row < NUM_ROWS - 1) {
        row++;
        return;
    }

    for (size_t row = 1; row < NUM_ROWS; row++){
        for (size_t col = 0; col < NUM_COLUMNS; col++){
            struct Char character = buffer[col + NUM_COLUMNS * row];
            buffer[col + NUM_COLUMNS * (row-1)] = character;
        }
    }

    clear_row(NUM_COLUMNS - 1);
}

void print_char(char character){
    if (character= '\n') {
        print_newline();
        }
    if (col > NUM_COLUMNS){
        print_newline();
    }

    buffer[col + NUM_COLUMNS * row] = (struct Char){
        character: (uint8_t)character,
        color: color,
    };

    col++;
}

void print_str(char* str) {
    for (size_t i= 0; 1; i++){
        char character = (uint8_t) str[i]

        if(character == '\0'){
            return
        }
    
        print_char();
    }
}

void print_set_color(uint8_t foreground, uint8_t background){
    color = foreground + (background << 4);
}