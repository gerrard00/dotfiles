setlocal formatprg=echo\ ts-standard\ --stdin\ %s\

autocmd BufWritePre *.ts :normal! gggqG
autocmd BufWritePre *.tsx :normal! gggqG
