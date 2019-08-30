#include <arch/px8.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <graphics.h>

char trex_data[] = {
  0b0000, 0b00000000, 0b00000000,
  0b0000, 0b00000001, 0b11111110,
  0b0000, 0b00000011, 0b01111111,
  0b0000, 0b00000011, 0b11111111,
  0b0000, 0b00000011, 0b11111111,
  0b0000, 0b00000011, 0b11111111,
  0b0000, 0b00000011, 0b11100000,
  0b0000, 0b00000011, 0b11111100,
  0b1000, 0b00000111, 0b11000000,
  0b1000, 0b00011111, 0b11000000,
  0b1100, 0b00111111, 0b11110000,
  0b1110, 0b01111111, 0b11010000,
  0b1111, 0b11111111, 0b11000000,
  0b1111, 0b11111111, 0b11000000,
  0b0111, 0b11111111, 0b10000000,
  0b0011, 0b11111111, 0b10000000,
  0b0001, 0b11111111, 0b00000000,
  0b0000, 0b11111110, 0b00000000,
  0b0000, 0b01110110, 0b00000000,
  0b0000, 0b01100010, 0b00000000,
  0b0000, 0b01000010, 0b00000000,
  0b0000, 0b01100011, 0b00000000,
  0b0000, 0b00000000, 0b00000000
};

typedef struct {
  short cmd;
  short cmd_len;
  short res;
  short res_len;
} cmd_t;

/**
 * define sprite: 0x20
 *    SP1: sprite index
 *    SP2: width (in blocks)
 *    SP3: height (in pixels)
 *    SP4..SPn: data (row-first)
 */
char define_sprite_header[] = "\x20\x01\x03\x17";
char define_sprite_cmd[4 + sizeof(trex_data)];

/**
 * draw sprite: 0x23
 *    SP1: X coordinate (in blocks)
 *    SP2: Y coordinate (in pixels)
 *    SP3: sprite index
 */
char draw_sprite_cmd[] = "\x23\x02\x20\x01";

extern char run();

void asm_benchmark() {
  int ts1 = clock();
  char res = run();
  int ts2 = clock();
  printf("%d\n", ts2 - ts1);
}

void c_benchmark() {
  memcpy(define_sprite_cmd, define_sprite_header, 4);
  memcpy(&(define_sprite_cmd[4]), trex_data, sizeof(trex_data));

  unsigned char res = 0;
  cmd_t cmd;
  cmd.cmd = &define_sprite_cmd;
  cmd.cmd_len = sizeof(define_sprite_cmd);
  cmd.res = &res;
  cmd.res_len = 1;
  subcpu_call(&cmd);

  cmd.cmd = &draw_sprite_cmd;
  cmd.cmd_len = sizeof(draw_sprite_cmd);

  unsigned int i = 0;
  char* ycoord = &(draw_sprite_cmd[2]);
  *ycoord = 0;
  int ts1 = clock();
  for (; i < 16384; ++i) {
    *ycoord = (*ycoord) + 1;
    if (*ycoord > 42) {
      *ycoord = 0;
    }
    subcpu_call(&cmd);
  }

  int ts2 = clock();
  printf("%d\n", ts2 - ts1);
}

int main() {
  clg();

  c_benchmark();
  asm_benchmark();

  int a = 0;
  scanf("%d\n", &a);
}
