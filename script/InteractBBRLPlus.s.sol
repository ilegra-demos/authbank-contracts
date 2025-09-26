// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {BBRLPlus} from "../src/BBRLPlus.sol";

/**
 * @title Interact BBRLPlus Script
 * @notice Script para interagir com o contrato BBRLPlus implantado
 * @dev Use este script para realizar operações básicas com o token BBRLPlus
 */
contract InteractBBRLPlus is Script {
    BBRLPlus public bbrlPlus;
    
    // Endereço do contrato implantado - deve ser configurado antes de executar
    address public constant CONTRACT_ADDRESS = address(0); // Substitua pelo endereço real
    
    function setUp() public {
        // Conecta ao contrato já implantado
        bbrlPlus = BBRLPlus(CONTRACT_ADDRESS);
    }
    
    /**
     * @notice Função principal que executa as interações básicas
     */
    function run() public {
        vm.startBroadcast();
        
        // Exemplo de uso - descomente as funções que desejar executar
        // checkContractInfo();
        // mintTokens(0x1234567890123456789012345678901234567890, 1000 * 10**18, "MINT-001");
        // transferTokens(0x1234567890123456789012345678901234567890, 100 * 10**18, "TRANSFER-001");
        // burnTokens(0x1234567890123456789012345678901234567890, "BURN-001", 50 * 10**18);
        
        vm.stopBroadcast();
    }
    
    /**
     * @notice Verifica informações básicas do contrato
     */
    function checkContractInfo() public view {
        console.log("=== Informacoes do Contrato BBRLPlus ===");
        console.log("Nome:", bbrlPlus.name());
        console.log("Simbolo:", bbrlPlus.symbol());
        console.log("Decimais:", bbrlPlus.decimals());
        console.log("Supply Total:", bbrlPlus.totalSupply());
        console.log("Contrato pausado:", bbrlPlus.paused());
        console.log("Tamanho da AllowList:", bbrlPlus.getAllowlistLength());
    }
    
    /**
     * @notice Minta tokens para um endereco especifico
     * @param to Endereco que recebera os tokens
     * @param amount Quantidade de tokens a serem mintados
     * @param ref Referencia para rastreamento off-chain
     */
    function mintTokens(address to, uint256 amount, string memory ref) public {
        console.log("=== Mintando Tokens ===");
        console.log("Para:", to);
        console.log("Quantidade:", amount);
        console.log("Referencia:", ref);
        
        uint256 balanceBefore = bbrlPlus.balanceOf(to);
        console.log("Saldo antes:", balanceBefore);
        
        bbrlPlus.mintRef(to, amount, ref);
        
        uint256 balanceAfter = bbrlPlus.balanceOf(to);
        console.log("Saldo depois:", balanceAfter);
        console.log("Tokens mintados com sucesso!");
    }
    
    /**
     * @notice Transfere tokens com referencia
     * @param to Endereco de destino
     * @param amount Quantidade a ser transferida
     * @param ref Referencia para rastreamento off-chain
     */
    function transferTokens(address to, uint256 amount, string memory ref) public {
        console.log("=== Transferindo Tokens ===");
        console.log("Para:", to);
        console.log("Quantidade:", amount);
        console.log("Referencia:", ref);
        
        address sender = msg.sender;
        uint256 senderBalanceBefore = bbrlPlus.balanceOf(sender);
        uint256 receiverBalanceBefore = bbrlPlus.balanceOf(to);
        
        console.log("Saldo do remetente antes:", senderBalanceBefore);
        console.log("Saldo do destinatario antes:", receiverBalanceBefore);
        
        bbrlPlus.transferWithRef(to, amount, ref);
        
        uint256 senderBalanceAfter = bbrlPlus.balanceOf(sender);
        uint256 receiverBalanceAfter = bbrlPlus.balanceOf(to);
        
        console.log("Saldo do remetente depois:", senderBalanceAfter);
        console.log("Saldo do destinatario depois:", receiverBalanceAfter);
        console.log("Transferencia realizada com sucesso!");
    }
    
    /**
     * @notice Queima tokens de um endereco especifico
     * @param from Endereco de onde os tokens serao queimados
     * @param ref Referencia para rastreamento off-chain
     * @param amount Quantidade de tokens a serem queimados
     */
    function burnTokens(address from, string memory ref, uint256 amount) public {
        console.log("=== Queimando Tokens ===");
        console.log("De:", from);
        console.log("Quantidade:", amount);
        console.log("Referencia:", ref);
        
        uint256 balanceBefore = bbrlPlus.balanceOf(from);
        uint256 totalSupplyBefore = bbrlPlus.totalSupply();
        
        console.log("Saldo antes:", balanceBefore);
        console.log("Supply total antes:", totalSupplyBefore);
        
        bbrlPlus.burnFromRef(from, ref, amount);
        
        uint256 balanceAfter = bbrlPlus.balanceOf(from);
        uint256 totalSupplyAfter = bbrlPlus.totalSupply();
        
        console.log("Saldo depois:", balanceAfter);
        console.log("Supply total depois:", totalSupplyAfter);
        console.log("Tokens queimados com sucesso!");
    }
    
    /**
     * @notice Verifica se um endereco esta na allowlist
     * @param account Endereco a ser verificado
     */
    function checkAllowlist(address account) public view {
        bool isAllowed = bbrlPlus.isInAllowlist(account);
        console.log("=== Verificacao da AllowList ===");
        console.log("Endereco:", account);
        console.log("Esta na AllowList:", isAllowed);
    }
    
    /**
     * @notice Lista todos os enderecos na allowlist
     */
    function listAllowlist() public view {
        console.log("=== Lista da AllowList ===");
        uint256 length = bbrlPlus.getAllowlistLength();
        console.log("Total de enderecos:", length);
        
        for (uint256 i = 0; i < length; i++) {
            address addr = bbrlPlus.getAllowlistAddress(i);
            console.log("Indice", i, ":", addr);
        }
    }
    
    /**
     * @notice Verifica o saldo de um endereco
     * @param account Endereco a ser consultado
     */
    function checkBalance(address account) public view {
        uint256 balance = bbrlPlus.balanceOf(account);
        console.log("=== Consulta de Saldo ===");
        console.log("Endereco:", account);
        console.log("Saldo:", balance);
        console.log("Saldo formatado:", balance / 10**bbrlPlus.decimals());
    }
    
    /**
     * @notice Verifica as permissoes de um endereco
     * @param account Endereco a ser verificado
     */
    function checkRoles(address account) public view {
        console.log("=== Verificacao de Permissoes ===");
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
    }
}