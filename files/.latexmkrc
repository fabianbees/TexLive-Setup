add_cus_dep('glo', 'gls', 0, 'makeglo2gls');
sub makeglo2gls {
    system("makeindex -s 'texlive-setup/Latex_Setup.sh[0]'.ist -t 'texlive-setup/Latex_Setup.sh[0]'.glg -o 'texlive-setup/Latex_Setup.sh[0]'.gls 'texlive-setup/Latex_Setup.sh[0]'.glo");
}
