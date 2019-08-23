#include <stdio.h>
#include <arch/px8.h>

int main() {
  printf("Hello, World!\n");
  subcpu_command("\x0A\x30\xE0\x21\x21\x21\x39\x25\x25\x25\x39");
  printf(" %c!\n", 0xE0);
  getc(stdin);
  return 0;
}
