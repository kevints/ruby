#include "ruby/ruby.h"
#include <pthread.h>
#include <stdio.h>

extern void gc_start_mark(void* objspace);
extern void gc_do_mark(void* objspace, VALUE ptr);

void gc_mark_parallel(void* objspace) {
    printf("~~rs\n");
    gc_start_mark(objspace);
    printf("~~re\n");
}

void gc_mark_defer(void *objspace, VALUE ptr, int lev) {
    printf("~~ns\n");
    printf("~~%d\n", ptr);
    gc_do_mark(objspace, ptr);
    printf("~~ne\n");
}
