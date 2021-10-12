"=============================================================================
" FILE: config.vim
" AUTHOR:  Shougo Matsushita <Shougo.Matsu at gmail.com>
" Last Modified: 17 Sep 2011.
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Version: 0.1, for Vim 7.2
"=============================================================================

let s:V = vital#of('neovundle')

if !exists('s:neobundles')
  let s:neobundles = {}
endif

function! neovundle#config#init()
  call s:rtp_rm_all_bundles()
  let s:neobundles = {}
endfunction

function! neovundle#config#get_neobundles()
  return s:neobundles
endfunction

function! vundle#config#bundle(arg, ...)
  let bundle = s:init_bundle(a:arg, a:000)
  if has_key(s:neobundles, bundle.path)
    call s:rtp_rm(bundle.rtpath)
  endif

  let s:neobundles[bundle.path] = bundle
  call s:rtp_add(bundle.rtpath)
endfunction

function! s:rtp_rm_all()
  call filter(values(s:neo_bundles), 's:rtp_rm(v:val.rtpath())')
endfunction

function! s:rtp_rm(dir)
  execute 'set rtp-='.fnameescape(expand(a:dir))
  execute 'set rtp-='.fnameescape(expand(a:dir.'/after'))
endfunction

function! s:rtp_add(dir) abort
  execute 'set rtp^='.fnameescape(expand(a:dir))
  execute 'set rtp+='.fnameescape(expand(a:dir.'/after'))
endfunction

function! s:init_bundle(name, opts)
  let bundle = extend(s:parse_options(a:opts),
        \ s:parse_name(substitute(a:name,"['".'"]\+','','g')))
  return extend(copy(s:bundle_base), bundle)
endfunction

function! s:parse_options(opts)
  " TODO: improve this
  if empty(a:opts)
    return {}
  endif

  if type(a:opts[0]) == type({})
    return a:opts[0]
  else
    return { 'rev': a:opts[0] }
  endif
endfunction

function! s:parse_name(arg)
  if a:arg =~ '^\s*\(gh\|github\):\S\+\|^\w[[:alnum:]-]*/[^/]\+$'
    let uri = 'https://github.com/'.split(arg, ':')[-1]
    let name = substitute(split(uri, '/')[-1], '\.git\s*$','','i')
  elseif a:arg =~ '^\s*\(git@\|git://\)\S\+'
        \   || a:arg =~ '\(file\|https\?\)://'
        \   || a:arg =~ '\.git\s*$'
    let uri = a:arg
    let name = split(substitute(uri, '/\?\.git\s*$','','i'), '/')[-1]
  else
    let name = a:arg
    let uri  = 'https://github.com/vim-scripts/'.name.'.git'
  endif

  return { 'name': name, 'uri': uri }
endfunction

let s:bundle_base = {}

function! s:bundle_base.path()
  return s:expand_path(neovundle#get_neobundle_dir().'/'.self.name)
endfunction

function! s:bundle_base.rtpath()
  return has_key(self, 'rtp') ?
        \ s:expand_path(self.path().'/'.self.rtp) : self.path()
endfunction

function! s:expand_path(path)
  return simplify(expand(a:path))
endfunction

function! s:bundle_base.has_doc()
  let rtpath = self.rtpath()
  return isdirectory(rtpath.'/doc')
  \   && (!filereadable(rtpath.'/doc/tags') || filewritable(rtpath.'/doc/tags'))
  \   && (glob(rtpath.'/doc/*.txt') != '' || glob(rtpath.'/doc/*.??x') != '')
endfunction

function! s:bundle_base.helptags()
  try
    helptags `=self.rtpath() . '/doc/'`
  catch
    call s:V.print_error('Error generating helptags in '.self.rtpath())
    call s:V.print_error(v:exception . ' ' . v:throwpoint)
  endtry
endfunction

