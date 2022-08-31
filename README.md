# Curso Defi - Lift Learning - Aula 07

Exercícios da Aula 07 usando o framework de smart contracts
[Foundry](https://github.com/gakonst/foundry)!

- [Curso Defi - Lift Learning - Aula 07](#curso-defi---lift-learning---aula-07)
- [Iniciando](#iniciando)
  - [Requisitos](#requisitos)
  - [Baixando repositório da aula](#baixando-repositório-da-aula)
- [Teste de smart contract](#teste-de-smart-contract)
- [Dando deploy nos contratos](#dando-deploy-nos-contratos)
  - [Setup](#setup)
  - [Deploy](#deploy)
    - [Carregando variáveis de ambiente](#carregando-variáveis-de-ambiente)
- [Contribuindo](#contribuindo)
  - [Recursos](#recursos)

# Iniciando

## Requisitos

Por favor instale o seguinte:

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - Você saberá que está pronto quando der `git --version` e aparecer por
    exemplo `git version 2.34.1`
- [Pacotes Redistribuíveis do Visual C++ para Visual Studio 2015](https://www.microsoft.com/pt-br/download/details.aspx?id=48145)
  - Verifique se você já tem instalado algum `Microsoft Visual C++ ...` no Powershell (<kbd>Win</kbd> + <kbd>R</kbd> powershell) usando:
  ```powershell
  Get-Package | Where-Object {$_.ProviderName -in @('Programs','msi','chocolatey') -and ($_.Name -like 'Microsoft Visual C++*')} | Select-Object $_.Name
  ```
  - Caso não apareça algo como:

  ```
  Microsoft Visual C++ 2015 x... 14.0.23026           msi
  Microsoft Visual C++ 2015 x... 14.0.23026           msi
  Microsoft Visual C++ 2015 R... 14.0.23026.0         Pro...
  ```
  - Então, baixe o `vc_redist.x64` no link acima.
- Instalação manual do Foundry
  - Clique [aqui](https://github.com/foundry-rs/foundry/releases), vá em Assets,
    tente encontrar algum que tenha `win32_amd64`, baixe `foundry_nightly_win32_amd64.zip` para Windows ou outro caso seja
    Linux/Mac
  - Crie uma pasta por exemplo em `C:\Users\Usuário\foundry\` e extraia os
    arquivos baixados para essa pasta
  - Adicione essa pasta no PATH das Variáveis de Ambiente (Windows)
    - Abra o executar (<kbd>Win</kbd> + <kbd>R</kbd>) rode o comando `sysdm.cpl`
    - Vá em Avançado -> Variáveis de Ambiente
    - Selecione Path (da área de cima, não embaixo), clique em Editar...
    - Clique em Novo, cole o caminho de onde estão os executáveis do Foundry,
      por exemplo `C:\Users\Usuário\foundry\`
    - Dê OK em todas as janelas
  - Abra o terminal e digite `forge --version` e verifique se deu algo parecido
    com `forge 0.2.0 (e385736 2022-08-13T00:11:42.087119284Z`

## Baixando repositório da aula

- Baixe o repositório:

```bash
git clone https://github.com/pietro-lopes/foundry-lift-aula07
cd foundry-lift-aula07
git submodule update --init --recursive
```

- Abra a pasta da aula no seu editor, por exemplo, VSCode.

# Teste de smart contract

Abra o terminal do VSCode e digite o seguinte comando para testar todos os
contratos:

```bash
forge test
```

# Dando deploy nos contratos

## Setup

Abra o arquivo `.env.example`. Você precisará atualizar as seguintes variáveis:

- `PRIVATE_KEY`: Uma chave privada da sua carteira.
- `POLYGONSCAN_API_KEY`: Se você for verificar o contrato no polygonscan.

Renomeie `.env.example` para `.env`

## Deploy

### Carregando variáveis de ambiente

Para dar deploy e precisamos carregas as variáveis que atualizamos no `.env`:
- Coloque como terminal padrão do seu VSCode o Git Bash
  - <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd>, digite `Terminal: Select Default Profile`, escolha `Git Bash`
- Abra um novo terminal no VSCode e verifique se abriu com o Git Bash
- Carregue as variáveis usando `source .env` no terminal

Para dar deploy e verificar na testnet da **Polygon Mumbai** por exemplo, use o
seguinte comando:

**Não esqueça de carregar as variáveis que estão em** `.env`

_Sempre que você fechar o terminal, você terá que recarregar as variáveis
novamente._

  ```bash
  forge create --verify --gas-price 60gwei --chain polygon-mumbai --rpc-url $MUMBAI_RPC --private-key $PRIVATE_KEY --etherscan-api-key $POLYGONSCAN_API_KEY src/T03TokenOwner.sol:T03TokenOwner
  ```

Edite onde for necessário, por exemplo o `--gas-price` e o contrato
`src/<contrato>.sol:<contrato>` e adicione
`--constructor-args <arg1> <arg2> <arg3>` caso seu contrato tenha construtor que
precise de argumentos para inicialização

# Contribuindo

Contribuições são sempre bem-vindas! Abra um PR or um issue!

## Recursos

- [Documentação do Foundry](https://book.getfoundry.sh/)
