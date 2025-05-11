@echo off
setlocal EnableDelayedExpansion
color 0A
title MENU DE GESTÃO DE DISPOSITIVOS

:inicio
cls
echo =============================================
echo         PENDRIVE TOOLS BY KOSURS
echo =============================================
echo.
echo Escolha o idioma / Choose the language:
echo 1. Portugues
echo 2. English
set /p idioma=Escolha uma opcao: 

if "%idioma%"=="1" (
    set "lang=pt"
) else if "%idioma%"=="2" (
    set "lang=en"
) else (
    echo Opcao invalida! Programa encerrado.
    pause
    exit /b
)

if "%lang%"=="pt" (
    set "m_opcao=Escolha uma opcao:"
    set "m_reformatar=Reformatar dispositivo"
    set "m_verificar=Verificar integridade"
    set "m_sair=Sair"
    set "m_confirma=Tem certeza? (S/N):"
    set "m_nome=Digite o nome do volume:"
    set "m_sistema=Escolha o sistema de arquivos:"
    set "m_quick=Usar formatacao rapida (quick)? (S/N):"
    set "m_finalizado=✅ Operacao concluida!"
) else (
    set "m_opcao=Choose an option:"
    set "m_reformatar=Reformat Device"
    set "m_verificar=Check Integrity"
    set "m_sair=Exit"
    set "m_confirma=Are you sure? (Y/N):"
    set "m_nome=Enter volume label:"
    set "m_sistema=Choose file system:"
    set "m_quick=Use quick format? (Y/N):"
    set "m_finalizado=✅ Operation completed!"
)

:menu
cls
echo =============================================
echo                  MENU
echo =============================================
echo.
echo %m_opcao%
echo 1. %m_reformatar%
echo 2. %m_verificar%
echo 3. %m_sair%
set /p opcao=

if "%opcao%"=="1" goto :formatar
if "%opcao%"=="2" goto :verificar
if "%opcao%"=="3" exit /b
echo Opcao invalida.
pause
goto :menu

:formatar
cls
echo =============================================
echo           %m_reformatar%
echo =============================================

:: Gerar lista de dispositivos
set "tempfile=%temp%\unidades.txt"
del "%tempfile%" >nul 2>&1

powershell -NoLogo -Command ^
  "$i=0; Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 } | ForEach-Object { $i++;" ^
  "$size = [math]::Round(($_.Size/1GB),1);" ^
  "$label = if ($_.VolumeName) { $_.VolumeName } else { 'Sem Nome' };" ^
  "Write-Host ($i.ToString() + '. Unidade: ' + $_.DeviceID + ' | Volume: ' + $label + ' | Tamanho: ' + $size + ' GB');" ^
  "Add-Content -Path '%tempfile%' -Value $_.DeviceID }"

echo.
set /p escolha=Digite o numero do dispositivo (ou 0 para cancelar): 
if "%escolha%"=="0" goto :menu

set /a linha=%escolha%-1
set "unidadeselecionada="
for /f "tokens=*" %%a in ('more +%linha% "%tempfile%"') do (
    set "unidadeselecionada=%%a"
    goto :fs_select
)

:fs_select
cls
echo.
echo %m_sistema%
echo 1. FAT32
echo 2. NTFS
echo 3. exFAT
set /p fsopt=Digite a opcao: 

if "%fsopt%"=="1" set "sistema=FAT32"
if "%fsopt%"=="2" set "sistema=NTFS"
if "%fsopt%"=="3" set "sistema=exFAT"

echo.
set /p nomevol=%m_nome%
if "%nomevol%"=="" set "nomevol=LIMPO"

echo.
set /p usarquick=%m_quick%
if /I "%usarquick%"=="S" set "quick=quick"
if /I "%usarquick%"=="Y" set "quick=quick"

echo.
set /p confirmar=%m_confirma%
if /I not "%confirmar%"=="S" if /I not "%confirmar%"=="Y" (
    echo Operacao cancelada.
    pause
    goto :menu
)

:: Gerar script diskpart
set "scriptdp=%temp%\formatar_script.txt"
(
    echo select volume %unidadeselecionada:~0,1%
    echo format fs=%sistema% label=%nomevol% %quick%
    echo assign
    echo exit
) > "%scriptdp%"

cls
echo Formatando a unidade %unidadeselecionada% com %sistema%...
diskpart /s "%scriptdp%"

del "%scriptdp%" >nul 2>&1
del "%tempfile%" >nul 2>&1

echo.
echo %m_finalizado%
pause
goto :menu

:verificar
cls
echo =============================================
echo       %m_verificar%
echo =============================================

set "tempfile=%temp%\unidades.txt"
del "%tempfile%" >nul 2>&1

powershell -NoLogo -Command ^
  "$i=0; Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 -or $_.DriveType -eq 3 } | ForEach-Object { $i++;" ^
  "$size = [math]::Round(($_.Size/1GB),1);" ^
  "$label = if ($_.VolumeName) { $_.VolumeName } else { 'Sem Nome' };" ^
  "Write-Host ($i.ToString() + '. Unidade: ' + $_.DeviceID + ' | Volume: ' + $label + ' | Tamanho: ' + $size + ' GB');" ^
  "Add-Content -Path '%tempfile%' -Value $_.DeviceID }"

echo.
set /p escolha=Digite o numero do dispositivo (ou 0 para cancelar): 
if "%escolha%"=="0" goto :menu

set /a linha=%escolha%-1
set "unidadeselecionada="
for /f "tokens=*" %%a in ('more +%linha% "%tempfile%"') do (
    set "unidadeselecionada=%%a"
    goto :verificar_run
)

:verificar_run
cls
echo Verificando unidade %unidadeselecionada%...
chkdsk %unidadeselecionada% /f

echo.
echo %m_finalizado%
pause
goto :menu
