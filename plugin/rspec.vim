let s:plugin_path = expand("<sfile>:p:h:h")

if !exists("g:rspec_runner")
  let g:rspec_runner = "os_x_terminal"
endif

if !exists("g:rspec_command")
  if exists("g:rspec_clear") && g:rspec_clear == "on"
    let s:cmd = "clear && rspec {spec}"
  else
    let s:cmd = "rspec {spec}"
  endif

  if has("gui_running") && has("gui_macvim")
    let g:rspec_command = "silent !" . s:plugin_path . "/bin/" . g:rspec_runner . " '" . s:cmd . "'"
  elseif has("win32") && fnamemodify(&shell, ':t') ==? "cmd.exe"
    let g:rspec_command = "!cls && echo " . s:cmd . " && " . s:cmd
  else
    let g:rspec_command = "!clear && echo " . s:cmd . " && " . s:cmd
  endif
endif

function! RunAllSpecs()
  let l:spec = "spec"
  call SetLastSpecCommand(l:spec)
  call RunSpecs(l:spec)
endfunction

function! RunCurrentSpecFile()
  if InSpecFile()
    let l:spec = @%
    call SetLastSpecCommand(l:spec)
    call RunSpecs(l:spec)
  else
    call RunLastSpec()
  endif
endfunction

function! RunNearestSpec()
  if InSpecFile()
    let l:spec = @% . ":" . line(".")
    call SetLastSpecCommand(l:spec)
    call RunSpecs(l:spec)
  else
    call RunLastSpec()
  endif
endfunction

function! RunLastSpec()
  if exists("s:last_spec_command")
    call RunSpecs(s:last_spec_command)
  endif
endfunction

function! InSpecFile()
  return match(expand("%"), "_spec.rb$") != -1
endfunction

function! SetLastSpecCommand(spec)
  let s:last_spec_command = a:spec
endfunction

function! RunSpecs(spec)
  execute ":wall"
  execute substitute(g:rspec_command, "{spec}", a:spec, "g")
endfunction

function! LoadAndDisplayRSpecQuickfix()
  if filereadable(g:quickfix_filename) && getfsize(g:quickfix_filename) != 0
    silent execute ":cfile " . g:quickfix_filename
    cclose
  else
    redraw!
    echohl WarningMsg | echo "Quickfix file " . g:quickfix_filename . " is missing or empty." | echohl None
  endif
endfunction
