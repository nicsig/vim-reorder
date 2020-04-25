" Interface {{{1
fu reorder#op(type) abort "{{{2
    let s:type = a:type

    if a:type is# 'line' || a:type is# 'V'
        call s:reorder_lines()
    else
        let cb_save  = &cb
        let sel_save = &selection
        let reg_save = ['"', getreg('"'), getregtype('"')]
        try
            set cb-=unnamed cb-=unnamedplus
            set selection=inclusive

            if s:type is# 'char'
                norm! `[v`]y
            elseif s:type is# 'v'
                norm! `<v`>y
            elseif s:type is# "\<c-v>"
                norm! gvy
            elseif s:type is# 'block'
                exe "norm! `[\<c-v>`]y"
            endif

            call s:paste_new_text(s:reorder_non_linewise_text())
        catch
            return lg#catch()
        finally
            let &cb  = cb_save
            let &sel = sel_save
            call call('setreg', reg_save)
        endtry
    endif

    " don't delete `s:how`, it would break the redo command
    unlet! s:type
endfu

" Core {{{1
fu s:paste_new_text(contents) abort "{{{2
    let reg_type = (s:type is# 'block' || s:type is# "\<c-v>") ? 'b' : ''
    call setreg('"', a:contents, reg_type)
    norm! gv""p
endfu

fu s:reorder_lines() abort "{{{2
    let range = s:type is# 'line' ? "'[,']" : "'<,'>"
    let firstline = s:type is# 'line' ? line("'[") : line("'<")
    let lastline = s:type is# 'line' ? line("']") : line("'>")

    if s:how is# 'sort'
        let lines = getline(firstline, lastline)
        let flag = s:contains_only_digits(lines) ? ' n' : ''
        exe range..'sort'..flag

    elseif s:how is# 'reverse'
        let [fen_save, winid, bufnr] = [&l:fen, win_getid(), bufnr('%')]
        try
            let &l:fen = 0
            exe 'keepj keepp '..range..'g/^/m '..(firstline - 1)
        finally
            if winbufnr(winid) == bufnr
                let [tabnr, winnr] = win_id2tabwin(winid)
                call settabwinvar(tabnr, winnr, '&fen', fen_save)
            endif
        endtry

    elseif s:how is# 'shuf'
        exe 'sil keepj keepp '..range..'!shuf'
    endif
endfu

fu s:reorder_non_linewise_text() abort "{{{2
    if s:type is# 'block' || s:type is# "\<c-v>"
        let texts_to_reorder = split(@")
        let sep_join = "\n"
        "   │
        "   └ separator which will be added between 2 consecutive texts

    elseif s:type is# 'char' || s:type is# 'v'
        " Try to guess what is the separator between the texts we want to sort.{{{
        " Could be a comma, a semicolon, or spaces.
        " We want a pattern, so `sep_split` may be:
        "
        "     ',\s*'
        "     ';\s*'
        "     '\s\+'
        "}}}
        let sep_split = @" =~# '[,;]'
                    \ ?     matchstr(@", '[,;]').'\s*'
                    \ :     '\s\+'

        let texts_to_reorder = split(@", sep_split)
        " remove surrounding whitespace
        call map(texts_to_reorder, {_,v -> matchstr(v, '^\s*\zs.\{-}\ze\s*$')})

        " `join()` doesn't interpret its 2nd argument the same way `split()` does:{{{
        "
        "     split():  regex
        "     join():   literal string
        "
        " `sep_join` may be:
        "
        "     ', '
        "     '; '
        "     ' '
        "     ','
        "     ';'
        "     ';'
        "}}}
        let has_space = !empty(matchstr(@", '\s'))
        let rep = has_space ? ' ' : ''
        let sep_join = substitute(sep_split, '^\\s\\+$\|\\s\*$', rep, '')
    endif

    let func = s:contains_only_digits(texts_to_reorder) ? 'N' : ''
    sil return s:how is# 'sort'
       \ ?     join(sort(texts_to_reorder, func), sep_join)
       \ : s:how is# 'reverse'
       \ ?     join(reverse(texts_to_reorder), sep_join)
       \ :     join(systemlist('shuf', texts_to_reorder), sep_join)
endfu

" Utility {{{1
fu s:contains_only_digits(...) abort "{{{2
    " if  the text  contains  only  digits, we  want  a  numerical sorting  (not
    " lexicographic)

    " Vim passes a variable to a function by reference not by copy,
    " and we don't want `map()` and `filter()` to alter the text.
    let texts = deepcopy(a:1)
    call map(texts, {_,v -> matchstr(v, '\D')})
    call filter(texts, {_,v -> v != ''})
    return empty(texts)
endfu

fu reorder#set_how(order_type) abort "{{{2
    let s:how = a:order_type
endfu
