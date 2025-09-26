# BBRLPlus - Brazilian Real Plus Token

**BBRLPlus é um token ERC20 com recursos avançados de controle de acesso e segurança, desenvolvido para representar o Real brasileiro na blockchain.**

## � Índice

- [📋 Visão Geral](#-visão-geral)
- [🏗 Stack de Desenvolvimento](#-stack-de-desenvolvimento)
- [📁 Estrutura do Projeto](#-estrutura-do-projeto)
- [🚀 Configuração Inicial](#-configuração-inicial)
- [🔧 Comandos de Desenvolvimento](#-comandos-de-desenvolvimento)
- [🧪 Testes Completos](#-testes-completos)
- [📜 Contratos](#-contratos)
- [📝 Scripts de Interação](#-scripts-de-interação)
- [🛠 Ferramentas do Foundry](#-ferramentas-do-foundry)
- [🔍 Debugging e Análise](#-debugging-e-análise-com-cast)
- [🚨 Configurações de Segurança](#-configurações-de-segurança)
- [📚 Recursos Adicionais](#-recursos-adicionais)

## �📋 Visão Geral

O projeto BBRLPlus implementa um token ERC20 com as seguintes características:

- ✅ **Controle de Acesso**: Sistema de roles (Admin, Minter, Burner, Pauser, Recovery)
- ✅ **AllowList**: Apenas endereços autorizados podem receber e transferir tokens
- ✅ **Pausável**: Capacidade de pausar o contrato em emergências
- ✅ **Mintagem Controlada**: Emissão de tokens apenas por endereços autorizados
- ✅ **Queima Controlada**: Destruição de tokens com rastreabilidade
- ✅ **Recuperação de Tokens**: Recuperação de tokens de endereços não autorizados
- ✅ **ERC20 Permit**: Suporte a aprovações via assinatura (gasless)

## 🏗 Stack de Desenvolvimento

### Ferramentas Principais
- **[Foundry](https://book.getfoundry.sh/)**: Toolkit completo para desenvolvimento Ethereum
  - **Forge**: Framework de testes
  - **Cast**: Ferramenta CLI para interação com contratos
  - **Anvil**: Node local Ethereum
  - **Chisel**: REPL para Solidity
- **[Soldeer](https://soldeer.xyz/)**: Gerenciador de dependências Solidity
- **[OpenZeppelin](https://openzeppelin.com/)**: Biblioteca de contratos seguros

### Dependências
- Solidity `^0.8.27`
- OpenZeppelin Contracts `^5.4.0`
- Forge Std (biblioteca de testes)

## 📁 Estrutura do Projeto

```
authbank-project/
├── src/                          # Contratos principais
│   ├── BBRLPlus.sol             # Contrato principal do token
│   └── Utils/
│       └── Errors.sol           # Biblioteca de erros customizados
├── script/                      # Scripts de deploy e interação
│   ├── DeployBBRLPlus.s.sol    # Deploy do contrato
│   ├── InteractBBRLPlus.s.sol  # Interações básicas
│   ├── AdminBBRLPlus.s.sol     # Operações administrativas
│   ├── QueryBBRLPlus.s.sol     # Consultas e relatórios
│   └── ExampleUsageBBRLPlus.s.sol # Exemplos de uso
├── test/                        # Testes unitários
├── lib/                         # Dependências (forge-std, openzeppelin)
├── broadcast/                   # Logs de deploy
└── cache/                       # Cache de compilação
```

## 🚀 Configuração Inicial

### 1. Instalação do Foundry
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2. Clonando e Configurando o Projeto
```bash
git clone <repository-url>
cd authbank-project
forge install
```

### 3. Configuração do Ambiente
Copie o arquivo de exemplo e configure suas variáveis:
```bash
cp .env.example .env
```

Edite o arquivo `.env`:
```bash
# RPC URLs
MAINNET_RPC_URL="https://your-mainnet-rpc"
TESTNET_RPC_URL="https://your-testnet-rpc"
LOCAL_RPC_URL="http://127.0.0.1:8545"

# Private Keys (NUNCA COMMITAR CHAVES REAIS)
PRIVATE_KEY="0x..."
DEPLOYER_PRIVATE_KEY="0x..."

# Addresses
ADMIN_ADDRESS="0x..."
MINTER_ADDRESS="0x..."
```

## 🔧 Comandos de Desenvolvimento

### Build
```bash
# Compilar contratos
forge build

# Verificar tamanho dos contratos
forge build --sizes
```

### Formatação e Análise
```bash
# Formatar código
forge fmt

# Análise estática
forge snapshot
```

## 🧪 Testes Completos

O projeto possui uma suíte completa de **60 testes** que cobrem 100% das funcionalidades do contrato BBRLPlus.

### 📊 Estrutura dos Testes

#### 1. Testes Unitários (`BBRLPlus.t.sol`) - 36 testes
- ✅ **Deployment e Configuração**: Verificação de inicialização e roles
- ✅ **Mint Operations**: Todas as variações com validações de segurança
- ✅ **Burn Operations**: Queima autorizada e cenários de erro
- ✅ **Transfer Operations**: Transfer padrão, com referência e transferFrom
- ✅ **Allowlist Management**: Adição, remoção e verificações
- ✅ **Pause/Unpause**: Controles de emergência e validações
- ✅ **Recovery Operations**: Recuperação de tokens de endereços não autorizados
- ✅ **Role Management**: Concessão, revogação e verificação de roles
- ✅ **ERC20 Permit**: Funcionalidade EIP-2612 completa
- ✅ **Fuzz Tests**: Testes com valores e parâmetros aleatórios
- ✅ **Invariant Tests**: Verificação de invariantes do contrato

#### 2. Testes de Integração (`BBRLPlusIntegration.t.sol`) - 13 testes
- ✅ **Workflows Completos**: Onboarding, emergência e recovery
- ✅ **Cenários Realísticos**: Detecção de usuários maliciosos
- ✅ **Stress Tests**: Operações em larga escala (1000+ usuários)
- ✅ **Edge Cases**: Valores zero, máximos e situações extremas
- ✅ **Security Tests**: Reentrância e controle de acesso
- ✅ **Compatibility**: ERC20 padrão e Permit (EIP-2612)

#### 3. Testes de Performance (`BBRLPlusPerformance.t.sol`) - 11 testes
- ✅ **Gas Benchmarks**: Medição precisa de uso de gas por operação
- ✅ **Scalability Tests**: Teste com allowlists grandes e alto volume
- ✅ **Memory Efficiency**: Uso otimizado de storage
- ✅ **Comparative Benchmarks**: Comparação entre tipos de operação

### 🚀 Executando os Testes

#### Comandos Básicos
```bash
# Executar todos os testes
forge test

# Executar com verbosidade básica
forge test -v

# Executar com verbosidade máxima (inclui logs e traces)
forge test -vvvv

# Executar com resumo
forge test --summary
```

#### Executar Testes Específicos
```bash
# Por arquivo de teste
forge test --match-contract BBRLPlusTest              # Testes unitários
forge test --match-contract BBRLPlusIntegrationTest   # Testes de integração  
forge test --match-contract BBRLPlusPerformanceTest   # Testes de performance

# Por nome de função
forge test --match-test test_MintRef                  # Testes de mint
forge test --match-test test_Transfer                 # Testes de transfer
forge test --match-test test_Allowlist               # Testes de allowlist
forge test --match-test test_RevertWhen               # Testes de erro

# Por padrão
forge test --match-path "*Integration*"               # Todos os testes de integração
forge test --match-path "*Performance*"              # Todos os testes de performance
```

#### Filtros Avançados
```bash
# Executar apenas testes que passam
forge test --no-match-test "test_RevertWhen"

# Executar testes específicos com verbosidade
forge test --match-test "test_CompleteUserOnboardingWorkflow" -vvv

# Executar todos exceto performance (para CI rápido)
forge test --no-match-contract "BBRLPlusPerformanceTest"
```

### 📊 Relatórios e Análises

#### Relatório de Gas
```bash
# Relatório básico de gas
forge test --gas-report

# Relatório detalhado com todos os testes
forge test --gas-report -vv

# Salvar relatório em arquivo
forge test --gas-report > gas-report.txt

# Relatório apenas para contratos específicos
forge test --match-contract BBRLPlusTest --gas-report
```

#### Cobertura de Testes
```bash
# Gerar relatório de cobertura
forge coverage

# Cobertura em formato LCOV
forge coverage --report lcov

# Cobertura detalhada por linha
forge coverage --report debug

# Cobertura para arquivos específicos
forge coverage --match-path "src/BBRLPlus.sol"
```

#### Análise de Performance
```bash
# Snapshot de gas (baseline para comparações)
forge snapshot

# Comparar com snapshot anterior
forge snapshot --diff .gas-snapshot

# Snapshot apenas para testes específicos
forge snapshot --match-test "test_Transfer"

# Snapshot com nomes personalizados
forge snapshot --snap .gas-snapshot-v2
```

### 🔍 Debugging e Análise

#### Trace de Execução
```bash
# Trace completo de teste específico
forge test --match-test "test_MintRef_Success" --debug

# Trace com informações de storage
forge test --match-test "test_Transfer_Success" -vvvv

# Executar teste isolado para debugging
forge test --match-test "test_RevertWhen_Transfer_UnauthorizedReceiver" --isolate
```

#### Informações Detalhadas
```bash
# Ver logs de console.log nos testes
forge test --match-contract BBRLPlusIntegrationTest -vv

# Executar com informações de setup
forge test --match-test "setUp" -vvv

# Ver eventos emitidos
forge test --match-test "test_MintRef_Success" --decode-internal
```

### 📈 Métricas de Performance

#### Gas Usage Médio por Operação
```
├── Mint: ~67,000 gas
├── Transfer: ~96,000 gas  
├── TransferWithRef: ~101,000 gas
├── Add to Allowlist: ~63,000 gas
├── Burn: ~77,000 gas
├── Recovery: ~121,000 gas
└── Role Operations: ~41,000 gas
```

#### Benchmarks de Escalabilidade
```
├── Allowlist Lookup: O(1) até 1,000+ usuários
├── Batch Transfers: Linear scaling até 200+ operações
├── Memory Usage: Eficiente até 500+ usuários
└── Role Checks: Constante ~2,700 gas
```

### 🎯 Comandos Úteis para Desenvolvimento

#### Durante Desenvolvimento
```bash
# Watch mode (re-executa testes quando arquivos mudam)
forge test --watch

# Executar testes rapidamente (sem gas report)
forge test --no-match-contract "Performance" --summary

# Teste específico com máximo debug
forge test --match-test "test_NewFeature" -vvvv --debug
```

#### Para CI/CD
```bash
# Testes para CI (rápido, sem performance tests)
forge test --no-match-contract "BBRLPlusPerformanceTest"

# Verificar se todos os testes passam (exit code)
forge test || exit 1

# Gerar relatórios para CI
forge test --gas-report --json > test-results.json
forge coverage --report lcov --report-file coverage.lcov
```

#### Verificação de Qualidade
```bash
# Verificar que não há testes que falham silenciosamente
forge test --fail-fast

# Executar com seed específico para reproduzibilidade
forge test --fuzz-seed 42

# Verificar fuzz tests com mais runs
forge test --fuzz-runs 1000 --match-test "testFuzz"
```

### 📋 Checklist de Testes

Antes de fazer deploy ou PR, execute:

```bash
# 1. Todos os testes passam
forge test

# 2. Cobertura adequada
forge coverage

# 3. Gas usage dentro dos limites
forge test --gas-report

# 4. Performance tests passam
forge test --match-contract BBRLPlusPerformanceTest

# 5. Código formatado
forge fmt --check

# 6. Build limpo
forge build
```

### 🐛 Troubleshooting

#### Problemas Comuns
```bash
# Se testes falham por gas limit
export FOUNDRY_GAS_LIMIT=30000000

# Se testes são muito lentos
forge test --no-match-contract "Performance"

# Limpar cache se testes comportam-se estranhamente
forge clean && forge build

# Debug de teste específico que está falhando
forge test --match-test "problem_test" -vvvv --debug
```

#### Debug Avançado
```bash
# Usar cast para verificar estado após teste
cast call $CONTRACT "balanceOf(address)" $USER --rpc-url $RPC

# Debug interativo com Chisel REPL
chisel
# > !help                  # Comandos disponíveis
# > !load src/BBRLPlus.sol # Carregar contrato
# > uint256 a = 100; a * 2 # Testar código Solidity
# > !quit                  # Sair
```

## 📜 Contratos

### BBRLPlus.sol
Contrato principal que implementa:

**Herança:**
- `ERC20`: Funcionalidade padrão de token
- `ERC20Burnable`: Capacidade de queima
- `ERC20Pausable`: Capacidade de pausar
- `AccessControl`: Sistema de roles
- `ERC20Permit`: Aprovações via assinatura

**Roles Definidas:**
- `DEFAULT_ADMIN_ROLE`: Administração geral do contrato
- `PAUSER_ROLE`: Pausar/despausar o contrato
- `MINTER_ROLE`: Criar novos tokens
- `BURNER_ROLE`: Queimar tokens
- `RECOVERY_ROLE`: Recuperar tokens de endereços não autorizados

**Funcões Principais:**
- `mintRef()`: Mintar tokens com referência
- `burnFromRef()`: Queimar tokens com referência
- `transferWithRef()`: Transferir com referência
- `recoverTokens()`: Recuperar tokens não autorizados
- `addToAllowlist()`: Adicionar endereço à allowlist
- `removeFromAllowlist()`: Remover endereço da allowlist

## 📝 Scripts de Interação

### 1. Deploy (DeployBBRLPlus.s.sol)
Deploy do contrato com configuração de roles:

```bash
# Deploy local (Anvil)
forge script script/DeployBBRLPlus.s.sol:DeployBBRLPlus \
    --rpc-url $LOCAL_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast

# Deploy testnet
forge script script/DeployBBRLPlus.s.sol:DeployBBRLPlus \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify
```

### 2. Interações Básicas (InteractBBRLPlus.s.sol)
Operações de mint, burn, transfer:

```bash
# Executar interações básicas
forge script script/InteractBBRLPlus.s.sol:InteractBBRLPlus \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### 3. Administração (AdminBBRLPlus.s.sol)
Gerenciamento de roles e allowlist:

```bash
# Operações administrativas
forge script script/AdminBBRLPlus.s.sol:AdminBBRLPlus \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### 4. Consultas (QueryBBRLPlus.s.sol)
Consultas de estado (sem broadcast):

```bash
# Consultar informações do contrato
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --rpc-url $RPC_URL
```

### 5. Exemplos de Uso (ExampleUsageBBRLPlus.s.sol)
Workflows completos para casos de uso:

```bash
# Executar exemplos
forge script script/ExampleUsageBBRLPlus.s.sol:ExampleUsageBBRLPlus \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

## 🛠 Ferramentas do Foundry

### Anvil (Node Local)
```bash
# Iniciar node local
anvil

# Fork de mainnet para testes
anvil --fork-url $MAINNET_RPC_URL

# Com configurações específicas
anvil --mnemonic "test test test..." --gas-price 1000000000
```

### Cast (Interação CLI)
```bash
# Verificar saldo e informações
cast balance $ADDRESS --rpc-url $RPC_URL
cast code $CONTRACT_ADDRESS --rpc-url $RPC_URL

# Chamar funções
cast call $CONTRACT_ADDRESS "balanceOf(address)" $ADDRESS --rpc-url $RPC_URL
cast send $CONTRACT_ADDRESS "transfer(address,uint256)" $TO $AMOUNT \
    --private-key $PRIVATE_KEY --rpc-url $RPC_URL

# Utilitários
cast --to-wei 1 ether
cast --from-wei 1000000000000000000
cast wallet new
```

### Soldeer (Gerenciador de Dependências)
```bash
# Instalar Soldeer
curl -L https://soldeer.xyz/install | bash

# Inicializar projeto
soldeer init

# Instalar dependência
soldeer install @openzeppelin-contracts~5.4.0

# Atualizar dependências
soldeer update

# Listar dependências instaladas
soldeer list
```

## 🔍 Debugging e Análise com Cast

### Análise de Transações e Contratos
```bash
# Simular transação
cast call $CONTRACT_ADDRESS "functionName()" --rpc-url $RPC_URL

# Estimar gas
cast estimate $CONTRACT_ADDRESS "functionName()" --rpc-url $RPC_URL

# Analisar receipt e trace
cast receipt $TX_HASH --rpc-url $RPC_URL
cast run $TX_HASH --rpc-url $RPC_URL

# Verificar storage e interface
cast storage $CONTRACT_ADDRESS $SLOT --rpc-url $RPC_URL
cast interface $CONTRACT_ADDRESS --rpc-url $RPC_URL
```

## 🚨 Configurações de Segurança

### Antes do Deploy em Produção
1. **Configurar endereços das roles** em `DeployBBRLPlus.s.sol`
2. **Usar hardware wallet** ou vault seguro para private keys
3. **Testar em testnet** primeiro
4. **Verificar contrato** no explorer
5. **Fazer auditoria** do código

### Boas Práticas
- ✅ Nunca commitar private keys reais
- ✅ Usar `.env` para variáveis sensíveis
- ✅ Testar todas as funções antes do deploy
- ✅ Configurar allowlist inicial
- ✅ Verificar todas as permissões

## 📚 Recursos Adicionais

### Documentação
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Docs](https://docs.openzeppelin.com/)
- [Solidity Docs](https://docs.soliditylang.org/)

### Exploradores de Rede
- **Ethereum Mainnet**: [Etherscan](https://etherscan.io/)
- **BSC Testnet**: [BscScan](https://testnet.bscscan.com/)
- **Polygon**: [PolygonScan](https://polygonscan.com/)

## 🤝 Contribuição

1. Fork do repositório
2. Criar branch para feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit das mudanças (`git commit -m 'Adicionar nova funcionalidade'`)
4. Push para branch (`git push origin feature/nova-funcionalidade`)
5. Abrir Pull Request

## 📄 Licença

Este projeto está licenciado sob a MIT License - veja o arquivo [LICENSE](LICENSE) para detalhes.
