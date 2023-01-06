CC = gcc

CFLAGS = -g -Wall -Wextra -Werror -Wno-unused-function
LDLIBS = -lm

LEXYACC_PATH = ./lex-yacc
INCLUDE_PATH = ./include

TARGET       = sos

SRCDIR       = src
OBJDIR       = obj
BINDIR       = bin

SOURCES     := $(wildcard $(SRCDIR)/*.c)
INCLUDES    := $(wildcard $(INCLUDE_PATH)/*.h)
OBJECTS_TMP     := $(SOURCES:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

LEXSRC      := $(wildcard $(LEXYACC_PATH)/*.lex)
YACCSRC     := $(wildcard $(LEXYACC_PATH)/*.y)
LEXC		:= $(LEXSRC:$(LEXYACC_PATH)/%.lex=$(SRCDIR)/%.c)
YACCC		:= $(YACCSRC:$(LEXYACC_PATH)/%.y=$(SRCDIR)/%.c)
LEXOBJ		:= $(LEXSRC:$(LEXYACC_PATH)/%.lex=$(OBJDIR)/%.o)
YACCOBJ		:= $(YACCSRC:$(LEXYACC_PATH)/%.y=$(OBJDIR)/%.o)

OBJECTS      = $(filter-out $(LEXOBJ) $(YACCOBJ), $(OBJECTS_TMP))

OUTPUT  = $(BINDIR)/$(TARGET)

all : $(OUTPUT)

$(LEXC):
	flex -o $@ $(LEXSRC)
	@echo "\033[92mLexing complete !\033[0m"

$(YACCC):
	bison -d -o $@ $(YACCSRC) 
	@echo "\033[92mYaccing complete !\033[0m"

$(OUTPUT): $(OBJECTS) $(LEXOBJ) $(YACCOBJ)
	mkdir -p $(BINDIR)
	$(CC) -o $@ $^ $(CFLAGS) $(LDLIBS)
	@echo "\033[92mLinking complete !\033[0m"

$(OBJECTS): $(OBJDIR)/%.o : $(SRCDIR)/%.c $(INCLUDES) $(LEXC) $(YACCC)
	mkdir -p $(OBJDIR)
	$(CC) -o $@ -c $< $(CFLAGS) -I$(INCLUDE_PATH)
	@echo "\033[92mCompiling complete !\033[0m"

$(LEXOBJ): $(OBJDIR)/%.o : $(SRCDIR)/%.c $(INCLUDES) $(LEXC)
	mkdir -p $(OBJDIR)
	$(CC) -o $@ -c $< $(CFLAGS) -I$(INCLUDE_PATH)
	@echo "\033[92mCompiling lex complete !\033[0m"

$(YACCOBJ): $(OBJDIR)/%.o : $(SRCDIR)/%.c $(INCLUDES) $(YACCC)
	mkdir -p $(OBJDIR)
	$(CC) -o $@ -c $< $(CFLAGS) -I$(INCLUDE_PATH)
	@echo "\033[92mCompiling yacc complete !\033[0m"

TESTDIR = tests
test :  $(OUTPUT)
		for file in $(wildcard $(TESTDIR)/*.txt) ; do \
			echo "\033[92m-------------------------------------------------TEST-------------------------------------------------\033[0m" $${file} ; \
			rm -f mips.asm ; \
			if ! ./$(OUTPUT) < $${file}  ; then \
				echo "\n\033[91mError in $${file}\033[0m" ; \
				exit 1 ; \
			fi ; \
        done

test_mips :  $(OUTPUT)
		for file in $(wildcard $(TESTDIR)/*.txt) ; do \
			echo "\033[92m-------------------------------------------------TEST-------------------------------------------------\033[0m" $${file} ; \
			rm -f mips.asm ; \
			if ! ./$(OUTPUT) < $${file}  ; then \
				echo "\n\033[91mError in $${file}\033[0m" ; \
				exit 1 ; \
			fi ; \
			echo "\033[92m----------------------TEST MIPS----------------------\033[0m" ; \
			if ! [ -z $(spim -file mips.asm | grep error | wc -l) ]  ; then \
				echo "\n\033[91mError in $${file}'s MIPS\033[0m" ; \
				exit 1 ; \
			fi ; \
        done

.PHONY: clean doc
doc:
	mkdir -p doc
	bison --report=all --report-file=doc/yacc.output \
		--graph=doc/yacc.dot --output=/dev/null \
		lex-yacc/yacc.y
	dot -Tpdf < doc/yacc.dot > doc/yacc.pdf

clean:
	rm -f $(OBJDIR)/*.o
	rm -f $(OUTPUT)
	rm -f $(LEXC)
	rm -f $(YACCC) $(YACCC:.c=.h) $(YACCC:.c=.output)
	rm -rf doc
	rm -f mips.asm

#prefixe=compilateur
#
## exige 3 fichiers:
## - $(prefixe).y (fichier bison)
## - $(prefixe).lex (fichier flex)
## - main.c (programme principal)
## construit un exécutable nommé "main"
#
## note : le programme principal ne doit surtout pas s'appeler $(prefixe).c
## (make l'écraserait parce qu'il a une règle "%.c: %.y")
#
#all: main
#
#main: $(prefixe).tab.o lex.yy.o main.o quads.o tos.o
#	$(CC) $(LDFLAGS) $^ -o $@ $(LDLIBS) -lm
#
#quads: quads.c quads.h	
#		$(CC) -o quads.o -c quads.c -Wall -Wextra -Werror -lm
#
#tos: tos.c tos.h	
#		$(CC) -o tos.o -c tos.c -Wall -Wextra -Werror
#
#$(prefixe).tab.c: $(prefixe).y
#	bison -t -d $(prefixe).y
#
#lex.yy.c: $(prefixe).lex $(prefixe).tab.h
#	flex $(prefixe).lex
#
#doc:
#	bison --report=all --report-file=$(prefixe).output \
#		--graph=$(prefixe).dot --output=/dev/null \
#		$(prefixe).y
#	dot -Tpdf < $(prefixe).dot > $(prefixe).pdf
#
#test : main
#	./main < tests/test2.txt 
#
#clean:
#	rm -f *.o $(prefixe).tab.c $(prefixe).tab.h lex.yy.c main \
#		$(prefixe).output $(prefixe).dot $(prefixe).pdf
#