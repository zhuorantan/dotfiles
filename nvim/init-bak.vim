" ========== LSP ==========
hi default LspErrorSign     ctermfg=Red     guifg=#ff0000 guibg=NONE
hi default LspWarningSign   ctermfg=Brown   guifg=#ff922b guibg=NONE
hi default LspInfoSign      ctermfg=Yellow  guifg=#fab005 guibg=NONE
hi default LspHintSign      ctermfg=Blue    guifg=#15aabf guibg=NONE

sign define LspDiagnosticsSignError text=>> linehl= texthl=LspErrorSign numhl=LspErrorSign
sign define LspDiagnosticsSignWarning text=⚠  linehl= texthl=LspWarningSign numhl=LspWarningSign
sign define LspDiagnosticsSignInformation text=>> linehl= texthl=LspInfoSign numhl=LspInfoSign
sign define LspDiagnosticsSignHint text=>> linehl= texthl=LspHintSign numhl=LspHintSign
