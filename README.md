# Web personal sobre mercado de trabajo

Este repositorio contiene el conjunto de archivos necesarios para visualizar mi web personal. Muestra, de manera minimalista, algunas clasificaciones y estimaciones relacionadas con el mercado de trabajo español.

En primer lugar, se incluye la clasificación de ocupaciones CNO-11 a 8 dígitos, extraída del catálogo del SEPE (para el SISPE). Se visualiza como un árbol desplegable en la web. En segundo lugar, se presenta una tabla con estimaciones sobre la probabilidad de estar empleado en cada ocupación dado que has estudiado un grado universitario de un cierto campo de estudio. La fuente de datos de estas estimaciones es la Encuesta de Inserción Laboral de Titulados Universitarios (EILU) 2019 del INE. 

## Estructura

- `index.html`: Página principal
- `gradocno.html`: Ocupaciones de graduados universitarios por campo de estudio
- `style.css`: Estilos
- `script.js`: Código para cargar el JSON y mostrarlo como árbol
- `ocupaciones_sispe_jerarquico.json`: Datos estructurados jerárquicamente en JSON
- `grado_occs_eilu19.csv`: Estimaciones de la EILU 2019.
