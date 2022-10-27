/*
Copyright (C) Telecom Paris
Copyright (C) Renaud Pacalet (renaud.pacalet@telecom-paris.fr)

This file must be used under the terms of the CeCILL. This source
file is licensed as described in the file COPYING, which you should
have received as part of this distribution. The terms are also
available at:
http://www.cecill.info/licences/Licence_CeCILL_V1.1-US.txt
*/

/* Example user-space application. */

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>

int main()
{
    uint32_t data, ok, rh, tp;
    FILE *fd;

    fd = fopen("/dev/dht11", "r");
    if (fd == NULL) {
        printf("error: cannot open /dev/dht11 in read mode\n");
        exit(1);
    }
    if (fread(&data, 4, 1, fd) != 1) {
        printf("error: cannot read /dev/dht11\n");
        exit(1);
    }
    ok = (data >> 31) & UINT32_C(0x1);
    rh = (data >> 8) & UINT32_C(0xff);
    tp = data & UINT32_C(0xff);
    printf("Last successful acquisition:\n");
    if (ok) {
        printf("  Relative humidity: %" PRIu32 "%%\n", rh);
        printf("  Temperature:       %" PRIu32 " °C\n", tp);
    } else {
        printf("  None\n");
    }
    fclose(fd);
    return 0;
}

// vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab textwidth=0:
