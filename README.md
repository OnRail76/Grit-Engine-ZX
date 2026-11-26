# GRIT ENGINE ZX — V1.1

**Tony C. Ware · 2026 · ZX Spectrum 48K · Z80**

Banco de desarrollo por perfiles. Seis tecnologías procedentes de Circo Dimensional, Halcones Estelares, ERROR 2026, Grit Claymore, Neptuno Ataca y Escoria Sideral. Cada perfil conserva su mapa de memoria y su renderizador.

## Descarga oficial

[**GRIT ENGINE TECH DEMO V1.1 (TAP)**](https://github.com/OnRail76/Grit-Engine-ZX/releases/latest/download/GRIT_ENGINE_TECH_DEMO_V1.1.tap) · [Release y paquete completo](https://github.com/OnRail76/Grit-Engine-ZX/releases/latest)

77.802 bytes · seis bloques TAP · SHA-256 `82036bb66376e3465ed91e7ab0d973cd429a39d0c5a528c5b0a153ef72dc7032`.

V1.1 es la única edición vigente. El TAP es idéntico al último binario aprobado en Fuse por el autor el 26/11/2026. V1.0 queda como referencia histórica y dependencia del constructor; no es una segunda demo vigente.

## Technology Demo

| Perfil | Tecnología |
|---|---|
| 1 | Fixed Platform — Circo Dimensional |
| 2 | Fixed Shooter — Halcones Estelares |
| 3 | Arena Shooter — ERROR 2026 |
| 4 | Ground Combat — Grit Claymore |
| 5 | Vertical Shmup — Neptuno Ataca |
| 6 | Horizontal Run & Gun — Escoria Sideral |

ZX Spectrum 48K: LOAD ""; 1–6 o Q/A y SPACE/FIRE; X vuelve al menú. QAOP + SPACE y Kempston. Los perfiles 1–5 conmutan en RAM. Para entrar en el 6, continúa la cinta cuando aparezca PLAY CINTA SPACE: pulsa y suelta SPACE. Para regresar, REBOBINA Y SPACE: rebobina y pulsa y suelta SPACE. Las demos 5 y 6 contienen solo la primera fase de su juego.

## Desarrollo

- `core/`: formatos y extracciones Z80 con procedencia.
- `profiles/`: perfiles de referencia, banco de rendimiento y constructor horizontal.
- `demo/technology_demo_v11/`: constructor y regresiones del selector oficial.
- `demo/technology_demo/`: base histórica V1.0 necesaria para reconstruir V1.1.
- `provenance/`: commits fijados e inventario.
- `docs/`: documentación técnica.

```sh
python3 -m pip install -r requirements.txt
python3 grit.py verify
python3 grit.py import Escoria-Sideral
python3 grit.py demo6
python3 demo/technology_demo_v11/build.py
python3 demo/technology_demo_v11/test_switch.py
```

[Manual de uso, mapa de memoria y construcción V1.1](demo/technology_demo_v11/LEEME.md) · [Arquitectura del perfil 6 y multicarga](docs/GRIT_ENGINE_ZX_V1.1_ESCORIA.md) · [Manual técnico histórico V1.0](docs/GRIT_ENGINE_48K_MANUAL_TECNICO_V1.0.pdf).

## Alcance y validación

El motor incorpora compositor antiparpadeo por bandas, compresión de sprites por diccionario, scroll de suelo a 2 px, director de oleadas, jefes por parches y beeper con prioridades y reserva de CPU. La transición de cinta espera la liberación de SPACE antes de acceder a la ROM. La demo conjunta ha sido aprobada en Fuse por el autor; las pruebas automatizadas simulan ROM e interrupciones. No se certifica hardware físico ni ABI Z80 universal. Los cuatro proyectos originales no empaquetados se recuperan mediante los commits fijados (`python3 grit.py import all`, requiere Git y conexión). No se modifican los repositorios de los juegos.

## Licencias

Código e infraestructura MIT, conservando las atribuciones originales de LICENSE. Los gráficos y contenidos se conservan como referencia; no se amplían sus permisos de reutilización.
