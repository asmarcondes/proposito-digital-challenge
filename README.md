# Propósito Digital Challenge - Quake Parser
Código desenvolvido para o desafio técnico da Propósito Digital, utilizando linguagem Ruby.

## Instalação

1. Instale o [Ruby `3.1.2`](https://www.ruby-lang.org/en/documentation/installation/)
2. Faça um clone deste repositório: `git@github.com:asmarcondes/proposito-digital-challenge.git`
3. Acesse a pasta `proposito-digital-challenge`
4. Execute `bundle` para instalar as dependências

```bash
$ git clone git@github.com:asmarcondes/proposito-digital-challenge.git
$ cd proposito-digital-challenge
$ bundle
```

## Execução

A aplicação consiste em 2 partes, que precisam ser executadas em ordem: 
1. A primeira é responsável por fazer o parse do arquivo `games.log` (extraindo as informações pertinentes) e exibir os dados formatados no terminal. Nessa etapa as informações são armazenadas em um arquivo JSON, simulando o momento que seriam gravadas em um banco de dados, para posterior consumo pela API.
2. Na segunda parte, a API expõe um endpoint GET para retornar informações sobre um game específico, buscando as informações da lista salva no arquivo JSON criado.

Execute os seguintes comandos no terminal para executar cada parte:

```bash
$ ruby parser/main.rb
$ ruby api/index.rb
```
O parser só precisa ser executado uma vez, caso o arquivo de log não seja alterado.

Após execução dos comandos, poderá visualizar o relatório do log no terminal e também acessar a API pelo navegador, através do endereço [localhost](http://localhost:4567) na porta `4567`.

> O endpoint GET para retornar dados de um game específico possui o seguinte padrão: `/games/{id}`
> 
> Ex.: http://localhost:4567/games/5
>
> Terá como retorno os dados em JSON do game número 5:
> ```JSON
> {
>  "id": "game_5",
>  "total_kills": 14,
>  "players": [
>    "Dono da Bola",
>    "Isgalamido",
>    "Zeh",
>    "Assasinu Credi"
>  ],
>  "kills": {
>    "Dono da Bola": 0,
>    "Isgalamido": 2,
>    "Zeh": 1,
>    "Assasinu Credi": 1
>  }
> }
> ```
> 

## Utilizando Docker (opcional)

Uma alternativa para rodar aplicação é utilizando o Docker (no caso, estou utilizando o Docker Compose), dessa forma não há necessidade de possuir a mesma versão do Ruby na máquina (ou até mesmo qualquer versão).

> Caso não tenha o Docker instalado, siga as instruções da [documentação](https://docs.docker.com/get-docker/).

Com isso só precisará de um comando para inicializar. Abra o terminal no local onde fez o clone do projeto e rode o comando:
```bash
$ docker compose up --build`
```

Usando o script `docker-compose.yml` e `Dockerfile`, a imagem correspondente do Ruby será baixada e, em seguida, seram feitas as instalações das dependências e execução dos scripts do parser e da API, acessível pela mesma porta `4567` no navegador.

---

## Solução proposta

1. Feita a abertura do arquivo de log, o processamento é feito linha a linha, permitindo trabalhar com arquivos de diversos tamanhos sem carregar todo em memória.
2. Em cada linha, com uso de RegEx, separa em 3 informações: `:time`, `:event` e `:content`. O `:event` que nos fornecerá qual evento ocorreu e temos `InitGame` para encontrar o início de cada partida, `ClientUserinfoChanged` contendo informações sobre os jogadores e `Kill` com os registros de mortes no jogo. Definido o evento, `:content` é utilizado para extrair informações específicas.
3. Cada `InitGame` sinaliza que um novo jogo foi iniciado, assim é possível tratar todos os registros seguintes como parte desse novo jogo.
4. A presença do `ClientUserinfoChanged` indica que podemos extrair o nome de um jogador na partida, mas por ter a possibilidade de aparecer mais de uma vez, se faz necessário garantir que esse jogador não apareça duplicado.
5. Por último, dos eventos tratados, o registro por ser `Kill`. Nessa linha o RegEx extrai os jogadores envolvidos, o que matou e o que foi morto. Com isso conseguimos calcular o total de mortes da partida e também o total de mortes que cada jogador causou. Destacando que a presença da palavra-chave `<world>` indica que não foi morto por outro humano, sendo que isso influencia no total de mortes causadas pelo mesmo.
6. Para verificar qual o tipo de evento do registro analisado, optei pela abordagem semelhante ao `object literal pattern` / `module pattern` em JavaScript, descartando a necessidade de blocos `if/else` ou `switch`, melhorando a organização do código.
    ```javascript
    let MeuObjeto = (function() {
      let fazAlgo = () => { ... };
      let fazOutroAlgo = () => { ... };
        
      return {
        fazAlgo,
        fazOutroAlgo,
      };
    })();

    MeuObjeto.fazAlgo();

    /* Também funcionaria dessa forma */
    // let qualFuncao = 'fazAlgo';
    // MeuObjeto[qualFuncao]();
    ```
7. Para a API, a ideia inicial seria utilizar o Rails, criando o projeto com o scaffold, mas logo percebi que era uma estrutura muito robusta para uma proposta mais simples (a velha metáfora de matar uma barata com bazuca). Dessa forma, o Sinatra atendeu de forma eficaz para produzir o resultado desejado pelo desafio.