if exists('g:loaded_reorder')
    finish
endif
let g:loaded_reorder = 1

" Mappings {{{1

nno <silent> gr     :<c-u>call reorder#set_how('reverse')<bar>set opfunc=reorder#main<cr>g@
nno <silent> grr    :<c-u>call reorder#set_how('reverse')<bar>set opfunc=reorder#main<bar>exe 'norm! '.v:count1.'g@_'<cr>
xno <silent> gr     :<c-u>call reorder#set_how('reverse')<bar>call reorder#main(visualmode())<cr>

nno <silent> gs     :<c-u>call reorder#set_how('sort')<bar>set opfunc=reorder#main<cr>g@
nno <silent> gss    :<c-u>call reorder#set_how('sort')<bar>set opfunc=reorder#main<bar>exe 'norm! '.v:count1.'g@_'<cr>
xno <silent> gs     :<c-u>call reorder#set_how('sort')<bar>call reorder#main(visualmode())<cr>

nno <silent> gS     :<c-u>call reorder#set_how('shuf')<bar>set opfunc=reorder#main<cr>g@
nno <silent> gSS    :<c-u>call reorder#set_how('shuf')<bar>set opfunc=reorder#main<bar>exe 'norm! '.v:count1.'g@_'<cr>
xno <silent> gS     :<c-u>call reorder#set_how('shuf')<bar>call reorder#main(visualmode())<cr>
" Usage: {{{1
"
"     gsip        sort paragraph
"     5gss        sort 5 lines
"     gsib        sort text between parentheses
"
"     gr          operator to reverse the order
"     gS          "           randomize the order
"
" When we call the operators with a characterwise motion / text-object,
" they try to guess what's the separator between the texts to sort.
" Indeed, in this case, the separator is probably not a newline, but a comma,
" a semicolon, a colon or a space.


" Sample texts to test the operators:

"     (b; c; a)    gsib
"     (b  c  a)    gsib

"     b    3gss ou gsip
"     c
"     a

