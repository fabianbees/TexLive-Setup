#!/bin/bash


install_version="full"


#####
## Simple command options parser
#####
while (( "$#" )); do

    case $1 in
        --min|--minimal)
            install_version="min"
            ;;
        --full)
            install_version="full"
            ;;
        -h|--help)
            help
            ;;
        *)
            help
            err "Unknown argument $1"
            ;;
    esac

    shift
done



help() {
            echo "Usage: $0 [--min|--full|--help]

Installs latest texlive environment.

Optional Arguments:
  --min, --minimal     Install minimal variant
  --full               Install the full distribution
  --help               Print this help dialog
"
        exit 2
}

guard_run_as_root () {
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges"
    exit 2
  fi  
}



function fail {
  echo $1 >&2
  exit 1
}

trap 'fail "The execution was aborted because a command exited with an error status code."' ERR

function retry {
  local n=1
  local max=10
  local delay=30

  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "Command failed. Attempt $n/$max:"
        sleep $delay;
      else
        fail "The command has failed after $n attempts."
      fi
    }
  done
}


# Ask for root execution
guard_run_as_root


apt update -y
apt upgrade -y

apt install perl ca-certificates wget -y

mkdir /tmp/texlive-install
cd /tmp/texlive-install

wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar xvzf install-tl-unx.tar.gz
cd ./install-tl-2*


# Config-File for TexLive 2023
cat > ./texlive-custom_2023.profile << EOF
# texlive.profile written on Mon May 17 08:31:10 2023 UTC
# It will NOT be updated and reflects only the
# installation profile at installation time.
selected_scheme scheme-custom
TEXDIR /usr/local/texlive/2023
TEXMFCONFIG ~/.texlive2023/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/2023/texmf-config
TEXMFSYSVAR /usr/local/texlive/2023/texmf-var
TEXMFVAR ~/.texlive2023/texmf-var
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
collection-langfrench 1
collection-langgerman 1
collection-langitalian 1
collection-latex 1
collection-latexextra 1
collection-latexrecommended 1
collection-luatex 1
collection-mathscience 1
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

# Config-File for TexLive 2023
cat > ./texlive-MINIMAL_2023.profile << EOF
# texlive.profile written on Tue May 18 07:14:59 2023 UTC
# It will NOT be updated and reflects only the
# installation profile at installation time.
selected_scheme scheme-basic
TEXDIR /usr/local/texlive/2023
TEXMFCONFIG ~/.texlive2023/texmf-config
TEXMFHOME ~/texmf
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/2023/texmf-config
TEXMFSYSVAR /usr/local/texlive/2023/texmf-var
TEXMFVAR ~/.texlive2023/texmf-var
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

case $(arch) in 
    aarch64)
        echo "binary_aarch64-linux 1" | tee -a ./texlive-custom_2023.profile ./texlive-MINIMAL_2023.profile
        ;;
    x86)
        echo "binary_x86_64-linux 1" | tee -a ./texlive-custom_2023.profile ./texlive-MINIMAL_2023.profile
        ;;
    armhf)
        echo "binary_armhf-linux 1" | tee -a ./texlive-custom_2023.profile ./texlive-MINIMAL_2023.profile
        ;;
esac


#start installation
if [ $install_version == 'full' ]
then
    echo "FULL INSTALLATION"
    retry ./install-tl --profile ./texlive-custom_2023.profile
elif [ $install_version == 'min' ]
then
    echo "MINIMAL INSTALLATION"
    retry ./install-tl --profile ./texlive-MINIMAL_2023.profile
else
    echo "ERROR: trying to install a unknown version of texlive!"
fi

cd ~
rm -rf /tmp/texlive-install


# This file is needed for the glossary to work
cat > ~/.latexmkrc << EOF
# --> See: https://tex.stackexchange.com/questions/1226/how-to-make-latexmk-use-makeglossaries



add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
#add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    my ($base_name, $path) = fileparse( $_[0] ); #handle -outdir param by splitting path and file, ...
    pushd $path; # ... cd-ing into folder first, then running makeglossaries ...

    if ( $silent ) {
        system "makeglossaries -q '$base_name'"; #unix
        # system "makeglossaries", "-q", "$base_name"; #windows
    }
    else {
        system "makeglossaries '$base_name'"; #unix
        # system "makeglossaries", "$base_name"; #windows
    };

    popd; # ... and cd-ing back again
}
EOF

cat > /usr/local/texlive/update_texlive.sh << EOF
#!/bin/bash
sudo tlmgr update --self
sudo tlmgr update --all
EOF
chmod +x /usr/local/texlive/update_texlive.sh
ln -s /usr/local/texlive/update_texlive.sh /usr/local/bin/update_texlive.sh


echo "Tex-Live was installed successfully!"

echo "For the best experience use this extention in Visual Studio Code: https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop"
