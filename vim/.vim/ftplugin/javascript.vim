" close preview if its still open after insert
autocmd InsertLeave <buffer> if pumvisible() == 0|pclose|endif

" match backticks
let b:match_words='`\<:\>`'
