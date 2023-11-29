{
    const reduzco_selecciono = function({ campos, de_tabla, junto, donde, ordenado_por, paginado_en }) {
        let sql = "";
        sql += "SELECT ";
        if(campos) {
            sql += campos;
        } else {
            sql += "*";
        }
        if(de_tabla) {
            sql += "\n";
            sql += "  FROM ";
            sql += de_tabla;
        }
        if(junto) {
            sql += "\n";
            sql += "  JOIN ";
            sql += junto;
        }
        if(donde) {
            sql += "\n";
            sql += " WHERE ";
            sql += donde;
        }
        if(ordenado_por) {
            sql += "\n";
            sql += " ORDER BY ";
            sql += ordenado_por;
        }
        if(paginado_en) {
            sql += paginado_en;
        }
        return sql;
    };
    const compongo_objeto = function(...args) {
      const output = {};
      for(let i=0; i<args.length; i++) {
        const arg = args[i];
        Object.assign(output, arg);
      }
      return output;
    };
    const reduzco_inserto = function({ en_tabla, valores }) {
      const claves = Object.keys(valores);
        let sql = "";
        sql += "INSERT INTO ";
        sql += en_tabla;
        sql += " (\n  ";
        for(let index_campos=0; index_campos<claves.length; index_campos++) {
          const clave = claves[index_campos];
          if(index_campos !== 0) {
            sql += ",\n  ";
          }
          sql += clave;
        }
        sql += "\n) VALUES (\n  ";
        for(let index_campos=0; index_campos<claves.length; index_campos++) {
          const clave = claves[index_campos];
          const valor = valores[clave];
          if(index_campos !== 0) {
            sql += ",\n  ";
          }
          sql += valor;
        }
        sql += "\n);";
        return sql;
    };
    const reduzco_actualizo = function({ en_tabla, donde, valores }) {
      const claves = Object.keys(valores);
        let sql = "";
        sql += "UPDATE ";
        sql += en_tabla;
        sql += " SET (\n  ";
        for(let index_campos=0; index_campos<claves.length; index_campos++) {
          const clave = claves[index_campos];
          const valor = valores[clave];
          if(index_campos !== 0) {
            sql += ",\n  ";
          }
          sql += valor;
        }
        sql += "\n) WHERE ";
        sql += donde;
        sql += ";";
        return sql;
    };
    const reduzco_elimino = function({ en_tabla, donde }) {
        let sql = "";
        sql += "DELETE FROM ";
        sql += en_tabla;
        sql += "\n) WHERE ";
        sql += donde;
        sql += ";";
        return sql;
    };
    const traducir_operador = function(operador) {
        switch(operador) {
            case " está entre ": return "IN";
            case " no está entre ": return "NOT IN";
            case " es como ": return "LIKE";
            case " no es como ": return "NOT LIKE";
            case " es nulo ": return "IS NULL";
            case " no es nulo ": return "IS NOT NULL";
            case "y": return "   AND";
            case "o": return "    OR";
            default: return operador;
        }
    };
}

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
    { return reduzco_selecciono({ campos, de_tabla, junto, donde, ordenado_por, paginado_en }) }

Subs_campos_de_seleccion = _+ "campos" _+ campos:Seleccion_de_campos { return campos }
Seleccion_de_campos = Seleccion_de_campos_todos / Seleccion_de_campos_algunos 
Seleccion_de_campos_todos = "*" 
Seleccion_de_campos_algunos = inicial:Seleccion_de_campos_algunos_inicial otros:Seleccion_de_campos_algunos_no_inicial { return inicial + (otros ? otros : "") }
Seleccion_de_campos_algunos_inicial =_* nombre:Nombre _+ "como" _+ texto:Texto_entre_comillas { return nombre + " AS " + texto }
Seleccion_de_campos_algunos_no_inicial = _* "," _* seleccion:Seleccion_de_campos_algunos_inicial { return ",\n       " + seleccion }

Subs_de_tabla = _+ "de tabla" _+ tabla:Nombre_simple { return tabla }

Subs_junto =
  token0:_+
  operador:("junto por la izquierda" / "junto por la derecha" / "junto todo" / "junto lo común" / "junto" )
  token1:_+
  tabla:Nombre
  token2:(_+ "por" _+)
  condicion:Condicion
    { return `${tabla}\n    ON ${condicion}` }

Subs_donde = _+ "donde" _+ condicion:Condicion { return condicion }

Subs_ordenado_por = _+ "ordenado por" _+ orden:Reglas_de_sentido { return orden }
Reglas_de_sentido = inicial:Regla_de_sentido_inicial otras:Regla_de_sentido_no_inicial* { return inicial + (otras ? otras : "") }
Regla_de_sentido_inicial = _* nombre:Nombre sentido:Sentido_del_orden? { return `${nombre} ${sentido === "ascendentemente" ? "ASC" : "DESC" }` }
Regla_de_sentido_no_inicial = "," regla:Regla_de_sentido_inicial { return "," + regla } 
Sentido_del_orden = _+ sentido:("ascendentemente" / "descendentemente") { return sentido }

Subs_paginado_en = _+ "en página" _+ pagina:Numero _+ "con ítems" _+ items:Numero { return ` LIMIT ${items} OFFSET ${ ( items * pagina ) - items}` }

Subs_creando = _+ "creando" _+ creando:Nombre_simple { return creando }

Condicion = Condicion_compleja / Condicion_simple

Condicion_compleja = 
  token0:_*
  token1:("(" _*)
  condicion:Condicion
  tokenZ:(_* ")")
  complementos:Complementos_de_condicion?
    { return "(" + condicion + ")" + (complementos ? complementos : "") }

Condicion_simple = 
  sujeto:Nombre_o_valor
  predicado:Operacion_condicional
  complementos:Complementos_de_condicion?
    { return sujeto + predicado + (complementos ? complementos : "") }

Complementos_de_condicion = Complemento_de_condicion+

Complemento_de_condicion =
  token0:_+
  operador:("y" / "o")
  token1:_+
  condicion:Condicion
    { return "\n" + traducir_operador(operador) + " " + condicion }

Operacion_condicional = Operador_condicional_sin_complemento / Operador_condicional_con_complemento
    
Operador_condicional_con_complemento = Operadores_grupo_1 / Operadores_grupo_2

Operadores_grupo_1 = 
  operador:( " = " / " != " / " <= " / " >= " / " < " / " > " / " es como " / " no es como " )
  operando:Nombre_o_valor
    { return " " + traducir_operador(operador) + " " + operando }
  
Operadores_grupo_2 = 
  operador:(" está entre " / " no está entre ")
  operando:Lista_de_valores
    { return " " + traducir_operador(operador) + " " + operando }

Operador_condicional_sin_complemento = "es nulo" / "no es nulo" { return text() === "es nulo" ? "IS NULL" : "IS NOT NULL" }

Lista_de_valores = 
  token1:(_* "[" _*)
  inicial:Valor_de_lista_inicial
  otros:Valor_de_lista_no_inicial*
  tokenZ:(_* "]")
    { return inicial + (otros ? otros : "" ) }
Valor_de_lista_inicial = Valor
Valor_de_lista_no_inicial = _* "," _* valor:Valor_de_lista_inicial { return valor }

Nombre_o_valor = Nombre / Valor
Nombre = Nombre_de_columna_de_base_de_datos / Nombre_de_columna_de_tabla / Nombre_de_columna { return text() }
Nombre_de_columna_de_base_de_datos = bd:Nombre_simple "." tabla:Nombre_simple "." columna:Nombre_simple { return text() }
Nombre_de_columna_de_tabla = tabla:Nombre_simple "." columna:Nombre_simple { return text() }
Nombre_de_columna = columna:Nombre_simple { return text() }
Nombre_de_tabla = tabla:Nombre_simple { return text() }
Nombre_de_tabla_de_base_de_datos = bd:Nombre_simple "." tabla:Nombre_simple { return text() }
Nombre_simple = [A-Za-z_\$] [0-9A-Za-z_\$]* { return text() }
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
    { return reduzco_inserto({ operacion: "Inserto", en_tabla, valores }) }
Subs_en_tabla = _+ "en tabla" _+ tabla:Nombre_de_tabla { return tabla }
Subs_valores = _+ "valores" _+ valores:Conjunto_de_valores { return valores }

Conjunto_de_valores =
  token0:(_* "{" _*)
  valor_1:Valor_inicial_de_conjunto
  valor_n:Valor_no_inicial_de_conjunto*
  tokenZ:(_* "}")
    { return compongo_objeto(valor_1, ...valor_n) }

Valor_inicial_de_conjunto = nombre:Nombre_simple _* ":" _* valor:Valor { return { [nombre]: valor } }
Valor_no_inicial_de_conjunto = _* "," _* valor:Valor_inicial_de_conjunto { return valor }

Sentencia_Actualizo = "Actualizo"
  en_tabla:Subs_en_tabla
  donde:Subs_donde?
  valores:Subs_valores
    { return reduzco_actualizo({ operacion: "Actualizo", en_tabla, donde, valores }) }

Sentencia_Elimino = "Elimino"
  en_tabla:Subs_en_tabla
  donde:Subs_donde?
    { return reduzco_elimino({ operacion: "Elimino", en_tabla, donde }) }

EOS = "."

_ = __ / ___ / Comentario_multilinea
__ = " " / "\t"
___ = "\r\n" / "\r" / "\n"

Comentario_multilinea = "/*" (!("*/").)* "*/" { return text() }