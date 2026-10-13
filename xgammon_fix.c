#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>

// Forward declarations (we only need pointer types for function calls)
typedef struct _XDisplay Display;
typedef unsigned long XID;
typedef XID Cursor;
typedef struct {
    unsigned long pixel;
    unsigned short red, green, blue;
    char flags;
    char pad;
} XColor;

// Intercept XRecolorCursor to ignore invalid cursor (None = 0)
void XRecolorCursor(Display *dpy, Cursor cursor, XColor *fore, XColor *back) {
    static void (*real)(Display*, Cursor, XColor*, XColor*) = NULL;
    if (!real) real = dlsym(RTLD_NEXT, "XRecolorCursor");
    if (cursor == 0) {
        fprintf(stderr, "[xgammon-fix] XRecolorCursor(cursor=0) skipped\n");
        return;
    }
    real(dpy, cursor, fore, back);
}

// Intercept XCreateFontCursor to fallback to XC_arrow (2) if shape fails
Cursor XCreateFontCursor(Display *dpy, unsigned int shape) {
    static Cursor (*real)(Display*, unsigned int) = NULL;
    if (!real) real = dlsym(RTLD_NEXT, "XCreateFontCursor");
    Cursor c = real(dpy, shape);
    if (c == 0) {
        fprintf(stderr, "[xgammon-fix] XCreateFontCursor(%u) failed, trying arrow\n", shape);
        c = real(dpy, 2); // XC_arrow
    }
    return c;
}
