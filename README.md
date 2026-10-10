# Qwen3.8-Flash-Next en Windows

Dos formas de instalar y utilizar Qwen3.8-Flash-Next en tu ordenador, desde cero y con PowerShell. Puedes seguir una sola guía. Cada recorrido descarga su propia versión del modelo y utiliza carpetas independientes.

| Recorrido | Modelo que descarga | Cómo funciona | Guía |
| --- | --- | --- | --- |
| llama.cpp con Expert Streaming y hashyy | Unsloth **UD-IQ3_XXS**, 3 archivos, unos 82 GB | Lee los expertos del SSD y mantiene una caché en la GPU | [Instalar hashyy paso a paso](guias/01-hashyy-iq3-xxs.md) |
| Strata | ISTA-DASLab **GSQ-RCO IQ2_XS**, 2 archivos, unos 68 GB | Reparte el trabajo entre RAM y GPU; prepara sus propios datos y descarga MTP | [Instalar Strata paso a paso](guias/02-strata-iq2-xs.md) |

**IQ3_XXS e IQ2_XS son dos compresiones distintas del modelo. Los archivos de estos recorridos no se intercambian.**

## Qué necesitas

- Windows 10 o 11 de **64 bits**, actualizado, y conexión a Internet para instalar y descargar los modelos.
- Para el recorrido principal de ambas guías: una **NVIDIA RTX con 12 GB de VRAM o más** y un controlador actualizado. Las RTX 20, 30, 40 y 50 se compilan para arquitecturas diferentes; el script de hashyy consulta tu tarjeta.
- **hashyy:** 32 GB de RAM como punto de partida y un SSD NVMe. Se ha comprobado la puesta en marcha en una RTX 5070 de 12 GB. Otras tarjetas pueden necesitar ajustes de caché.
- **Strata IQ2_XS:** 48 GB de RAM como mínimo para el recorrido normal; 64 GB dejan más margen. Con 32 GB y una GPU de 24 GB existe una modalidad de RAM reducida, explicada en su guía.
- Reserva **120 GB libres por recorrido**. Es un margen práctico para el modelo, herramientas, descargas y archivos preparados. Para conservar ambos, reserva unos 240 GB. Los instaladores pueden necesitar espacio adicional en C: aunque guardes los modelos en otra unidad.

En Strata hay también un recorrido AMD. Está explicado por separado en su guía y remite a la compatibilidad del proyecto. El recorrido hashyy de este tutorial utiliza CUDA y NVIDIA.

## Empieza aquí

1. Descarga este repositorio con **Code → Download ZIP** y pulsa **Extraer todo**. No ejecutes los archivos desde dentro del ZIP.
2. Copia la carpeta extraída a **`C:\QwenTutorial\tutorial`**. Dentro deben verse `README.md`, `guias` y `scripts` directamente.
3. Abre Inicio, escribe **Windows PowerShell** y abre la aplicación. No necesitas instalar PowerShell 7.
4. Copia este bloque y pulsa Intro:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
```

La primera orden permite ejecutar los scripts solamente en esa ventana. Si aparece una confirmación, acéptala para continuar. Al cerrar la ventana se pierde este ajuste.

5. Elige [hashyy con IQ3_XXS](guias/01-hashyy-iq3-xxs.md) o [Strata con IQ2_XS](guias/02-strata-iq2-xs.md) y sigue sus pasos en orden. Las dos guías repiten lo necesario para poder usarse de forma independiente.

Si un paso muestra un error, detente y consulta [Solución de problemas](guias/03-solucion-de-problemas.md). No pegues el paso siguiente hasta resolverlo.

## Dónde queda cada instalación

```text
C:\QwenTutorial\
├── tutorial\               Estas guías y sus scripts
├── hashyy\
│   ├── hashyy-original\    Repositorio original de hashyy
│   ├── llama.cpp\          Fuentes corregidas y compilación
│   └── modelos\            Los tres GGUF UD-IQ3_XXS
└── strata\
    ├── app\                Strata, su entorno Python y configuración
    └── Strata-data\        Los dos GGUF IQ2_XS, datos preparados y MTP
```

Puedes elegir otra unidad. Las guías muestran cómo cambiar las rutas en todos los pasos. No hace falta una cuenta de GitHub para ejecutar el tutorial.

## Cuando ya están instalados

Abre PowerShell y ejecuta **solo uno**:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial

# hashyy: cambia 0 por el número de la GPU que elegiste.
.\scripts\Iniciar-Hashyy.ps1 -Gpu 0
```

O bien:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Set-Location C:\QwenTutorial\tutorial
.\scripts\Iniciar-Strata.ps1
```

| Servicio | Página del chat | Dirección para aplicaciones compatibles |
| --- | --- | --- |
| hashyy | `http://127.0.0.1:8099` | `http://127.0.0.1:8099/v1` |
| Strata | `http://127.0.0.1:8080` | `http://127.0.0.1:8080/v1` |

Mantén abierta la ventana del servidor. Para detenerlo, pulsa **Ctrl+C** en esa ventana y espera a que vuelva el cursor. Los servidores escuchan únicamente en tu ordenador. Tras descargar todo, el chat local no necesita una conexión a Internet.

## Versiones y comprobaciones

Las fuentes y los modelos se fijan a versiones concretas para evitar que una actualización cambie los pasos. hashyy incluye un parche que se aplica sin conflictos sobre una base disponible de llama.cpp. Strata utiliza el motor precompilado **0.1.40.2**: no exige instalar Visual Studio ni CUDA Toolkit en el recorrido normal.

Consulta [Versiones, fuentes y comprobaciones](VERSIONES.md) para ver los commits, las descargas, los límites de las pruebas y las licencias. Las velocidades dependen de la tarjeta, RAM, SSD, contexto y carga del ordenador; este tutorial no promete una velocidad concreta.

## Licencias

Las guías y los scripts de este repositorio se distribuyen con [licencia MIT](LICENSE). El parche conserva las atribuciones de [hashyy](licencias/hashyy-MIT.txt) y [llama.cpp](licencias/llama.cpp-MIT.txt). Strata y los modelos tienen sus propias licencias, enlazadas en [VERSIONES.md](VERSIONES.md). Los modelos no están incluidos en este repositorio.
