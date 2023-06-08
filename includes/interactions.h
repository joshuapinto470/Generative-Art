#pragma once

#include <stdio.h>
#define W 1920
#define H 1080

#define TITLE_STRING "Generative"

float Shiftrange(float c, float d, float t)
{
   return c + (float)(d - c) * t;
}