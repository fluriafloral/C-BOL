# C-BOL
Projeto da disciplina de Engenharia de Linguagens - 2024.1

## Alunos
Hannah Santos, Isaac Lourenço, Mateus Loiola, Pedro Silva

## Instruções para rodar

lex lexer.l

yacc parser.y -d -v -g

gcc lex.yy.c y.tab.c

./a.out (ler da entrada padrão) ou ./a.out < examples/fileName.cbol (ler arquivo de testes)

## Syntax Highlight (VSCode)

Para ativar o syntax highlight no VSCode, basta executar: `cp -r c-bol-syntax-highlight/ ~/.vscode/extensions/`