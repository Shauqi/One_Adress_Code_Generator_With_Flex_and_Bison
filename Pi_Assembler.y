%{
#include<stdio.h>
#include<stdlib.h>
#include <malloc.h>
#include <math.h>
extern int yylex();
extern int yyparse();
extern FILE *yyin;
extern FILE *yyout;

int tcounter=0;
int fcounter=0;
int caseCounter=0;
int sym[26]={0};
int sw=-1;
int flag = 0;
int varCounter[26]={0};

%}


%token NUMBER ID END IF ELSE EQUAL GREATER LESS GREATEREQ LESSEQ IFX SWITCH CASE NOTEQ DEFAULT DEFMAIN VAR PRINT FOR
%%
program: DEFMAIN '{' statements '}' END   { printf("STP\n"); return 0;}
        ;

statements: statement  { $$ = $1;}
          | statements statement 
          ;

statement : ID '=' expression   { 
						            if(varCounter[$1-'a']<1)
						            {
						            	printf("%c is not declared\n",$1);
						            	return 0;
						            }
						            else
						            {
						              	$$ = $1;
						              	sym[$1-'a']=(int)01-$3;
						              	if ($3 <= 0) printf("LDA #%d\n",(int)01-$3);
						              	else 
						                	printf("LDA %c\n",$3);
						              	printf("STO %c\n",$1);
						            }
                              	}

            | IFX '(' statement ')' '{' statements '}' { 
                                                            $$ = -1;
                                                            if($6>1)
                                                            {
		                                                        if(01-$3!=0) 
		                                                        {
		                                                        	printf("JMP LabelTrue_%d\n",tcounter);
                                                                    printf("LabelTrue_%d: STO %c\n",tcounter++, $6);
                                                                }
		                                                        else printf("JMP LabelFalse_%d\n",fcounter++);
                                                            }
                                                            else
                                                            {
		                                                        if(01-$3!=0) 
		                                                        {
		                                                        	printf("JMP LabelTrue_%d\n",tcounter);
                                                                    printf("LabelTrue_%d: %d\n",tcounter++, 1-$6);
                                                                }
		                                                        else printf("JMP LabelFalse_%d\n",fcounter++);

                                                            }
                                                       }

            | IF '(' statement ')' '{' statements '}' ELSE '{' statements '}'	{
                               														$$=-1;
                                                                                    if(01-$3!=0)
	                                                                                { 
	                                                                                	printf("JMP LabelTrue_%d\n",tcounter);
	                                                                                	if($6>1)
	                                                                                	{
	                                                                                		printf("LabelTrue_%d: STO %c\n",tcounter++, $6);
	                                                                                	}
	                                                                                	else
	                                                                                	{
	                                                                                		printf("LabelTrue_%d: %d\n",tcounter++,1-$6);
	                                                                                	}
	                                                                                }
	                                                                                else
	                                                                                {
	                                                                                	printf("JMP LabelFalse_%d\n",fcounter);
	                                                                                	if($10>1)
	                                                                                	{
	                                                                                		printf("LabelFalse_%d: STO %c\n",fcounter++, $10);
	                                                                                	}
	                                                                                	else
	                                                                                	{
	                                                                                		printf("LabelFalse_%d: %d\n",fcounter++, 1-$10);
	                                                                                	}
	                                                                                }
                                                                            	}
            | expression {
                             if($1<=1)
                             {
                                $$ = $1;
                                printf("LDA #%d\n",(int)01-$1);
                             }
                             else
                             {
                                $$ = (int)01-sym[$1-'a'];
                                printf("%d\n",sym[$1-'a']);
                             } 
                         } 

            | SWITCH '(' statement ')' '{'  { 
												sw = 1-$3;
                                        	}


            | CASE operand ':' '{' statements '}' statement {
            													if($2<=0)
            													{
            														if(sw == ((int)01-$2))
            														{
            															printf("JMP CaseTrue_%d\n",caseCounter);
            															if($5>1)
            															{
            																printf("CaseTrue_%d: STO %c\n",caseCounter++,$5);
            															}
            															else
            															{
            																printf("CaseTrue_%d: %d\n",caseCounter++,1-$5);
            															}
            															flag = 1;
            														}
            													}
            													else
            													{
            													    if(sw == sym[$2-'a'])
            													    {
            													    	printf("JMP CaseTrue_%d\n",caseCounter);
            															if($5>1)
            															{
            																printf("CaseTrue_%d: STO %c\n",caseCounter++,$5);
            															}
            															else
            															{
            																printf("CaseTrue_%d: %d\n",caseCounter++,1-$5);
            															}
            															flag = 1;
            													    }
            													}
            												}
            | DEFAULT ':' '{' statements '}' '}'	{
            										}

            | VAR expression   {
            						if($2<=0)
            						{
            						   printf("You cannot write %d as a variable\n",(int)01-$2);
            						   return 0;
            						}
            						else
            						{
            						    if(varCounter[$2-'a']>0)
            						    {
            						       printf("%c is already declared\n",$2);
            						       return 0;
            						    }
            						    else
            						    {
            						       varCounter[$2-'a']++;
            						    }
            						}
            				   }
            | ',' expression	{
            						if($2<=0)
            						{
            						   printf("You cannot write %d as a variable\n",(int)01-$2);
            						}
            						else
            						{
            						    if(varCounter[$2-'a']>0)
            						    {
            						       printf("%c is already declared\n",$2);
            						       return 0;
            						    }
            						    else
            						    {
            						       varCounter[$2-'a']++;
            						    }
            						}
            					}

            | FOR '(' expression ')' '{' statement '}' {
            												if($3>1)
            												{
            													for(int i=0;i<sym[$3-'a'];i++)
            													{
            														if($6>1)
            														{
            															printf("%d\n",sym[$6-'a']);
            														}
            														else
            														{
            															printf("%d\n",1-$6);
            														}
            													}
            												}
            												else
            												{
            													for(int i=0;i<1-$3;i++)
            													{
            														if($6>1)
            														{
            															printf("%d\n",sym[$6-'a']);
            														}
            														else
            														{
            															printf("%d\n",1-$6);
            														}
            													}
            												}
            										   }

            | PRINT '(' statements ')'	{
											$$ = $3;
            							}
            ;




expression : operand { $$ = $1 ; }
           | expression '+' operand    {
							                if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) + (01-$3)) ;
							                else 
							                {
							                    if ($3 <= 0) 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else
						                       		{
						                     			$$ =  01-(sym[$1-'a']+((int)01-$3));
								                        printf("LDA %c\n",$1);
								                        printf("ADD #%d\n",(int)01-$3);
						                       		}
						                        }
							                    else 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else if(varCounter[$3-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$3);
						                       			return 0;
						                       		}
						                       		else
						                       		{
                   				                        $$ = 01- (sym[$1-'a']+sym[$3 - 'a']);
						                            	printf("LDA %c\n",$1);
						                            	printf("ADD %c\n",$3);
						                       		}

						                        }
							                }
                                       }

            | expression '*' operand   {
                                            if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) * (01-$3));
							                else 
							                {
							                    if ($3 <= 0) 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else
						                       		{
						                     			$$ =  01-(sym[$1-'a']*((int)01-$3));
								                        printf("LDA %c\n",$1);
								                        printf("MUL #%d\n",(int)01-$3);
						                       		}
						                        }
							                    else 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else if(varCounter[$3-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$3);
						                       			return 0;
						                       		}
						                       		else
						                       		{
                   				                        $$ = 01- (sym[$1-'a']*sym[$3 - 'a']);
						                            	printf("LDA %c\n",$1);
						                            	printf("MUL %c\n",$3);
						                       		}

						                        }
							                }
                                        }

            | expression '-' operand    {
								            if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) - (01-$3));
							                else 
							                {
							                    if ($3 <= 0) 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else
						                       		{
						                     			$$ =  01-(sym[$1-'a']-((int)01-$3));
								                        printf("LDA %c\n",$1);
								                        printf("SUB #%d\n",(int)01-$3);
						                       		}
						                        }
							                    else 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else if(varCounter[$3-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$3);
						                       			return 0;
						                       		}
						                       		else
						                       		{
                   				                        $$ = 01- (sym[$1-'a']-sym[$3 - 'a']);
						                            	printf("LDA %c\n",$1);
						                            	printf("SUB %c\n",$3);
						                       		}

						                        }
							                }
                                        }

            | expression '/' operand    {
							                if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) / (01-$3));
							                else 
							                {
							                    if ($3 <= 0) 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else
						                       		{
						                     			$$ =  01-(sym[$1-'a']/((int)01-$3));
								                        printf("LDA %c\n",$1);
								                        printf("DIV #%d\n",(int)01-$3);
						                       		}
						                        }
							                    else 
						                        {
						                       		if(varCounter[$1-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$1);
						                       			return 0;
						                       		}
						                       		else if(varCounter[$3-'a']<1)
						                       		{
						                       			printf("%c is not declared\n",$3);
						                       			return 0;
						                       		}
						                       		else
						                       		{
                   				                        $$ = 01- (sym[$1-'a']/sym[$3 - 'a']);
						                            	printf("LDA %c\n",$1);
						                            	printf("DIV %c\n",$3);
						                       		}

						                        }
							                }
                                        }

            | expression EQUAL operand  {
		                                    if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) == (01-$3));
									        else 
									        { 
												if ($3 <= 0) 
						                        {
						                          	$$ =  01-(sym[$1-'a']==((int)01-$3));
						                        }
							                    else 
							                    {
							                        $$ = 01- (sym[$1-'a']==sym[$3 - 'a']);
							                    }
									        }
            							}

            | expression GREATER operand  {
		                                    if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) > (01-$3));
									        else 
									        { 
												if ($3 <= 0) 
						                        {
						                          	$$ =  01-(sym[$1-'a'] > ((int)01-$3));
						                        }
							                    else 
							                    {
							                        $$ = 01- (sym[$1-'a'] > sym[$3 - 'a']);
							                    }
									        }
            							}

            | expression LESS operand  {
		                                    if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) < (01-$3));
									        else 
									        { 
												if ($3 <= 0) 
						                        {
						                          	$$ =  01-(sym[$1-'a'] < ((int)01-$3));
						                        }
							                    else 
							                    {
							                        $$ = 01- (sym[$1-'a'] < sym[$3 - 'a']);
							                    }
									        }
            							}

            | expression GREATEREQ operand  {
		                                    if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) >= (01-$3));
									        else 
									        { 
												if ($3 <= 0) 
						                        {
						                          	$$ =  01-(sym[$1-'a'] >= ((int)01-$3));
						                        }
							                    else 
							                    {
							                        $$ = 01- (sym[$1-'a'] >= sym[$3 - 'a']);
							                    }
									        }
            							}

           | expression LESSEQ operand  {
		                                    if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) < (01-$3));
									        else 
									        { 
												if ($3 <= 0) 
						                        {
						                          	$$ =  01-(sym[$1-'a'] < ((int)01-$3));
						                        }
							                    else 
							                    {
							                        $$ = 01- (sym[$1-'a'] < sym[$3 - 'a']);
							                    }
									        }
            							}

            | expression NOTEQ operand  {
		                                    if ( ($1 <= 0) && ($3 <= 0)) $$ = 01-((01-$1) != (01-$3));
									        else 
									        { 
												if ($3 <= 0) 
						                        {
						                          	$$ =  01-(sym[$1-'a'] != ((int)01-$3));
						                        }
							                    else 
							                    {
							                        $$ = 01- (sym[$1-'a'] != sym[$3 - 'a']);
							                    }
									        }
            							}
           ;

operand : NUMBER
        | ID
        ;


%%

int main(void) {
	yyin = freopen("in.txt","r",stdin);
	yyout = freopen("out.txt","w",stdout);
	yyparse();
}

int yywrap()
{
return 1;
}


int yyerror(char *s){
	printf( "%s\n", s);
}
