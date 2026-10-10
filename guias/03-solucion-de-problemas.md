# Solución de problemas

[Inicio](../README.md) · [hashyy](01-hashyy-iq3-xxs.md) · [Strata](02-strata-iq2-xs.md)

Resuelve el error del paso actual antes de continuar. Ejecuta un solo servidor cada vez, especialmente si ambos utilizan la misma GPU.

## PowerShell no permite ejecutar los scripts

Abre una nueva ventana y ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
```

Este ajuste solo afecta a esa ventana. Si el ZIP descargado deja los archivos bloqueados, desbloquea únicamente los scripts de la copia que acabas de revisar:

```powershell
Get-ChildItem .\scripts -Filter *.ps1 | Unblock-File
```

Una política de empresa puede impedirlo. En ese caso consulta al administrador; no cambies políticas globales para forzar la ejecución.

## No existe la carpeta o no encuentra un script

El ZIP debe estar extraído. Dentro de `C:\QwenTutorial\tutorial` deben aparecer directamente `README.md`, `scripts` y `guias`. Si ves otra carpeta con el nombre del repositorio, mueve su contenido un nivel arriba.

Comprueba dónde estás:

```powershell
Get-Location
Test-Path .\scripts\Comun.ps1
```

Debe mostrar `True`. Si elegiste otra unidad para el programa, vuelve a definir `$CarpetaHashyy` o `$CarpetaStrata` en cada nueva ventana de PowerShell.

## WinGet, Git o CMake no se reconocen

- Si falta WinGet, instala **Instalador de aplicaciones** desde Microsoft Store. [Instrucciones oficiales](https://learn.microsoft.com/windows/package-manager/winget/).
- Después de instalar Git o CMake, cierra PowerShell y abre una ventana nueva para que reciba el PATH actualizado.
- Si WinGet indica que una versión no está disponible, no reemplaces a ciegas todas las versiones. Comprueba `winget show --id Kitware.CMake --exact --versions` o el identificador del paquete que falló. Conserva el mensaje para identificar el cambio.
- Si falta el compilador, abre Visual Studio Installer y comprueba las herramientas C++, MSVC v143, SDK de Windows y CMake del paquete Build Tools 2022.

## Python no se instala o se abre Microsoft Store

Este apartado afecta a Strata. El lanzador busca Python de 64 bits, versión 3.10 o posterior. Si no lo encuentra, intenta instalar Python 3.12 para tu usuario.

Si tienes WinGet:

```powershell
winget install --exact --id Python.Python.3.12 --scope user --source winget --accept-package-agreements --accept-source-agreements
```

Sin WinGet, abre [Python 3.12.10](https://www.python.org/downloads/release/python-31210/) y descarga **Windows installer (64-bit)**. Marca **Add python.exe to PATH** y utiliza la instalación para tu usuario. Cierra PowerShell y abre una ventana nueva.

Comprueba:

```powershell
py -3.12 -c "import sys; print(sys.version); print(sys.maxsize > 2**32)"
```

La última línea debe ser `True`. Vuelve al paso `START-HERE.bat --check`. No hace falta activar manualmente `.venv` ni cambiar el Python de otros proyectos.

Si ya existe una `.venv` incompleta, cierra Strata y renómbrala antes de repetir el paso:

```powershell
Rename-Item -LiteralPath 'C:\QwenTutorial\strata\app\.venv' -NewName ('.venv-anterior-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
```

Adapta la ruta si instalaste en otra unidad. El lanzador creará un entorno nuevo.

## La descarga se interrumpe o da un error de conexión

Repite exactamente la orden de descarga o instalación que estabas utilizando. No renombres los fragmentos ni mezcles archivos de revisiones distintas.

Para hashyy, los `.part` conservan los datos descargados. Si curl dice que el servidor no admite continuar, o falla la suma de comprobación, renombra **solo el `.part` afectado** para que el siguiente intento empiece limpio. Ejemplo:

```powershell
Rename-Item -LiteralPath 'C:\QwenTutorial\hashyy\modelos\Qwen3.8-Flash-Next-UD-IQ3_XXS-00002-of-00003.gguf.part' -NewName 'fragmento-02-descarga-anterior.part'
```

Para Strata, el instalador ya comprueba sus descargas. No crees a mano archivos `.done` para saltarte la comprobación. Si un GGUF terminado no coincide, renómbralo y repite la instalación; conserva la copia anterior hasta resolver el problema.

Comprueba espacio libre, fecha y hora de Windows y acceso a GitHub, Hugging Face y PyPI. Si la conexión pasa por un proxy de empresa, pide su configuración. No desactives la comprobación de certificados.

## Git muestra conflictos o «patch does not apply»

El recorrido incluido no realiza una mezcla de ramas: descarga una base fija y aplica un parche comprobado. Un fallo suele indicar que has usado otra base, editado las fuentes o aplicado el parche anteriormente.

Comprueba:

```powershell
git -C 'C:\QwenTutorial\hashyy\llama.cpp' rev-parse HEAD
git -C 'C:\QwenTutorial\hashyy\llama.cpp' status --short
```

HEAD debe ser `254b177307b14d055bbe4c050c9c441a1e06d8a4`. Los cambios del parche aparecen en `status`: es normal que estas fuentes no estén limpias tras aplicarlo.

No uses `git reset --hard` ni fuerces el parche. Conserva la carpeta y prepara una nueva:

```powershell
.\scripts\Preparar-Hashyy.ps1 -Carpeta 'C:\QwenTutorial\hashyy-nuevo'
```

Después utiliza esa ruta para compilar, descargar e iniciar. Si un primer intento quedó a medias, la misma opción permite empezar en una carpeta nueva sin borrar nada.

## «Filename too long» o errores de rutas durante la compilación

Utiliza rutas cortas, como las propuestas en las guías. `Preparar-Hashyy.ps1` activa `core.longpaths` en su copia de Git. Evita extraer el tutorial dentro de varias carpetas anidadas o en OneDrive.

Si elegiste una ruta larga y el compilador falla, prepara una instalación nueva en una ruta corta. El `build-tutorial` guarda rutas absolutas; no lo muevas para intentar reutilizarlo.

## La compilación no encuentra CUDA, MSVC o Ninja

Comprueba que existe CUDA 13.4:

```powershell
Test-Path "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v13.4\bin\nvcc.exe"
```

El script de compilación busca Visual Studio **2022**, activa su entorno de 64 bits y utiliza su Ninja. Tener solo Visual Studio 2026 no satisface esa búsqueda. Instala Build Tools 2022 con los componentes indicados en la guía.

Si has cambiado de GPU o herramientas y CMake indica que la caché pertenece a otra configuración, conserva la carpeta de compilación anterior:

```powershell
Rename-Item -LiteralPath 'C:\QwenTutorial\hashyy\llama.cpp\build-tutorial' -NewName ('build-anterior-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
.\scripts\Compilar-Hashyy.ps1 -Gpu 0
```

Adapta ruta y GPU. Si el error es por memoria durante la compilación, usa `-Trabajos 2`.

## «Unknown argument: --moe-stream-cache»

Estás utilizando un llama.cpp sin el parche de Expert Streaming, o un ejecutable de otra carpeta. El servidor de esta guía es `hashyy\llama.cpp\build-tutorial\bin\llama-server.exe`.

Comprueba:

```powershell
& 'C:\QwenTutorial\hashyy\llama.cpp\build-tutorial\bin\llama-server.exe' --help | Select-String 'moe-stream'
```

Si no aparece, vuelve a preparar y compilar las fuentes del tutorial.

## No encuentra el modelo o faltan fragmentos

- hashyy necesita los **tres** archivos Unsloth UD-IQ3_XXS juntos. El primero mide unos 11 MB y no basta por sí solo.
- Strata IQ2_XS necesita los **dos** GSQ-RCO de ISTA-DASLab, su pack preparado y MTP. No ejecutes directamente `strata.exe` con un solo GGUF.
- Conserva los nombres originales. Un archivo `.part` todavía no es una descarga terminada.

Utiliza `Descargar-Modelo.ps1 -SoloVerificar` con la carpeta y el recorrido correctos.

## Falta una DLL o «CUDA driver version is insufficient»

Actualiza el controlador NVIDIA y reinicia. No descargues DLL sueltas de páginas ajenas.

Para hashyy, utiliza `Iniciar-Hashyy.ps1`: añade al proceso las bibliotecas de CUDA 13.4. Conserva todas las DLL junto a los ejecutables de `build-tutorial\bin`.

Para Strata, utiliza `Iniciar-Strata.ps1`: carga la configuración que apunta a las bibliotecas de `.venv`. Si has movido carpetas, las rutas absolutas guardadas pueden haber quedado desactualizadas. Conserva el modelo y repite la instalación con la ruta definitiva.

## «Out of memory», el motor se cierra o el ordenador va muy lento

Primero cierra otros servidores, juegos y programas que usen mucha GPU o RAM. Consulta:

```powershell
nvidia-smi --query-gpu=index,name,memory.total,memory.free --format=csv
```

**hashyy:** reduce caché y contexto:

```powershell
.\scripts\Iniciar-Hashyy.ps1 -Gpu 0 -CacheGiB 3 -Contexto 2048
```

**Strata:** detén el servidor y vuelve a guardar una configuración con menos contexto:

```powershell
.\scripts\Instalar-Strata.ps1 -Gpu 0 -Contexto 8192 -ReservaMiB 3072
.\scripts\Iniciar-Strata.ps1
```

Adapta todas las rutas si no son las predeterminadas. Aumentar la reserva deja menos espacio para expertos pero más margen al escritorio. No soluciona una falta de RAM del sistema. Para IQ2_XS, 32 GB de RAM con una tarjeta pequeña quedan fuera del recorrido principal.

En el primer inicio Strata carga mucha RAM y puede ralentizar Windows. Si el equipo sigue sin responder tras varios minutos, revisa RAM libre y log; no presupongas que está trabajando correctamente porque exista un proceso.

## Utiliza la tarjeta equivocada

Consulta `nvidia-smi` y elige su `index`. hashyy lo transforma en UUID y expone solamente esa GPU; que el log la llame `CUDA0` es normal.

Strata guarda la selección en `strata-iq2_xs.json`. Para cambiarla de forma persistente, detén Strata y utiliza `Ajustar-Gpus-Strata.ps1`, después reinicia y revisa el log. No reutilices los números de GPU del ejemplo sin comprobar los tuyos.

## El puerto está ocupado

Comprueba si ya tienes una ventana del mismo servidor abierta. Para identificar el proceso:

```powershell
Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue | Select-Object LocalAddress, LocalPort, OwningProcess
```

Para hashyy cambia `8080` por `8099`. No cierres un proceso desconocido solo porque ocupa el puerto. Puedes elegir otro:

```powershell
.\scripts\Iniciar-Hashyy.ps1 -Gpu 0 -Puerto 8100
.\scripts\Comprobar-Servidor.ps1 -Recorrido hashyy -Puerto 8100
```

O, para Strata:

```powershell
.\scripts\Iniciar-Strata.ps1 -Puerto 8101
.\scripts\Comprobar-Servidor.ps1 -Recorrido strata -Puerto 8101
```

Actualiza también la dirección en el navegador y en las aplicaciones que conectes.

## La página abre, pero no genera texto

Ejecuta la prueba del recorrido en otra ventana. Strata debe mostrar `loaded: true`, además de `status: ok`. Revisa el log si la prueba agota la espera o recibe una respuesta vacía.

Si el modelo solo devuelve razonamiento y alcanza el límite de salida, desactiva el razonamiento en la interfaz para una prueba corta o aumenta el límite de salida. No interpretes una respuesta HTTP correcta como una generación válida.

## Cómo pedir ayuda

Indica el recorrido, el paso que falló, versión de Windows, tarjeta y VRAM, RAM del equipo y mensaje completo de error. Para Strata puedes adjuntar `app\strata-iq2_xs.log`. Para hashyy conserva la salida de compilación o de la ventana del servidor. Revisa los archivos antes de compartirlos: pueden contener rutas y texto de tus peticiones.
