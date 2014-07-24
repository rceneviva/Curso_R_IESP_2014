###########################
## LAB 1 -  Intro to R 
## Ricardo Ceneviva
## via http://CRAN.R-project.org/ 
## packages: AER, car
## IESP, Rio de Janeiro, Brazil, July 2014
## Lego III: Modelos para variaveis dependentes limitadas
###########################


#####
#####
#####  1. BASICS OF R
#####
#####

  
#Clear all objects from memory
remove(list=ls(all=TRUE))


#Exibe o seu diretorio de trabalho corrente
getwd()

#Fixa um diretório de trabalho
setwd("~/Dropbox/iesp_uerj/escola_inverno/Intro_R_2014/")


##############
# Aula 1 - R #
##############

### Um primeiro uso para o R: Calculadora:
2 + 2
# [1] 4

# Ou seja, o indice do valor aparece entre chaves e o resultado logo após
# o índice...

# Alguns numeros estranhos que o R tem é o pi:
pi

# E daí,
sin(pi) # Ou seja, seno de pi: igual a zero...

# Logaritmo:
log(100, base=10)

# E quando a base não é especificada, ele aplica logaritimo natural...
log(100)

# A base é igual a:
exp(1)

# O numero de Euler... Em um curso de cálculo vocês vão ver isso...
# Seno de pi deu algo estranho certo? Esse numero é difícil de ler...
# Para isso usamos o comando round:
round(sin(pi), digits=4) # Quatro dígitos de precisão... zero!

# São várias as funções matemáticas e elas podem ser aplicadas também a
# vetores... Veremos vetores mais à frente. Não vamos nos aprofundar neste
# ponto porque isso não faz parte do que devemos abordar principalmente...

# A logica do R é, nome_da_função(parâmetro1, parâmetro2, ...)
# Para salvarmos o resultado de um cálculo em uma variável basta então:
X = 10*3.2

# Note que o R, em geral, não faz festinha quando ele processa um comando...
# Para ler a variável X, basta perguntar por ela...
X

# Monte uma Y com um valor qualquer...
Y = 13*log(2)

# Vendo a Y...
Y

# Multiplicando uma pela outra...
X*Y

# Ou seja, se pedimos para ele mandar para algum lugar (comando '=' ou '<-')
# ele salva e ponto. Se não, ele exibe o resultado...


### Lendo o Script:
# Os scripts servem para salvarmos os passos que fazemos em nossa pesquisa.
# Nele nós colocamos os comandos que fazemos em nossa pesquisa.
# Eventualmente, isso nos auxilia na nossa comunicação com outros técnicos...

# A primeira coisa que você deve aprender sobre um script está contida na
# seguinte frase, que motiva os cientistas da computação:

# "Programs must be written for people to read, and incidentally for 
# machines to execute." -  H. Abelson, G. Sussman, 
# The Structure and Interpretation of Computer Programs

# ... ou seja, comente seu script porque nem sempre a pessoa que lê sabe
# os processos que o R executa nele.
# O caractere '#' serve para fazer estes comentários. Depois que ele aparece,
# o R pára de interpretar o que está escrito até a próxima linha.

# Nunca se esqueça na hora de usar o R que ele é 'case sensitive', ou seja,
# ele diferencia letras maiusculas de minusculas...

# Outra coisa importante: 1.2 é diferente de 1,2... 1.2 é um numero e 
# 1,2 é uma sequencia com os numeros 1 e 2. Isso também é muito importante.

# Os valores de missing no R aparecem como NA (Not Avialable) e os calculos
# errados do tipo dividir algo por zero aparecem como NaN (Not a Number)...
# Vamos testar (raiz quadrada de -2... não existe!):
sqrt(-2)

# Ou seja, conforme previsto...


### Usando o help
# O help é o comando mais importante do R. Nele podemos encontrar descrições de fun-
# ções que esquecemos para que servem, funções que nunca ouvimos falar, ou
# mesmo aquelas funções que sabemos usar mas estamos em dúvida sobre como
# alimenta-las, quais os tipos de dados a inserir e etc.
# Um exemplo: comando 'hist', que serve para fazermos histogramas:
help(hist)

# Este tipo de pesquisa serve somente quando sabemos perfeitamente o nome
# do comando. Quando não sabemos, não podemos usar este comando.
# Um exemplo disso é o comando 'Hist', que não existe:
help(Hist)

# Ou seja, ele nos sugere usarmos a busca fuzzy. Para este tipo de busca
# devemos proceder da seguinte maneira: help.search("palavra"). Um exemplo:
help.search("linear")

# e ele nos retorna vários comandos relacionados a coisas lineares...
# Aparece na descrição entre parenteses, depois do nome do comando, o nome
# do pacote que ele está vinculado.
# Escolha como exercício algum comando, carregue o pacote que ele está 
# e peça um help normal.

# Outro modo bem de pedir um help do tipo fuzzy:
apropos("linear")

# Que é mais economico que o help normal... Pode usar também um pedaço do
# da função que deseja:
apropos("lin")

# Mas é lógico que quanto mais próximo do comando, mais breve serão os re-
# sultados.

# As vezes você quer só saber os argumentos para alimentar uma função. Use
# o comando args:
args(lm) # Comando para fazer regressão linear...

# Mas este comando nem sempre funciona...
args(hist) # Comando para fazer histogramas

# Quando não funcionar use o help normal.

# Alguns comandos também tem exemplos:
example(image)


### Pacotes:
# Vá no menu do R e instale um pacote. Se você estiver na internet instale di-
# retamente. Se você não estiver, carregue dos que foram passados...
# Para ver seus pacotes e uma breve descrição do que eles fazem:
library()

#instala os pacotes
install.packages("MASS", dependencies=TRUE)


# Para carregar um pacote dê:
require(MASS) # carrega o pacote MASS por exemplo...

# E por aí vai...


### Bancos de Dados do R
# O R vem com vários bancos de dados em seu default e mais os que você ins-
# tala quando carrega pacotes da internet. Isso é muito bom! Vamos olhar
# nossos bancos!
data()

# Ok, eu támbem não acho legal que a maioria é ligado à pesquisa médica, 
# mas isso a gente pode relevar por ora... Vamos carregar o banco USArrests
data(USArrests)

# Agora vamos conferi-lo...
USArrests

# Mas logicamente não sabemos do que se tratam estes dados. Vamos então
# pedir um help...
help(USArrests)

# E para vermos algumas relações:
pairs(USArrests, gap=0, col=2)           # gap=0 cola um gráfico no outro
					 # col=2 usa cor vermelha para as bolotas...

## TAREFA 1 ##

# Agora é com você, carregue um banco desses do R, peça um help para
# saber do que se trata e plote-o com o comando pairs.



#############
##VARIAVEIS##
#############


# A maneira mais simples de se criar uma variavel no
# R é por meio do designador <- (que pode ser substituido
# pelo sinal de = ). Uma variavel pode conter qualquer tipo
# de dado, como sera visto adiante


# A variável x recebe o valor (numérico) 2
# A variável y recebe o valor (numérico) 10

x <- 2
y <- 10

# A variável 3 recebe o valor (numérico) z


3 <- z

################
# NAO FUNCIONA #
################




### Vetores, Matrizes, Arrays e Data-frames.
# Os objetos do R são basicamente 4 (na verdade são bem mais, mas os
# outros não são muito usados por nós): vetores, matrizes, data frames e 
# listas. A diferença entre estes objetos é basicamente o modo como os 
# dados ficam organizados em seu interior.
# Vamos falar de vetores e data frames. Os outros você precisaria mais
# em programação matemática, que não vamos abordar...

# O objeto mais básico de todos é o vetor. Pense por exemplo na idade
# dos seus colegas de turma. Podemos organizar esta informação em um vetor.
# Um exemplo hipotético é:
idades <- c(18, 21, 25, 19, 34, 45, 60, 28, 31)

# Lembre-se que quando o R não dá nenhum sinal, significa que foi tudo ok!
# Para ler o vetor:
idades

# Ok, já temos um vetor com idades. Vejamos agora um vetor com opiniões
# destes mesmos indivíduos sobre a questão do aborto:
aborto <- c (1, 0, 0, 1, 1, 0, 1, 0, 0)

# Bom, se você não entendeu, 1 significa a favor e 0 contra a legalização do
# aborto. Vejamos nosso vetor:
aborto

# Outro modo de descrever esta variável é:
aborto_fac <- c ("Favor", "Contra", "Contra", 
	"Favor", "Favor", "Contra", "Favor", "Contra", "Contra")
aborto_fac

# Note que se você der o comando pela metade aparece um sinal de mais '+'
# pedindo que você termine o comando...

# Já temos então um pequeno banco de dados com 9 casos e duas variáveis:
# idade e aborto. Vamos então escrever nosso banco:
banco1 <- data.frame(idades, aborto, aborto_fac)

# Vejamos nosso banco...
banco1

# Não está bom... Vamos incluir o sexo: 0=Homem e 1= Mulher...
sexo <- c(1, 1, 1, 0, 0, 0, 1, 0, 1)

# Vejamos o sexo...
sexo

# Colocando no banquinho
banco1 <- data.frame(banco1, sexo)
banco1

# Agora só para brincar mais, um pouco da renda dos nossos amigos...
renda <- c(5, 4, 4, 1, 7, 10, 3, 5, 2)

# Em Salários mínimos antes que alguem se manifeste...
# Colocando também no banco1...
banco1 <- data.frame(banco1, renda)
banco1



renda2 <- c(5, ,4, 4, 1, 7, 10, 3, 5)

# Em Salários mínimos antes que alguem se manifeste...
# Colocando também no banco1...
banco1 <- data.frame(banco1, renda2)
banco1

