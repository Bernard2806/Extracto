@echo off
setlocal enabledelayedexpansion

:: Verificar si el script se ejecuta como Administrador
fsutil dirty query %SystemDrive% >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] Este script necesita ejecutarse como Administrador.
    echo    Cierra esta ventana y ejecútalo como Administrador.
    echo.
    pause
    exit
)

:: Limpiar variables
set count=0

:: Detectar todas las unidades conectadas
for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%D:\ (
        set /a count+=1
        set "unidad[!count!]=%%D:"
    )
)

:: Si no hay unidades disponibles, salir
if %count%==0 (
    echo [!] No se detectaron unidades de disco.
    pause
    exit
)

:menu_unidad
cls
echo ========================================
echo       SELECCIONE UNA UNIDAD ORIGEN
echo ========================================
for /l %%i in (1,1,%count%) do (
    echo %%i. !unidad[%%i]!
)
set /a maxOpcion=%count%+1
echo %maxOpcion%. Salir
echo ========================================
set /p opcion=Ingrese el número de la unidad: 

:: Validar entrada
if "%opcion%"=="" goto menu_unidad
if %opcion% GEQ 1 if %opcion% LEQ %maxOpcion% (
    if %opcion%==%maxOpcion% exit
    set "unidadSeleccionada=!unidad[%opcion%]!"
    goto menu_extraccion
) else (
    echo Opción no válida. Intente nuevamente.
    pause
    goto menu_unidad
)

:menu_extraccion
cls
echo ========================================
echo   SELECCIONE QUE DESEA EXTRAER
echo ========================================
echo 1. Imagenes (.jpg, .png, .gif)
echo 2. Documentos (.pdf, .docx, .doc, .xls, .xlsx, .ppt, .pptx, .txt, .rtf)
echo 3. Videos (.mp4, .avi, .mkv, .mov)
echo 4. Volver al menú anterior
echo ========================================
set /p tipo=Ingrese el número de la opción: 

if "%tipo%"=="1" set "extension=jpg png gif" & set "nombre=Imagenes"
if "%tipo%"=="2" set "extension=pdf docx doc xls xlsx ppt pptx txt rtf" & set "nombre=Documentos"
if "%tipo%"=="3" set "extension=mp4 avi mkv mov" & set "nombre=Videos"
if "%tipo%"=="4" goto menu_unidad
if not defined extension (
    echo Opción no válida. Intente nuevamente.
    pause
    goto menu_extraccion
)

:: Elegir destino de extracción
:menu_destino
cls
echo ========================================
echo   SELECCIONE LA UNIDAD DESTINO
echo ========================================
for /l %%i in (1,1,%count%) do (
    echo %%i. !unidad[%%i]!
)
echo %maxOpcion%. Usar "C:\Extraccion"
echo %maxOpcion%+1. Volver al menú anterior
echo ========================================
set /p destinoOpcion=Ingrese el número de la unidad destino: 

:: Validar entrada
if "%destinoOpcion%"=="" goto menu_destino
set /a volverAtras=%maxOpcion%+1
if %destinoOpcion% GEQ 1 if %destinoOpcion% LEQ %maxOpcion% (
    if %destinoOpcion%==%maxOpcion% set "destino=C:\Extraccion" & goto extraer_archivos
    set "destino=!unidad[%destinoOpcion%]!\Extraccion" & goto extraer_archivos
) else if "%destinoOpcion%"=="%volverAtras%" (
    goto menu_extraccion
) else (
    echo Opción no válida. Intente nuevamente.
    pause
    goto menu_destino
)

:extraer_archivos
:: Crear carpeta de extracción
if not exist "%destino%\%nombre%" mkdir "%destino%\%nombre%"

:: Copiar archivos seleccionados
echo Extrayendo %nombre% desde %unidadSeleccionada% a %destino%...
for %%E in (%extension%) do (
    xcopy /s /y "%unidadSeleccionada%\*.%%E" "%destino%\%nombre%" >nul 2>&1
)

echo Proceso finalizado. Los archivos se copiaron a "%destino%\%nombre%".
pause
goto menu_extraccion