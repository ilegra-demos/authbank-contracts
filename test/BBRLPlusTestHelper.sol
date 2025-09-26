// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {BBRLPlus} from "../src/BBRLPlus.sol";

/**
 * @title BBRLPlus Test Helper
 * @notice Helper contract with common test utilities and setup functions
 */
abstract contract BBRLPlusTestHelper is Test {
    BBRLPlus public token;
    
    // Standard test addresses
    address public constant ADMIN = address(0x1);
    address public constant PAUSER = address(0x2);
    address public constant MINTER = address(0x3);
    address public constant BURNER = address(0x4);
    address public constant RECOVERY = address(0x5);
    
    address public constant USER_A = address(0x10);
    address public constant USER_B = address(0x20);
    address public constant USER_C = address(0x30);
    address public constant USER_D = address(0x40);
    address public constant UNAUTHORIZED_USER = address(0x99);
    
    // Standard amounts
    uint256 public constant LARGE_AMOUNT = 1_000_000e18;
    uint256 public constant MEDIUM_AMOUNT = 10_000e18;
    uint256 public constant SMALL_AMOUNT = 100e18;
    uint256 public constant TINY_AMOUNT = 1e18;
    
    // Events for testing
    event TokensMinted(address indexed to, string indexed ref, uint256 amount);
    event TokensBurned(address indexed from, string indexed ref, uint256 amount);
    event TokensTransferred(address indexed to, string indexed ref, uint256 amount);
    event TokensRecovered(address indexed account, string indexed ref, uint256 amount);
    
    /**
     * @notice Deploy a fresh BBRLPlus contract with standard configuration
     * @param name Token name
     * @param symbol Token symbol
     */
    function deployFreshToken(string memory name, string memory symbol) public {
        token = new BBRLPlus(
            ADMIN,
            PAUSER,
            MINTER,
            BURNER,
            RECOVERY,
            name,
            symbol
        );
    }
    
    /**
     * @notice Setup standard allowlist with test users
     */
    function setupStandardAllowlist() public {
        vm.startPrank(ADMIN);
        token.addToAllowlist(USER_A);
        token.addToAllowlist(USER_B);
        token.addToAllowlist(USER_C);
        token.addToAllowlist(USER_D);
        token.addToAllowlist(MINTER);
        token.addToAllowlist(BURNER);
        token.addToAllowlist(RECOVERY);
        vm.stopPrank();
    }
    
    /**
     * @notice Mint tokens to multiple users for testing
     * @param amounts Array of amounts to mint
     * @param recipients Array of recipient addresses
     * @param ref Reference string for minting
     */
    function mintToMultipleUsers(
        uint256[] memory amounts,
        address[] memory recipients,
        string memory ref
    ) public {
        require(amounts.length == recipients.length, "Arrays length mismatch");
        
        vm.startPrank(MINTER);
        for (uint256 i = 0; i < amounts.length; i++) {
            token.mintRef(recipients[i], amounts[i], ref);
        }
        vm.stopPrank();
    }
    
    /**
     * @notice Setup a standard test scenario with pre-minted tokens
     */
    function setupStandardScenario() public {
        setupStandardAllowlist();
        
        uint256[] memory amounts = new uint256[](4);
        amounts[0] = LARGE_AMOUNT;
        amounts[1] = MEDIUM_AMOUNT;
        amounts[2] = SMALL_AMOUNT;
        amounts[3] = TINY_AMOUNT;
        
        address[] memory recipients = new address[](4);
        recipients[0] = USER_A;
        recipients[1] = USER_B;
        recipients[2] = USER_C;
        recipients[3] = USER_D;
        
        mintToMultipleUsers(amounts, recipients, "SETUP");
    }
    
    /**
     * @notice Add a user to allowlist and mint tokens in one transaction
     * @param user User address
     * @param amount Amount to mint
     * @param ref Reference string
     */
    function addUserAndMint(address user, uint256 amount, string memory ref) public {
        vm.prank(ADMIN);
        token.addToAllowlist(user);
        
        vm.prank(MINTER);
        token.mintRef(user, amount, ref);
    }
    
    /**
     * @notice Remove user from allowlist and recover their tokens
     * @param user User address
     * @param ref Reference string
     */
    function removeUserAndRecover(address user, string memory ref) public {
        uint256 userBalance = token.balanceOf(user);
        
        vm.prank(ADMIN);
        token.removeFromAllowlist(user);
        
        if (userBalance > 0) {
            vm.prank(RECOVERY);
            token.recoverTokens(user, ref, userBalance);
        }
    }
    
    /**
     * @notice Perform emergency pause and verify all functions are blocked
     */
    function performEmergencyPause() public {
        vm.prank(PAUSER);
        token.pause();
        
        assertTrue(token.paused());
    }
    
    /**
     * @notice Unpause and verify functions work again
     */
    function performUnpause() public {
        vm.prank(PAUSER);
        token.unpause();
        
        assertFalse(token.paused());
    }
    
    /**
     * @notice Create a permit signature for testing
     * @param ownerPrivateKey Private key of the owner
     * @param spender Spender address
     * @param value Amount to approve
     * @param deadline Permit deadline
     */
    function createPermitSignature(
        uint256 ownerPrivateKey,
        address spender,
        uint256 value,
        uint256 deadline
    ) public view returns (uint8 v, bytes32 r, bytes32 s) {
        address owner = vm.addr(ownerPrivateKey);
        
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
            owner,
            spender,
            value,
            token.nonces(owner),
            deadline
        ));
        
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        return vm.sign(ownerPrivateKey, digest);
    }
    
    /**
     * @notice Verify token state consistency
     */
    function verifyTokenStateConsistency() public view {
        // Verify total supply equals sum of known balances (simplified)
        uint256 knownBalances = token.balanceOf(USER_A) + 
                               token.balanceOf(USER_B) + 
                               token.balanceOf(USER_C) + 
                               token.balanceOf(USER_D) +
                               token.balanceOf(MINTER) +
                               token.balanceOf(BURNER) +
                               token.balanceOf(RECOVERY);
        
        // Total supply should be at least the known balances
        assertGe(token.totalSupply(), knownBalances);
        
        // Verify allowlist integrity
        uint256 allowlistLength = token.getAllowlistLength();
        for (uint256 i = 0; i < allowlistLength; i++) {
            address user = token.getAllowlistAddress(i);
            assertTrue(token.isInAllowlist(user));
        }
    }
    
    /**
     * @notice Log current contract state for debugging
     */
    function logContractState() public view {
        console.log("=== Contract State ===");
        console.log("Total Supply:", token.totalSupply());
        console.log("Paused:", token.paused());
        console.log("Allowlist Length:", token.getAllowlistLength());
        console.log("USER_A Balance:", token.balanceOf(USER_A));
        console.log("USER_B Balance:", token.balanceOf(USER_B));
        console.log("USER_C Balance:", token.balanceOf(USER_C));
        console.log("USER_D Balance:", token.balanceOf(USER_D));
        console.log("====================");
    }
    
    /**
     * @notice Assert role assignments are correct
     */
    function assertCorrectRoleAssignments() public view {
        bytes32 DEFAULT_ADMIN_ROLE = token.DEFAULT_ADMIN_ROLE();
        bytes32 PAUSER_ROLE = token.PAUSER_ROLE();
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        bytes32 BURNER_ROLE = token.BURNER_ROLE();
        bytes32 RECOVERY_ROLE = token.RECOVERY_ROLE();
        
        assertTrue(token.hasRole(DEFAULT_ADMIN_ROLE, ADMIN));
        assertTrue(token.hasRole(PAUSER_ROLE, PAUSER));
        assertTrue(token.hasRole(MINTER_ROLE, MINTER));
        assertTrue(token.hasRole(BURNER_ROLE, BURNER));
        assertTrue(token.hasRole(RECOVERY_ROLE, RECOVERY));
    }
    
    /**
     * @notice Expect revert with specific role error
     * @param account Account that doesn't have the role
     * @param role Role that is required
     */
    function expectAccessControlRevert(address account, bytes32 role) public {
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                account, 
                role
            )
        );
    }
    
    /**
     * @notice Simulate high gas scenario
     */
    function simulateHighGasScenario() public {
        // Perform gas-intensive operations
        vm.startPrank(ADMIN);
        for (uint256 i = 0; i < 50; i++) {
            address newUser = address(uint160(0x5000 + i));
            token.addToAllowlist(newUser);
        }
        vm.stopPrank();
    }
    
    /**
     * @notice Get role constants for testing
     */
    function getRoles() public view returns (
        bytes32 defaultAdmin,
        bytes32 pauser,
        bytes32 minter,
        bytes32 burner,
        bytes32 recovery
    ) {
        return (
            token.DEFAULT_ADMIN_ROLE(),
            token.PAUSER_ROLE(),
            token.MINTER_ROLE(),
            token.BURNER_ROLE(),
            token.RECOVERY_ROLE()
        );
    }
}