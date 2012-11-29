#include "ruby/ruby.h"
#include <pthread.h>
#include <stdlib.h>
/* 
 * Mocks for functions defined in gc.c
 */



static pthread_mutex_t marked_set_lock;

extern void mocks_init() {
    /* pthread_mutex_init(&marked_set_lock); */
}


extern void gc_do_mark(void* objspace, VALUE ptr) {
    
}
extern void gc_start_mark(void* objspace) {

}

int gc_defer_mark = 1;


