#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

/* Lower lower and lower upper bounds of ascii table */
#define LL_ASCII 0x07
#define LU_ASCII 0x0D

/*  Mid element */
#define M_ASCII  0x1B

/* Upper Lower and upper upper bound of ascii table */
#define UL_ASCII 0x20
#define UU_ASCII 0x7E

enum file_type {
ERROR,
EMPTY,
DATA,
ASCII,
};

const char * const FILE_TYPE_STRINGS[] = {
"error",
"empty",
"data",
"ASCII text",
};

extern int errno;

int print_error(char *path, int errnum) {
    return fprintf(stdout, "%s: cannot determin (%s)\n",
                   path, strerror(errnum));
}

int element_of_table(unsigned char c) {
    if((c >= LL_ASCII && c <= LU_ASCII) ||
        c == M_ASCII   ||
       (c >= UL_ASCII && c <= UU_ASCII)) {
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}

int read_file(char file_name[]) {
    int c;
    FILE *fp;
    fp = fopen(file_name, "r");
    if (fp) {
        enum run_state {
        NO_RUN,
        RAN,
        RAN_NON_ASCII,
        };
        int ran = NO_RUN;
        while ((c = getc(fp)) != EOF) {
            ran = RAN;
            if (element_of_table(c) == EXIT_FAILURE) {
                ran = RAN_NON_ASCII;
                break;
            }
        }
        fclose(fp);
        if (ran == NO_RUN) {
            return EMPTY;
        } else if (ran == RAN_NON_ASCII) {
            return DATA;
        } else {
            return ASCII;
        }
    } else {
        print_error(file_name, errno);
        return ERROR;
    }
}

int main(int argc, char *argv[]) {
    if (!(argc == 2)) {
        fprintf(stderr, "Usage: file path\n");
        return EXIT_FAILURE;
    }
    int file_guess = read_file(argv[1]);
    if (file_guess == ERROR) {
        return EXIT_SUCCESS;
    }
    else {
        printf("%s: %s\n", argv[1], FILE_TYPE_STRINGS[file_guess]);
        return EXIT_SUCCESS;
    }
}
