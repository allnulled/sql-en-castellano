Lenguaje = Sentencia_completa*

Sentencia_completa = _* sentencia:Sentencia EOS _* { return sentencia }

Sentencia = Sentencia_Selecciono / Sentencia_Inserto / Sentencia_Actualizo / Sentencia_Elimino

Sentencia_Selecciono = "Selecciono"
  campos:Subs_campos_de_seleccion?
  de_tabla:Subs_de_tabla
  junto:Subs_junto?
  donde:Subs_donde?
  ordenado_por:Subs_ordenado_por?
  paginado_en:Subs_paginado_en?
  creando:Subs_creando?
    { return { operacion: "Selecciono", campos, de_tabla, junto, donde, ordenado_por, paginado_en, creando } }
Subs_campos_de_seleccion = _+ "campos" _+ campos:Seleccion_de_campos { return campos }
Seleccion_de_campos = Seleccion_de_campos_todos 
Seleccion_de_campos_todos = "*" 
Subs_de_tabla = _+ "de tabla" _+ tabla:Nombre_simple { return tabla }
Subs_junto =
  token0:_+
  operador:("junto por la izquierda" / "junto por la derecha" / "junto todo" / "junto lo común" / "junto" )
  token1:_+
  tabla:Nombre
  token2:(_+ "por" _+)
  condicion:Condicion
    { return { tabla, operador, condicion } }
Subs_donde = _+ "donde" _+ condicion:Condicion { return condicion }
Subs_ordenado_por = _+ "ordenado por" _+ sentido:Reglas_de_sentido { return sentido }
Reglas_de_sentido = inicial:Regla_de_sentido_inicial otras:Regla_de_sentido_no_inicial* { return otras ? [inicial, ...otras] : [inicial]; }
Regla_de_sentido_inicial = _* nombre:Nombre sentido:Sentido_del_orden? { return { nombre, sentido } }
Regla_de_sentido_no_inicial = "," regla:Regla_de_sentido_inicial { return regla } 
Sentido_del_orden = _+ sentido:("ascendentemente" / "descendentemente") { return sentido }
Subs_paginado_en = _+ "en página" _+ pagina:Numero _+ "con" _+ items:Numero _+ "ítems por página" { return { pagina, items } }
Subs_creando = _+ "creando" _+ creando:Nombre_simple { return creando }

Condicion = Condicion_compleja / Condicion_simple

Condicion_compleja = 
  token0:_*
  token1:("(" _*)
  condicion:Condicion
  tokenZ:(_* ")")
  complementos:Complementos_de_condicion?
    { return { tipo: "condición compleja", condicion, complementos } }

Condicion_simple = 
  sujeto:Nombre
  predicado:Operacion_condicional
  complementos:Complementos_de_condicion?
    { return { tipo: "condición simple", sujeto, predicado, complementos } }

Complementos_de_condicion = Complemento_de_condicion+

Complemento_de_condicion =
  token0:_+
  operador:("y" / "o")
  token1:_+
  condicion:Condicion
    { return { operador, condicion } }

Operacion_condicional = Operador_condicional_sin_complemento / Operador_condicional_con_complemento
    
Operador_condicional_con_complemento = 
  operador:( " = " / " != " / " <= " / " >= " / " < " / " > " / " está entre " / " no está entre " / " es como " / " no es como " )
  operando:Nombre_o_valor
    { return { operador, operando } }
  
Operador_condicional_sin_complemento = "es nulo" / "no es nulo" 

Nombre_o_valor = Nombre / Valor
Nombre = Nombre_de_columna_de_base_de_datos / Nombre_de_columna_de_tabla / Nombre_de_columna
Nombre_en_texto = Nombre { return text()}
Nombre_de_columna_de_base_de_datos = bd:Nombre_simple "." tabla:Nombre_simple "." columna:Nombre_simple { return { bd, tabla, columna } }
Nombre_de_columna_de_tabla = tabla:Nombre_simple "." columna:Nombre_simple { return { tabla, columna } }
Nombre_de_columna = columna:Nombre_simple { return { columna } }
Nombre_de_tabla = tabla:Nombre_simple { return { tabla } }
Nombre_de_tabla_de_base_de_datos = bd:Nombre_simple "." tabla:Nombre_simple { return { bd, tabla } }
Nombre_simple = [A-Za-z_\$] [0-9A-Za-z_\$]+ { return text() }
Valor = Texto_entre_comillas / Numero
Numero = [0-9]+ ("." [0-9]+)? { return parseInt(text()) }
Texto_entre_comillas = Texto_entre_comillas_simples / Texto_entre_comillas_dobles
Texto_entre_comillas_simples = Abrir_simples_comillas Cerrar_simples_comillas { return text() }
Texto_entre_comillas_dobles = Abrir_dobles_comillas Cerrar_dobles_comillas { return text() }

Abrir_simples_comillas = "'"
Cerrar_simples_comillas = (!("'")("\\'"/"\\"/.))* "'"
Abrir_dobles_comillas = '"'
Cerrar_dobles_comillas = (!('"')('\\"'/'\\'/.))* '"'

Sentencia_Inserto = "Inserto"
  en_tabla:Subs_en_tabla
  valores:Subs_valores
    { return { operacion: "Inserto", en_tabla, valores } }
Subs_en_tabla = _+ "en tabla" _+ tabla:Nombre_de_tabla { return tabla }
Subs_valores = _+ "valores" _+ valores:Conjunto_de_valores { return valores }

Conjunto_de_valores =
  token0:(_* "{" _*)
  valor_1:Valor_inicial_de_conjunto
  valor_n:Valor_no_inicial_de_conjunto*
  tokenZ:(_* "}")
    { return [valor_1].concat(valor_n ? valor_n : []) }

Valor_inicial_de_conjunto = nombre:Nombre_simple _* ":" _* valor:Valor { return { nombre, valor } }
Valor_no_inicial_de_conjunto = _* "," _* valor:Valor_inicial_de_conjunto { return valor }

Sentencia_Actualizo = "Actualizo"
  en_tabla:Subs_en_tabla
  donde:Subs_donde?
  valores:Subs_valores
    { return { operacion: "Actualizo", en_tabla, donde, valores } }

Sentencia_Elimino = "Elimino"
  en_tabla:Subs_en_tabla
  donde:Subs_donde?
    { return { operacion: "Elimino", en_tabla, donde } }

EOS = "."

_ = __ / ___ / Comentario_multilinea
__ = " " / "\t"
___ = "\r\n" / "\r" / "\n"

Comentario_multilinea = "/*" (!("*/").)* "*/" { return text() }