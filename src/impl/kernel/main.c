#include "print.h"

void kernel_main(){
    print_clear();
    print_set_color(PRINT_COLOR_MAGENTA, PRINT_COLOR_BLACK);
    print_str("Welcome to SNAKE OS. Ready to play snake?");
}