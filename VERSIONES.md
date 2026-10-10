# Versiones, fuentes y comprobaciones

[Volver al inicio](README.md)

Revisión: **10 de octubre de 2026**. Las guías utilizan las versiones que figuran aquí. Para repetir estos pasos, conserva esos commits y las revisiones de los modelos.

## llama.cpp con hashyy

| Componente | Versión o referencia |
| --- | --- |
| [hashyy](https://github.com/MohammadHaishemKhawaja/hashyy/tree/6189bf3746e6bc267465c66d85cc07ebd8dde79a) | `6189bf3746e6bc267465c66d85cc07ebd8dde79a` |
| [Base de llama.cpp](https://github.com/ggml-org/llama.cpp/tree/254b177307b14d055bbe4c050c9c441a1e06d8a4) | `254b177307b14d055bbe4c050c9c441a1e06d8a4` |
| [Expert Streaming, PR #25294](https://github.com/ggml-org/llama.cpp/pull/25294) | Integración adaptada a la base anterior y correcciones de hashyy |
| [Parche completo](patches/hashyy-expert-streaming.patch) | SHA-256 `190d0cc8cfeaa0c5067d842683ec58b695acdc49bc802515334b6f65dd82e94b` |
| CMake | 4.4.4 |
| MSVC de Visual Studio 2022 | Compilación comprobada con 19.44; instalador Build Tools 17.14.41 en WinGet |
| CUDA Toolkit | 13.4, `nvcc 13.4.59`; paquete WinGet 13.4, instalador CUDA 13.4.1 |
| Arquitectura comprobada | `120`, RTX 5070 |
| Modelo | [Unsloth UD-IQ3_XXS](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF/tree/38bb39ee97821de2c9009abb7e93950eec396e66/UD-IQ3_XXS) |
| Revisión del modelo | `38bb39ee97821de2c9009abb7e93950eec396e66` |

El parche se distribuye completo: integra la adaptación de Expert Streaming a la base seleccionada y los cambios de hashyy. Se ha aplicado sobre una copia limpia, sin conflictos. Sus 18 archivos resultantes coinciden con las fuentes de la instalación comprobada, normalizando únicamente los finales de línea de Windows.

La base `177375096650b78a2ee4b220ec9abf2a57b73ec9`, mencionada en las instrucciones originales de hashyy, no estaba disponible en upstream. Este tutorial no depende de ella ni de una mezcla manual de ramas.

## Strata

| Componente | Versión o referencia |
| --- | --- |
| [Fuentes de Strata](https://github.com/Niko1221/Strata/tree/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a) | `e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a` |
| Archivo ZIP de esas fuentes | SHA-256 `9e5a8086fc1869c6a23859bd9d06e93d91adbc066b54c4239f84a70f791e4480` |
| [Motor NVIDIA para Windows](https://github.com/Niko1221/Strata/releases/tag/v0.1.40.2) | 0.1.40.2, `strata-windows-x64.zip` |
| ZIP del motor | 135.496.886 bytes; SHA-256 `02901f0cd0691ab33ec827e354ffa72e1ab4f19a093f0280c6deb7327b26eb30` |
| Metadatos del motor | CUDA 13.0; `sm_75`, `sm_86`, `sm_89`, `sm_120` y PTX |
| Bibliotecas CUDA privadas | `nvidia-cublas==13.0.2.14`, `nvidia-cuda-runtime==13.0.96` |
| llama.cpp auxiliar de Strata | `3cf03257f219afbe7334045ff7c6a06ac68c627d`, descargado por su instalador |
| Modelo | [ISTA-DASLab GSQ-RCO IQ2_XS](https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF/tree/ed59f92082b1e93c0e96d60a8b11aab089b52f09/IQ2_XS) |
| Revisión del modelo | `ed59f92082b1e93c0e96d60a8b11aab089b52f09` |
| Checkpoint para MTP | [Qwen3.8-Flash-Next](https://huggingface.co/Qwen/Qwen3.8-Flash-Next/tree/de4b8e4d43b917e7706784d8bb445c9af86a3540), revisión `de4b8e4d43b917e7706784d8bb445c9af86a3540` |

Strata descarga los rangos de los tensores MTP necesarios y los prepara; no requiere descargar los cientos de gigabytes del checkpoint completo. Las revisiones del modelo y MTP estaban accesibles en la comprobación.

El instalador de Strata puede proponer o utilizar archivos actuales si una revisión antigua deja de existir. Si muestra ese aviso, la instalación ya no corresponde exactamente a las revisiones de esta tabla: detente y revisa la descarga antes de darla por equivalente.

### Dependencias Python

El [requirements.txt de este commit](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/requirements.txt) fija las dependencias. Se han instalado correctamente en un entorno privado nuevo:

| Paquete | Versión |
| --- | --- |
| numpy | 2.5.3 para Python ≥3.12; 2.4.6 para Python 3.11; 2.2.6 para Python anterior |
| jinja2 / markupsafe | 3.1.6 / 3.0.3 |
| regex | 2026.9.10 |
| pyyaml | 6.0.3 |
| tqdm | 4.70.1 |
| requests | 2.34.2 |
| cmake / ninja | 4.4.3 / 1.13.2 |
| pillow / psutil | 12.3.0 / 7.2.2 |
| certifi | 2026.7.22 |
| charset-normalizer / idna | 3.5.1 / 3.20 |
| urllib3 / colorama | 2.8.0 / 0.4.6 |

El primer inicio sin Python utiliza el mecanismo de instalación de `START-HERE.bat`: WinGet para Python 3.12 o el instalador oficial 3.12.10 de 64 bits como alternativa. La prueba del entorno nuevo utilizó un Python ya disponible. El arranque desde un Windows sin Python se ha revisado en el lanzador, pero no se ha repetido desinstalando Python del equipo de prueba.

## Integridad de los modelos

[modelos.json](modelos.json) contiene, para cada fragmento, repositorio, revisión, ruta, tamaño exacto en bytes y SHA-256 publicado por Hugging Face. Los cinco GGUF disponibles en el equipo se han leído completos y sus sumas coinciden con ese manifiesto.

Los tamaños de las guías usan GB decimales. Las opciones de caché de hashyy usan GiB; las reservas de Strata usan MiB. No son unidades intercambiables.

## Qué se ha probado

Equipo de comprobación: Windows 11 Pro de 64 bits, 64 GB de RAM, RTX 5070 de 12 GB, RTX 5060 Ti de 16 GB y controlador NVIDIA 616.92.

| Comprobación | Resultado |
| --- | --- |
| Descarga de los commits mediante los scripts de preparación | Correcta para ambos recorridos |
| Aplicación del parche de hashyy sobre una base limpia | Sin conflictos; 18 archivos reproducidos |
| Compilación limpia de hashyy con el script incluido | Correcta; `llama-server` y `llama-bench` creados |
| Versión, dispositivos y ayuda del servidor compilado | Correctos; opción de Expert Streaming presente |
| hashyy con UD-IQ3_XXS completo, caché 4 GiB, contexto 4096 y RTX 5070 | Carga y generación correctas |
| Dependencias Strata en un entorno nuevo | Instaladas correctamente |
| Instalador de Strata del commit fijado | Correcto; motor descargado y configuración creada, reutilizando los GGUF, pack y MTP existentes |
| Lanzador incluido de Strata con una RTX 5070 | Carga y generación correctas |
| Ajuste y arranque de Strata con RTX 5070 + RTX 5060 Ti | Reparto activo y generación correcta |
| SHA-256 de los 3 GGUF de hashyy y los 2 de Strata | Coinciden con los publicados |
| Descarga interrumpida de un fragmento de hashyy | Continuación correcta desde 1 MiB, con SHA-256 final correcto |
| Prueba común del servidor | `/health`, `/v1/models` y `/v1/chat/completions` correctos en ambos recorridos |

En ambos servidores, la petición «cuánto es dos más dos» devolvió **«Dos más dos es cuatro.»** Las pruebas se realizaron en puertos locales alternativos para evitar interferencias con otras instalaciones. Los puertos predeterminados del tutorial son 8099 para hashyy y 8080 para Strata.

Estas pruebas confirman instalación de fuentes y dependencias, compilación de hashyy, carga y una generación corta. No son un benchmark, una prueba prolongada ni una garantía para cualquier hardware. No se ha repetido la instalación completa en una máquina Windows vacía, ni la descarga íntegra de los modelos, la preparación inicial del pack de Strata o la extracción inicial de MTP durante esta revisión. Los mecanismos y las revisiones de esas etapas se han contrastado con el código del instalador.

Las alternativas AMD, 32 GB de RAM, otras arquitecturas NVIDIA y Windows 10 se basan en la documentación y opciones de sus proyectos; no se han ejecutado en ese hardware durante esta comprobación.

## Documentación oficial

- [Instalación de CUDA en Windows](https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/).
- [Descarga de CUDA Toolkit 13.4.1](https://developer.nvidia.com/cuda-13-4-1-download-archive).
- [WinGet y App Installer](https://learn.microsoft.com/windows/package-manager/winget/).
- [Instalación de herramientas C++ de Microsoft](https://learn.microsoft.com/cpp/overview/acquire-msvc?view=msvc-170).
- [Instalación de Strata](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/docs/INSTALL.md).
- [Modelos y RAM en Strata](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/docs/MODELS.md).
- [Varias GPU en Strata](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/docs/MULTI_GPU.md).

## Atribuciones y licencias

- **hashyy:** Mohammad Haishem Khawaja, MIT. Se conserva su [licencia y aviso originales](licencias/hashyy-MIT.txt).
- **llama.cpp / ggml:** los autores de ggml, MIT. Se conserva su [licencia](licencias/llama.cpp-MIT.txt). El parche deriva de llama.cpp, de la propuesta de Expert Streaming y de los cambios de hashyy, con adaptación a la base indicada.
- **Strata:** [licencia MIT del proyecto](https://github.com/Niko1221/Strata/blob/e8ca9afd03d839d4f8dbbe82dffce7f8a3bafd7a/LICENSE). No se redistribuye su motor en este tutorial: lo descarga su instalador.
- **Qwen3.8-Flash-Next:** [ficha y licencia del modelo original](https://huggingface.co/Qwen/Qwen3.8-Flash-Next).
- **Unsloth e ISTA-DASLab:** consulta las fichas de las dos cuantizaciones enlazadas arriba y sus condiciones antes de redistribuir pesos.

La licencia de los scripts no sustituye las condiciones de CUDA, Visual Studio, Python o los modelos. El ZIP del tutorial contiene documentación, scripts y un parche; no incluye modelos ni ejecutables de terceros.
