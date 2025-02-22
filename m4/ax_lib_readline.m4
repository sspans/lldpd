# ===========================================================================
#      http://www.gnu.org/software/autoconf-archive/ax_lib_readline.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_LIB_READLINE_LLDPD
#
# DESCRIPTION
#
#   Searches for a readline compatible library. If found, defines
#   `HAVE_LIBREADLINE'. If the found library has the `add_history' function,
#   sets also `HAVE_READLINE_HISTORY'. Also checks for the locations of the
#   necessary include files and sets `HAVE_READLINE_H' or
#   `HAVE_READLINE_READLINE_H' and `HAVE_READLINE_HISTORY_H' or
#   'HAVE_HISTORY_H' if the corresponding include files exists.
#
#   The libraries that may be readline compatible are `libedit',
#   `libeditline' and `libreadline'. Sometimes we need to link a termcap
#   library for readline to work, this macro tests these cases too by trying
#   to link with `libtermcap', `libcurses' or `libncurses' before giving up.
#
#   Here is an example of how to use the information provided by this macro
#   to perform the necessary includes or declarations in a C file:
#
#     #ifdef HAVE_LIBREADLINE
#     #  if defined(HAVE_READLINE_READLINE_H)
#     #    include <readline/readline.h>
#     #  elif defined(HAVE_READLINE_H)
#     #    include <readline.h>
#     #  else /* !defined(HAVE_READLINE_H) */
#     extern char *readline ();
#     extern int rl_insert_text(const char*);
#     extern void rl_forced_update_display(void);
#     extern int rl_bind_key(int, int(*f)(int, int));
#     #  endif /* !defined(HAVE_READLINE_H) */
#     char *cmdline = NULL;
#     #else /* !defined(HAVE_READLINE_READLINE_H) */
#       /* no readline */
#     #endif /* HAVE_LIBREADLINE */
#
#     #ifdef HAVE_READLINE_HISTORY
#     #  if defined(HAVE_READLINE_HISTORY_H)
#     #    include <readline/history.h>
#     #  elif defined(HAVE_HISTORY_H)
#     #    include <history.h>
#     #  else /* !defined(HAVE_HISTORY_H) */
#     extern void add_history ();
#     extern int write_history ();
#     extern int read_history ();
#     #  endif /* defined(HAVE_READLINE_HISTORY_H) */
#       /* no history */
#     #endif /* HAVE_READLINE_HISTORY */
#
# LICENSE
#
#   Copyright (c) 2008 Ville Laurikari <vl@iki.fi>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

# Modified version to include support for pkg-config. Original version is
# available here:
#  http://www.gnu.org/software/autoconf-archive/ax_lib_readline.html

#serial 6

AU_ALIAS([VL_LIB_READLINE], [AX_LIB_READLINE_LLDPD])
AC_DEFUN([AX_LIB_READLINE_LLDPD], [
  if test -z "$ax_cv_lib_readline"; then
    PKG_CHECK_MODULES(READLINE, readline, [ax_cv_lib_readline="$READLINE_LIBS"; ax_cv_lib_readline_cflags="$READLINE_CFLAGS"], [:])
  fi
  if test -z "$ax_cv_lib_readline"; then
    PKG_CHECK_MODULES(LIBEDIT, libedit, [ax_cv_lib_readline="$LIBEDIT_LIBS"; ax_cv_lib_readline_cflags="$LIBEDIT_CFLAGS"], [:])
  fi
  if test -z "$ax_cv_lib_readline"; then
    PKG_CHECK_MODULES(LIBEDITLINE, libeditline, [ax_cv_lib_readline="$LIBEDITLINE_LIBS"; ax_cv_lib_readline_cflags="$LIBEDITLINE_CFLAGS"], [:])
  fi
  if test -z "$ax_cv_lib_readline"; then
    AC_CACHE_CHECK([for a readline compatible library],
                 ax_cv_lib_readline, [
      _save_LIBS="$LIBS"
      for readline_lib in readline edit editline; do
        for termcap_lib in "" termcap curses ncurses; do
          if test -z "$termcap_lib"; then
            TRY_LIB="-l$readline_lib"
          else
            TRY_LIB="-l$readline_lib -l$termcap_lib"
          fi
          LIBS="$ORIG_LIBS $TRY_LIB"
          for readline_func in readline rl_insert_text rl_forced_update_display; do
            AC_TRY_LINK_FUNC($readline_func, ax_cv_lib_readline="$TRY_LIB", ax_cv_lib_readline="")
            if test -z "$ax_cv_lib_readline"; then
              break
            fi
          done
          if test -n "$ax_cv_lib_readline"; then
            break
          fi
        done
        if test -n "$ax_cv_lib_readline"; then
          break
        fi
      done
      if test -z "$ax_cv_lib_readline"; then
        ax_cv_lib_readline="no"
      fi
      LIBS="$_save_LIBS"
    ])
  fi

  if test "$ax_cv_lib_readline" != "no"; then
    READLINE_LIBS="$ax_cv_lib_readline"
    READLINE_CLFAGS="$ax_cv_lib_readline_cflags"
    AC_SUBST(READLINE_LIBS)
    AC_SUBST(READLINE_CFLAGS)

    _save_LIBS="$LIBS"
    _save_CFLAGS="$CFLAGS"
    LIBS="$LIBS $ax_cv_lib_readline"
    CFLAGS="$LIBS $ax_cv_lib_readline_cflags"
    AC_DEFINE(HAVE_LIBREADLINE, 1,
              [Define if you have a readline compatible library])
    AC_CHECK_HEADERS(readline.h readline/readline.h editline/readline.h)
    AC_CACHE_CHECK([whether readline supports history],
                   ax_cv_lib_readline_history, [
      ax_cv_lib_readline_history="no"
      AC_TRY_LINK_FUNC(add_history, ax_cv_lib_readline_history="yes")
    ])
    if test "$ax_cv_lib_readline_history" = "yes"; then
      AC_DEFINE(HAVE_READLINE_HISTORY, 1,
                [Define if your readline library has \`add_history'])
      AC_CHECK_HEADERS(history.h readline/history.h editline/history.h)
    fi

    LIBS="$_save_LIBS"
    CFLAGS="$_save_CFLAGS"
  fi
])dnl
