# sqlite-en-castellano

SQLite en castellano. Bueno, SQLite, SQLite no, solo un ridículo subconjunto de él que permite las CRUD más básicas.

## Versión online

Puedes ir directamente a practicar la sintaxis en:

- [https://allnulled.github.io/sqlite-en-castellano](https://allnulled.github.io/sqlite-en-castellano)

## Sintaxis

Este es el test que está ahora.

```
Selecciono
  campos recurso.id como 'Recurso ID',
    recurso.nombre como 'Nombre'
  de tabla recurso
  junto otro_recurso
    por recurso.id_otro = otro_recurso.id
  donde recurso.id = 15
      y ( 
        recurso.id != 10
        o recurso.id != 11
        o recurso.id != 12
        o recurso.id != 13
        o ( recurso.id != 14 o recurso.id != 16 o recurso.id != 17))
  ordenado por recurso.id descendentemente, otro_recurso.id ascendentemente
  en página 1
  con ítems 20
  creando variable.

Inserto en tabla recurso valores {
    col_1: 'algun valor',
    col_2: 'algun otro valor'
}.

Actualizo en tabla recurso donde (recurso.id = 10) y (recurso.id != 9) y (recurso.id != 7) valores {
    col_1: 'Nuevo valor'
}.

Elimino en tabla recurso donde ( recurso.id = 10 ).

```
