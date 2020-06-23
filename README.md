# Now I See

![Now I See](now_i_see.jpg)

Scanner de hosts escrito em Julia.

## Objetivo

Esta ferramenta tem o objetivo de auxiliar a estudar um host e descobrir informações sobre ele, é uma ferramenta de análise somente, não realizando qualquer tipo de dano ao host.

## Funcionaliades

- Scanner de portas TCP;
- Scanner de SMTP via VRFY;
- Scanner de diretórios e arquivos comuns no servidor HTTP;
- Scanner de links a partir da página inicial do servidor HTTP;

## Como rodar

Para rodar você precisará do interpretador da linguagem Julia instalado. Você pode baixá-lo [aqui](https://julialang.org/downloads/).

Também é necessário baixar as dependências do programa.

Para isso basta ir ao diretório do programa e rodar o `julia`.

Dentro do console digite `]` para entrar no modo de pkg e entre `activate .` e depois `instantiate`.

Saia do console do `julia`

Feito isso você pode rodar o comando básico:

```bash
./nis.jl -t HOST
```

Com este comando a ferramenta vai executar todas as funcionalidades que conseguir no host informado.

O range padrão de portas a serem testadas é de 1 a 1000.

## Opções

Você pode configurar o programa através de argumentos da linha de comando.

Estão disponíveis as seguintes opções:

- `-t` ou `--target`: Host alvo, pode ser um IP ou domínio. Origatório.
- `-s` ou `--start`: Porta inicial do range de portas a serem escaneadas. Padrão 1.
- `-e` ou `--end`: Porta final do range de portas a serem escaneadas. Padrão 1000.
- `-o` ou `--open`: Exibir somente portas abertas. Padrão `false`.
- `--smtp`: Executar o scan de SMTP via VRFY. Padrão `false`.
- `--files`: Executar o scan de arquivos e diretórios no host. Padrão `false`.
- `--links`: Executar o scan de links no host. Padrão `false`.
- `--depth`: A profundidade máxima do scan de links no host. Padrão 2.

Você também pode usar o `--help` sempre que quiser consultar o guia de uso.

## LICENSE

[MIT](LICENSE)

## Autores

- TheCrypters
