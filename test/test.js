const sql_en_castellano = require(__dirname + "/../src/sql-en-castellano.parser.js");

const fs = require("fs");
const basedir = __dirname + "/tests";
const files = fs.readdirSync(basedir);
for(let index_file=0; index_file<files.length; index_file++) {
  const file = files[index_file];
  const contents = fs.readFileSync(basedir + "/" + file).toString();
  const ast = sql_en_castellano.parse(contents);
  console.log(JSON.stringify(ast, null, 4));
  for(let index_statements=0; index_statements<ast.length; index_statements++) {
    const statement = ast[index_statements];
    console.log(statement);
  }
}
