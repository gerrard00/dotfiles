" use python to generate uuid/guids, adapted from vim-nuuuid
function! NewUUID()
py3 << endpython
import vim
import sys,uuid;

# do important stuff
vim.command("return \"" + str(uuid.uuid4()) + "\"") # return from the Vim function!
endpython
endfunction

" Mappings to create uuids using NewUUID
nnoremap <Leader>uuid a<C-R>=NewUUID()<CR><Esc>
inoremap <Leader>uuid <C-R>=NewUUID()<CR>
vnoremap <Leader>uuid c<C-R>=NewUUID()<CR><Esc>0
