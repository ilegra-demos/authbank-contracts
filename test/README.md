# BBRLPlus Test Suite Documentation

## Visão Geral

Este diretório contém uma suíte completa de testes para o contrato BBRLPlus, incluindo testes unitários, de integração, e de performance. Os testes são implementados usando o framework Foundry e seguem as melhores práticas para testes de contratos inteligentes.

## Estrutura dos Testes

### 1. Testes Principais (`BBRLPlus.t.sol`)

Testes unitários completos que cobrem todas as funcionalidades do contrato:

#### Testes de Deployment
- ✅ Verificação dos parâmetros iniciais (nome, símbolo, decimais)
- ✅ Validação das roles atribuídas corretamente
- ✅ Estado inicial do contrato (não pausado, supply zero)

#### Testes de Mint
- ✅ Mint com sucesso para usuário na allowlist
- ✅ Rejeição de mint por usuário não autorizado
- ✅ Rejeição de mint quando contrato está pausado
- ✅ Mint com quantidade zero
- ✅ Rejeição de mint para endereço zero

#### Testes de Burn
- ✅ Burn com sucesso de tokens existentes
- ✅ Rejeição de burn por usuário não autorizado
- ✅ Rejeição de burn quando saldo insuficiente
- ✅ Rejeição de burn quando contrato está pausado

#### Testes de Transfer
- ✅ Transfer padrão entre usuários autorizados
- ✅ Transfer com referência (`transferWithRef`)
- ✅ Transfer via `transferFrom` com aprovação
- ✅ Rejeição de transfer de/para usuários não autorizados

#### Testes de Allowlist
- ✅ Adição de usuários à allowlist
- ✅ Remoção de usuários da allowlist
- ✅ Verificação de usuários na allowlist
- ✅ Rejeição de operações não autorizadas na allowlist

#### Testes de Pause/Unpause
- ✅ Pausar contrato com role PAUSER
- ✅ Despausar contrato com role PAUSER
- ✅ Rejeição de pause/unpause por usuários não autorizados

#### Testes de Recovery
- ✅ Recuperação de tokens de usuários não autorizados
- ✅ Rejeição de recovery por usuários não autorizados
- ✅ Rejeição de recovery com quantidade zero

#### Testes de Roles
- ✅ Concessão de roles por admin
- ✅ Revogação de roles por admin
- ✅ Verificação de roles

#### Testes ERC20 Permit
- ✅ Funcionalidade permit (EIP-2612)
- ✅ Verificação de assinaturas
- ✅ Controle de nonces

#### Testes Fuzz
- ✅ Mint com parâmetros aleatórios
- ✅ Transfer com quantidades aleatórias

#### Testes Invariantes
- ✅ Total supply igual à soma dos balances
- ✅ Integridade da allowlist

### 2. Testes de Integração (`BBRLPlusIntegration.t.sol`)

Testes de cenários complexos e workflows completos:

#### Workflows Completos
- ✅ **Onboarding de usuário**: Adição à allowlist → mint → transferências
- ✅ **Situação de emergência**: Pause → bloqueio de operações → unpause → recuperação
- ✅ **Detecção de usuário malicioso**: Remoção da allowlist → recovery de tokens

#### Testes de Stress
- ✅ Operações em larga escala na allowlist (100+ usuários)
- ✅ Alto volume de transações (50+ transfers sequenciais)

#### Testes de Edge Cases
- ✅ Operações com quantidade zero
- ✅ Tamanho máximo da allowlist (500+ usuários)
- ✅ Transição de roles entre usuários

#### Testes de Segurança
- ✅ Proteção contra reentrância
- ✅ Edge cases de controle de acesso

#### Testes de Otimização de Gas
- ✅ Eficiência de operações da allowlist
- ✅ Medição de uso de gas para diferentes operações

#### Testes de Compatibilidade
- ✅ Compatibilidade ERC20 padrão
- ✅ Funcionalidade Permit (EIP-2612)

### 3. Testes de Performance (`BBRLPlusPerformance.t.sol`)

Benchmarks e testes de performance:

#### Benchmarks de Gas
- ✅ **Operações de Mint**: ~67k gas por mint
- ✅ **Operações de Transfer**: ~96k gas por transfer padrão, ~101k para transferWithRef
- ✅ **Operações de Allowlist**: ~60k gas para adicionar, ~5k para verificar
- ✅ **Operações de Roles**: ~3k gas para verificar role

#### Testes de Escalabilidade
- ✅ **Allowlist**: Verificação O(1) independente do tamanho (até 500 usuários testados)
- ✅ **Transfers**: Gas por transfer permanece constante com múltiplas operações

#### Testes de Stress
- ✅ **Allowlist máxima**: 1000+ operações sem degradação
- ✅ **Alto volume**: 200+ transfers mantendo consistência
- ✅ **Eficiência de memória**: Adição/remoção de 500+ usuários

#### Benchmarks Comparativos
- ✅ Comparação entre tipos de transfer (padrão vs. com referência vs. transferFrom)

#### Casos Extremos
- ✅ Valores máximos (1 bilhão de tokens)
- ✅ Operações com quantidades muito grandes

### 4. Helper de Testes (`BBRLPlusTestHelper.sol`)

Contrato abstrato com utilitários para facilitar a criação de testes:

#### Funcionalidades
- 🔧 **Setup padronizado**: Deployment e configuração automática
- 🔧 **Utilitários de allowlist**: Adição/remoção em batch
- 🔧 **Mint em massa**: Para múltiplos usuários simultaneamente
- 🔧 **Cenários pré-configurados**: Setup completo para testes
- 🔧 **Assinaturas Permit**: Criação automática de assinaturas válidas
- 🔧 **Verificação de consistência**: Validação automática do estado
- 🔧 **Logging**: Funções para debug e monitoramento
- 🔧 **Constantes e endereços**: Padronização de valores de teste

## Como Executar os Testes

### Executar Todos os Testes
```bash
forge test
```

### Executar Testes Específicos
```bash
# Testes principais
forge test --match-contract BBRLPlusTest

# Testes de integração
forge test --match-contract BBRLPlusIntegrationTest

# Testes de performance
forge test --match-contract BBRLPlusPerformanceTest
```

### Executar com Verbosidade
```bash
# Verbosidade básica
forge test -v

# Verbosidade máxima (inclui logs)
forge test -vvvv
```

### Executar Testes Específicos por Nome
```bash
# Testes de mint
forge test --match-test test_MintRef

# Testes de transfer
forge test --match-test test_Transfer

# Testes de allowlist
forge test --match-test test_Allowlist
```

## Cobertura de Testes

### Funcionalidades Testadas
- ✅ **Mint**: 100% - Todos os cenários cobertos
- ✅ **Burn**: 100% - Todos os cenários cobertos  
- ✅ **Transfer**: 100% - Padrão, com referência, e transferFrom
- ✅ **Allowlist**: 100% - Adição, remoção, verificação
- ✅ **Pause/Unpause**: 100% - Controles de emergência
- ✅ **Recovery**: 100% - Recuperação de tokens
- ✅ **Access Control**: 100% - Todas as roles testadas
- ✅ **ERC20 Compatibility**: 100% - Padrão ERC20 + Permit

### Cenários de Edge Cases
- ✅ Quantidades zero
- ✅ Endereços zero
- ✅ Overflow/underflow
- ✅ Usuários não autorizados
- ✅ Contrato pausado
- ✅ Saldos insuficientes
- ✅ Roles não atribuídas

### Performance e Escalabilidade
- ✅ Gas benchmarking
- ✅ Operações em larga escala
- ✅ Stress testing
- ✅ Eficiência de memória

## Métricas de Performance

### Gas Usage (Aproximado)
| Operação | Gas Estimado |
|----------|-------------|
| Mint | ~67,000 |
| Transfer | ~96,000 |
| Transfer com Ref | ~101,000 |
| Add to Allowlist | ~60,000 |
| Check Allowlist | ~5,000 |
| Burn | ~77,000 |
| Recovery | ~121,000 |

### Escalabilidade
| Métrica | Limite Testado | Resultado |
|---------|----------------|-----------|
| Allowlist Size | 1,000 usuários | ✅ O(1) lookup |
| Batch Transfers | 200+ transfers | ✅ Gas linear |
| Role Operations | Múltiplas roles | ✅ Eficiente |

## Resultados Esperados

Todos os testes devem passar com as seguintes características:

- **Total de Testes**: 60+ testes
- **Cobertura**: 100% das funcionalidades
- **Performance**: Dentro dos limites de gas estabelecidos
- **Segurança**: Todos os controles de acesso validados
- **Compatibilidade**: ERC20 e EIP-2612 totalmente compatíveis

## Troubleshooting

### Problemas Comuns

1. **Falha de compilação**:
   ```bash
   forge clean
   forge build
   ```

2. **Testes falhando por gas**:
   - Verificar se os limites de gas estão atualizados
   - Analisar otimizações no contrato

3. **Testes de fuzz falhando**:
   - Verificar assumes nos testes fuzz
   - Ajustar ranges de valores de teste

4. **Invariantes falhando**:
   - Verificar se todos os endereços estão sendo considerados
   - Validar lógica de tracking de balances

### Debug
```bash
# Executar teste específico com logs detalhados
forge test --match-test <nome_do_teste> -vvvv

# Executar com gas reporting
forge test --gas-report
```

## Desenvolvimento de Novos Testes

### Estrutura Recomendada
1. Use o `BBRLPlusTestHelper` como base
2. Siga a convenção de nomes: `test_Function_Scenario`
3. Para testes de revert: `test_RevertWhen_Function_Condition`
4. Inclua logs para debug quando necessário
5. Verifique estado antes e depois das operações

### Exemplo de Novo Teste
```solidity
function test_NewFunction_Success() public {
    // Setup
    setupStandardAllowlist();
    
    // Action
    vm.prank(AUTHORIZED_USER);
    bool result = token.newFunction(parameters);
    
    // Assertions
    assertTrue(result);
    assertEq(token.someState(), expectedValue);
    
    // Verify consistency
    verifyTokenStateConsistency();
}
```