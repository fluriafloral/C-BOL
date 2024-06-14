all: compiler

compiler: lex.yy.c y.tab.c 
	gcc lex.yy.c y.tab.c ./lib/hashtable.c ./lib/record.c ./lib/strsplit.c -o compiler

lex.yy.c: lexer.l
	lex lexer.l

y.tab.c: parser.y  
	yacc parser.y -d -v

clean:
	rm -rf lex.yy.c y.tab.* y.dot compiler in.cbol out.txt