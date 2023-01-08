#ifndef MIPS_H
#define MIPS_H

#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdnoreturn.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include "errors.h"
#include "quads.h"
#include "tos.h"
extern listQ *Lglobal;
extern struct tos_entry **tos;

void mips(void);

void QuadToMips(listQ *liste, char *buffer);

/* Une variable temporaire porte le nom : __TEMP__NUM 
Cette fonction retourne le NUM par exemple __TEMP__15 
la fonction renverra 15*/

int isTemporaryVariable(const char *varName);

#endif