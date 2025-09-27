// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {DEMOBR} from "../src/BBRLPlus.sol";

/**
 * @title Admin BBRLPlus Script
 * @notice Script para funcoes administrativas do contrato BBRLPlus
 * @dev Use este script para gerenciar roles, denylist e operacoes administrativas
 */
contract AdminBBRLPlus is Script {
    DEMOBR public bbrlPlus;
    
    // Endereco do contrato implantado - deve ser configurado antes de executar
    address public constant CONTRACT_ADDRESS = address(0); // Substitua pelo endereco real
    
    function setUp() public {
        // Conecta ao contrato ja implantado
        bbrlPlus = DEMOBR(CONTRACT_ADDRESS);
    }
    
    /**
     * @notice Funcao principal que executa as operacoes administrativas
     */
    function run() public {
        vm.startBroadcast();
        
        // Exemplo de uso - descomente as funcoes que desejar executar
        // grantMinterRole(0x1234567890123456789012345678901234567890);
    // addToDenylist(0x1234567890123456789012345678901234567890); // exemplo: negar um endereco
        // pauseContract();
        // unpauseContract();
        // recoverTokens(0x1234567890123456789012345678901234567890, "RECOVERY-001", 100 * 10**18);
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Concede role de MINTER para um endereco
     * @param account Endereco que recebera a role
     */
    function grantMinterRole(address account) public {
        console.log("=== Concedendo Role de Minter ===");
        console.log("Endereco:", account);
        
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(MINTER_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.grantRole(MINTER_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(MINTER_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Minter concedida com sucesso!");
    }
    
    /**
     * @notice Concede role de BURNER para um endereco
     * @param account Endereco que recebera a role
     */
    function grantBurnerRole(address account) public {
        console.log("=== Concedendo Role de Burner ===");
        console.log("Endereco:", account);
        
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(BURNER_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.grantRole(BURNER_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(BURNER_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Burner concedida com sucesso!");
    }
    
    /**
     * @notice Concede role de PAUSER para um endereco
     * @param account Endereco que recebera a role
     */
    function grantPauserRole(address account) public {
        console.log("=== Concedendo Role de Pauser ===");
        console.log("Endereco:", account);
        
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(PAUSER_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.grantRole(PAUSER_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(PAUSER_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Pauser concedida com sucesso!");
    }
    
    /**
     * @notice Concede role de RECOVERY para um endereco
     * @param account Endereco que recebera a role
     */
    function grantRecoveryRole(address account) public {
        console.log("=== Concedendo Role de Recovery ===");
        console.log("Endereco:", account);
        
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(RECOVERY_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.grantRole(RECOVERY_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(RECOVERY_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Recovery concedida com sucesso!");
    }
    
    /**
     * @notice Revoga role de MINTER de um endereco
     * @param account Endereco que tera a role revogada
     */
    function revokeMinterRole(address account) public {
        console.log("=== Revogando Role de Minter ===");
        console.log("Endereco:", account);
        
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(MINTER_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.revokeRole(MINTER_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(MINTER_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Minter revogada com sucesso!");
    }
    
    /**
     * @notice Revoga role de BURNER de um endereco
     * @param account Endereco que tera a role revogada
     */
    function revokeBurnerRole(address account) public {
        console.log("=== Revogando Role de Burner ===");
        console.log("Endereco:", account);
        
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(BURNER_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.revokeRole(BURNER_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(BURNER_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Burner revogada com sucesso!");
    }
    
    /**
     * @notice Revoga role de PAUSER de um endereco
     * @param account Endereco que tera a role revogada
     */
    function revokePauserRole(address account) public {
        console.log("=== Revogando Role de Pauser ===");
        console.log("Endereco:", account);
        
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(PAUSER_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.revokeRole(PAUSER_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(PAUSER_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Pauser revogada com sucesso!");
    }
    
    /**
     * @notice Revoga role de RECOVERY de um endereco
     * @param account Endereco que tera a role revogada
     */
    function revokeRecoveryRole(address account) public {
        console.log("=== Revogando Role de Recovery ===");
        console.log("Endereco:", account);
        
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        bool hadRole = bbrlPlus.hasRole(RECOVERY_ROLE, account);
        console.log("Tinha role antes:", hadRole);
        
        bbrlPlus.revokeRole(RECOVERY_ROLE, account);
        
        bool hasRoleNow = bbrlPlus.hasRole(RECOVERY_ROLE, account);
        console.log("Tem role agora:", hasRoleNow);
        console.log("Role de Recovery revogada com sucesso!");
    }
    
    /**
     * @notice Adiciona um endereco a deny list (bloqueia transferencias)
     * @param account Endereco a ser adicionado
     */
    function addToDenylist(address account) public {
        console.log("=== Adicionando a DenyList ===");
        console.log("Endereco:", account);
        
        bool wasInList = bbrlPlus.isDenied(account);
        console.log("Estava na lista antes:", wasInList);
        
        bbrlPlus.addToDenylist(account);
        
        bool isInListNow = bbrlPlus.isDenied(account);
        console.log("Esta na lista agora:", isInListNow);
        console.log("Endereco adicionado a DenyList com sucesso!");
    }
    
    /**
     * @notice Remove um endereco da deny list (volta a poder transferir/receber)
     * @param account Endereco a ser removido
     */
    function removeFromDenylist(address account) public {
        console.log("=== Removendo da DenyList ===");
        console.log("Endereco:", account);
        
        bool wasInList = bbrlPlus.isDenied(account);
        console.log("Estava na lista antes:", wasInList);
        
        bbrlPlus.removeFromDenylist(account);
        
        bool isInListNow = bbrlPlus.isDenied(account);
        console.log("Esta na lista agora:", isInListNow);
        console.log("Endereco removido da DenyList com sucesso!");
    }
    
    /**
     * @notice Pausa o contrato
     */
    function pauseContract() public {
        console.log("=== Pausando Contrato ===");
        
        bool wasPaused = bbrlPlus.paused();
        console.log("Estava pausado antes:", wasPaused);
        
        bbrlPlus.pause();
        
        bool isPausedNow = bbrlPlus.paused();
        console.log("Esta pausado agora:", isPausedNow);
        console.log("Contrato pausado com sucesso!");
    }
    
    /**
     * @notice Despausa o contrato
     */
    function unpauseContract() public {
        console.log("=== Despausando Contrato ===");
        
        bool wasPaused = bbrlPlus.paused();
        console.log("Estava pausado antes:", wasPaused);
        
        bbrlPlus.unpause();
        
        bool isPausedNow = bbrlPlus.paused();
        console.log("Esta pausado agora:", isPausedNow);
        console.log("Contrato despausado com sucesso!");
    }
    
    /**
     * @notice Recupera tokens de um endereco nao autorizado
     * @param account Endereco de onde recuperar os tokens
     * @param ref Referencia para rastreamento off-chain
     * @param amount Quantidade de tokens a serem recuperados
     */
    function recoverTokens(address account, string memory ref, uint256 amount) public {
        console.log("=== Recuperando Tokens ===");
        console.log("De:", account);
        console.log("Quantidade:", amount);
        console.log("Referencia:", ref);
        
        uint256 balanceBefore = bbrlPlus.balanceOf(account);
        uint256 recovererBalanceBefore = bbrlPlus.balanceOf(msg.sender);
        
        console.log("Saldo do endereco antes:", balanceBefore);
        console.log("Saldo do recuperador antes:", recovererBalanceBefore);
        
        bbrlPlus.recoverTokens(account, ref, amount);
        
        uint256 balanceAfter = bbrlPlus.balanceOf(account);
        uint256 recovererBalanceAfter = bbrlPlus.balanceOf(msg.sender);
        
        console.log("Saldo do endereco depois:", balanceAfter);
        console.log("Saldo do recuperador depois:", recovererBalanceAfter);
        console.log("Tokens recuperados com sucesso!");
    }
    
    /**
     * @notice Adiciona multiplos enderecos a deny list
     * @param accounts Array de enderecos a serem adicionados
     */
    function addMultipleToDenylist(address[] memory accounts) public {
        console.log("=== Adicionando Multiplos Enderecos a DenyList ===");
        console.log("Quantidade de enderecos:", accounts.length);
        
        for (uint256 i = 0; i < accounts.length; i++) {
            console.log("Adicionando endereco", i, ":", accounts[i]);
            bbrlPlus.addToDenylist(accounts[i]);
        }
        
        console.log("Todos os enderecos adicionados com sucesso!");
    }
    
    /**
     * @notice Remove multiplos enderecos da deny list
     * @param accounts Array de enderecos a serem removidos
     */
    function removeMultipleFromDenylist(address[] memory accounts) public {
        console.log("=== Removendo Multiplos Enderecos da DenyList ===");
        console.log("Quantidade de enderecos:", accounts.length);
        
        for (uint256 i = 0; i < accounts.length; i++) {
            console.log("Removendo endereco", i, ":", accounts[i]);
            bbrlPlus.removeFromDenylist(accounts[i]);
        }
        
        console.log("Todos os enderecos removidos com sucesso!");
    }
    
    /**
     * @notice Verifica todas as roles de um endereco
     * @param account Endereco a ser verificado
     */
    function checkAllRoles(address account) public view {
        console.log("=== Verificacao Completa de Roles ===");
        console.log("Endereco:", account);
        
        bytes32 DEFAULT_ADMIN_ROLE = bbrlPlus.DEFAULT_ADMIN_ROLE();
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        console.log("Default Admin:", bbrlPlus.hasRole(DEFAULT_ADMIN_ROLE, account));
        console.log("Pauser:", bbrlPlus.hasRole(PAUSER_ROLE, account));
        console.log("Minter:", bbrlPlus.hasRole(MINTER_ROLE, account));
        console.log("Burner:", bbrlPlus.hasRole(BURNER_ROLE, account));
        console.log("Recovery:", bbrlPlus.hasRole(RECOVERY_ROLE, account));
        console.log("Na DenyList:", bbrlPlus.isDenied(account));
    }
}