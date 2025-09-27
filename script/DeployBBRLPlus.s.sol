// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {DEMOBR} from "../src/BBRLPlus.sol";

/**
 * @title Deploy BBRLPlus Script
 * @notice Script para implantar o contrato BBRLPlus
 * @dev Configure os enderecos das roles antes de executar o deploy
 */
contract DeployBBRLPlus is Script {
    
    // Configuracao dos enderecos das roles - MODIFIQUE ANTES DO DEPLOY
    address public constant DEFAULT_ADMIN = 0xb5d6B26818A777Aff58C46C297458fFa6fdd2426;
    address public constant PAUSER = 0xeB6197375Bc88A8E6673b909F4E3B6Ee3ead8255;
    address public constant MINTER = 0xE4055E9875087ee2a6d93Fd6268d12e4Bd6551B3;
    address public constant BURNER = 0x26Df3718044BEF34e7bdB9FbEf26771F5d1fa51a;
    address public constant RECOVERY = 0x8ca109d240976eAAE8D0AFc0cf61B9a1BEBD0711;
    
    // Configuracao do token
    string public constant TOKEN_NAME = "DEMO BR";
    string public constant TOKEN_SYMBOL = "DEMOBR";
    
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        console.log("=== INICIANDO DEPLOY DO Reward BR ===");
        console.log("Configuracao:");
        console.log("  Nome:", TOKEN_NAME);
        console.log("  Simbolo:", TOKEN_SYMBOL);
        console.log("  Default Admin:", DEFAULT_ADMIN);
        console.log("  Pauser:", PAUSER);
        console.log("  Minter:", MINTER);
        console.log("  Burner:", BURNER);
        console.log("  Recovery:", RECOVERY);

        // Deploy do contrato
        DEMOBR bbrlPlus = new DEMOBR(
            DEFAULT_ADMIN,  // defaultAdmin
            PAUSER,         // pauser
            MINTER,         // minter
            BURNER,         // burner
            RECOVERY,       // recovery
            TOKEN_NAME,     // name
            TOKEN_SYMBOL    // symbol
        );

        console.log("=== DEPLOY CONCLUIDO ===");
        console.log("Endereco do contrato:", address(bbrlPlus));
        console.log("Supply inicial:", bbrlPlus.totalSupply());
        console.log("Contrato pausado:", bbrlPlus.paused());
        console.log("Denylist vazia:", bbrlPlus.getDenylistLength() == 0);

        // Verificar roles atribuidas
        console.log("=== VERIFICACAO DE ROLES ===");
        bytes32 DEFAULT_ADMIN_ROLE = bbrlPlus.DEFAULT_ADMIN_ROLE();
        bytes32 PAUSER_ROLE = bbrlPlus.PAUSER_ROLE();
        bytes32 MINTER_ROLE = bbrlPlus.MINTER_ROLE();
        bytes32 BURNER_ROLE = bbrlPlus.BURNER_ROLE();
        bytes32 RECOVERY_ROLE = bbrlPlus.RECOVERY_ROLE();
        
        console.log("Default Admin role:", bbrlPlus.hasRole(DEFAULT_ADMIN_ROLE, DEFAULT_ADMIN));
        console.log("Pauser role:", bbrlPlus.hasRole(PAUSER_ROLE, PAUSER));
        console.log("Minter role:", bbrlPlus.hasRole(MINTER_ROLE, MINTER));
        console.log("Burner role:", bbrlPlus.hasRole(BURNER_ROLE, BURNER));
        console.log("Recovery role:", bbrlPlus.hasRole(RECOVERY_ROLE, RECOVERY));

        console.log("=== DEPLOY FINALIZADO COM SUCESSO ===");
        console.log("IMPORTANTE: Salve o endereco do contrato para usar nos outros scripts!");
        console.log("Endereco do BBRLPlus:", address(bbrlPlus));

        vm.stopBroadcast();
    }

    /**
     * @notice Funcao para implantar com configuracao customizada
     * @param defaultAdmin Endereco do administrador principal
     * @param pauser Endereco com permissao de pausar
     * @param minter Endereco com permissao de mintar
     * @param burner Endereco com permissao de queimar
     * @param recovery Endereco com permissao de recuperar
     * @param name Nome do token
     * @param symbol Simbolo do token
     */
    function deployCustom(
        address defaultAdmin,
        address pauser,
        address minter,
        address burner,
        address recovery,
        string memory name,
        string memory symbol
    ) public returns (address) {
        vm.startBroadcast();

        console.log("=== DEPLOY CUSTOMIZADO DO BBRLPLUS ===");
        
        DEMOBR bbrlPlus = new DEMOBR(
            defaultAdmin,
            pauser,
            minter,
            burner,
            recovery,
            name,
            symbol
        );

        console.log("Contrato implantado em:", address(bbrlPlus));

        vm.stopBroadcast();
        
        return address(bbrlPlus);
    }
}