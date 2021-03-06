/*
 * File:
 *   mod_mem.c
 * Author(s):
 *   Pascal Felber <pascal.felber@unine.ch>
 *   Patrick Marlier <patrick.marlier@unine.ch>
 * Description:
 *   Module for dynamic memory management.
 *
 * Copyright (c) 2007-2011.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation, version 2
 * of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "mod_mem.h"

#include "gc.h"
#include "stm.h"

/* ################################################################### *
 * TYPES
 * ################################################################### */

typedef struct mod_mem_block {          /* Block of allocated memory */
  void *addr;                           /* Address of memory */
  struct mod_mem_block *next;           /* Next block */
} mod_mem_block_t;

typedef struct mod_mem_info {           /* Memory descriptor */
  mod_mem_block_t *allocated;           /* Memory allocated by this transation (freed upon abort) */
  mod_mem_block_t *freed;               /* Memory freed by this transation (freed upon commit) */
} mod_mem_info_t;

static int mod_mem_key;
static int mod_mem_initialized = 0;
#ifdef EPOCH_GC
static int mod_mem_use_gc = 0;
#endif /* EPOCH_GC */

/* ################################################################### *
 * FUNCTIONS
 * ################################################################### */

/*
 * Called by the CURRENT thread to allocate memory within a transaction.
 */
void *stm_malloc(TXPARAMS size_t size)
{
  /* Memory will be freed upon abort */
  mod_mem_info_t *mi;
  mod_mem_block_t *mb;

  if (!mod_mem_initialized) {
    fprintf(stderr, "Module mod_mem not initialized\n");
    exit(1);
  }

  mi = (mod_mem_info_t *)stm_get_specific(TXARGS mod_mem_key);
  assert(mi != NULL);

  /* ASF can abort anywhere => libc malloc is not safe for this */
#ifdef HYDRID_ASF
  if (stm_hybrid()) {
    stm_set_software();
    /* Unreachable point */
  }
#endif /* HYBRID_ASF */

  /* Round up size */
  if (sizeof(stm_word_t) == 4) {
    size = (size + 3) & ~(size_t)0x03;
  } else {
    size = (size + 7) & ~(size_t)0x07;
  }

  if ((mb = (mod_mem_block_t *)malloc(sizeof(mod_mem_block_t))) == NULL) {
    perror("malloc");
    exit(1);
  }
  if ((mb->addr = malloc(size)) == NULL) {
    perror("malloc");
    exit(1);
  }
  mb->next = mi->allocated;
  mi->allocated = mb;

  return mb->addr;
}

/*
 * Called by the CURRENT thread to allocate initialized memory within a transaction.
 */
void *stm_calloc(TXPARAMS size_t nm, size_t size)
{
  /* Memory will be freed upon abort */
  mod_mem_info_t *mi;
  mod_mem_block_t *mb;

  if (!mod_mem_initialized) {
    fprintf(stderr, "Module mod_mem not initialized\n");
    exit(1);
  }

  mi = (mod_mem_info_t *)stm_get_specific(TXARGS mod_mem_key);
  assert(mi != NULL);

  /* ASF can abort anywhere => libc malloc is not safe for this */
#ifdef HYDRID_ASF
  if (stm_hybrid()) {
    stm_set_software();
    /* Unreachable point */
  }
#endif /* HYBRID_ASF */

  /* Round up size */
  if (sizeof(stm_word_t) == 4) {
    size = (size + 3) & ~(size_t)0x03;
  } else {
    size = (size + 7) & ~(size_t)0x07;
  }

  if ((mb = (mod_mem_block_t *)malloc(sizeof(mod_mem_block_t))) == NULL) {
    perror("malloc");
    exit(1);
  }
  if ((mb->addr = calloc(nm, size)) == NULL) {
    perror("malloc");
    exit(1);
  }
  mb->next = mi->allocated;
  mi->allocated = mb;

  return mb->addr;
}

/*
 * Called by the CURRENT thread to free memory within a transaction.
 */
void stm_free(TXPARAMS void *addr, size_t size)
{
  stm_free2(TXARGS addr, 0, size);
}

/*
 * Called by the CURRENT thread to free memory within a transaction.
 */
void stm_free2(TXPARAMS void *addr, size_t idx, size_t size)
{
  /* Memory disposal is delayed until commit */
  mod_mem_info_t *mi;
  mod_mem_block_t *mb;
  stm_word_t *a;

  if (!mod_mem_initialized) {
    fprintf(stderr, "Module mod_mem not mod_mem_initialized\n");
    exit(1);
  }

  mi = (mod_mem_info_t *)stm_get_specific(TXARGS mod_mem_key);
  assert(mi != NULL);

  /* ASF can abort anywhere => libc malloc is not safe for this */
#ifdef HYDRID_ASF
  if (stm_hybrid()) {
    stm_set_software();
    /* Unreachable point */
  }
#endif /* HYBRID_ASF */

  /* TODO: if block allocated in same transaction => no need to overwrite */
  if (size > 0) {
    /* Overwrite to prevent inconsistent reads */
    if (sizeof(stm_word_t) == 4) {
      idx = (idx + 3) >> 2;
      size = (size + 3) >> 2;
    } else {
      idx = (idx + 7) >> 3;
      size = (size + 7) >> 3;
    }
    a = (stm_word_t *)addr + idx;
    while (size-- > 0) {
      /* Acquire lock and update version number */
      stm_store2(TXARGS a++, 0, 0);
    }
  }
  /* Schedule for removal */
  if ((mb = (mod_mem_block_t *)malloc(sizeof(mod_mem_block_t))) == NULL) {
    perror("malloc");
    exit(1);
  }
  mb->addr = addr;
  mb->next = mi->freed;
  mi->freed = mb;
}

/*
 * Called upon thread creation.
 */
static void mod_mem_on_thread_init(TXPARAMS void *arg)
{
  mod_mem_info_t *mi;

  if ((mi = (mod_mem_info_t *)malloc(sizeof(mod_mem_info_t))) == NULL) {
    perror("malloc");
    exit(1);
  }
  mi->allocated = mi->freed = NULL;

  stm_set_specific(TXARGS mod_mem_key, mi);
}

/*
 * Called upon thread deletion.
 */
static void mod_mem_on_thread_exit(TXPARAMS void *arg)
{
  free(stm_get_specific(TXARGS mod_mem_key));
}

/*
 * Called upon transaction commit.
 */
static void mod_mem_on_commit(TXPARAMS void *arg)
{
  mod_mem_info_t *mi;
  mod_mem_block_t *mb, *next;
#ifdef EPOCH_GC
  stm_word_t t = 0;
#endif /* EPOCH_GC */

  mi = (mod_mem_info_t *)stm_get_specific(TXARGS mod_mem_key);
  assert(mi != NULL);

  /* Keep memory allocated during transaction */
  if (mi->allocated != NULL) {
    mb = mi->allocated;
    while (mb != NULL) {
      next = mb->next;
      free(mb);
      mb = next;
    }
    mi->allocated = NULL;
  }

  /* Dispose of memory freed during transaction */
  if (mi->freed != NULL) {
#ifdef EPOCH_GC
    if (mod_mem_use_gc)
      t = stm_get_clock();
#endif /* EPOCH_GC */
    mb = mi->freed;
    while (mb != NULL) {
      next = mb->next;
#ifdef EPOCH_GC
      if (mod_mem_use_gc)
        gc_free(mb->addr, t);
      else
        free(mb->addr);
#else /* ! EPOCH_GC */
      free(mb->addr);
#endif /* ! EPOCH_GC */
      free(mb);
      mb = next;
    }
    mi->freed = NULL;
  }
}

/*
 * Called upon transaction abort.
 */
static void mod_mem_on_abort(TXPARAMS void *arg)
{
  mod_mem_info_t *mi;
  mod_mem_block_t *mb, *next;

  mi = (mod_mem_info_t *)stm_get_specific(TXARGS mod_mem_key);
  assert (mi != NULL);

  /* Dispose of memory allocated during transaction */
  if (mi->allocated != NULL) {
    mb = mi->allocated;
    while (mb != NULL) {
      next = mb->next;
      free(mb->addr);
      free(mb);
      mb = next;
    }
    mi->allocated = NULL;
  }

  /* Keep memory freed during transaction */
  if (mi->freed != NULL) {
    mb = mi->freed;
    while (mb != NULL) {
      next = mb->next;
      free(mb);
      mb = next;
    }
    mi->freed = NULL;
  }
}

/*
 * Initialize module.
 */
void mod_mem_init(int gc)
{
  if (mod_mem_initialized)
    return;

  stm_register(mod_mem_on_thread_init, mod_mem_on_thread_exit, NULL, NULL, mod_mem_on_commit, mod_mem_on_abort, NULL);
  mod_mem_key = stm_create_specific();
  if (mod_mem_key < 0) {
    fprintf(stderr, "Cannot create specific key\n");
    exit(1);
  }
#ifdef EPOCH_GC
  mod_mem_use_gc = gc;
#endif /* EPOCH_GC */
  mod_mem_initialized = 1;
}
