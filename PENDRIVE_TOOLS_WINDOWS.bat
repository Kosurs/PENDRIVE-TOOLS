@echo off
setlocal enabledelayedexpansion
color 0A
title MENU DE GESTÃO DE DISPOSITIVOS

:menu_inicio
cls
echo =============================================
echo         PENDRIVE TOOLS BY KOSURS
echo =============================================
echo.
echo Escolha o idioma do MENU:
echo 1. Portugues
echo 2. English
set /p idioma=Escolha uma opcao: 

if "%idioma%"=="1" (
    set "idioma=portugues"
) else if "%idioma%"=="2" (
    set "idioma=ingles"
) else (
    echo Opcao invalida! O programa sera encerrado.
    pause
    exit /b
)

if "%idioma%"=="portugues" (
    set "msg_opcao=Escolha uma opcao:"
    set "msg_reformatar=Reformatar dispositivo"
    set "msg_integridade=Verificar integridade do dispositivo"
    set "msg_sair=Sair"
) else (
    set "msg_opcao=Choose an option:"
    set "msg_reformatar=Reformat Device"
    set "msg_integridade=Check Drive Integrity"
    set "msg_sair=Exit"
)

:menu_principal
cls
echo =============================================
echo                     MENU    
echo =============================================
echo.
echo %msg_opcao%
echo 1. %msg_reformatar%
echo 2. %msg_integridade%
echo 3. %msg_sair%
set /p escolha=Escolha uma opcao: 

if "%escolha%"=="1" (
    call :reformatar
) else if "%escolha%"=="2" (
    call :verificar_integridade
) else if "%escolha%"=="3" (
    echo Operacao cancelada.
    exit /b
) else (
    echo Opcao invalida. Tente novamente.
    pause
    goto :menu_principal
)

:reformatar
cls
echo =============================================
echo                    FORMAT
echo =============================================
echo.
echo Listando todos os dispositivos com armazenamento...
echo.

REM Cria um arquivo temporário para guardar os discos (somente DeviceID)
set "tempfile=%temp%\discos_temp.txt"
del "%tempfile%" >nul 2>&1

REM Lista os discos removíveis e fixos usando PowerShell
powershell -NoLogo -Command ^
  "$i = 0; Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 } | ForEach-Object { "^
  "$i++; "^
  "$sizeGB = if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { 0 }; "^
  "$vol = if ($_.VolumeName) { $_.VolumeName } else { 'Sem Nome' }; "^
  "$fs = if ($_.FileSystem) { $_.FileSystem } else { 'Desconhecido' }; "^
  "Write-Host ($i.ToString() + '. Unidade: ' + $_.DeviceID + ' | Volume: ' + $vol + ' | Sistema: ' + $fs + ' | Tamanho: ' + $sizeGB + ' GB');" ^
  "Add-Content -Path '%tempfile%' -Value $_.DeviceID "^
  "} "

echo.
set /p escolha=Digite o numero do dispositivo que deseja FORMATAR (ou 0 para sair): 

if "%escolha%"=="0" (
    echo Operacao cancelada.
    pause
    exit /b
)

REM Lê o DeviceID correspondente
set /a linha=%escolha%-1
set "unidadeselecionada="
for /f "tokens=*" %%a in ('more +%linha% "%tempfile%"') do (
    set "unidadeselecionada=%%a"
    goto confirmar
)

:confirmar
echo.
echo ATENCAO: TODOS OS DADOS DA UNIDADE %unidadeselecionada% SERAO APAGADOS!
echo.
echo Escolha o sistema de arquivos para formatar:
echo 1. FAT32
echo 2. NTFS
echo 3. exFAT
set /p fsescolhido=Digite o numero correspondente: 

if "%fsescolhido%"=="1" (
    set "sistema=FAT32"
)
if "%fsescolhido%"=="2" (
    set "sistema=NTFS"
)
if "%fsescolhido%"=="3" (
    set "sistema=exFAT"
)

set /p nomevol="Digite o nome do volume (ou deixe vazio para 'LIMPO'): "
if "%nomevol%"=="" set "nomevol=LIMPO"

echo.
echo Tem certeza que deseja continuar com a formatação para %sistema% na unidade %unidadeselecionada%?
set /p confirmar=Tem certeza? (S/N): 
if /I not "%confirmar%"=="S" (
    echo Operacao cancelada.
    pause
    exit /b
)

echo.
echo FORMATANDO a unidade %unidadeselecionada% em %sistema% com o nome "%nomevol%"...
powershell -NoLogo -Command "Get-Volume -DriveLetter '%unidadeselecionada:~0,1%' | Format-Volume -FileSystem %sistema% -NewFileSystemLabel '%nomevol%' -Confirm:$false -Force"

echo.
echo ✅ Formatacao concluida!
pause
exit /b

:verificar_integridade
cls
echo =============================================
echo     VERIFICACAO DE INTEGRIDADE DO DISPOSITIVO
echo =============================================
echo.
echo Listando todos os dispositivos com armazenamento...
echo.

REM Cria um arquivo temporário para guardar os discos (somente DeviceID)
set "tempfile=%temp%\discos_temp.txt"
del "%tempfile%" >nul 2>&1

REM Lista os discos removíveis e fixos usando PowerShell
powershell -NoLogo -Command ^
  "$i = 0; Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 } | ForEach-Object { "^
  "$i++; "^
  "$sizeGB = if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { 0 }; "^
  "$vol = if ($_.VolumeName) { $_.VolumeName } else { 'Sem Nome' }; "^
  "$fs = if ($_.FileSystem) { $_.FileSystem } else { 'Desconhecido' }; "^
  "$status = if ($_.Status) { $_.Status } else { 'Desconhecido' }; "^
  "Write-Host ($i.ToString() + '. Unidade: ' + $_.DeviceID + ' | Volume: ' + $vol + ' | Sistema: ' + $fs + ' | Tamanho: ' + $sizeGB + ' GB | Status: ' + $status);" ^
  "Add-Content -Path '%tempfile%' -Value $_.DeviceID "^
  "} "

echo.
set /p escolha=Digite o numero do dispositivo que deseja VERIFICAR (ou 0 para sair): 

if "%escolha%"=="0" (
    echo Operacao cancelada.
    pause
    exit /b
)

REM Lê o DeviceID correspondente
set /a linha=%escolha%-1
set "unidadeselecionada="
for /f "tokens=*" %%a in ('more +%linha% "%tempfile%"') do (
    set "unidadeselecionada=%%a"
    goto verificar
)

:verificar
echo Verificando a integridade do dispositivo %unidadeselecionada%...

REM Exibir informações detalhadas sobre o dispositivo
echo.
powershell -Command "Get-PhysicalDisk | Where-Object { $_.DeviceID -eq '%unidadeselecionada%' } | Format-List"

REM Usar chkdsk para verificar a integridade do dispositivo
chkdsk %unidadeselecionada% /f

echo.
echo ✅ Verificação Concluída!
pause
exit /b
