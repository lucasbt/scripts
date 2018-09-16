#!/bin/bash

#-------------------------------------------------------------------------------------------
# Script para carga inicial de uma instalação linux, especificamente Ubuntu e derivados.
#-------------------------------------------------------------------------------------------
red=`tput setaf 9 && tput bold`
green=`tput setaf 2`
reset=`tput sgr0`
yellow=`tput setaf 11`
bold=`tput bold`

WORK_DESENVOLVIMENTO_FERRAMENTAS="/work/desenvolvimento/ferramentas"
JAVA_HOME_WORK=
MAVEN_HOME_WORK=
DIR_WALLPAPER="/usr/share/wallpapers/${USER}Collection"
NOME_ESTACAO=$(hostname -f)
INSECURE_REGISTRIES_DOCKER=
MAVEN_URL_RELEASES="http://www-us.apache.org/dist/maven/maven-3/"
USA_GTK3="S"
ehCorporativo="n"

inicializa(){
    cabecalho true
    tput setaf 7 && echo "Antes de começar me responda..."
    read -p "Esta é uma estação de trabalho corporativa? ${green}Esta opção ditará aplicação de proxy, por exemplo.${reset} [S/n] (Padrão ""n"") " ehCorporativo && tput setaf 2
    cabecalho true
    
    tput setaf 7 && echo "Qual o caminho para a pasta de ferramentas? (Padrão: ${red}/work/desenvolvimento/ferramentas)${reset}" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then
        WORK_DESENVOLVIMENTO_FERRAMENTAS=$RESPOSTA
    fi
    
    cabecalho true
    tput setaf 7 && echo "Qual o caminho para home da JDK? ${red}Caso não informe será realizado download da mais recente JDK 8 e descompactará em $WORK_DESENVOLVIMENTO_FERRAMENTAS.${reset}" && tput setaf 2
    read RESPOSTA && tput sgr0
    if [ ! -z "$RESPOSTA" ]; then 
        JAVA_HOME_WORK=$RESPOSTA
    fi

    cabecalho true
    tput setaf 7 && echo "Qual o caminho para home do Maven? ${red}Caso não informe será realizado download da release mais nova a partir de $MAVEN_URL_RELEASES e descompactará em $WORK_DESENVOLVIMENTO_FERRAMENTAS.${reset}" && tput setaf 2
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
    tput setaf 7 && echo 'Revise os dados informados:' && tput setaf 2
    printVariaveis
    tput setaf 7 && echo 'Confirma os dados informados? (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
        finaliza
    fi
    
}

printVariaveis(){
    echo ""
    echo "- ${red}Pasta ferramentas:${reset} $WORK_DESENVOLVIMENTO_FERRAMENTAS${yellow}"
    echo "- ${red}Java Home:${reset} $JAVA_HOME_WORK${yellow}" $([ -z "$JAVA_HOME_WORK" ] && echo "Não preenchido ainda. Vai efetuar o download mais a frente.." || echo "")    
    echo "- ${red}Maven Home:${reset} $MAVEN_HOME_WORK${yellow}" $([ -z "$MAVEN_HOME_WORK" ] && echo "Não preenchido ainda." || echo '')
    echo "- ${red}Registro Docker:${reset} $INSECURE_REGISTRIES_DOCKER${yellow}" $([ -z "$INSECURE_REGISTRIES_DOCKER" ] && echo "Não utilizado." || echo '')
    echo "- ${red}Usa GTK 3:${reset} " $([ "$USA_GTK3" = "N" ] || [ "$RESPOSTA" = "n" ] && echo "Não" || echo 'Sim')
    echo ""
}

cabecalho()
{
    clear
    tput setaf 11
    
    if [ -z "$1" ] 
        then
            echo ""
            echo "##### Script de Inicialização de Ambiente Linux - Ubuntu e derivados ${red}@$NOME_ESTACAO${reset}${yellow} por Lucas Bittencourt #####"
            echo ""
            echo "${bold}Dados de Inicialização:${reset}${yellow}"
            printVariaveis
    else
            echo ""
            echo "##### Script de Inicialização de Ambiente Linux - Ubuntu e derivados ${red}@$NOME_ESTACAO${reset}${yellow} por Lucas Bittencourt #####"
            echo ""
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
    echo '1. Configurar os repositórios (APT) de pacotes'
    echo '2. Atualização da distribuição'
    echo '3. Criação do mapeamento do Home para o diretório de trabalho (Work)'
    echo '4. Configuração do ambiente de trabalho'
    echo '5. Instalação de pacotes extras e restritos'
    echo '6. Remove programas supérfulos e tunning do sistema.'    
    echo ''
    echo -n 'Qual a opção desejada : '
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


configuraRepositorios(){

    # Configuração dos repositórios internos da Fóton e de terceiros.
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

#        if [ "$ehCorporativo" = "S" ]; then
#            sudo mv /etc/apt/sources.list /etc/apt/sources.list.original
#            sudo touch /etc/apt/sources.list
#            echo '# Ubuntu 16.04 (Xenial Xerus) Daily Build'  | sudo tee --append /etc/apt/sources.list > /dev/null
#            echo 'deb http:://172.25.1.170/repo/mirror/archive.ubuntu.com/ubuntu/ xenial-backports main multiverse restricted universe'  | sudo tee --append /etc/apt/sources.list > /dev/null
#            echo 'deb http:://172.25.1.170/repo/mirror/archive.ubuntu.com/ubuntu/ xenial-updates main multiverse restricted universe'  | sudo tee --append /etc/apt/sources.list > /dev/null
#            echo 'deb http:://172.25.1.170/repo/mirror/archive.ubuntu.com/ubuntu/ xenial main multiverse restricted universe'  | sudo tee --append /etc/apt/sources.list > /dev/null
#            echo 'deb http:://172.25.1.170/repo/mirror/archive.ubuntu.com/ubuntu/ xenial-security main multiverse restricted universe'  | sudo tee --append /etc/apt/sources.list > /dev/null 
#            echo 'deb http:://172.25.1.170/repo/mirror/archive.ubuntu.com/ubuntu/ xenial partner'  | sudo tee --append /etc/apt/sources.list > /dev/null 
#             
#        fi

        sudo apt install \
                apt-transport-https \
                ca-certificates \
                curl \
                software-properties-common -y
                
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo apt-key fingerprint 0EBFCD88
        sudo add-apt-repository \
                "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) \
                stable"
                
        sudo add-apt-repository ppa:noobslab/icons -y
        sudo add-apt-repository ppa:papirus/papirus -y
        sudo apt update

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
                    ~/Músicas \
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
                        /work/.sqldeveloper \
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
            
            if [ ! -d ~/Músicas ]; then
                ln -s /work/músicas ~/Músicas
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
            
            if [ ! -d ~/.sqldeveloper ]; then
                ln -s /work/.sqldeveloper ~/.sqldeveloper
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

    sudo apt install docker-ce -y
    
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
            #echo '# Proxy' >> ~/.bashrc
            #echo 'export http_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            #echo 'export https_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            #echo 'export ftp_proxy="http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA"' >> ~/.bashrc
            
            echo '# Proxy' | sudo tee --append /etc/wgetrc> /dev/null
            echo 'http_proxy = http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA/' | sudo tee --append /etc/wgetrc > /dev/null
            echo 'https_proxy = https://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA/' | sudo tee --append /etc/wgetrc > /dev/null

            echo '# Proxy' | sudo tee --append /etc/apt/apt.conf > /dev/null
            echo 'Acquire::http::Proxy "http://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA";' | sudo tee --append /etc/apt/apt.conf > /dev/null
            echo 'Acquire::https::Proxy "https://$PROXY_USUARIO:$PROXY_SENHA@$PROXY_HOST:$PROXY_PORTA";' | sudo tee --append /etc/apt/apt.conf > /dev/null
            
            echo '# Proxy' | sudo tee --append /etc/environment > /dev/null
            echo 'no_proxy="localhost"' | sudo tee --append /etc/environment > /dev/null
            echo "alias lso=\"ls -alG | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\\\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\\\" %0o \\\",k);print}'\"" | tee --append ~/.bashrc > /dev/null
            source ~/.bashrc
            tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _        

        elif [ "$RESPOSTA" = "N" ] || [ "$RESPOSTA" = "n" ]; then
            sudo rm -rf /etc/apt/apt.conf
            tput setaf 2 && echo 'Pressione [ENTER] para continuar.' && tput sgr0 && read _

        else
            tput setaf 1 && echo 'Você digitou uma opção inválida. Fim da execução do script.' && tput sgr0
        fi

    fi
    sudo service docker restart
    sudo systemctl restart docker
    
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

    sudo apt install gnome-themes-standard bash-completion curl libavcodec-extra kubuntu-restricted-extras kubuntu-restricted-addons ssh rar unrar p7zip-rar p7zip-full gtk2-engines-murrine gtk2-engines-pixbuf gtk3-engines-unico yakuake apt-xapian-index smb4k kde-l10n-ptbr firefox-locale-br gtk3-engines-breeze papirus-icon-theme libreoffice libreoffice-style-papirus filezilla filezilla-theme-papirus libreoffice-style-breeze build-essential git partitionmanager kate clementine kubuntu-driver-manager network-manager-openvpn partitionmanager kcalc docker -y

    sudo apt install --install-recommends arc-kde adapta-kde -y
    
    tput setaf 7 && echo 'Deseja baixar wallpapers customizados? Lembrando que irá consumir banda de internet em modo corporativo (S/N ou s/n)' && tput setaf 2
    read RESPOSTA
    tput sgr0

    if [ "$RESPOSTA" = "S" ] || [ "$RESPOSTA" = "s" ]; then       
        sudo git clone https://gist.github.com/85942af486eb79118467.git ${DIR_WALLPAPER}_1        
        sudo git clone https://github.com/Mayccoll/wallpapers-collection.git ${DIR_WALLPAPER}_2
        sudo git clone https://github.com/kotajacob/wallpapers.git ${DIR_WALLPAPER}_3
        sudo git clone https://github.com/himynameisxtd/wallpapers.git ${DIR_WALLPAPER}_4
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
    
    sudo apt remove apport kwrite -y
    sudo apt auto-remove -y

}

instalaJDK(){

# jdk_version: 8(default) or 9
# ext: rpm or tar.gz
    jdk_version="8"
    ext="tar.gz"


    caminhoJDK=$JAVA_HOME_WORK
    if [ -z "$caminhoJDK" ]; then
        mkdir -p $WORK_DESENVOLVIMENTO_FERRAMENTAS/older-jdks
        find $WORK_DESENVOLVIMENTO_FERRAMENTAS -maxdepth 1 -type d -name "jdk*" -exec mv -fi {}  $WORK_DESENVOLVIMENTO_FERRAMENTAS/older-jdks/ \;
    
        readonly url="http://www.oracle.com"
        readonly jdk_download_url1="$url/technetwork/java/javase/downloads/index.html"
        readonly jdk_download_url2=$(
            curl -s $jdk_download_url1 | grep -Po "\/technetwork\/java/\javase\/downloads\/jdk${jdk_version}-downloads-.+?\.html" | head -1
        )
        [[ -z "$jdk_download_url2" ]] && echo "Could not get jdk download url - $jdk_download_url1" >> /dev/stderr

        readonly jdk_download_url3="${url}${jdk_download_url2}"
        readonly jdk_download_url4=$(
            curl -s $jdk_download_url3 | \
            egrep -o "http\:\/\/download.oracle\.com\/otn-pub\/java\/jdk\/[8-9](u[0-9]+|\+).*\/jdk-${jdk_version}.*(-|_)linux-(x64|x64_bin).$ext" | tail -1
        )

        NOME_ARQUIVO=${jdk_download_url4##*/}
        echo $NOME_ARQUIVO
        wget --no-cookies \
            --no-check-certificate \
            --header "Cookie: oraclelicense=accept-securebackup-cookie" \
            -N $jdk_download_url4
        
        mv $NOME_ARQUIVO $WORK_DESENVOLVIMENTO_FERRAMENTAS/
        
        tar -xzf $WORK_DESENVOLVIMENTO_FERRAMENTAS/$NOME_ARQUIVO -C $WORK_DESENVOLVIMENTO_FERRAMENTAS
        rm -f $WORK_DESENVOLVIMENTO_FERRAMENTAS/$NOME_ARQUIVO
        caminhoJDK=$(find /work/desenvolvimento/ferramentas/ -maxdepth 1 -name "jdk*")
        JAVA_HOME_WORK=caminhoJDK
    fi
    
    echo "" | sudo tee --append /etc/profile > /dev/null  
    echo "# Variaveis de ambiente para desenvolvimento" | sudo tee --append /etc/profile > /dev/null  
    echo "JAVA_HOME=\"$caminhoJDK\"" | sudo tee --append /etc/profile > /dev/null  
    echo "PATH=\"\$PATH:\$JAVA_HOME/bin\"" | sudo tee --append /etc/profile > /dev/null  
    
    sudo update-alternatives --quiet --remove-all java
    sudo update-alternatives --quiet --remove-all javac

    sudo update-alternatives --install /usr/bin/java java ${caminhoJDK}/bin/java 0;
    sudo update-alternatives --install /usr/bin/javac javac ${caminhoJDK}/bin/javac 0;
    sudo update-alternatives --install /usr/bin/javadoc javadoc ${caminhoJDK}/bin/javadoc 0;
    sudo update-alternatives --install /usr/bin/javaws javaws ${caminhoJDK}/bin/javaws 0;    

}

install_maven() {

    if hash mvn 2>/dev/null; 
        then
        echo "Maven já instalado."
        mvn --version | grep "Apache Maven"
    else
        mkdir -p $WORK_DESENVOLVIMENTO_FERRAMENTAS/older-mavens
        find $WORK_DESENVOLVIMENTO_FERRAMENTAS -maxdepth 1 -type d -name "apache-maven*" -exec mv -fi {}  $WORK_DESENVOLVIMENTO_FERRAMENTAS/older-mavens/ \;
   
        latest=$(curl $MAVEN_URL_RELEASES | tac | sed -ne 's/[^0-9]*\(\([0-9]\.\)\{0,3\}[0-9]\).*/\1/p' | head -1)
        
        echo "Última versão: $latest"
        NOME_ARQUIVO="apache-maven-$latest-bin.tar.gz"
        
        wget $MAVEN_URL_RELEASES$latest/binaries/$NOME_ARQUIVO

        mv $NOME_ARQUIVO $WORK_DESENVOLVIMENTO_FERRAMENTAS/
        
        echo $WORK_DESENVOLVIMENTO_FERRAMENTAS/$NOME_ARQUIVO
        
        tar -xzf $WORK_DESENVOLVIMENTO_FERRAMENTAS/$NOME_ARQUIVO -C $WORK_DESENVOLVIMENTO_FERRAMENTAS
        rm -f $WORK_DESENVOLVIMENTO_FERRAMENTAS/$NOME_ARQUIVO
        caminhoMaven=$(find /work/desenvolvimento/ferramentas/ -maxdepth 1 -name "apache-maven*")

        MAVEN_HOME_WORK=caminhoMaven
        
        echo "M2_HOME=\"$caminhoMaven\"" | sudo tee --append /etc/profile > /dev/null  
        echo "MAVEN_HOME=\"$caminhoMaven\"" | sudo tee --append /etc/profile > /dev/null
        echo "M2=\"\$M2_HOME/bin\"" | sudo tee --append /etc/profile > /dev/null 
        echo "MAVEN_OPTS=\"Xms256m -Xmx512m\"" | sudo tee --append /etc/profile > /dev/null 
        echo "PATH=\"\$M2:\$PATH\"" | sudo tee --append /etc/profile > /dev/null         
        source /etc/profile
        sudo wget https://raw.github.com/dimaj/maven-bash-completion/master/bash_completion.bash --output-document /etc/bash_completion.d/mvn    
    fi
    
} 

finaliza(){

    tput setaf 2
    echo 'FIM DA CONFIGURAÇÃO DO AMBIENTE. Pressione qualquer tecla para sair...'
    tput sgr0
    read
    exit 0

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

inicializa
menu
finaliza
