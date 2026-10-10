# llama.cpp con Expert Streaming, hashyy e IQ3_XXS

[Volver al inicio](../README.md)

Este recorrido compila llama.cpp con las modificaciones de hashyy y ejecuta **Qwen3.8-Flash-Next UD-IQ3_XXS de Unsloth**. Expert Streaming lee los expertos desde el SSD y guarda una parte en la memoria de la tarjeta gráfica.

## 1. Comprueba el equipo y prepara la carpeta del tutorial

Necesitas Windows 10/11 de 64 bits, una NVIDIA RTX con al menos 12 GB de VRAM, 32 GB de RAM como punto de partida, un SSD NVMe y unos 120 GB libres. Una tarjeta más pequeña queda fuera del recorrido comprobado. La caché inicial de 4 GiB se ha utilizado en una RTX 5070 de 12 GB; no es una reserva universal para cualquier GPU.

Descarga el ZIP de este tutorial, pulsa **Extraer todo** y copia su contenido a `C:\QwenTutorial\tutorial`. En esa carpeta deben aparecer directamente `README.md`, `scripts` y `guias`.

Abre **Windows PowerShell** desde Inicio y ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
[Environment]::Is64BitOperatingSystem
[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name='LibreGB';Expression={[math]::Round($_.Free / 1GB, 1)}}
```

La primera comprobación debe mostrar `True`. La segunda muestra la RAM instalada en GiB. La última muestra el espacio libre en cada unidad.

**Para instalar en otra unidad**, define ahora una sola variable y úsala en todos los pasos:

```powershell
$CarpetaHashyy = 'C:\QwenTutorial\hashyy'
```

Por ejemplo, puedes cambiarla a `D:\QwenTutorial\hashyy`. Elige una ruta corta, fuera de OneDrive y de `Archivos de programa`. No la cambies a mitad de la instalación. Si abres otra ventana, vuelve a definirla.

## 2. Instala el controlador NVIDIA

Ejecuta:

```powershell
nvidia-smi
```

Si Windows no reconoce la orden, o muestra un fallo del controlador, abre la página oficial:

```powershell
Start-Process 'https://www.nvidia.com/Download/index.aspx'
```

Selecciona tu tarjeta y tu versión de Windows, descarga el controlador e instálalo. Reinicia Windows al terminar. Para CUDA 13.4 utiliza un controlador actual que cumpla los requisitos de [NVIDIA](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/); la prueba de este tutorial utilizó el controlador 616.92. No confundas el campo «CUDA Version» de `nvidia-smi` con tener instalado CUDA Toolkit: son cosas distintas.

Después del reinicio vuelve a abrir PowerShell, permite los scripts en esa ventana, entra en la carpeta del tutorial y define `$CarpetaHashyy` de nuevo.

## 3. Instala las herramientas de compilación

Comprueba si tienes WinGet, el gestor de instalaciones de Windows:

```powershell
winget --version
```

Si no existe, abre Microsoft Store desde esta orden:

```powershell
Start-Process 'ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1'
```

Instala o actualiza **Instalador de aplicaciones**, publicado por Microsoft. Cierra PowerShell y abre una ventana nueva. Si Microsoft Store está deshabilitada en tu equipo, instala [App Installer siguiendo las instrucciones de Microsoft](https://learn.microsoft.com/windows/package-manager/winget/).

Ejecuta el instalador incluido:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
.\scripts\Instalar-Herramientas-Hashyy.ps1
```

Instala o comprueba:

| Herramienta | Para qué sirve | Versión solicitada |
| --- | --- | --- |
| Git | Descargar las fuentes exactas | Versión disponible en WinGet |
| CMake | Preparar la compilación | 4.4.4 |
| Visual Studio Build Tools 2022 | Compilar C++, con las herramientas recomendadas del paquete VCTools | 17.14.41 |
| CUDA Toolkit | Compilar el código de NVIDIA | 13.4 |

Acepta las ventanas de permisos de Windows. No cierres los instaladores mientras trabajan. CUDA y Visual Studio ocupan varios gigabytes. No necesitas instalar Visual Studio Community ni su editor.

**Cuando termine, cierra PowerShell y abre una nueva ventana.** Si el instalador pide reiniciar, reinicia antes de continuar. Ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
$CarpetaHashyy = 'C:\QwenTutorial\hashyy'
git --version
cmake --version
& "$env:ProgramFiles\NVIDIA GPU Computing Toolkit\CUDA\v13.4\bin\nvcc.exe" --version
nvidia-smi --query-gpu=index,name,compute_cap,memory.total,driver_version --format=csv
```

Si ya tenías Build Tools instalado, abre **Visual Studio Installer → Build Tools 2022 → Modificar** y comprueba que está seleccionado **Desarrollo para el escritorio con C++**, con MSVC v143, un SDK de Windows y herramientas de CMake para C++. Una instalación anterior incompleta puede no añadir los componentes al repetir WinGet.

## 4. Elige la GPU

En la tabla anterior, mira la columna `index`. Ese es el número que usarás. No copies el número de otro ordenador.

```powershell
$GpuHashyy = 0
```

Cambia `0` si tu tarjeta aparece como `1` u otro número. El script obtiene su identificador UUID y lo pasa a CUDA. Así selecciona exactamente esa tarjeta, aunque llama.cpp la llame `CUDA0` dentro del proceso.

Con dos tarjetas este recorrido utiliza **una sola GPU elegida**. No suma automáticamente sus memorias. No añadas parámetros de reparto de otra versión de llama.cpp: la configuración comprobada de este parche es la de una GPU.

## 5. Descarga y prepara las fuentes

```powershell
.\scripts\Preparar-Hashyy.ps1 -Carpeta $CarpetaHashyy
```

El script descarga hashyy en `hashyy-original`, descarga llama.cpp en `llama.cpp` y comprueba el parche antes de aplicarlo. Fija estos commits:

- hashyy: `6189bf3746e6bc267465c66d85cc07ebd8dde79a`.
- llama.cpp: `254b177307b14d055bbe4c050c9c441a1e06d8a4`.

El parche incluido integra Expert Streaming y las correcciones de hashyy sobre esa base. No hace falta buscar una rama antigua ni resolver conflictos. El commit que aparece en las instrucciones originales de hashyy no está disponible en el repositorio upstream; por eso este tutorial proporciona una base accesible y el parche completo.

La descarga de llama.cpp configura las rutas largas **solo en esa copia de Git**. Si el paso falla a mitad, consulta la solución de problemas; no apliques el parche dos veces.

## 6. Compila

```powershell
.\scripts\Compilar-Hashyy.ps1 -CarpetaFuente "$CarpetaHashyy\llama.cpp" -Gpu $GpuHashyy
```

El script encuentra Visual Studio 2022, activa su compilador, utiliza Ninja y consulta la arquitectura de tu GPU. Por ejemplo, una RTX 5070 usa `120`; una RTX 3090 usa `86`. No debes poner `120` para todas las tarjetas.

Compila en modo Release con CUDA, crea `llama-server.exe` y `llama-bench.exe` y comprueba que el servidor incluye `--moe-stream-cache`. Las opciones efectivas son:

```text
Generador: Ninja
CMAKE_BUILD_TYPE=Release
GGML_CUDA=ON
CMAKE_CUDA_ARCHITECTURES=arquitectura consultada de tu tarjeta
CMAKE_CUDA_COMPILER=CUDA 13.4/bin/nvcc.exe
CUDAToolkit_ROOT=carpeta de CUDA 13.4
LLAMA_CURL=OFF
LLAMA_BUILD_TESTS=OFF
LLAMA_BUILD_EXAMPLES=OFF
GGML_NATIVE=ON
```

`LLAMA_CURL=OFF` evita depender de una biblioteca adicional para descargar modelos desde el servidor. El tutorial los descarga por separado. `GGML_NATIVE=ON` optimiza el programa para tu procesador; compila de nuevo si trasladas los ejecutables a otro ordenador.

Puede tardar bastante. Los pasos de CUDA no avanzan siempre al mismo ritmo. Si no aparece un error, deja que termine. Si falta RAM durante la compilación, repite con menos tareas:

```powershell
.\scripts\Compilar-Hashyy.ps1 -CarpetaFuente "$CarpetaHashyy\llama.cpp" -Gpu $GpuHashyy -Trabajos 2
```

Al terminar, los ejecutables quedan en:

```text
C:\QwenTutorial\hashyy\llama.cpp\build-tutorial\bin\
```

## 7. Descarga IQ3_XXS

```powershell
.\scripts\Descargar-Modelo.ps1 -Recorrido hashyy -Carpeta "$CarpetaHashyy\modelos"
```

Descarga únicamente **UD-IQ3_XXS** desde [Unsloth](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF/tree/38bb39ee97821de2c9009abb7e93950eec396e66/UD-IQ3_XXS), en una revisión fija. No necesita Python ni una cuenta de Hugging Face.

| Archivo | Tamaño aproximado |
| --- | ---: |
| `Qwen3.8-Flash-Next-UD-IQ3_XXS-00001-of-00003.gguf` | 11 MB |
| `Qwen3.8-Flash-Next-UD-IQ3_XXS-00002-of-00003.gguf` | 49,57 GB |
| `Qwen3.8-Flash-Next-UD-IQ3_XXS-00003-of-00003.gguf` | 32,38 GB |

Necesitas **los tres**, con sus nombres originales y en la misma carpeta. El primer archivo pequeño no contiene todo el modelo. El servidor recibe la ruta del primero y encuentra los otros dos automáticamente.

Si se interrumpe Internet, repite la misma orden. Los archivos `.part` permiten continuar la descarga. El script comprueba tamaño y SHA-256 antes de aceptar cada archivo; esta lectura puede tardar varios minutos y no muestra un porcentaje.

Si ya tienes los tres archivos de esta revisión, colócalos en `modelos` y ejecuta:

```powershell
.\scripts\Descargar-Modelo.ps1 -Recorrido hashyy -Carpeta "$CarpetaHashyy\modelos" -SoloVerificar
```

## 8. Inicia el servidor

Cierra otras aplicaciones que utilicen mucha GPU. Ejecuta:

```powershell
.\scripts\Iniciar-Hashyy.ps1 -Carpeta $CarpetaHashyy -Gpu $GpuHashyy
```

Esta ventana queda ocupada mientras funciona el modelo. El inicio utiliza:

| Opción | Valor inicial | Significado |
| --- | --- | --- |
| `--moe-stream-cache` | `4` | Caché de expertos de unos 4 GiB; activa Expert Streaming |
| `--moe-stream-io-threads` | `4` | Lectores de los expertos desde el SSD |
| `-ngl` | `99` | Solicita llevar las capas a la GPU; el modelo tiene menos capas |
| `-fa` | `on` | Flash Attention |
| `-ctk` / `-ctv` | `q8_0` / `q8_0` | Compresión de la caché del contexto |
| `-ub` | `128` | Tamaño del microlote |
| `-c` / `-np` | `4096` / `1` | Contexto inicial y una petición simultánea |
| `--poll` | `0` | Reduce la espera activa del procesador |
| `--jinja` | Activado | Plantilla de chat del modelo |
| `--host` / `--port` | `127.0.0.1` / `8099` | Acceso local |

El script activa `LLAMA_MOE_STREAM_KEEP_MMAP=1`. No requiere archivos previos de expertos calientes ni un historial de uso: elimina para ese proceso las variables `LLAMA_MOE_STREAM_HOT`, `LLAMA_MOE_STREAM_HEAT` y `LLAMA_MOE_STREAM_ONE_HANDLE`.

Si aparece «out of memory», detén el servidor con Ctrl+C y prueba:

```powershell
.\scripts\Iniciar-Hashyy.ps1 -Carpeta $CarpetaHashyy -Gpu $GpuHashyy -CacheGiB 3 -Contexto 2048
```

Una caché menor puede reducir la velocidad. No cambies varios ajustes a la vez cuando busques el límite de tu equipo.

## 9. Comprueba que genera una respuesta

Abre **otra ventana de PowerShell**, dejando abierta la del servidor:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
.\scripts\Comprobar-Servidor.ps1 -Recorrido hashyy
```

El script espera a que `/health` esté listo, consulta el modelo y pide una respuesta a «cuánto es dos más dos». Debe mostrar una respuesta visible. Esta prueba confirma carga y generación; no mide estabilidad prolongada ni calidad general.

Abre [el chat local](http://127.0.0.1:8099) en tu navegador. Para otras aplicaciones utiliza `http://127.0.0.1:8099/v1`, una clave como `local` y el identificador que devuelve `/v1/models`.

## 10. Volver a utilizarlo

No necesitas recompilar ni descargar todo cada vez:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
.\scripts\Iniciar-Hashyy.ps1 -Carpeta 'C:\QwenTutorial\hashyy' -Gpu 0
```

Sustituye la carpeta y el número de GPU por los que elegiste. Para detenerlo, pulsa Ctrl+C en la ventana del servidor.

[Solución de problemas](03-solucion-de-problemas.md) · [Versiones y fuentes](../VERSIONES.md)
