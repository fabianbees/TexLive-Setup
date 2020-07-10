#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install perl ca-certificates wget -y

mkdir /tmp/texlive-install
cd /tmp/texlive-install

wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar xvzf install-tl-unx.tar.gz
cd ./install-tl-2*


#Config-File for TexLive 2020
cat > ./texlive-custom_2020.profile << EOF
# texlive.profile written on Tue Apr 14 14:03:58 2020 UTC
# It will NOT be updated and reflects only the
# installation profile at installation time.
selected_scheme scheme-custom
TEXDIR /usr/local/texlive/2020
TEXMFCONFIG ~/.texlive2020/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/2020/texmf-config
TEXMFSYSVAR /usr/local/texlive/2020/texmf-var
TEXMFVAR ~/.texlive2020/texmf-var
binary_x86_64-linux 1
collection-basic 1
collection-bibtexextra 1
collection-binextra 1
collection-context 1
collection-fontsextra 1
collection-fontsrecommended 1
collection-fontutils 1
collection-formatsextra 1
collection-games 1
collection-humanities 1
collection-langenglish 1
collection-langgerman 1
collection-latex 1
collection-latexextra 1
collection-latexrecommended 1
collection-metapost 1
collection-pictures 1
collection-plaingeneric 1
collection-pstricks 1
collection-publishers 1
instopt_adjustpath 1
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 1
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 1
tlpdbopt_file_assocs 1
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 1
tlpdbopt_install_srcfiles 1
tlpdbopt_post_code 1
tlpdbopt_sys_bin /usr/local/bin
tlpdbopt_sys_info /usr/local/info
tlpdbopt_sys_man /usr/local/man
tlpdbopt_w32_multi_user 1
EOF


# This file is needed for the glossary to work
cat > ~/.latexmkrc << EOF
add_cus_dep('glo', 'gls', 0, 'makeglo2gls');
sub makeglo2gls {
    system("makeindex -s '$_[0]'.ist -t '$_[0]'.glg -o '$_[0]'.gls '$_[0]'.glo");
}
EOF

cat > ~/update_texlive.sh << EOF
#!/bin/bash
sudo tlmgr update --self
sudo tlmgr update --all
EOF

sudo chmod +x ~/update_texlive.sh

#start installation
sudo ./install-tl --profile=texlive-custom_2020.profile

cd ~
sudo rm -rf /tmp/texlive-install


echo "Tex-Live was installed successfully!"

echo "For the best experience use this extention in Visual Studio Code: https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop"