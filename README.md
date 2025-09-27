<div align="center">

# BBRLPlus (Brazilian Bank Real Plus Token)

**Token ERC20 avançado com segurança, governança granular e rastreabilidade de operações para representar BRL tokenizado.**

</div>

> Documentação unificada: todo o conteúdo de testes, scripts e operações está concentrado neste arquivo (`README.md`). READMEs secundários foram removidos para evitar duplicação.

## 🧭 Índice

1. [Visão Geral](#-visão-geral)
2. [Arquitetura & Stack](#-arquitetura--stack)
3. [Estrutura do Projeto](#-estrutura-do-projeto)
4. [Configuração & Ambiente](#-configuração--ambiente)
5. [Build & Desenvolvimento](#-build--desenvolvimento)
6. [Contrato Principal](#-contrato-principal-bbrlplussol)
7. [Scripts (Deploy / Operações / Query / Exemplos)](#-scripts)
8. [Testes (Unit / Integração / Performance)](#-testes)
9. [Relatórios: Gas, Cobertura, Snapshots](#-relatórios-gas-cobertura-snapshots)
10. [Debug & Ferramentas (Forge, Cast, Chisel)](#-debug--ferramentas)
11. [Métricas & Benchmarks](#-métricas--benchmarks)
12. [Checklists (Dev / CI / Deploy)](#-checklists)
13. [Segurança & Boas Práticas](#-segurança--boas-práticas)
14. [Ambiente & Variáveis (.env)](#-ambiente--variáveis-env)
15. [Contribuição](#-contribuição)
16. [Licença](#-licença)

---

## 📋 Visão Geral

Características chave:

- 🔐 **Controle de Acesso Granular** (roles: Admin, Minter, Burner, Pauser, Recovery)
- 🚫 **DenyList por Modelo Negativo** (somente endereços bloqueados são restringidos)
- 🛑 **Pausável** (resposta a incidentes / emergência)
- 🪙 **Mint & Burn Controlados** (auditoria via referência)
- ♻️ **Recuperação de Tokens** (endereços bloqueados / incidentes)
- ✍️ **ERC20Permit (EIP‑2612)** para aprovações gasless
- 🧾 **Referências em Operações** (mint / burn / transfer com metadata curta)

## 🧱 Arquitetura & Stack

| Componente | Uso |
|------------|-----|
| Solidity ^0.8.27 | Linguagem de contrato |
| Foundry (Forge, Cast, Anvil, Chisel) | Build, teste, interação |
| OpenZeppelin 5.4.0 | Primitivas seguras |
| forge-std 1.10.0 | Utilidades de teste |
| Soldeer | Gestão de dependências |

Rede suportada via `foundry.toml` (exemplo custom: `[bnbtestnet]`).

## 📁 Estrutura do Projeto

```
src/                  # Contratos
script/               # Scripts operacionais (deploy, admin, interação, query, exemplos)
test/                 # Testes unitários, integração, performance, helpers
lib/                  # Dependências (forge-std, openzeppelin)
broadcast/            # Saídas de execução forge script
cache/ & out/         # Artefatos de compilação
foundry.toml          # Configuração Foundry
.env(.example)        # Variáveis de ambiente
```

## ⚙️ Configuração & Ambiente

Instalar Foundry:
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

Clonar & instalar dependências:
```bash
git clone <repository-url>
cd authbank-project
forge install
cp .env.example .env
```

Editar `.env` (exemplo mínimo):
```bash
BNBTESTNET_RPC_URL="https://..."  # ou TESTNET / MAINNET
LOCAL_RPC_URL="http://127.0.0.1:8545"

PRIVATE_KEY="0x..."          # nunca commitar
ADMIN_ADDRESS="0x..."
MINTER_ADDRESS="0x..."
```

## 🛠 Build & Desenvolvimento

```bash
forge build            # Compila
forge build --sizes    # Tamanhos
forge fmt              # Formata
forge clean && forge build # Limpa e recompila
```

### Qualidade
```bash
forge test --summary
forge coverage --report lcov
forge snapshot
```

## 🧾 Contrato Principal: `BBRLPlus.sol`

Herança: `ERC20`, `ERC20Burnable`, `ERC20Pausable`, `AccessControl`, `ERC20Permit`.

Roles:
- `DEFAULT_ADMIN_ROLE`
- `PAUSER_ROLE`
- `MINTER_ROLE`
- `BURNER_ROLE`
- `RECOVERY_ROLE`

Principais funções estendidas:
- `mintRef(address to,uint256 amount,string ref)`
- `burnFromRef(address from,uint256 amount,string ref)`
- `transferWithRef(address to,uint256 amount,string ref)`
- `recoverTokens(address from,string ref,uint256 amount)`
- `addToDenylist(address)` / `removeFromDenylist(address)`

Invariantes (testadas):
1. Total supply = soma dos balances
2. Endereço na denylist não pode ser origem ou destino
3. Operações pausadas bloqueiam mutações

## 📜 Scripts

Todos escritos em Solidity Script (`forge script`). Após deploy atualize a `CONTRACT_ADDRESS` nos scripts que interagem.

| Script | Propósito | Principais Ações |
|--------|-----------|------------------|
| `DeployBBRLPlus.s.sol` | Deploy inicial | Define roles, valida setup |
| `AdminBBRLPlus.s.sol` | Governança/roles/denylist | Grant/Revoke/Pause/Recovery |
| `InteractBBRLPlus.s.sol` | Operações básicas | Mint / Transfer / Burn |
| `QueryBBRLPlus.s.sol` | Relatórios e leitura | Overview / Stats / Permissions |
| `ExampleUsageBBRLPlus.s.sol` | Workflows completos | Onboarding / Recovery / Demo |

### Exemplos
```bash
# Deploy (testnet)
forge script script/DeployBBRLPlus.s.sol:DeployBBRLPlus \
    --rpc-url $BNBTESTNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast --verify

# Operações administrativas
forge script script/AdminBBRLPlus.s.sol:AdminBBRLPlus \
    --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast

# Consulta (dry run)
forge script script/QueryBBRLPlus.s.sol:QueryBBRLPlus --rpc-url $RPC_URL
```

Uso com assinatura específica (`--sig`):
```bash
forge script script/ExampleUsageBBRLPlus.s.sol:ExampleUsageBBRLPlus \
    --sig "onboardingExample(address)" 0x1234... --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

## 🧪 Testes

Total atual: **≈60 testes** (unit + integração + performance) cobrindo 100% das funcionalidades críticas.

| Categoria | Arquivo | Escopo | Qtd aprox |
|-----------|---------|--------|-----------|
| Unit | `BBRLPlus.t.sol` | Funções isoladas & invariantes | 36 |
| Integração | `BBRLPlusIntegration.t.sol` | Workflows / cenários compostos | 13 |
| Performance | `BBRLPlusPerformance.t.sol` | Benchmarks gas & stress | 11 |

Execução básica:
```bash
forge test                      # todos
forge test -vvvv                # máximo debug
forge test --match-contract BBRLPlusIntegrationTest
forge test --match-test test_MintRef
```

Fuzz / invariantes / seeds:
```bash
forge test --fuzz-runs 1000 --match-test testFuzz
forge test --fuzz-seed 42
forge test --match-test test_Invariant_TotalSupply
```

Isolamento & debug:
```bash
forge test --match-test test_RevertWhen_Transfer_UnauthorizedReceiver --isolate -vvvv --debug
```

## 📊 Relatórios (Gas, Cobertura, Snapshot)

```bash
forge test --gas-report
forge coverage --report lcov
forge snapshot                # cria/atualiza .gas-snapshot
forge snapshot --diff .gas-snapshot
```

Filtrar:
```bash
forge test --match-contract BBRLPlusPerformanceTest --gas-report
forge coverage --match-path src/BBRLPlus.sol
```

## 🧪➡️🔍 Fluxo Recomendado de Teste
1. `forge test --summary`
2. `forge test --gas-report`
3. `forge coverage`
4. `forge snapshot --diff .gas-snapshot`
5. Executar performance apenas antes de PR final: `forge test --match-contract BBRLPlusPerformanceTest`

## 🐞 Debug & Ferramentas

Cast:
```bash
cast balance $ADDRESS --rpc-url $RPC_URL
cast call $CONTRACT "balanceOf(address)" $USER --rpc-url $RPC_URL
cast send $CONTRACT "transfer(address,uint256)" $TO 1000 \
    --private-key $PRIVATE_KEY --rpc-url $RPC_URL
```

Chisel REPL:
```bash
chisel
!load src/BBRLPlus.sol
```

Snapshots / repetibilidade:
```bash
forge test --fail-fast
forge test --fuzz-seed 123
```

## 📈 Métricas & Benchmarks

Gas médio aproximado:
```
Mint                ~67k
Transfer            ~96k
TransferWithRef     ~101k
AddToDenylist       ~63k
Burn                ~77k
Recovery            ~121k
Role Check          ~3k
```

Escalabilidade:
```
Denylist lookup:   O(1) (EnumerableSet)
Batch transfers:   Escala linear até 200+ operações
Invariantes:       Estáveis sob mutações simultâneas
```

## ✅ Checklists

### Desenvolvimento Diário
```bash
forge test --no-match-contract BBRLPlusPerformanceTest --summary
forge fmt --check
```

### Pré-PR
```bash
forge test
forge coverage
forge test --gas-report
forge snapshot --diff .gas-snapshot
```

### Pré-Deploy
```bash
forge build --sizes
forge test --match-contract BBRLPlusPerformanceTest
forge coverage --report lcov
forge snapshot
```

## 🔐 Segurança & Boas Práticas

1. Nunca commitar chaves privadas (usar `.env` + hardware wallet em produção)
2. Revisar roles definidas no script de deploy antes de broadcast
3. Testar em testnet → validar → só então mainnet
4. Verificar contrato (explorer) e reter endereço em variável imutável de monitoramento
5. Limitar frequência de operações de recovery e registrar referência (`ref`)

### Considerações de Modelo de Ameaça
- Denylist atua como mecanismo reativo (não preventivo KYC completo)
- Pausa é controle de mitigação de incidente, não substitui auditoria
- Referências servem para auditoria off-chain (logs indexados)

## 🌱 Ambiente & Variáveis (.env)
Chaves comuns:
```bash
BNBTESTNET_RPC_URL=
LOCAL_RPC_URL=
PRIVATE_KEY=
ADMIN_ADDRESS=
MINTER_ADDRESS=
```

Use perfis adicionais em `foundry.toml` para redes extras.

## 🤝 Contribuição
1. Fork
2. Branch feature: `git checkout -b feature/minha-feature`
3. Commits descritivos
4. Executar checklists (test/gas/coverage)
5. Abrir PR com descrição clara

## 📄 Licença
MIT License. Consulte `LICENSE`.

---

> Dúvidas ou melhorias? Abra uma issue ou PR. Documentação será expandida conforme novas capacidades forem adicionadas (ex: bridging, compliance hooks, batch operations).
