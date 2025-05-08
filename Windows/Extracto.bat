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

:: Configuración del script
title Herramienta de Extracción de Archivos v3.1
color 0A

:: Limpiar variables
set count=0
set totalCopiados=0
set totalBytes=0

:: Detectar todas las unidades conectadas
for %%D in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%D:\ (
        set /a count+=1
        set "unidad[!count!]=%%D:"
        
        :: Obtener la etiqueta del volumen (si existe)
        for /f "tokens=5 delims= " %%V in ('vol %%D: 2^>nul') do (
            set "etiqueta[!count!]=%%V"
        )
        
        :: Si no tiene etiqueta, usar "Sin Etiqueta"
        if not defined etiqueta[!count!] set "etiqueta[!count!]=Sin Etiqueta"
        
        :: Obtener tipo de unidad
        for /f "tokens=1" %%T in ('wmic logicaldisk where "DeviceID='%%D:'" get Description ^| findstr /v "Description"') do (
            set "tipo[!count!]=%%T"
        )
    )
)

:: Si no hay unidades disponibles, salir
if %count%==0 (
    echo [!] No se detectaron unidades de disco.
    pause
    exit
)

:menu_principal
cls
echo ========================================
echo    HERRAMIENTA DE EXTRACCIÓN DE ARCHIVOS
echo ========================================
echo.
echo 1. Seleccionar unidad y extraer archivos
echo 2. Modo recuperación avanzada (busca archivos borrados)
echo 3. Acerca de
echo 4. Salir
echo.
echo ========================================
set /p opcion_principal=Seleccione una opción: 

if "%opcion_principal%"=="1" goto menu_unidad
if "%opcion_principal%"=="2" goto menu_recuperacion
if "%opcion_principal%"=="3" goto acerca_de
if "%opcion_principal%"=="4" exit
goto menu_principal

:acerca_de
cls
echo ========================================
echo         ACERCA DE ESTA HERRAMIENTA
echo ========================================
echo.
echo  Herramienta de Extracción de Archivos v3.1
echo  Actualizada: Mayo 2025
echo.
echo  Esta herramienta permite extraer diferentes
echo  tipos de archivos de cualquier unidad
echo  conectada a su equipo y organizarlos en
echo  subcarpetas por extensión.
echo.
echo ========================================
pause
goto menu_principal

:menu_unidad
cls
echo ========================================
echo       SELECCIONE UNA UNIDAD ORIGEN
echo ========================================
echo.
for /l %%i in (1,1,%count%) do (
    echo %%i. !unidad[%%i]! [!etiqueta[%%i]!] - !tipo[%%i]!
)
set /a maxOpcion=%count%+1
echo %maxOpcion%. Volver al menú principal
echo.
echo ========================================
set /p opcion=Ingrese el número de la unidad: 

:: Validar entrada
if "%opcion%"=="" goto menu_unidad
if %opcion% GEQ 1 if %opcion% LEQ %maxOpcion% (
    if %opcion%==%maxOpcion% goto menu_principal
    set "unidadSeleccionada=!unidad[%opcion%]!"
    goto menu_extraccion
) else (
    echo Opción no válida. Intente nuevamente.
    timeout /t 2 >nul
    goto menu_unidad
)

:menu_extraccion
cls
echo ========================================
echo   SELECCIONE QUE DESEA EXTRAER
echo ========================================
echo.
echo 1. Imágenes (.jpg, .jpeg, .png, .gif, .bmp, .tiff, .webp, .svg, .raw, .cr2)
echo 2. Documentos (.pdf, .docx, .doc, .xls, .xlsx, .ppt, .pptx, .txt, .rtf, .odt, .csv)
echo 3. Videos (.mp4, .avi, .mkv, .mov, .wmv, .flv, .webm, .m4v, .3gp)
echo 4. Audio (.mp3, .wav, .flac, .aac, .ogg, .wma, .m4a, .opus)
echo 5. Archivos comprimidos (.zip, .rar, .7z, .tar, .gz, .iso)
echo 6. Código fuente (.py, .js, .html, .css, .java, .c, .cpp, .cs, .php, .sql)
echo 7. Todos los tipos anteriores
echo 8. Personalizado (definir extensiones)
echo 9. Volver al menú anterior
echo.
echo ========================================
set /p tipo=Ingrese el número de la opción: 

if "%tipo%"=="1" set "extension=jpg jpeg png gif bmp tiff webp svg raw cr2 nef arw" & set "nombre=Imagenes" & goto elegir_destino
if "%tipo%"=="2" set "extension=pdf docx doc xls xlsx ppt pptx txt rtf odt csv md" & set "nombre=Documentos" & goto elegir_destino
if "%tipo%"=="3" set "extension=mp4 avi mkv mov wmv flv webm m4v 3gp ts mts mpg mpeg" & set "nombre=Videos" & goto elegir_destino
if "%tipo%"=="4" set "extension=mp3 wav flac aac ogg wma m4a opus mid amr aif" & set "nombre=Audio" & goto elegir_destino
if "%tipo%"=="5" set "extension=zip rar 7z tar gz iso bz2 cab" & set "nombre=Comprimidos" & goto elegir_destino
if "%tipo%"=="6" set "extension=py js html css java c cpp cs php sql rb go ts json xml bat sh" & set "nombre=Codigo" & goto elegir_destino
if "%tipo%"=="7" set "extension=jpg jpeg png gif bmp tiff webp svg raw cr2 nef arw pdf docx doc xls xlsx ppt pptx txt rtf odt csv md mp4 avi mkv mov wmv flv webm m4v 3gp ts mts mpg mpeg mp3 wav flac aac ogg wma m4a opus mid amr aif zip rar 7z tar gz iso bz2 cab py js html css java c cpp cs php sql rb go ts json xml bat sh" & set "nombre=Todos" & goto elegir_destino
if "%tipo%"=="8" goto extension_personalizada
if "%tipo%"=="9" goto menu_unidad

echo Opción no válida. Intente nuevamente.
timeout /t 2 >nul
goto menu_extraccion

:extension_personalizada
cls
echo ========================================
echo      CONFIGURACIÓN PERSONALIZADA
echo ========================================
echo.
echo Ingrese las extensiones separadas por espacios
echo Ejemplo: jpg pdf mp3 doc
echo.
echo ========================================
set /p extension=Extensiones: 
set "nombre=Personalizados"
goto elegir_destino

:elegir_destino
cls
echo ========================================
echo   SELECCIONE LA UNIDAD DESTINO
echo ========================================
echo.
for /l %%i in (1,1,%count%) do (
    echo %%i. !unidad[%%i]! [!etiqueta[%%i]!] - !tipo[%%i]!
)
set /a maxOpcion=%count%+1
echo %maxOpcion%. Usar "C:\Extraccion"
echo %maxOpcion%+1. Carpeta personalizada
echo %maxOpcion%+2. Volver al menú anterior
echo.
echo ========================================
set /p destinoOpcion=Ingrese el número de la unidad destino: 

:: Validar entrada
if "%destinoOpcion%"=="" goto elegir_destino
set /a opcionPersonalizada=%maxOpcion%+1
set /a volverAtras=%maxOpcion%+2
if %destinoOpcion% GEQ 1 if %destinoOpcion% LEQ %maxOpcion% (
    if %destinoOpcion%==%maxOpcion% (
        set "destino=C:\Extraccion"
        goto menu_organizacion
    )
    set "destino=!unidad[%destinoOpcion%]!\Extraccion"
    goto menu_organizacion
) else if "%destinoOpcion%"=="%opcionPersonalizada%" (
    goto destino_personalizado
) else if "%destinoOpcion%"=="%volverAtras%" (
    goto menu_extraccion
) else (
    echo Opción no válida. Intente nuevamente.
    timeout /t 2 >nul
    goto elegir_destino
)

:destino_personalizado
cls
echo ========================================
echo     CONFIGURAR CARPETA DE DESTINO
echo ========================================
echo.
echo Ingrese la ruta completa donde desea guardar los archivos
echo Ejemplo: D:\Mis Documentos\Extraccion
echo.
echo ========================================
set /p destino=Ruta completa: 
goto menu_organizacion

:menu_organizacion
cls
echo ========================================
echo    SELECCIONE MODO DE ORGANIZACIÓN
echo ========================================
echo.
echo 1. Organizar por extensión (una carpeta por cada tipo)
echo 2. Organizar por fecha (año/mes)
echo 3. Sin organización adicional (modo clásico)
echo 4. Volver al menú anterior
echo.
echo ========================================
set /p modo_organizacion=Seleccione una opción: 

if "%modo_organizacion%"=="1" set "organizacion=extension" & goto confirmar_extraccion
if "%modo_organizacion%"=="2" set "organizacion=fecha" & goto confirmar_extraccion
if "%modo_organizacion%"=="3" set "organizacion=clasico" & goto confirmar_extraccion
if "%modo_organizacion%"=="4" goto elegir_destino

echo Opción no válida. Intente nuevamente.
timeout /t 2 >nul
goto menu_organizacion

:confirmar_extraccion
cls
echo ========================================
echo        CONFIRMAR EXTRACCIÓN
echo ========================================
echo.
echo Origen: %unidadSeleccionada%
echo Tipo: %nombre%
echo Destino: %destino%\%nombre%
echo Organización: !organizacion!
echo.
echo ¿Desea continuar? (S/N)
echo.
echo ========================================
set /p confirmar=Su elección: 

if /i "%confirmar%"=="S" goto extraer_archivos
if /i "%confirmar%"=="N" goto menu_organizacion
goto confirmar_extraccion

:extraer_archivos
:: Crear carpeta de extracción principal
if not exist "%destino%\%nombre%" mkdir "%destino%\%nombre%"

:: Mostrar barra de progreso
cls
echo ========================================
echo       EXTRAYENDO ARCHIVOS...
echo ========================================
echo.
echo Origen: %unidadSeleccionada%
echo Tipo: %nombre%
echo Destino: %destino%\%nombre%
echo Organización: !organizacion!
echo.
echo Buscando archivos, por favor espere...

:: Crear archivo de log
set "log_file=%destino%\%nombre%\log_extraccion.txt"
echo Detalles de la extracción de %nombre% desde %unidadSeleccionada% > "%log_file%"
echo Fecha: %date% Hora: %time% >> "%log_file%"
echo Modo de organización: !organizacion! >> "%log_file%"
echo. >> "%log_file%"

:: Copiar archivos seleccionados según el modo de organización
for %%E in (%extension%) do (
    echo Buscando archivos .%%E...
    echo Archivos .%%E: >> "%log_file%"
    
    :: Contar archivos para esta extensión y copiarlos
    set count_ext=0
    
    for /f "tokens=*" %%F in ('dir /b /s "%unidadSeleccionada%\*.%%E" 2^>nul') do (
        set /a count_ext+=1
        set /a totalCopiados+=1
        
        :: Obtener tamaño del archivo
        for %%Z in ("%%F") do set /a fileSize=%%~zZ
        set /a totalBytes+=!fileSize!
        
        :: Mostrar progreso
        echo Copiando: %%~nxF
        
        :: Determinar la carpeta de destino según el modo de organización
        if "!organizacion!"=="extension" (
            :: Crear subcarpeta si no existe
            if not exist "%destino%\%nombre%\%%E" mkdir "%destino%\%nombre%\%%E"
            
            :: Copiar el archivo a la subcarpeta correspondiente
            copy "%%F" "%destino%\%nombre%\%%E\" >nul 2>&1
            
            :: Registrar en el log
            echo %%F --^> %destino%\%nombre%\%%E\%%~nxF >> "%log_file%"
            
        ) else if "!organizacion!"=="fecha" (
            :: Obtener fecha de creación del archivo
            for /f "tokens=1-3 delims=/" %%a in ('dir /tc "%%F" ^| findstr "/"') do (
                set "dia=%%a"
                set "mes=%%b"
                set "anio=%%c"
            )
            
            :: Extraer solo el año (últimos 4 caracteres)
            set "anio=!anio:~-4!"
            
            :: Crear subcarpetas de año/mes si no existen
            if not exist "%destino%\%nombre%\!anio!" mkdir "%destino%\%nombre%\!anio!"
            if not exist "%destino%\%nombre%\!anio!\!mes!" mkdir "%destino%\%nombre%\!anio!\!mes!"
            
            :: Copiar el archivo a la subcarpeta correspondiente
            copy "%%F" "%destino%\%nombre%\!anio!\!mes!\" >nul 2>&1
            
            :: Registrar en el log
            echo %%F --^> %destino%\%nombre%\!anio!\!mes!\%%~nxF >> "%log_file%"
            
        ) else (
            :: Modo clásico: todos en la misma carpeta
            copy "%%F" "%destino%\%nombre%\" >nul 2>&1
            
            :: Registrar en el log
            echo %%F --^> %destino%\%nombre%\%%~nxF >> "%log_file%"
        )
    )
    
    echo Encontrados !count_ext! archivos .%%E
    echo Total encontrados: !count_ext! archivos >> "%log_file%"
    echo. >> "%log_file%"
    echo.
)

:: Calcular el tamaño total en MB
set /a totalMB=!totalBytes! / 1048576

echo ========================================
echo      PROCESO FINALIZADO
echo ========================================
echo.
echo Se copiaron %totalCopiados% archivos (aproximadamente %totalMB% MB)
echo Los archivos se guardaron en "%destino%\%nombre%"
echo Organizados por: !organizacion!
echo.
echo Se ha creado un archivo de registro en:
echo %log_file%
echo.
echo ========================================
pause
goto menu_principal

:menu_recuperacion
cls
echo ========================================
echo    MODO DE RECUPERACIÓN AVANZADA
echo      (ARCHIVOS ELIMINADOS)
echo ========================================
echo.
echo Esta función requiere herramientas adicionales.
echo.
echo 1. Instalar herramientas necesarias
echo 2. Ejecutar recuperación (requiere instalación previa)
echo 3. Volver al menú principal
echo.
echo ========================================
set /p opcion_recuperacion=Seleccione una opción: 

if "%opcion_recuperacion%"=="1" goto instalar_herramientas
if "%opcion_recuperacion%"=="2" goto ejecutar_recuperacion
if "%opcion_recuperacion%"=="3" goto menu_principal
goto menu_recuperacion

:instalar_herramientas
cls
echo ========================================
echo    INSTALACIÓN DE HERRAMIENTAS
echo ========================================
echo.
echo Esta función descargará e instalará Recuva,
echo una herramienta de recuperación de terceros.
echo.
echo Esta operación requiere conexión a Internet.
echo.
echo 1. Continuar con la instalación
echo 2. Volver al menú anterior
echo.
echo ========================================
set /p opcion_instalar=Seleccione una opción: 

if "%opcion_instalar%"=="1" (
    echo.
    echo Para completar esta función, abra un navegador y vaya a:
    echo https://www.ccleaner.com/recuva/download
    echo.
    echo Descargue e instale Recuva para poder usar la
    echo funcionalidad de recuperación de archivos.
    echo.
    pause
    goto menu_recuperacion
)
if "%opcion_instalar%"=="2" goto menu_recuperacion
goto instalar_herramientas

:ejecutar_recuperacion
cls
echo ========================================
echo    EJECUTANDO RECUPERACIÓN
echo ========================================
echo.
echo Comprobando si Recuva está instalado...

:: Comprobar si recuva está instalado
if exist "C:\Program Files\Recuva\recuva.exe" (
    echo Recuva encontrado. Iniciando...
    start "" "C:\Program Files\Recuva\recuva.exe"
) else if exist "C:\Program Files (x86)\Recuva\recuva.exe" (
    echo Recuva encontrado. Iniciando...
    start "" "C:\Program Files (x86)\Recuva\recuva.exe"
) else (
    echo.
    echo [!] No se encontró Recuva instalado.
    echo     Por favor, instale primero las herramientas necesarias.
    echo.
    pause
)
goto menu_recuperacion