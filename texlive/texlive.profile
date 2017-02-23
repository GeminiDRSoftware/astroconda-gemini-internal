# texlive.profile written on Fri Feb 17 17:09:27 2017 UTC
# It will NOT be updated and reflects only the
# installation profile at installation time.
#
# Options equivalent to something like this in the interactive installer (not
# including package selection):
# D
# 1
# ${PREFIX}/texlive
# R
# O
# P
# R
# I
#
# For some reason, the option to use letter-sized paper by default seems to
# cause an obscure failure (looking for things under the wrong install path).
#
# The documentation, source & extra fonts are omitted (along with a handful of
# unneeded features) because they are enormous and cause the package build &
# install to take 3hrs & 0.5hr, respectively (per dependent package build!).
#
selected_scheme scheme-full
TEXDIR ${PREFIX}/texlive
TEXMFCONFIG ~/.texlive2016/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL texmf-local
TEXMFSYSCONFIG ${PREFIX}/texlive/texmf-config
TEXMFSYSVAR ${PREFIX}/texlive/texmf-var
TEXMFVAR ~/.texlive2016/texmf-var
binary_x86_64-linux 0
binary_x86_64-darwin 0
collection-basic 1
collection-bibtexextra 1
collection-binextra 1
collection-context 0
collection-fontsextra 0
collection-fontsrecommended 1
collection-fontutils 1
collection-formatsextra 0
collection-games 0
collection-genericextra 1
collection-genericrecommended 1
collection-htmlxml 1
collection-humanities 0
collection-langafrican 0
collection-langarabic 0
collection-langchinese 0
collection-langcjk 0
collection-langcyrillic 0
collection-langczechslovak 0
collection-langenglish 1
collection-langeuropean 0
collection-langfrench 1
collection-langgerman 0
collection-langgreek 1
collection-langindic 0
collection-langitalian 0
collection-langjapanese 0
collection-langkorean 1
collection-langother 0
collection-langpolish 0
collection-langportuguese 1
collection-langspanish 1
collection-latex 1
collection-latexextra 1
collection-latexrecommended 1
collection-luatex 1
collection-mathscience 1
collection-metapost 1
collection-music 0
collection-omega 0
collection-pictures 1
collection-plainextra 1
collection-pstricks 1
collection-publishers 1
collection-texworks 1
collection-xetex 1
in_place 0
option_adjustrepo 1
option_autobackup 1
option_backupdir tlpkg/backups
option_desktop_integration 1
option_doc 0
option_file_assocs 1
option_fmt 1
option_letter 0
option_menu_integration 1
option_path 1
option_post_code 1
option_src 0
option_sys_bin ${PREFIX}/bin
option_sys_info ${PREFIX}/share/info
option_sys_man ${PREFIX}/share/man
option_w32_multi_user 1
option_write18_restricted 1
portable 0
