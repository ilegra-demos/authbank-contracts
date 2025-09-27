// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {DEMOBR} from "../src/BBRLPlus.sol";

/**
 * @title Query BBRLPlus Script
 * @notice Script para consultar informacoes do contrato BBRLPlus
 * @dev Use este script para obter informacoes sobre balances, allowances e estado do contrato
 */
contract QueryBBRLPlus is Script {
    DEMOBR public bbrlPlus;
    
    // Endereco do contrato implantado - deve ser configurado antes de executar
    address public constant CONTRACT_ADDRESS = address(0); // Substitua pelo endereco real
    
    function setUp() public {
        // Conecta ao contrato ja implantado
        bbrlPlus = DEMOBR(CONTRACT_ADDRESS);
    }
    
    /**
     * @notice Funcao principal que executa as consultas
     */
    function run() public view {
        // Exemplo de uso - descomente as funcoes que desejar executar
        // getContractOverview();
    // getDenylistInfo();
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
    console.log("Tamanho da DenyList:", bbrlPlus.getDenylistLength());
        
        console.log("======================================");
    }
    
    /**
     * @notice Obtem informacoes detalhadas da deny list
     */
    function getDenylistInfo() public view {
        console.log("======================================");
        console.log("=== INFORMACOES DA DENYLIST ===");
        console.log("======================================");
        
        uint256 length = bbrlPlus.getDenylistLength();
        console.log("Total de enderecos na DenyList:", length);
        
        if (length > 0) {
            console.log("Enderecos na DenyList:");
            for (uint256 i = 0; i < length; i++) {
                address addr = bbrlPlus.getDenylistAddress(i);
                uint256 balance = bbrlPlus.balanceOf(addr);
                console.log("Indice:", i);
                console.log("Endereco:", addr);
                console.log("Saldo:", balance);
                console.log("---");
            }
        } else {
            console.log("Nenhum endereco na DenyList");
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
        
    bool isDeniedAddr = bbrlPlus.isDenied(account);
    console.log("Na DenyList:", isDeniedAddr);
        
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
        
    console.log("Owner na DenyList:", bbrlPlus.isDenied(owner));
    console.log("Spender na DenyList:", bbrlPlus.isDenied(spender));
        
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
        
    bool isDeniedAddr = bbrlPlus.isDenied(account);
    console.log("Na DenyList:", isDeniedAddr);
        
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
    console.log("  Transferir/Receber:", !isDeniedAddr);
        
        // Verificacoes de seguranca
        bool isPaused = bbrlPlus.paused();
        uint256 balance = bbrlPlus.balanceOf(account);
        
        console.log("Estado do contrato:");
        console.log("  Contrato pausado:", isPaused);
        console.log("  Saldo do endereco:", balance);
        
        if (isPaused) {
            console.log("AVISO: Contrato pausado - transferencias bloqueadas");
        }
        
        if (isDeniedAddr && balance > 0) {
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
    uint256 denylistLength = bbrlPlus.getDenylistLength();
        
        console.log("Supply Total:", totalSupply);
    console.log("Enderecos na DenyList:", denylistLength);
        
        if (denylistLength > 0) {
            uint256 totalBalanceDenied = 0;
            uint256 activeHolders = 0;
            
            for (uint256 i = 0; i < denylistLength; i++) {
                address addr = bbrlPlus.getDenylistAddress(i);
                uint256 balance = bbrlPlus.balanceOf(addr);
                totalBalanceDenied += balance;
                
                if (balance > 0) {
                    activeHolders++;
                }
            }
            
            console.log("Total de tokens em enderecos negados:", totalBalanceDenied);
            console.log("Holders ativos (com saldo > 0):", activeHolders);
            
            if (totalSupply > 0) {
                uint256 percentageDenied = (totalBalanceDenied * 100) / totalSupply;
                console.log("% do supply em enderecos negados:", percentageDenied, "%");
            }
            
            if (denylistLength > 0) {
                uint256 averageBalance = totalBalanceDenied / denylistLength;
                console.log("Saldo medio por endereco negado:", averageBalance);
            }
        } else {
            console.log("Nenhum endereco na DenyList");
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
        bool fromDenied = bbrlPlus.isDenied(from);
        bool toDenied = bbrlPlus.isDenied(to);
        uint256 fromBalance = bbrlPlus.balanceOf(from);
        
        console.log("Verificacoes:");
        console.log("  Contrato pausado:", isPaused);
    console.log("  From na DenyList:", fromDenied);
    console.log("  To na DenyList:", toDenied);
        console.log("  Saldo do From:", fromBalance);
        console.log("  Saldo suficiente:", fromBalance >= amount);
        
    bool canTransfer = !isPaused && !fromDenied && !toDenied && fromBalance >= amount;
        
        console.log("RESULTADO:");
        if (canTransfer) {
            console.log("  TRANSFERENCIA POSSIVEL [OK]");
        } else {
            console.log("  TRANSFERENCIA BLOQUEADA [ERRO]");
            
            if (isPaused) {
                console.log("  Motivo: Contrato pausado");
            }
            if (fromDenied) {
                console.log("  Motivo: Remetente negado");
            }
            if (toDenied) {
                console.log("  Motivo: Destinatario negado");
            }
            if (fromBalance < amount) {
                console.log("  Motivo: Saldo insuficiente");
            }
        }
        
        console.log("======================================");
    }
}