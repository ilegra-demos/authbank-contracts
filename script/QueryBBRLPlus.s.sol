// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {BBRLPlus} from "../src/BBRLPlus.sol";

/**
 * @title Query BBRLPlus Script
 * @notice Script para consultar informacoes do contrato BBRLPlus
 * @dev Use este script para obter informacoes sobre balances, allowances e estado do contrato
 */
contract QueryBBRLPlus is Script {
    BBRLPlus public bbrlPlus;
    
    // Endereco do contrato implantado - deve ser configurado antes de executar
    address public constant CONTRACT_ADDRESS = address(0); // Substitua pelo endereco real
    
    function setUp() public {
        // Conecta ao contrato ja implantado
        bbrlPlus = BBRLPlus(CONTRACT_ADDRESS);
    }
    
    /**
     * @notice Funcao principal que executa as consultas
     */
    function run() public view {
        // Exemplo de uso - descomente as funcoes que desejar executar
        // getContractOverview();
        // getAllowlistInfo();
        // getRolesInfo();
        // getBalanceInfo(0x1234567890123456789012345678901234567890);
        // getAllowanceInfo(0x1234567890123456789012345678901234567890, 0x0987654321098765432109876543210987654321);
    }
    
    /**
     * @notice Obtem uma visao geral do contrato
     */
    function getContractOverview() public view {
        console.log("======================================");
        console.log("=== VISAO GERAL DO CONTRATO BBRLPlus ===");
        console.log("======================================");
        
        console.log("Nome do Token:", bbrlPlus.name());
        console.log("Simbolo:", bbrlPlus.symbol());
        console.log("Decimais:", bbrlPlus.decimals());
        console.log("Supply Total:", bbrlPlus.totalSupply());
        
        uint256 formattedSupply = bbrlPlus.totalSupply() / (10 ** bbrlPlus.decimals());
        console.log("Supply Total Formatado:", formattedSupply);
        
        console.log("Contrato Pausado:", bbrlPlus.paused());
        console.log("Tamanho da AllowList:", bbrlPlus.getAllowlistLength());
        
        console.log("======================================");
    }
    
    /**
     * @notice Obtem informacoes detalhadas da allowlist
     */
    function getAllowlistInfo() public view {
        console.log("======================================");
        console.log("=== INFORMACOES DA ALLOWLIST ===");
        console.log("======================================");
        
        uint256 length = bbrlPlus.getAllowlistLength();
        console.log("Total de enderecos na AllowList:", length);
        
        if (length > 0) {
            console.log("Enderecos na AllowList:");
            for (uint256 i = 0; i < length; i++) {
                address addr = bbrlPlus.getAllowlistAddress(i);
                uint256 balance = bbrlPlus.balanceOf(addr);
                console.log("Indice:", i);
                console.log("Endereco:", addr);
                console.log("Saldo:", balance);
                console.log("---");
            }
        } else {
            console.log("Nenhum endereco na AllowList");
        }
        
        console.log("======================================");
    }
    
    /**
     * @notice Obtem informacoes sobre as roles do contrato
     */
    function getRolesInfo() public view {
        console.log("======================================");
        console.log("=== INFORMACOES DAS ROLES ===");
        console.log("======================================");
        
        bytes32 DEFAULT_ADMIN_ROLE = bbrlPlus.DEFAULT_ADMIN_ROLE();
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        console.log("DEFAULT_ADMIN_ROLE:");
        console.logBytes32(DEFAULT_ADMIN_ROLE);
        
        console.log("PAUSER_ROLE:");
        console.logBytes32(PAUSER_ROLE);
        
        console.log("MINTER_ROLE:");
        console.logBytes32(MINTER_ROLE);
        
        console.log("BURNER_ROLE:");
        console.logBytes32(BURNER_ROLE);
        
        console.log("RECOVERY_ROLE:");
        console.logBytes32(RECOVERY_ROLE);
        
        console.log("======================================");
    }
    
    /**
     * @notice Obtem informacoes detalhadas de saldo de um endereco
     * @param account Endereco a ser consultado
     */
    function getBalanceInfo(address account) public view {
        console.log("======================================");
        console.log("=== INFORMACOES DE SALDO ===");
        console.log("======================================");
        
        console.log("Endereco:", account);
        
        uint256 balance = bbrlPlus.balanceOf(account);
        console.log("Saldo (wei):", balance);
        
        if (balance > 0) {
            uint256 formattedBalance = balance / (10 ** bbrlPlus.decimals());
            console.log("Saldo Formatado:", formattedBalance);
            
            uint256 totalSupply = bbrlPlus.totalSupply();
            if (totalSupply > 0) {
                uint256 percentage = (balance * 100) / totalSupply;
                console.log("Porcentagem do Supply:", percentage, "%");
            }
        } else {
            console.log("Saldo: 0 (sem tokens)");
        }
        
        bool inAllowlist = bbrlPlus.isInAllowlist(account);
        console.log("Na AllowList:", inAllowlist);
        
        // Verificar roles
        bytes32 DEFAULT_ADMIN_ROLE = bbrlPlus.DEFAULT_ADMIN_ROLE();
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        console.log("Roles do endereco:");
        console.log("  Default Admin:", bbrlPlus.hasRole(DEFAULT_ADMIN_ROLE, account));
        console.log("  Pauser:", bbrlPlus.hasRole(PAUSER_ROLE, account));
        console.log("  Minter:", bbrlPlus.hasRole(MINTER_ROLE, account));
        console.log("  Burner:", bbrlPlus.hasRole(BURNER_ROLE, account));
        console.log("  Recovery:", bbrlPlus.hasRole(RECOVERY_ROLE, account));
        
        console.log("======================================");
    }
    
    /**
     * @notice Obtem informacoes de allowance entre dois enderecos
     * @param owner Endereco do proprietario dos tokens
     * @param spender Endereco autorizado a gastar os tokens
     */
    function getAllowanceInfo(address owner, address spender) public view {
        console.log("======================================");
        console.log("=== INFORMACOES DE ALLOWANCE ===");
        console.log("======================================");
        
        console.log("Proprietario:", owner);
        console.log("Gastador:", spender);
        
        uint256 allowance = bbrlPlus.allowance(owner, spender);
        console.log("Allowance (wei):", allowance);
        
        if (allowance > 0) {
            uint256 formattedAllowance = allowance / (10 ** bbrlPlus.decimals());
            console.log("Allowance Formatado:", formattedAllowance);
            
            uint256 ownerBalance = bbrlPlus.balanceOf(owner);
            if (ownerBalance > 0) {
                uint256 percentage = (allowance * 100) / ownerBalance;
                console.log("Porcentagem do Saldo do Owner:", percentage, "%");
            }
        } else {
            console.log("Allowance: 0 (sem autorizacao)");
        }
        
        console.log("Owner na AllowList:", bbrlPlus.isInAllowlist(owner));
        console.log("Spender na AllowList:", bbrlPlus.isInAllowlist(spender));
        
        console.log("======================================");
    }
    
    /**
     * @notice Verifica se um endereco pode realizar operacoes especificas
     * @param account Endereco a ser verificado
     */
    function checkPermissions(address account) public view {
        console.log("======================================");
        console.log("=== VERIFICACAO DE PERMISSOES ===");
        console.log("======================================");
        
        console.log("Endereco:", account);
        
        bool inAllowlist = bbrlPlus.isInAllowlist(account);
        console.log("Na AllowList:", inAllowlist);
        
        bytes32 DEFAULT_ADMIN_ROLE = bbrlPlus.DEFAULT_ADMIN_ROLE();
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        bool isAdmin = bbrlPlus.hasRole(DEFAULT_ADMIN_ROLE, account);
        bool canPause = bbrlPlus.hasRole(PAUSER_ROLE, account);
        bool canMint = bbrlPlus.hasRole(MINTER_ROLE, account);
        bool canBurn = bbrlPlus.hasRole(BURNER_ROLE, account);
        bool canRecover = bbrlPlus.hasRole(RECOVERY_ROLE, account);
        
        console.log("Pode fazer:");
        console.log("  Administrar contrato:", isAdmin);
        console.log("  Pausar/Despausar:", canPause);
        console.log("  Mintar tokens:", canMint);
        console.log("  Queimar tokens:", canBurn);
        console.log("  Recuperar tokens:", canRecover);
        console.log("  Transferir/Receber:", inAllowlist);
        
        // Verificacoes de seguranca
        bool isPaused = bbrlPlus.paused();
        uint256 balance = bbrlPlus.balanceOf(account);
        
        console.log("Estado do contrato:");
        console.log("  Contrato pausado:", isPaused);
        console.log("  Saldo do endereco:", balance);
        
        if (isPaused) {
            console.log("AVISO: Contrato pausado - transferencias bloqueadas");
        }
        
        if (!inAllowlist && balance > 0) {
            console.log("AVISO: Endereco com saldo mas nao autorizado - tokens podem ser recuperados");
        }
        
        console.log("======================================");
    }
    
    /**
     * @notice Obtem estatisticas gerais do contrato
     */
    function getContractStats() public view {
        console.log("======================================");
        console.log("=== ESTATISTICAS DO CONTRATO ===");
        console.log("======================================");
        
        uint256 totalSupply = bbrlPlus.totalSupply();
        uint256 allowlistLength = bbrlPlus.getAllowlistLength();
        
        console.log("Supply Total:", totalSupply);
        console.log("Enderecos na AllowList:", allowlistLength);
        
        if (allowlistLength > 0) {
            uint256 totalBalanceInAllowlist = 0;
            uint256 activeHolders = 0;
            
            for (uint256 i = 0; i < allowlistLength; i++) {
                address addr = bbrlPlus.getAllowlistAddress(i);
                uint256 balance = bbrlPlus.balanceOf(addr);
                totalBalanceInAllowlist += balance;
                
                if (balance > 0) {
                    activeHolders++;
                }
            }
            
            console.log("Total de tokens em enderecos autorizados:", totalBalanceInAllowlist);
            console.log("Holders ativos (com saldo > 0):", activeHolders);
            
            if (totalSupply > 0) {
                uint256 percentageInAllowlist = (totalBalanceInAllowlist * 100) / totalSupply;
                console.log("% do supply em enderecos autorizados:", percentageInAllowlist, "%");
            }
            
            if (allowlistLength > 0) {
                uint256 averageBalance = totalBalanceInAllowlist / allowlistLength;
                console.log("Saldo medio por endereco autorizado:", averageBalance);
            }
        } else {
            console.log("Nenhum endereco na AllowList");
        }
        
        bool isPaused = bbrlPlus.paused();
        console.log("Status do contrato:", isPaused ? "PAUSADO" : "ATIVO");
        
        console.log("======================================");
    }
    
    /**
     * @notice Simula uma transferencia para verificar se seria bem-sucedida
     * @param from Endereco de origem
     * @param to Endereco de destino
     * @param amount Quantidade a ser transferida
     */
    function simulateTransfer(address from, address to, uint256 amount) public view {
        console.log("======================================");
        console.log("=== SIMULACAO DE TRANSFERENCIA ===");
        console.log("======================================");
        
        console.log("De:", from);
        console.log("Para:", to);
        console.log("Quantidade:", amount);
        
        // Verificacoes
        bool isPaused = bbrlPlus.paused();
        bool fromInAllowlist = bbrlPlus.isInAllowlist(from);
        bool toInAllowlist = bbrlPlus.isInAllowlist(to);
        uint256 fromBalance = bbrlPlus.balanceOf(from);
        
        console.log("Verificacoes:");
        console.log("  Contrato pausado:", isPaused);
        console.log("  From na AllowList:", fromInAllowlist);
        console.log("  To na AllowList:", toInAllowlist);
        console.log("  Saldo do From:", fromBalance);
        console.log("  Saldo suficiente:", fromBalance >= amount);
        
        bool canTransfer = !isPaused && fromInAllowlist && toInAllowlist && fromBalance >= amount;
        
        console.log("RESULTADO:");
        if (canTransfer) {
            console.log("  TRANSFERENCIA POSSIVEL [OK]");
        } else {
            console.log("  TRANSFERENCIA BLOQUEADA [ERRO]");
            
            if (isPaused) {
                console.log("  Motivo: Contrato pausado");
            }
            if (!fromInAllowlist) {
                console.log("  Motivo: Remetente nao autorizado");
            }
            if (!toInAllowlist) {
                console.log("  Motivo: Destinatario nao autorizado");
            }
            if (fromBalance < amount) {
                console.log("  Motivo: Saldo insuficiente");
            }
        }
        
        console.log("======================================");
    }
}