#!/bin/bash

# Ativar cores
GREEN="\e[32m"
RESET="\e[0m"

clear
echo -e "${GREEN}============================================="
echo "        PENDRIVE TOOLS BY KOSURS (Linux)"
echo -e "=============================================${RESET}"
echo
echo "Escolha o idioma do MENU:"
echo "1. Português"
echo "2. English"
read -p "Escolha uma opção: " idioma

if [[ "$idioma" == "1" ]]; then
    lang="pt"
elif [[ "$idioma" == "2" ]]; then
    lang="en"
else
    echo "Opção inválida! Encerrando..."
    exit 1
fi

# Mensagens por idioma
if [[ "$lang" == "pt" ]]; then
    msg_opcao="Escolha uma opção:"
    msg_reformatar="Reformatar dispositivo"
    msg_integridade="Verificar integridade do dispositivo"
    msg_sair="Sair"
    msg_confirmacao="Você tem certeza que deseja formatar"
    msg_cancelado="Operação cancelada."
    msg_concluido="✅ Formatação concluída!"
    msg_verificando="Executando verificação com fsck em"
    msg_verif_concluida="✅ Verificação concluída."
    msg_continuar="Pressione Enter para continuar..."
else
    msg_opcao="Choose an option:"
    msg_reformatar="Reformat device"
    msg_integridade="Check device integrity"
    msg_sair="Exit"
    msg_confirmacao="Are you sure you want to format"
    msg_cancelado="Operation canceled."
    msg_concluido="✅ Formatting completed!"
    msg_verificando="Running fsck check on"
    msg_verif_concluida="✅ Check complete."
    msg_continuar="Press Enter to continue..."
fi

while true; do
    clear
    echo -e "${GREEN}============================================="
    echo "                  MENU"
    echo -e "=============================================${RESET}"
    echo
    echo "$msg_opcao"
    echo "1. $msg_reformatar"
    echo "2. $msg_integridade"
    echo "3. $msg_sair"
    read -p "Opção: " escolha

    case $escolha in
        1)
            clear
            echo -e "${GREEN}============== FORMATAR DISPOSITIVO ==============${RESET}"
            lsblk -p -o NAME,SIZE,MODEL,FSTYPE,MOUNTPOINT,LABEL
            echo
            read -p "Digite o caminho do dispositivo (ex: /dev/sdb): " dispositivo
            read -p "Escolha o sistema de arquivos (vfat, ntfs, ext4): " fs
            read -p "Digite o nome do volume (ou deixe em branco): " label

            echo
            echo "$msg_confirmacao $dispositivo como $fs? (S/N)"
            read -p "> " confirm

            if [[ "$confirm" =~ ^[SsYy]$ ]]; then
                echo
                echo "🔄 Desmontando (se necessário)..."
                sudo umount "$dispositivo"* &>/dev/null

                echo "💿 Formatando $dispositivo como $fs..."
                case "$fs" in
                    vfat)
                        sudo mkfs.vfat -I ${label:+-n "$label"} "$dispositivo"
                        ;;
                    ntfs)
                        sudo mkfs.ntfs -f ${label:+-L "$label"} "$dispositivo"
                        ;;
                    ext4)
                        sudo mkfs.ext4 -F ${label:+-L "$label"} "$dispositivo"
                        ;;
                    *)
                        echo "❌ Tipo de sistema de arquivos inválido!"
                        read -p "$msg_continuar"
                        continue
                        ;;
                esac
                echo -e "${GREEN}$msg_concluido${RESET}"
            else
                echo "$msg_cancelado"
            fi
            read -p "$msg_continuar" ;;
        2)
            clear
            echo -e "${GREEN}========== VERIFICAR INTEGRIDADE ========== ${RESET}"
            lsblk -p -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL
            echo
            read -p "Digite o caminho da partição (ex: /dev/sdb1): " part
            echo
            echo "$msg_verificando $part..."
            sudo umount "$part" &>/dev/null
            sudo fsck -v "$part"
            echo -e "${GREEN}$msg_verif_concluida${RESET}"
            read -p "$msg_continuar" ;;
        3)
            echo "Saindo..."
            exit 0 ;;
        *)
            echo "Opção inválida!"
            read -p "$msg_continuar" ;;
    esac
done
