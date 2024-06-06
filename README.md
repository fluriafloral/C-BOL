# C-BOL
Projeto da disciplina de Engenharia de Linguagens - 2024.1

## Alunos
Hannah Santos, Isaac Lourenço, Mateus Loiola, Pedro Silva

## Instruções para rodar

lex lexer.l

yacc parser.y -d -v -g

gcc lex.yy.c y.tab.c

./a.out (ler da entrada padrão) ou ./a.out < examples/fileName.cbol (ler arquivo de testes)

## Exemplos

Foram elaborados exemplos para cada tipo de construção sintática da linguagem e alguns algoritmos como quicksort e mergesort. Como não foi desenvolvido ainda a semântica da linguagem, as saídas esperadas para cada compilação de um código sintáticamente correta é vazia.

## Syntax Highlight (VSCode)

Para ativar o syntax highlight no VSCode, basta executar: `cp -r c-bol-syntax-highlight/ ~/.vscode/extensions/`
