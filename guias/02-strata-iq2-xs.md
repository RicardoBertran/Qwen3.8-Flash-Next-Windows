# Strata con Qwen3.8-Flash-Next IQ2_XS

[Volver al inicio](../README.md)

Este recorrido instala **Strata con los archivos GSQ-RCO IQ2_XS de ISTA-DASLab**. Strata prepara sus propios datos, descarga el componente MTP y utiliza una parte del modelo en RAM y otra en GPU. Su recorrido normal descarga un motor ya compilado.

## 1. Comprueba el equipo y prepara la carpeta del tutorial

Para el recorrido principal necesitas Windows 10/11 de 64 bits, una NVIDIA RTX con **12 GB de VRAM o más**, **48 GB de RAM como mínimo** —64 GB dan más margen—, controlador NVIDIA 580 o posterior y unos 120 GB libres en un SSD. El procesador debe tener AVX2 para el recorrido con el motor normal.

Descarga el ZIP del tutorial, pulsa **Extraer todo** y copia su contenido a `C:\QwenTutorial\tutorial`. Dentro deben aparecer directamente `README.md`, `scripts` y `guias`.

Abre **Windows PowerShell** desde Inicio y ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
[Environment]::Is64BitOperatingSystem
[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name='LibreGB';Expression={[math]::Round($_.Free / 1GB, 1)}}
nvidia-smi --query-gpu=index,name,memory.total,driver_version --format=csv
```

La primera comprobación debe mostrar `True`. La segunda muestra la RAM en GiB. Si no existe `nvidia-smi`, instala el [controlador oficial de NVIDIA](https://www.nvidia.com/Download/index.aspx) y reinicia Windows. El instalador de Strata comprobará también el procesador y el controlador.

Define la carpeta que vas a utilizar:

```powershell
$CarpetaStrata = 'C:\QwenTutorial\strata'
$GpuStrata = 0
```

Puedes cambiar la carpeta a `D:\QwenTutorial\strata`. Cambia el `0` por el índice que muestra `nvidia-smi` para tu tarjeta. Elige una ruta corta, fuera de OneDrive y de `Archivos de programa`. Si abres otra ventana, vuelve a definir estas variables.

No necesitas tener instalados Git, Python, Visual Studio, CMake ni CUDA Toolkit. El script descarga las fuentes por HTTPS; `START-HERE.bat` instala Python si falta y crea un entorno privado dentro de `app\.venv`.

## 2. Descarga una versión concreta de Strata

```powershell
.\scripts\Preparar-Strata.ps1 -Carpeta $CarpetaStrata
```

Descarga el commit `e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a` del [repositorio de Strata](https://github.com/Niko1221/Strata) y lo extrae en `app`. El programa de instalación se llama `START-HERE.bat`; la lógica de instalación está en `setup.py`.

## 3. Comprueba el ordenador

```powershell
Push-Location "$CarpetaStrata\app"
.\START-HERE.bat --check
Pop-Location
```

Este paso puede instalar Python y crear `.venv`, pero todavía no descarga el modelo. Revisa el resultado: tarjeta, controlador, RAM, procesador y espacio libre. Si aparece un problema, resuélvelo antes de continuar.

Si Python no se instala automáticamente, sigue [la solución para Python](03-solucion-de-problemas.md#python-no-se-instala-o-se-abre-microsoft-store). Utiliza Python 3.12 de 64 bits y vuelve a ejecutar el paso.

## 4. Instala IQ2_XS

```powershell
.\scripts\Instalar-Strata.ps1 -Carpeta $CarpetaStrata -Gpu $GpuStrata
```

La orden utiliza estos ajustes:

| Opción | Valor | Para qué sirve |
| --- | --- | --- |
| `--family` | `qwen` | Familia original de Qwen3.8-Flash-Next |
| `--model` | `IQ2_XS` | Compresión GSQ-RCO IQ2_XS |
| `--context` | `32768` | Contexto inicial |
| `--vision` | `no` | Instalación de chat de texto |
| `--gpu` | El índice que elegiste | Una tarjeta para la primera instalación |
| `--backend` / `--cuda` | `cuda` / `13` | Motor NVIDIA y sus bibliotecas |
| `--vram-reserve-mib` | `2048` | Deja margen para Windows y el escritorio |
| `--source` | `huggingface` | Descargas de los modelos |
| `--prebuilt` | Release `v0.1.40.2` | Motor concreto, sin sustituirlo automáticamente por la última release |
| `--host` | `127.0.0.1` | Acceso desde el propio ordenador |
| `--yes` / `--setup` / `--no-start` | Activadas | Instala esos ajustes sin preguntas y deja el inicio para el siguiente paso |

El instalador hace lo siguiente:

1. Comprueba el equipo.
2. Instala las dependencias Python de su `requirements.txt` en `app\.venv`.
3. Instala las bibliotecas CUDA de ejecución dentro del entorno: `nvidia-cublas==13.0.2.14` y `nvidia-cuda-runtime==13.0.96`.
4. Descarga y comprueba el motor `strata-windows-x64.zip`, versión **0.1.40.2**.
5. Descarga los dos archivos IQ2_XS, sus archivos auxiliares y el componente MTP. Strata obtiene este último del checkpoint original y lo prepara para su motor.
6. Prepara los datos en `Strata-data`.
7. Crea `app\strata-iq2_xs.json` y el lanzador `app\run-iq2_xs.bat`.

Las dos piezas del modelo son:

| Archivo | Tamaño aproximado |
| --- | ---: |
| `Qwen3.8-Flash-Next-GSQ-RCO-IQ2_XS-00001-of-00002.gguf` | 39,23 GB |
| `Qwen3.8-Flash-Next-GSQ-RCO-IQ2_XS-00002-of-00002.gguf` | 28,80 GB |

Los dos se guardan en `Strata-data\models\IQ2_XS`. Ambos son necesarios. El segundo contiene una gran tabla que el motor utiliza desde el SSD. La descarga completa también incluye MTP, datos del tokenizador y dependencias: no son solamente los 68 GB de GGUF.

**No copies los UD-IQ3_XXS de hashyy en esta carpeta.** Strata distingue entre sus modelos y sus formatos compatibles; la coincidencia parcial de un nombre no basta.

Si la descarga se interrumpe, repite la misma orden del paso 4. Strata reutiliza los archivos preparados y continúa las descargas pendientes. No ejecutes dos instaladores al mismo tiempo.

Puedes pedir una comprobación adicional de los GGUF:

```powershell
.\scripts\Descargar-Modelo.ps1 -Recorrido strata -Carpeta "$CarpetaStrata\Strata-data\models\IQ2_XS" -SoloVerificar
```

El script lee los dos archivos y compara su SHA-256 con `modelos.json`. Puede tardar varios minutos.

### Guardar los datos en otra unidad

Si quieres dejar el programa en C: y los modelos en D:, sustituye la orden del paso 4 por:

```powershell
.\scripts\Instalar-Strata.ps1 -Carpeta $CarpetaStrata -CarpetaDatos 'D:\QwenTutorial\Strata-data' -Gpu $GpuStrata
```

La configuración guardará las rutas elegidas. Strata también recuerda la carpeta de datos en `%APPDATA%\Strata\settings.json`. Para comprobar los GGUF, utiliza entonces `D:\QwenTutorial\Strata-data\models\IQ2_XS`.

## 5. Inicia Strata

```powershell
.\scripts\Iniciar-Strata.ps1 -Carpeta $CarpetaStrata
```

El script utiliza el Python privado, el servidor de Strata y `strata-iq2_xs.json`, sin volver a lanzar una actualización. La configuración contiene las rutas al motor, los GGUF, el pack preparado, MTP y sus bibliotecas.

Al cargar el modelo, el ordenador puede ralentizarse mientras se reserva RAM. Espera a que el motor termine. Si aparece un error, consúltalo en la ventana y en `app\strata-iq2_xs.log`. Mantén abierta la ventana del servidor.

El navegador se abre en [http://127.0.0.1:8080](http://127.0.0.1:8080). Si no se abre automáticamente, escribe esa dirección en tu navegador.

## 6. Comprueba carga y respuesta

Abre **otra ventana de PowerShell** y ejecuta:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
.\scripts\Comprobar-Servidor.ps1 -Recorrido strata
```

La prueba espera tanto `status: ok` como `loaded: true`. El servidor de Strata puede contestar a `/health` antes de que el modelo esté cargado: recibir una página no basta.

Después consulta el modelo y pide una respuesta a «cuánto es dos más dos». Debe mostrar una respuesta visible. Para otras aplicaciones utiliza `http://127.0.0.1:8080/v1`, una clave como `local` y el identificador que devuelve `/v1/models`.

Para detener Strata, pulsa **Ctrl+C** en su ventana y espera a que vuelva el cursor.

## 7. Usar dos GPU NVIDIA

Primero comprueba que el recorrido de una GPU funciona. Detén Strata antes de cambiar la configuración y consulta los índices:

```powershell
nvidia-smi --query-gpu=index,name,memory.total,memory.free --format=csv
```

Strata reparte las capas entre las tarjetas. No requiere NVLink. Cada tarjeta debe disponer de memoria para su parte y para los buffers; en este recorrido de reparto se admiten RTX con al menos 8 GB por tarjeta, con margen suficiente. No se mezclan NVIDIA y AMD.

Ejemplo para un equipo donde la tarjeta principal es GPU 1 y los monitores están en GPU 0:

```powershell
.\scripts\Ajustar-Gpus-Strata.ps1 -Carpeta $CarpetaStrata -Gpus '1,0' -ReservaPrimeraMiB 2048 -ReservaOtrasMiB 3072
.\scripts\Iniciar-Strata.ps1 -Carpeta $CarpetaStrata
```

**Adapta `1,0` a tu equipo.** La primera de la lista es la principal. El script guarda una copia de seguridad de `strata-iq2_xs.json`, fija `gpu` a la lista, `gpus_asked` a `true` y `layer_split` a `auto`.

`--vram-reserve-mib` reserva memoria para la primera tarjeta. `--vram-reserve-later-mib` aplica la otra reserva a todas las tarjetas posteriores. Son reservas en **MiB**, no cantidades de expertos. No pongas esta última opción directamente en `setup.py`: en esta versión es una opción del motor y se escribe en `args` del JSON.

Las reservas del ejemplo son un punto de partida. La tarjeta que utiliza los monitores puede necesitar más margen. Comprueba la GPU utilizada y la memoria disponible en el log tras cada reinicio.

Para volver a una sola tarjeta:

```powershell
.\scripts\Ajustar-Gpus-Strata.ps1 -Carpeta $CarpetaStrata -Gpus '0' -ReservaPrimeraMiB 2048
```

Cambia `0` por tu GPU elegida y vuelve a iniciar Strata. Más tarjetas no garantizan una mejora en todas las peticiones. Consulta la [documentación de reparto de Strata](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/docs/MULTI_GPU.md).

## 8. Si tienes 32 GB de RAM

El recorrido principal se detiene por debajo de 48 GB. Strata documenta IQ2_XS con 32 GB y una NVIDIA de **24 GB de VRAM**, usando su modalidad de RAM reducida. Este caso no se ha probado aquí.

Después del paso 3, ejecuta directamente el instalador de Strata:

```powershell
Push-Location "$CarpetaStrata\app"
& .\.venv\Scripts\python.exe setup.py --yes --setup --family qwen --model IQ2_XS --low-ram auto --context 8192 --vision no --gpu $GpuStrata --backend cuda --cuda 13 --vram-reserve-mib 2048 --host 127.0.0.1 --data-dir "$CarpetaStrata\Strata-data" --source huggingface --prebuilt 'https://github.com/Niko1221/Strata/releases/download/v0.1.40.2/' --no-start
if ($LASTEXITCODE -ne 0) { throw 'Strata no ha terminado la instalación.' }
Pop-Location
```

Revisa especialmente los avisos de RAM y memoria de GPU. Con 32 GB y una tarjeta de 12 GB, IQ2_XS puede depender demasiado del SSD y no es el recorrido normal de este tutorial. No sustituyas silenciosamente IQ2_XS por Coder: es otro modelo.

## 9. Si tu tarjeta es AMD

El instalador de Strata admite determinadas Radeon y dispone de un motor HIP para Windows. El script `Instalar-Strata.ps1` de este tutorial comprueba NVIDIA; para AMD usa el instalador original del commit descargado.

Instala un controlador Adrenalin actualizado y confirma tu tarjeta en la [lista oficial de compatibilidad](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/docs/AMD_HIP.md). Necesitas igualmente la RAM y el espacio de IQ2_XS. Desde PowerShell:

```powershell
Push-Location "$CarpetaStrata\app"
.\START-HERE.bat --check
& .\.venv\Scripts\python.exe setup.py --setup --family qwen --model IQ2_XS --context 32768 --vision no --backend hip --host 127.0.0.1 --data-dir "$CarpetaStrata\Strata-data" --prebuilt 'https://github.com/Niko1221/Strata/releases/download/v0.1.40.2/' --no-start
if ($LASTEXITCODE -ne 0) { throw 'Strata no ha terminado la instalación.' }
Pop-Location
```

Elige la tarjeta en el menú del instalador. Los índices AMD son los que muestra Strata, no los de `nvidia-smi`. Esta alternativa se ha contrastado con las opciones y documentación del proyecto; no se ha probado en una Radeon en este tutorial.

## 10. Volver a utilizarlo y conservar la versión

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
.\scripts\Iniciar-Strata.ps1 -Carpeta 'C:\QwenTutorial\strata'
```

Utiliza tu carpeta si elegiste otra. No ejecutes `UPDATE.bat` para seguir esta versión del tutorial: esa orden cambia el código y el motor. Para probar una versión nueva, prepara otra carpeta y conserva la instalación que funciona.

**Sobre la compilación:** el motor NVIDIA que utiliza esta guía ya viene compilado para `sm_75`, `sm_86`, `sm_89` y `sm_120`, con PTX, y sus metadatos indican CUDA 13.0. Las bibliotecas de ejecución se instalan en `.venv`; no necesitas CUDA Toolkit. Compilar Strata desde fuente es un recorrido distinto y no es necesario para esta instalación.

[Solución de problemas](03-solucion-de-problemas.md) · [Versiones y fuentes](../VERSIONES.md)
