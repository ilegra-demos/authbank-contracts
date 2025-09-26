# Scripts de Interação BBRLPlus

Esta pasta contém todos os scripts para deploy e interação com o contrato BBRLPlus, implementados usando Foundry Script para máxima compatibilidade e facilidade de uso.

## 📋 Visão Geral dos Scripts

### 🚀 DeployBBRLPlus.s.sol
**Deploy do contrato principal**

**Funcionalidades:**
- Deploy com configuração automática de roles
- Verificação pós-deploy das permissões
- Logs detalhados do processo
- Função de deploy customizado para diferentes cenários

**Configuração necessária:**
```solidity
// Configure os endereços das roles antes do deploy
address public constant DEFAULT_ADMIN = 0x...;
address public constant PAUSER = 0x...;
address public constant MINTER = 0x...;
address public constant BURNER = 0x...;
address public constant RECOVERY = 0x...;
```

### 🔄 InteractBBRLPlus.s.sol
**Interações básicas com o token**

**Funcionalidades principais:**
- `mintTokens()`: Criar novos tokens com referência
- `transferTokens()`: Transferir tokens com rastreamento
- `burnTokens()`: Queimar tokens de forma controlada
- `checkContractInfo()`: Informações gerais do contrato
- `checkBalance()`: Consultar saldos detalhados
- `checkRoles()`: Verificar permissões específicas
- `listAllowlist()`: Listar endereços autorizados

### ⚙️ AdminBBRLPlus.s.sol
**Operações administrativas avançadas**

**Gerenciamento de Roles:**
- `grantMinterRole()`, `grantBurnerRole()`, `grantPauserRole()`, `grantRecoveryRole()`
- `revokeMinterRole()`, `revokeBurnerRole()`, `revokePauserRole()`, `revokeRecoveryRole()`

**Gerenciamento da AllowList:**
- `addToAllowlist()`, `removeFromAllowlist()`: Individual
- `addMultipleToAllowlist()`, `removeMultipleFromAllowlist()`: Em lote

**Controle de Emergência:**
- `pauseContract()`, `unpauseContract()`: Controle de pausa
- `recoverTokens()`: Recuperação de tokens não autorizados

**Auditoria:**
- `checkAllRoles()`: Verificação completa de permissões

### 📊 QueryBBRLPlus.s.sol
**Consultas e relatórios detalhados**

**Relatórios disponíveis:**
- `getContractOverview()`: Visão geral completa
- `getAllowlistInfo()`: Estatísticas da allowlist
- `getBalanceInfo()`: Análise detalhada de saldos
- `getRolesInfo()`: Informações sobre roles
- `checkPermissions()`: Verificação de capacidades
- `getContractStats()`: Estatísticas gerais
- `simulateTransfer()`: Simulação de operações

### 💡 ExampleUsageBBRLPlus.s.sol
**Workflows completos e casos de uso**

**Exemplos implementados:**
- `setupExample()`: Setup inicial completo do sistema
- `transferExample()`: Fluxos de transferência
- `adminExample()`: Operações administrativas típicas
- `recoveryExample()`: Processos de recuperação
- `onboardingExample()`: Onboarding de novos usuários
- `burnExample()`: Queima controlada de tokens

**Funcionalidades**:
- `getContractOverview()`: Visão geral do contrato
- `getAllowlistInfo()`: Informações detalhadas da allowlist
- `getRolesInfo()`: Informações sobre as roles do contrato
- `getBalanceInfo()`: Informações detalhadas de saldo
- `getAllowanceInfo()`: Informações de allowance entre endereços
- `checkPermissions()`: Verifica permissões de um endereço
- `getContractStats()`: Estatísticas gerais do contrato
- `simulateTransfer()`: Simula uma transferência para verificar viabilidade

## Configuração

Antes de usar os scripts, você deve configurar o endereço do contrato:

1. Abra cada arquivo de script
2. Localize a linha: `address public constant CONTRACT_ADDRESS = address(0);`
3. Substitua `address(0)` pelo endereço real do contrato implantado

Exemplo:
```solidity
address public constant CONTRACT_ADDRESS = 0x1234567890123456789012345678901234567890;
```

## Como Usar

### Configuração do Ambiente

1. **Instale o Foundry** (se ainda não tiver):
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Configure as variáveis de ambiente**:
   ```bash
   # .env
   PRIVATE_KEY=sua_chave_privada
   RPC_URL=https://sua_rpc_url
   ```

3. **Configure seu foundry.toml** (se necessário):
   ```toml
   [profile.default]
   src = "src"
   out = "out"
   libs = ["lib"]
   ```

### Executando Scripts

#### Execução Básica (Dry Run)
Para executar um script sem fazer transações reais:

```bash
# Verificar informações do contrato
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus --rpc-url $RPC_URL

# Interações básicas (dry run)
forge script script/InteractBBRLPlus.s.sol:InteractBBRLPlus --rpc-url $RPC_URL
```

#### Execução com Transações Reais
Para executar com transações reais na blockchain:

```bash
# Executar operações administrativas
forge script script/AdminBBRLPlus.s.sol:AdminBBRLPlus \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast

# Executar interações básicas
forge script script/InteractBBRLPlus.s.sol:InteractBBRLPlus \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

#### Verificação de Contratos (Opcional)
Para verificar o contrato na blockchain:

```bash
forge script script/InteractBBRLPlus.s.sol:InteractBBRLPlus \
  --rpc-url $RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

## Exemplos de Uso

### 1. Verificar Estado do Contrato
```solidity
// No QueryBBRLPlus.s.sol, descomente na função run():
getContractOverview();
getAllowlistInfo();
getContractStats();
```

### 2. Mintar Tokens
```solidity
// No InteractBBRLPlus.s.sol, descomente na função run():
mintTokens(0x1234567890123456789012345678901234567890, 1000 * 10**18, "MINT-001");
```

### 3. Adicionar Endereço à AllowList
```solidity
// No AdminBBRLPlus.s.sol, descomente na função run():
addToAllowlist(0x1234567890123456789012345678901234567890);
```

### 4. Transferir Tokens
```solidity
// No InteractBBRLPlus.s.sol, descomente na função run():
transferTokens(0x1234567890123456789012345678901234567890, 100 * 10**18, "TRANSFER-001");
```

### 5. Pausar/Despausar Contrato
```solidity
// No AdminBBRLPlus.s.sol, descomente na função run():
pauseContract();    // Para pausar
unpauseContract();  // Para despausar
```

## Personalização dos Scripts

### Modificando Funções Existentes

Você pode modificar os parâmetros das funções diretamente nos scripts. Por exemplo:

```solidity
function run() public {
    vm.startBroadcast();
    
    // Personalize os parâmetros conforme necessário
    mintTokens(
        0xSeuEnderecoAqui,           // to
        1000 * 10**18,               // amount (1000 tokens)
        "MINT-PERSONALIZADO-001"     // ref
    );
    
    vm.stopBroadcast();
}
```

### Criando Novas Funções

Você pode adicionar suas próprias funções aos scripts:

```solidity
/**
 * @notice Função personalizada para setup inicial
 */
function setupInitial() public {
    // Adicionar múltiplos endereços à allowlist
    address[] memory accounts = new address[](3);
    accounts[0] = 0x1111111111111111111111111111111111111111;
    accounts[1] = 0x2222222222222222222222222222222222222222;
    accounts[2] = 0x3333333333333333333333333333333333333333;
    
    addMultipleToAllowlist(accounts);
    
    // Mintar tokens para cada endereço
    for (uint i = 0; i < accounts.length; i++) {
        mintTokens(accounts[i], 100 * 10**18, "INITIAL-MINT");
    }
}
```

## Segurança e Boas Práticas

### 1. Verificação de Permissões
Sempre verifique se sua conta tem as permissões necessárias antes de executar operações:

```bash
# Verificar suas permissões
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus -s "checkPermissions(address)" $SEU_ENDERECO --rpc-url $RPC_URL
```

### 2. Simulação Antes da Execução
Execute sempre em modo de simulação primeiro:

```bash
# Simular sem fazer transações
forge script script/AdminBBRLPlus.s.sol:AdminBBRLPlus --rpc-url $RPC_URL
```

### 3. Backup das Chaves
- Nunca commite chaves privadas no Git
- Use arquivos `.env` e adicione-os ao `.gitignore`
- Considere usar hardware wallets para operações em produção

### 4. Verificação de Endereços
Sempre verifique os endereços antes de executar operações importantes:

```bash
# Verificar informações de um endereço
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus -s "getBalanceInfo(address)" $ENDERECO --rpc-url $RPC_URL
```

## 🔧 Configuração dos Scripts

### 1. Configurar Endereço do Contrato
Em cada script, atualize a constante após o deploy:
```solidity
address public constant CONTRACT_ADDRESS = address(0); // ← Substitua pelo endereço real
```

### 2. Configurar Variáveis de Ambiente
Crie ou atualize seu arquivo `.env`:
```bash
# RPC URLs
LOCAL_RPC_URL="http://127.0.0.1:8545"
TESTNET_RPC_URL="https://data-seed-prebsc-1-s1.binance.org:8545/"
MAINNET_RPC_URL="https://bsc-dataseed.binance.org/"

# Private Keys (NUNCA COMMITAR CHAVES REAIS)
PRIVATE_KEY="0x..."
ADMIN_PRIVATE_KEY="0x..."
MINTER_PRIVATE_KEY="0x..."

# Contract Address (após deploy)
BBRLPLUS_CONTRACT="0x..."
```

## 🚀 Guia de Execução

### Passo 1: Deploy do Contrato
```bash
# 1. Configure as roles no DeployBBRLPlus.s.sol
# 2. Execute o deploy
forge script script/DeployBBRLPlus.s.sol:DeployBBRLPlus \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify

# 3. Salve o endereço do contrato retornado
```

### Passo 2: Configurar Scripts
```bash
# Atualize CONTRACT_ADDRESS em todos os scripts
# Use o endereço obtido no deploy
```

### Passo 3: Setup Inicial do Sistema
```bash
# Execute o setup com allowlist inicial e mint
forge script script/ExampleUsageBBRLPlus.s.sol:ExampleUsageBBRLPlus \
    --sig "setupExample()" \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Passo 4: Verificar Estado
```bash
# Consulte o estado atual do contrato
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --sig "getContractOverview()" \
    --rpc-url $TESTNET_RPC_URL
```

## 📋 Exemplos de Uso Prático

### Cenário 1: Onboarding de Usuário
```bash
# Adicionar novo usuário ao sistema
forge script script/ExampleUsageBBRLPlus.s.sol:ExampleUsageBBRLPlus \
    --sig "onboardingExample(address)" 0x1234567890123456789012345678901234567890 \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Cenário 2: Transferência de Tokens
```bash
# Executar transferência com referência
forge script script/InteractBBRLPlus.s.sol:InteractBBRLPlus \
    --sig "transferTokens(address,uint256,string)" \
    0x1234567890123456789012345678901234567890 \
    1000000000000000000 \
    "PAYMENT-001" \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast
```

### Cenário 3: Operação de Emergência
```bash
# Pausar contrato em emergência
forge script script/AdminBBRLPlus.s.sol:AdminBBRLPlus \
    --sig "pauseContract()" \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $ADMIN_PRIVATE_KEY \
    --broadcast

# Recuperar tokens de endereço não autorizado
forge script script/AdminBBRLPlus.s.sol:AdminBBRLPlus \
    --sig "recoverTokens(address,string,uint256)" \
    0x9999999999999999999999999999999999999999 \
    "RECOVERY-001" \
    1000000000000000000 \
    --rpc-url $TESTNET_RPC_URL \
    --private-key $RECOVERY_PRIVATE_KEY \
    --broadcast
```

### Cenário 4: Relatórios e Auditoria
```bash
# Relatório completo do sistema
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --sig "getContractStats()" \
    --rpc-url $TESTNET_RPC_URL

# Verificar permissões de um endereço
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --sig "checkPermissions(address)" 0x1234... \
    --rpc-url $TESTNET_RPC_URL
```

## 🛡️ Permissões e Segurança

### Matriz de Permissões
| Script | Função | Role Necessária | Allowlist Necessária |
|--------|--------|----------------|---------------------|
| Deploy | `run()` | Nenhuma | Não |
| Interact | `mintTokens()` | MINTER_ROLE | Não |
| Interact | `transferTokens()` | Nenhuma | Sim (sender/receiver) |
| Interact | `burnTokens()` | BURNER_ROLE | Não |
| Admin | `grantRole()` | DEFAULT_ADMIN_ROLE | Não |
| Admin | `addToAllowlist()` | DEFAULT_ADMIN_ROLE | Não |
| Admin | `pauseContract()` | PAUSER_ROLE | Não |
| Admin | `recoverTokens()` | RECOVERY_ROLE | Não |
| Query | Todas | Nenhuma | Não |

### Boas Práticas de Segurança
- ✅ **Sempre testar em testnet primeiro**
- ✅ **Usar contas específicas para cada role**
- ✅ **Verificar permissões antes de executar**
- ✅ **Monitorar logs de execução**
- ✅ **Fazer backup das private keys**
- ✅ **Nunca commitar chaves privadas**

## 🔍 Debugging e Troubleshooting

### Problemas Comuns

**1. "Contract not deployed"**
```bash
# Verificar se contrato existe
cast code $CONTRACT_ADDRESS --rpc-url $RPC_URL
# Se retornar "0x", o contrato não está implantado
```

**2. "UnauthorizedCaller" Error**
```bash
# Verificar se está na allowlist
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --sig "checkAllowlist(address)" $USER_ADDRESS \
    --rpc-url $RPC_URL
```

**3. "AccessControl: missing role" Error**
```bash
# Verificar roles do usuário
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --sig "checkPermissions(address)" $USER_ADDRESS \
    --rpc-url $RPC_URL
```

**4. "Pausable: paused" Error**
```bash
# Verificar se contrato está pausado
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --sig "getContractOverview()" \
    --rpc-url $RPC_URL
```

### Comandos de Debug
```bash
# Executar sem broadcast para testar
forge script script/InteractBBRLPlus.s.sol:InteractBBRLPlus \
    --rpc-url $RPC_URL # SEM --broadcast

# Logs verbosos
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus \
    --rpc-url $RPC_URL -vvvv

# Simular transação específica
cast call $CONTRACT_ADDRESS \
    "balanceOf(address)(uint256)" \
    $USER_ADDRESS \
    --rpc-url $RPC_URL

# Estimar gas de operação
cast estimate $CONTRACT_ADDRESS \
    "mintRef(address,uint256,string)" \
    $USER_ADDRESS 1000000000000000000 "MINT-001" \
    --rpc-url $RPC_URL
```

## 📝 Logs e Monitoramento

### Interpretar Logs dos Scripts
Os scripts produzem logs estruturados:
```
=== MINTANDO TOKENS ===
Para: 0x1234567890123456789012345678901234567890
Quantidade: 1000000000000000000
Referencia: MINT-001
Saldo antes: 0
Saldo depois: 1000000000000000000
Tokens mintados com sucesso!
```

### Monitoramento Contínuo
```bash
# Script para monitoramento automático
watch -n 30 'forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus --sig "getContractStats()" --rpc-url $RPC_URL'
```

## 🤝 Contribuindo

### Adicionando Novos Scripts
1. **Siga o padrão de nomenclatura**: `OperationBBRLPlus.s.sol`
2. **Use herança de `Script`**: `contract MyScript is Script`
3. **Inclua logs detalhados**: Use `console.log()` extensivamente
4. **Documente as funções**: Comentários NatSpec
5. **Teste em testnet**: Sempre teste antes de PR

### Padrão de Código
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {BBRLPlus} from "../src/BBRLPlus.sol";

contract MyOperationBBRLPlus is Script {
    BBRLPlus public bbrlPlus;
    address public constant CONTRACT_ADDRESS = address(0);
    
    function setUp() public {
        bbrlPlus = BBRLPlus(CONTRACT_ADDRESS);
    }
    
    function run() public {
        // Implementação
    }
}
```

## 📚 Referências

- [Foundry Book](https://book.getfoundry.sh/) - Documentação completa
- [Foundry Scripts](https://book.getfoundry.sh/tutorials/solidity-scripting) - Guia de scripts
- [OpenZeppelin AccessControl](https://docs.openzeppelin.com/contracts/access-control) - Sistema de roles
- [ERC20 Standard](https://eips.ethereum.org/EIPS/eip-20) - Padrão de tokens