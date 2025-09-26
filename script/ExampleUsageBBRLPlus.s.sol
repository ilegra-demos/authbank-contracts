// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {BBRLPlus} from "../src/BBRLPlus.sol";

/**
 * @title Example Usage BBRLPlus Script
 * @notice Script de exemplo mostrando casos de uso comuns do BBRLPlus
 * @dev Use este script como referencia para implementar seus proprios workflows
 */
contract ExampleUsageBBRLPlus is Script {
    BBRLPlus public bbrlPlus;
    
    // Endereco do contrato implantado - deve ser configurado antes de executar
    address public constant CONTRACT_ADDRESS = address(0); // Substitua pelo endereco real
    
    // Enderecos de exemplo - substitua pelos enderecos reais
    address public constant USER_A = 0x1111111111111111111111111111111111111111;
    address public constant USER_B = 0x2222222222222222222222222222222222222222;
    address public constant USER_C = 0x3333333333333333333333333333333333333333;
    
    function setUp() public {
        // Conecta ao contrato ja implantado
        bbrlPlus = BBRLPlus(CONTRACT_ADDRESS);
    }
    
    /**
     * @notice Funcao principal - descomente o exemplo que desejar executar
     */
    function run() public {
        // Descomente o exemplo que desejar executar:
        
        // setupExample();
        // transferExample();
        // adminExample();
        // recoveryExample();
        // queryExample();
    }
    
    /**
     * @notice Exemplo 1: Setup inicial do sistema
     * @dev Adiciona usuarios a allowlist e minta tokens iniciais
     */
    function setupExample() public {
        vm.startBroadcast();
        
        console.log("=== EXEMPLO: SETUP INICIAL ===");
        
        // 1. Adicionar usuarios a allowlist
        console.log("1. Adicionando usuarios a allowlist...");
        bbrlPlus.addToAllowlist(USER_A);
        bbrlPlus.addToAllowlist(USER_B);
        bbrlPlus.addToAllowlist(USER_C);
        
        // 2. Mintar tokens iniciais
        console.log("2. Mintando tokens iniciais...");
        bbrlPlus.mintRef(USER_A, 1000 * 10**18, "INITIAL-MINT-A");
        bbrlPlus.mintRef(USER_B, 500 * 10**18, "INITIAL-MINT-B");
        bbrlPlus.mintRef(USER_C, 750 * 10**18, "INITIAL-MINT-C");
        
        // 3. Verificar setup
        console.log("3. Verificando setup...");
        console.log("Total supply:", bbrlPlus.totalSupply());
        console.log("Allowlist size:", bbrlPlus.getAllowlistLength());
        console.log("USER_A balance:", bbrlPlus.balanceOf(USER_A));
        console.log("USER_B balance:", bbrlPlus.balanceOf(USER_B));
        console.log("USER_C balance:", bbrlPlus.balanceOf(USER_C));
        
        console.log("Setup inicial concluido com sucesso!");
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Exemplo 2: Transferencias entre usuarios
     * @dev Demonstra transferencias normais e com referencia
     */
    function transferExample() public {
        vm.startBroadcast();
        
        console.log("=== EXEMPLO: TRANSFERENCIAS ===");
        
        // Verificar saldos iniciais
        console.log("Saldos iniciais:");
        console.log("USER_A:", bbrlPlus.balanceOf(USER_A));
        console.log("USER_B:", bbrlPlus.balanceOf(USER_B));
        
        // 1. Transferencia simples de A para B
        console.log("1. Transferencia simples de A para B...");
        uint256 amount1 = 100 * 10**18;
        bbrlPlus.transfer(USER_B, amount1);
        
        // 2. Transferencia com referencia de B para C
        console.log("2. Transferencia com referencia de B para C...");
        uint256 amount2 = 50 * 10**18;
        bbrlPlus.transferWithRef(USER_C, amount2, "PAYMENT-001");
        
        // Verificar saldos finais
        console.log("Saldos finais:");
        console.log("USER_A:", bbrlPlus.balanceOf(USER_A));
        console.log("USER_B:", bbrlPlus.balanceOf(USER_B));
        console.log("USER_C:", bbrlPlus.balanceOf(USER_C));
        
        console.log("Transferencias concluidas com sucesso!");
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Exemplo 3: Operacoes administrativas
     * @dev Demonstra pause/unpause e gerenciamento de roles
     */
    function adminExample() public {
        vm.startBroadcast();
        
        console.log("=== EXEMPLO: OPERACOES ADMINISTRATIVAS ===");
        
        // 1. Pausar o contrato
        console.log("1. Pausando o contrato...");
        bool wasUnpaused = !bbrlPlus.paused();
        if (wasUnpaused) {
            bbrlPlus.pause();
            console.log("Contrato pausado com sucesso!");
        } else {
            console.log("Contrato ja estava pausado");
        }
        
        // 2. Tentar uma transferencia (deve falhar)
        console.log("2. Tentando transferencia com contrato pausado...");
        console.log("(Esta operacao deve falhar - apenas para demonstracao)");
        
        // 3. Despausar o contrato
        console.log("3. Despausando o contrato...");
        bbrlPlus.unpause();
        console.log("Contrato despausado com sucesso!");
        
        // 4. Conceder role de minter para USER_A
        console.log("4. Concedendo role de minter para USER_A...");
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        bbrlPlus.grantRole(MINTER_ROLE, USER_A);
        
        // 5. Verificar roles
        console.log("5. Verificando roles do USER_A...");
        console.log("Tem MINTER_ROLE:", bbrlPlus.hasRole(MINTER_ROLE, USER_A));
        
        console.log("Operacoes administrativas concluidas!");
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Exemplo 4: Recuperacao de tokens
     * @dev Demonstra como recuperar tokens de enderecos nao autorizados
     */
    function recoveryExample() public {
        vm.startBroadcast();
        
        console.log("=== EXEMPLO: RECUPERACAO DE TOKENS ===");
        
        // Endereco nao autorizado que supostamente tem tokens
        address unauthorizedUser = 0x9999999999999999999999999999999999999999;
        
        // 1. Simular que um endereco nao autorizado tem tokens
        console.log("1. Simulando cenario de recuperacao...");
        console.log("(Em um cenario real, este endereco teria recebido tokens antes de ser removido da allowlist)");
        
        // 2. Verificar se o endereco esta na allowlist
        bool isInAllowlist = bbrlPlus.isInAllowlist(unauthorizedUser);
        console.log("Endereco esta na allowlist:", isInAllowlist);
        
        // 3. Verificar saldo do endereco nao autorizado
        uint256 unauthorizedBalance = bbrlPlus.balanceOf(unauthorizedUser);
        console.log("Saldo do endereco nao autorizado:", unauthorizedBalance);
        
        // 4. Se tiver saldo e nao estiver autorizado, recuperar
        if (unauthorizedBalance > 0 && !isInAllowlist) {
            console.log("4. Recuperando tokens...");
            bbrlPlus.recoverTokens(unauthorizedUser, "RECOVERY-001", unauthorizedBalance);
            console.log("Tokens recuperados com sucesso!");
        } else {
            console.log("4. Nenhuma recuperacao necessaria");
            if (unauthorizedBalance == 0) {
                console.log("   Motivo: Endereco nao tem saldo");
            }
            if (isInAllowlist) {
                console.log("   Motivo: Endereco esta autorizado");
            }
        }
        
        console.log("Verificacao de recuperacao concluida!");
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Exemplo 5: Consultas e relatorios
     * @dev Demonstra como obter informacoes completas do contrato
     */
    function queryExample() public view {
        console.log("=== EXEMPLO: CONSULTAS E RELATORIOS ===");
        
        // 1. Informacoes basicas do contrato
        console.log("1. INFORMACOES BASICAS:");
        console.log("   Nome:", bbrlPlus.name());
        console.log("   Simbolo:", bbrlPlus.symbol());
        console.log("   Decimais:", bbrlPlus.decimals());
        console.log("   Supply Total:", bbrlPlus.totalSupply());
        console.log("   Pausado:", bbrlPlus.paused());
        
        // 2. Informacoes da allowlist
        console.log("2. ALLOWLIST:");
        uint256 allowlistLength = bbrlPlus.getAllowlistLength();
        console.log("   Total de enderecos:", allowlistLength);
        
        if (allowlistLength > 0) {
            console.log("   Primeiros 3 enderecos:");
            uint256 maxToShow = allowlistLength > 3 ? 3 : allowlistLength;
            for (uint256 i = 0; i < maxToShow; i++) {
                address addr = bbrlPlus.getAllowlistAddress(i);
                uint256 balance = bbrlPlus.balanceOf(addr);
                console.log("     Endereco:", addr);
                console.log("     Saldo:", balance);
            }
        }
        
        // 3. Estatisticas de distribuicao
        console.log("3. ESTATISTICAS DE DISTRIBUICAO:");
        uint256 totalSupply = bbrlPlus.totalSupply();
        uint256 totalInAllowlist = 0;
        uint256 activeHolders = 0;
        
        for (uint256 i = 0; i < allowlistLength; i++) {
            address addr = bbrlPlus.getAllowlistAddress(i);
            uint256 balance = bbrlPlus.balanceOf(addr);
            totalInAllowlist += balance;
            if (balance > 0) {
                activeHolders++;
            }
        }
        
        console.log("   Total em enderecos autorizados:", totalInAllowlist);
        console.log("   Holders ativos:", activeHolders);
        
        if (totalSupply > 0) {
            uint256 percentage = (totalInAllowlist * 100) / totalSupply;
            console.log("   % do supply em enderecos autorizados:", percentage);
        }
        
        // 4. Verificacao de seguranca
        console.log("4. VERIFICACAO DE SEGURANCA:");
        console.log("   Contrato pausado:", bbrlPlus.paused());
        
        uint256 orphanedTokens = totalSupply - totalInAllowlist;
        if (orphanedTokens > 0) {
            console.log("   AVISO: Tokens em enderecos nao autorizados:", orphanedTokens);
        } else {
            console.log("   Todos os tokens em enderecos autorizados: OK");
        }
        
        console.log("Relatorio de consultas concluido!");
    }
    
    /**
     * @notice Exemplo 6: Workflow completo de onboarding de usuario
     * @dev Demonstra processo completo de adicionar novo usuario
     */
    function onboardingExample(address newUser) public {
        vm.startBroadcast();
        
        console.log("=== EXEMPLO: ONBOARDING DE USUARIO ===");
        console.log("Novo usuario:", newUser);
        
        // 1. Verificar se ja esta na allowlist
        bool alreadyInList = bbrlPlus.isInAllowlist(newUser);
        console.log("1. Usuario ja na allowlist:", alreadyInList);
        
        if (!alreadyInList) {
            // 2. Adicionar a allowlist
            console.log("2. Adicionando usuario a allowlist...");
            bbrlPlus.addToAllowlist(newUser);
            
            // 3. Mintar tokens iniciais
            console.log("3. Mintando tokens iniciais...");
            uint256 initialAmount = 100 * 10**18; // 100 tokens
            bbrlPlus.mintRef(newUser, initialAmount, "ONBOARDING-MINT");
            
            // 4. Verificar resultado
            console.log("4. Verificando resultado do onboarding...");
            console.log("   Na allowlist:", bbrlPlus.isInAllowlist(newUser));
            console.log("   Saldo:", bbrlPlus.balanceOf(newUser));
            
            console.log("Onboarding concluido com sucesso!");
        } else {
            console.log("Usuario ja esta na allowlist - onboarding nao necessario");
        }
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Exemplo 7: Workflow de queima de tokens
     * @dev Demonstra processo de queima controlada de tokens
     */
    function burnExample() public {
        vm.startBroadcast();
        
        console.log("=== EXEMPLO: QUEIMA DE TOKENS ===");
        
        // 1. Verificar supply atual
        uint256 supplyBefore = bbrlPlus.totalSupply();
        console.log("1. Supply antes da queima:", supplyBefore);
        
        // 2. Verificar saldo do usuario
        uint256 userBalance = bbrlPlus.balanceOf(USER_A);
        console.log("2. Saldo do USER_A:", userBalance);
        
        if (userBalance > 0) {
            // 3. Queimar parte dos tokens
            uint256 burnAmount = userBalance / 4; // 25% do saldo
            console.log("3. Queimando tokens...");
            console.log("   Quantidade:", burnAmount);
            
            bbrlPlus.burnFromRef(USER_A, "BURN-DEFLATION-001", burnAmount);
            
            // 4. Verificar resultado
            uint256 supplyAfter = bbrlPlus.totalSupply();
            uint256 userBalanceAfter = bbrlPlus.balanceOf(USER_A);
            
            console.log("4. Resultado da queima:");
            console.log("   Supply depois:", supplyAfter);
            console.log("   Supply reduzido em:", supplyBefore - supplyAfter);
            console.log("   Saldo do USER_A depois:", userBalanceAfter);
            
            console.log("Queima de tokens concluida com sucesso!");
        } else {
            console.log("3. Usuario nao tem tokens para queimar");
        }
        
        vm.stopBroadcast();
    }
}