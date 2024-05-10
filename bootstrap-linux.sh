#!/bin/bash

#-------------------------------------------------------------------------------------------
# Script para carga inicial de uma instalação linux, especificamente Ubuntu e derivados.
#-------------------------------------------------------------------------------------------
readonly bold=$(tput bold)
readonly red=$(tput setaf 1)
readonly green=$(tput setaf 10)
readonly reset=$(tput sgr0)
readonly yellow=$(tput setaf 11)
readonly white=$(tput setaf 15)
readonly blue=$(tput setaf 4)
readonly purple=$(tput setaf 5)
readonly orange=$(tput setaf 208)
readonly gray=$(tput setaf 250) 
readonly data=$(date '+%a %d/%b/%Y às %H:%M')

WORK_DESENVOLVIMENTO_FERRAMENTAS="/work/desenvolvimento/ferramentas"
JAVA_HOME_WORK=
MAVEN_HOME_WORK=
DIR_WALLPAPER="/usr/share/wallpapers/${USER}Collection"
NOME_ESTACAO=$(hostname -f)
NOME_USUARIO=$(whoami)
INSECURE_REGISTRIES_DOCKER=
MAVEN_URL_RELEASES="http://www-us.apache.org/dist/maven/maven-3/"
USA_GTK3="S"
ehCorporativo="n"

inicializa(){    
    cabecalho true
    tput setaf 7 && echo "Antes de começar..."    
    read -p "Esta é uma estação de trabalho corporativa? ${green}Esta opção ditará aplicação de proxy, por exemplo.${reset} [S/n] (Padrão ""n"") " ehCorporativo && tput setaf 2
    cabecalho true
    
    tput setaf 7 && echo "Qual o caminho para a pasta de ferramentas? (Padrão: ${red}/work/desenvolvimento/ferramentas${reset})" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then
        WORK_DESENVOLVIMENTO_FERRAMENTAS=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo "Qual o caminho para home da JDK principal?" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        JAVA_HOME_WORK=$RESPOSTA
    fi

    cabecalho true
    tput setaf 7 && echo "Qual o caminho para home do Maven principal?" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        MAVEN_HOME_WORK=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo "Utiliza algum servidor de registro para imagens Docker além do Hub Central? Geralmente http://<host>:5000" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        INSECURE_REGISTRIES_DOCKER=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo 'Utilizar versão GTK 3? Caso escolha "N/n" será usado fallback GTK 2. (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        USA_GTK3="N"
    fi
    
    cabecalho true
    tput setaf 7 && echo "$(tput smul)Revise os dados informados$(tput rmul):" && tput setaf 2
    printVariaveis
    tput setaf 7 && echo 'Confirma os dados informados? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" != "S" ] && [ "$RESPOSTA" != "s" ]; then
        finaliza
    fi
    
}

printVariaveis(){
    echo ""
    echo "${red}Pasta ferramentas:${yellow} $WORK_DESENVOLVIMENTO_FERRAMENTAS"
    echo "${red}Java Home:${yellow} $JAVA_HOME_WORK${yellow}" $([ -z "$JAVA_HOME_WORK" ] && echo "Não preenchido." || echo "")    
    echo "${red}Maven Home:${yellow} $MAVEN_HOME_WORK${yellow}" $([ -z "$MAVEN_HOME_WORK" ] && echo "Não preenchido." || echo '')
    echo "${red}Registro Docker:${yellow} $INSECURE_REGISTRIES_DOCKER${yellow}" $([ -z "$INSECURE_REGISTRIES_DOCKER" ] && echo "Não utilizado." || echo '')
    echo "${red}Usa GTK 3:${yellow} " $([ "$USA_GTK3" = "N" ] || [ "$RESPOSTA" = "n" ] && echo "Não" || echo 'Sim')
    echo ""
}

cabecalho()
{
    clear
    echo "${yellow}===================================================================="
    echo "${yellow}  $(tput smul)BOOTSTRAP LINUX - Inicializador de Ambiente - Ubuntu e derivados$(tput rmul)  "
    echo ""
    echo "${yellow}  $(tput smul)Autor$(tput rmul)......: ${orange}Lucas Bittencourt                     "
    echo "${yellow}  $(tput smul)Execução$(tput rmul)...: ${orange}$NOME_USUARIO@$NOME_ESTACAO em ${data}${reset}${yellow} "    
    echo "${yellow}===================================================================="
    echo ""
    if [ -z "$1" ] 
        then
            echo "${bold}Dados de Inicialização:${reset}${yellow}"
            printVariaveis
    fi
    tput sgr0
}

menu(){
    cabecalho

    tput setaf 11  
    echo "Escolha uma opção a seguir:"
    echo ''
    tput setaf 9
    echo "[CTRL-C] ou [q] para sair..."
    tput setaf 2
    echo ''
    echo "[ENTER] para execução completa!"
    tput setaf 15
    echo ''
    echo '  1. Configurar os repositórios (APT) de pacotes'
    echo '  2. Atualização da distribuição'
    echo '  3. Criação do mapeamento do Home para o diretório de trabalho (Work)'
    echo '  4. Configuração do ambiente de trabalho'
    echo '  5. Instalação de pacotes extras e restritos'
    echo '  6. Remove programas supérfulos e tunning do sistema.'    
    echo ''
    tput setaf 2
    echo -n 'Qual a opção desejada : '
    tput setaf 15
    read opcaoMenu
    
    tput sgr0
    
    if [ -z "$opcaoMenu" ]; then
        executaCompleto        
    fi    
    
    case $opcaoMenu in
        q) exit 0 ;;
        1) configuraRepositorios ;;
        2) atualizaDistribuicao ;;
        3) mapeamentoDiretorioHomeParaWork ;;
        4) configuracaoAmbienteTrabalho ;;
        5) instalacaoPacotesExtras ;;
        6) tunningSistemaEClean ;;
        *) tput setaf 9 && echo "Opção ${opcaoMenu} inválida!"&& tput sgr0 && read _ && menu ;;
    esac

}

executaCompleto(){
    atualizaDistribuicao
    mapeamentoDiretorioHomeParaWork
    configuraRepositorios
    instalacaoPacotesExtras     
    configuracaoAmbienteTrabalho
    tunningSistemaEClean
    
    tput setaf 7 && echo 'Deseja reiniciar a máquina? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then 
        sudo reboot
    fi
}


configuraRepositorios(){
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Configurando os repositórios de pacotes"
    echo ''
    echo ''
    tput sgr0

    tput setaf 7 && echo 'Deseja realizar a configuração? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then    

        sudo apt install \
                apt-transport-https \
                ca-certificates \
                curl \
                software-properties-common -y
        sudo dpkg --add-architecture i386
        wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository \
                "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) \
                stable"
                
        sudo add-apt-repository ppa:papirus/papirus -y
        sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main' -y

        tput setaf 2
        echo 'Passo executado...pressione qualquer tecla para continuar ou CTRL-c para sair.'
        tput sgr0
        read

    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            
        tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

    else
        tput setaf 1 && echo 'Você digitou uma opção inválida. Pressione [ENTER] para continuar a execução do próximo passo do script.' && tput sgr0 && read _
    fi

}


atualizaDistribuicao(){

    # Atualização do ambiente linux
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Atualização da distribuição"
    echo ''
    tput sgr0

    tput setaf 7 && echo 'Deseja continuar? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then

        sudo apt update -y
        sudo apt full-upgrade -y

        tput setaf 2
        echo 'Passo executado...pressione qualquer tecla para continuar ou CTRL-c para sair.'
        tput sgr0
        read
        
    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            
        tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

    else
        tput setaf 1 && echo 'Você digitou uma opção inválida. Pressione [ENTER] para continuar a execução do próximo passo do script.' && tput sgr0 && read _
    fi

}

mapeamentoDiretorioHomeParaWork(){

    # Criação do mapeamento do Home para o diretório de trabalho (Work)
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Criação do mapeamento do Home para o diretório de trabalho (Work)"
    echo ''
    tput sgr0
    tput setaf 7 && echo 'Deseja realizar a configuração? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then

        if [ -d /work ]; then
            
            chown -R $USER:$USER /work
        
            rm -rf  ~/Área\ de\ Trabalho \
                    ~/Documentos \
                    ~/Downloads \
                    ~/Imagens \
                    ~/Modelos \
                    ~/Música \
                    ~/Público \
                    ~/Vídeos \
                    ~/Projetos

            mkdir -p	/work/área\ de\ trabalho \
                        /work/documentos \
                        /work/downloads \
                        /work/imagens \
                        /work/músicas \
                        /work/público \
                        /work/vídeos \
                        /work/projetos \
                        /work/desenvolvimento \
                        /work/programas \
                        /work/.mozilla \
                        /work/.themes \
                        /work/.icons
                        
            if [ ! -d ~/Área\ de\ Trabalho ]; then
                ln -s /work/área\ de\ trabalho ~/Área\ de\ Trabalho
            fi
            
            if [ ! -d ~/Documentos ]; then
                ln -s /work/documentos ~/Documentos
            fi
            
            if [ ! -d ~/Downloads ]; then
                ln -s /work/downloads/ ~/Downloads
            fi
            
            if [ ! -d ~/Imagens ]; then
                ln -s /work/imagens ~/Imagens
            fi
            
            if [ ! -d ~/Música ]; then
                ln -s /work/músicas ~/Música
            fi
            
            if [ ! -d ~/Público ]; then
                ln -s /work/público ~/Público
            fi
            
            if [ ! -d ~/Projetos ]; then
                ln -s /work/projetos ~/Projetos
            fi
            
            if [ ! -d ~/Desenvolvimento ]; then
                ln -s /work/desenvolvimento ~/Desenvolvimento
            fi
            
            if [ ! -d ~/.mozilla ]; then
                ln -s /work/.mozilla ~/.mozilla
            fi
            
            if [ ! -d ~/.icons ]; then
                ln -s /work/.icons ~/.icons
            fi        
            
            if [ ! -d ~/.themes ]; then
                ln -s /work/.themes ~/.themes
            fi        
            
            tput setaf 2
            echo 'Passo executado...pressione qualquer tecla para continuar ou CTRL-c para sair.'
            tput sgr0
            read
            
        else
            tput setaf 1 && echo 'Diretório /work não existe. Fim da execução do script.' && tput sgr0 && exit 1
        fi


    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            
        tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

    else
        tput setaf 1 && echo 'Você digitou uma opção inválida. Pressione [ENTER] para continuar a execução do próximo passo do script.' && tput sgr0 && read _
    fi
}



configuracaoAmbienteTrabalho(){

# Configuração do ambiente de desenvolvimento (Utilizando a partição /work).
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Configuração do ambiente de trabalho"
    echo ''
    tput sgr0

    echo "" | sudo tee --append /etc/profile > /dev/null    
    #Configuração para utilizar gtk 2
    if [[ $USA_GTK3 = N ]] ; then
        echo "SWT_GTK3=\"0\"" | sudo tee --append /etc/profile > /dev/null
    fi

    tput setaf 7 && echo 'Deseja configurar as definições de JAVA e MAVEN na estação? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then

        instalaJDK 

        install_maven 
        
        source /etc/profile
        
    elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            
        tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

    else
        tput setaf 1 && echo 'Você digitou uma opção inválida. Pressione [ENTER] para continuar a execução do próximo passo do script.' && tput sgr0 && read _
    fi

    sudo apt install docker-ce docker-ce-cli containerd.io -y
    sudo apt-get install --install-recommends winehq-stable
    sudo systemctl start docker
    sudo systemctl enable docker
    docker --version
    sudo gpasswd -a ${USER} docker
    sudo groupadd -f docker 
    sudo usermod -aG docker $USER
    
    #continuando configuracao ambiente de trabalho.
    if [[ $ehCorporativo = S ]] ; then
        cabecalho

        sudo touch /etc/docker/daemon.json
        echo "{\"insecure-registries\":[\"$INSECURE_REGISTRIES_DOCKER\"]}" | sudo tee --append /etc/docker/daemon.json > /dev/null
        
        tput setaf 7 && echo 'Como está no ambiente corporativo, deseja configurar o proxy? (S/N ou s/n)' && tput setaf 2
        read RESPOSTA
        tput sgr0

        if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then
            
            tput setaf 114 && echo '' && echo 'Alterando o arquivo /etc/wgetrc' && sed -i 's/#use_proxy = on/use_proxy = on/' /etc/wgetrc
            
            tput setaf 7 && echo '' && echo 'Digite o endereço do proxy.' && tput setaf 2
            read PROXY_HOST

            tput setaf 7 && echo '' && echo 'Digite a porta do proxy.' && tput setaf 2
            read PROXY_PORTA

            tput setaf 7 && echo '' && echo 'Digite o nome do usuário de autenticação no proxy.' && tput setaf 2
            read PROXY_USUARIO
            
            tput setaf 7 && echo '' && echo 'Digite a senha do usuário de autenticação no proxy.' && tput setaf 2
            read -s PROXY_SENHA

            tput setaf 7
            echo '# Proxy' >> ~/.bashrc
            echo 'export http_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            echo 'export https_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            echo 'export ftp_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            
            echo '# Proxy' | sudo tee --append /etc/wgetrc> /dev/null
            echo 'http_proxy = http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA/' | sudo tee --append /etc/wgetrc > /dev/null
            echo 'https_proxy = https://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA/' | sudo tee --append /etc/wgetrc > /dev/null

            echo '# Proxy' | sudo tee --append /etc/apt/apt.conf > /dev/null
            echo 'Acquire::http::Proxy "http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA";' | sudo tee --append /etc/apt/apt.conf > /dev/null
            echo 'Acquire::https::Proxy "https://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA";' | sudo tee --append /etc/apt/apt.conf > /dev/null
            
            echo '# Proxy' | sudo tee --append /etc/environment > /dev/null
            echo 'no_proxy="localhost"' | sudo tee --append /etc/environment > /dev/null
            
            tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _        

        elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            sudo rm -rf /etc/apt/apt.conf
            tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

        else
            tput setaf 1 && echo 'Você digitou uma opção inválida. Fim da execução do script.' && tput sgr0
        fi

    fi
    
    tput setaf 2
    echo 'Passo executado...pressione qualquer tecla para continuar ou CTRL-c para sair.'
    tput sgr0
    read

}

instalacaoPacotesExtras(){
    # Instalação de pacotes restritos (flash, codecs, zips, etc).
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Instalação de pacotes extras e restritos"
    echo ''
    tput sgr0

    sudo apt install bash-completion curl libavcodec-extra libdvd-pkg kubuntu-restricted-extras kubuntu-restricted-addons ssh rar unrar p7zip-rar p7zip-full gtk2-engines-murrine gtk2-engines-pixbuf gtk3-engines-unico yakuake apt-xapian-index smb4k kde-l10n-ptbr firefox-locale-br gtk3-engines-breeze papirus-icon-theme libreoffice libreoffice-style-papirus filezilla filezilla-theme-papirus libreoffice-help-pt-br libreoffice-l10n-pt-br hunspell-pt-br  hunspell-pt-pt  libreoffice-style-* libreoffice-gtk3  build-essential git partitionmanager kate kubuntu-driver-manager partitionmanager kcalc docker-ce docker-ce-cli containerd.io -y

    sudo apt install --install-recommends arc-kde adapta-kde materia-kde -y
    
    tput setaf 7 && echo 'Deseja baixar wallpapers customizados? Lembrando que irá consumir banda de internet em modo corporativo (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then       
        sudo git clone https://gist.github.com/85942af486eb79118467.git ${DIR_WALLPAPER}_1        
        sudo git clone https://github.com/LukeSmithxyz/wallpapers.git ${DIR_WALLPAPER}_2
        #sudo git clone https://github.com/kotajacob/wallpapers.git ${DIR_WALLPAPER}_3
        #sudo git clone https://github.com/himynameisxtd/wallpapers.git ${DIR_WALLPAPER}_4
    fi

    tput setaf 2
    echo 'Passo executado...pressione qualquer tecla para continuar ou CTRL-c para sair.'
    tput sgr0
    read


}



tunningSistemaEClean(){


    # Remove programas supérfulos e tunning do sistema.
    cabecalho

    tput setaf 114
    echo ''
    echo "-- Remove programas supérfulos e tunning do sistema."
    echo '    '
    tput sgr0

    #Melhorias de performace
    echo "vm.swappiness=1" | sudo tee --append /etc/sysctl.conf > /dev/null 
    echo "vm.vfs_cache_pressure=50" | sudo tee --append /etc/sysctl.conf > /dev/null 
    echo "vm.dirty_background_bytes=16777216" | sudo tee --append /etc/sysctl.conf > /dev/null 
    echo "vm.dirty_bytes=50331648" | sudo tee --append /etc/sysctl.conf > /dev/null 
    
    sudo apt remove apport kwrite k3b -y
    sudo apt auto-remove -y

}

instalaJDK(){
    local caminhoJDK=$JAVA_HOME_WORK
    
    if [ ! -d "$caminhoJDK" ]; then    
        info "Caminho da JDK não foi informado, pulando passo!"
        return
    fi
        
    info "Instalando a JDK em $caminhoJDK"
    
    sudo ln -sf "$caminhoJDK" "/usr/lib/jvm/$2"
    
    if [ "$3" = "S" ] || [ "$3" = "s" ]; then 
        if grep -Fxq "JAVA_HOME=" /etc/profile
        then
            info "Variável JAVA_HOME já configurada!"
        else
            echo "" | sudo tee --append /etc/profile > /dev/null  
            echo "# Variaveis de ambiente para desenvolvimento" | sudo tee --append /etc/profile > /dev/null  
            echo "JAVA_HOME=\"$caminhoJDK\"" | sudo tee --append /etc/profile > /dev/null  
            echo "PATH=\"\$PATH:\$JAVA_HOME/bin\"" | sudo tee --append /etc/profile > /dev/null  
        fi
    fi
    
    sudo update-alternatives --install /usr/bin/java java ${caminhoJDK}/bin/java 0;
    sudo update-alternatives --install /usr/bin/javac javac ${caminhoJDK}/bin/javac 0;
    sudo update-alternatives --install /usr/bin/javadoc javadoc ${caminhoJDK}/bin/javadoc 0;
    sudo update-alternatives --install /usr/bin/javaws javaws ${caminhoJDK}/bin/javaws 0;
    
    sudo apt install openjdk-8-jdk openjdk-11-jdk
    
}

install_maven() {

    if hash mvn 2>/dev/null; 
        then
        echo "Maven já instalado."
        mvn --version | grep "Apache Maven"
    else
    
        local caminhoMaven=$MAVEN_HOME_WORK    
        
        if [ -d "$caminhoMaven" ]; then            
            echo "M2_HOME=\"$caminhoMaven\"" | sudo tee --append /etc/profile > /dev/null  
            echo "MAVEN_HOME=\"$caminhoMaven\"" | sudo tee --append /etc/profile > /dev/null
            echo "M2=\"\$M2_HOME/bin\"" | sudo tee --append /etc/profile > /dev/null 
            echo "MAVEN_OPTS=\"Xms256m -Xmx512m\"" | sudo tee --append /etc/profile > /dev/null 
            echo "PATH=\"\$M2:\$PATH\"" | sudo tee --append /etc/profile > /dev/null         
            source /etc/profile
        fi        

        sudo wget https://raw.github.com/dimaj/maven-bash-completion/master/bash_completion.bash --output-document /etc/bash_completion.d/mvn    
    fi
    
} 

function info(){        
    echo -e "\e[36m[INFO] $1\e[0m"
}

finaliza(){

    tput setaf 2
    echo 'FIM DA CONFIGURAÇÃO DO AMBIENTE. Pressione qualquer tecla para sair...'
    tput sgr0
    read
    exit 0

}

inicializa
menu
finaliza
