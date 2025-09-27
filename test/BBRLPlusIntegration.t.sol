// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {DEMOBR} from "../src/BBRLPlus.sol";
import {LibErrors} from "../src/Utils/Errors.sol";

/**
 * @title BBRLPlus Integration Test Suite
 * @notice Integration and advanced scenario tests for BBRLPlus token
 */
contract BBRLPlusIntegrationTest is Test {
    DEMOBR public token;
    
    // Test addresses
    address public constant ADMIN = address(0x1);
    address public constant PAUSER = address(0x2);
    address public constant MINTER = address(0x3);
    address public constant BURNER = address(0x4);
    address public constant RECOVERY = address(0x5);
    
    address public constant USER_A = address(0x10);
    address public constant USER_B = address(0x20);
    address public constant USER_C = address(0x30);
    address public constant MALICIOUS_USER = address(0x99);
    
    // Test constants
    uint256 public constant LARGE_AMOUNT = 1_000_000e18;
    uint256 public constant MEDIUM_AMOUNT = 10_000e18;
    uint256 public constant SMALL_AMOUNT = 100e18;
    
    function setUp() public {
        token = new DEMOBR(
            ADMIN,
            PAUSER,
            MINTER,
            BURNER,
            RECOVERY,
            "Brazilian Real Plus Integration",
            "BBRL+INT"
        );
        
    // Deny list model: no need to add addresses initially (all allowed unless denied)
    }
    
    // ========== COMPLETE WORKFLOW TESTS ==========
    
    function test_CompleteUserOnboardingWorkflow() public {
        string memory ref = "ONBOARD-001";
        
        console.log("=== Starting User Onboarding Workflow ===");
        
    // Step 1: (Deny list) Ensure new user is not denied
        address newUser = address(0x100);
    assertFalse(token.isDenied(newUser));
    console.log("Step 1: User not in deny list");
        
        // Step 2: Minter mints initial tokens
        vm.prank(MINTER);
        token.mintRef(newUser, MEDIUM_AMOUNT, ref);
        
        console.log("Step 2: Minted tokens to user");
        assertEq(token.balanceOf(newUser), MEDIUM_AMOUNT);
        
        // Step 3: User performs transactions
        vm.startPrank(newUser);
        
        // Transfer to another user
        uint256 transferAmount = MEDIUM_AMOUNT / 4;
        token.transferWithRef(USER_A, transferAmount, string.concat(ref, "-TRANSFER"));
        
        console.log("Step 3: User transferred tokens");
        assertEq(token.balanceOf(newUser), MEDIUM_AMOUNT - transferAmount);
        assertEq(token.balanceOf(USER_A), transferAmount);
        
        vm.stopPrank();
        
        // Step 4: Verify final state
        assertEq(token.totalSupply(), MEDIUM_AMOUNT);
    assertFalse(token.isDenied(newUser));
        
        console.log("=== User Onboarding Workflow Complete ===");
    }
    
    function test_EmergencyPauseAndRecoveryWorkflow() public {
        string memory ref = "EMERGENCY-001";
        
        console.log("=== Starting Emergency Workflow ===");
        
        // Setup: Mint tokens to users
        vm.prank(MINTER);
        token.mintRef(USER_A, LARGE_AMOUNT, ref);
        
        vm.prank(MINTER);
        token.mintRef(USER_B, MEDIUM_AMOUNT, ref);
        
        console.log("Setup: Minted tokens to users");
        
        // Emergency: Suspicious activity detected, pause contract
        vm.prank(PAUSER);
        token.pause();
        
        console.log("Emergency: Contract paused");
        assertTrue(token.paused());
        
        // Verify all operations are blocked
        vm.startPrank(MINTER);
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        token.mintRef(USER_C, SMALL_AMOUNT, ref);
        vm.stopPrank();
        
        vm.startPrank(USER_A);
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        token.transfer(USER_B, SMALL_AMOUNT);
        vm.stopPrank();
        
        console.log("Verified: All operations blocked during pause");
        
        // Investigation complete, unpause
        vm.prank(PAUSER);
        token.unpause();
        
        console.log("Recovery: Contract unpaused");
        assertFalse(token.paused());
        
        // Verify operations work again
        vm.prank(USER_A);
        token.transfer(USER_B, SMALL_AMOUNT);
        
        assertEq(token.balanceOf(USER_A), LARGE_AMOUNT - SMALL_AMOUNT);
        assertEq(token.balanceOf(USER_B), MEDIUM_AMOUNT + SMALL_AMOUNT);
        
        console.log("=== Emergency Workflow Complete ===");
    }
    
    function test_MaliciousUserDetectionAndRecovery() public {
        string memory ref = "MALICIOUS-001";
        
        console.log("=== Starting Malicious User Recovery ===");
        
    // Setup: Mint tokens to user (assumed allowed)
        
        vm.prank(MINTER);
        token.mintRef(MALICIOUS_USER, MEDIUM_AMOUNT, ref);
        
        console.log("Setup: Malicious user received tokens");
        
    // Detection: Add malicious user to deny list
    vm.prank(ADMIN);
    token.addToDenylist(MALICIOUS_USER);
    console.log("Detection: Added malicious user to deny list");
    assertTrue(token.isDenied(MALICIOUS_USER));
        
        // Recovery: Recover tokens from malicious user
        uint256 recoveredAmount = token.balanceOf(MALICIOUS_USER);
        uint256 initialRecoveryBalance = token.balanceOf(RECOVERY);
        
        vm.prank(RECOVERY);
        token.recoverTokens(MALICIOUS_USER, ref, recoveredAmount);
        
        console.log("Recovery: Tokens recovered from malicious user");
        assertEq(token.balanceOf(MALICIOUS_USER), 0);
        assertEq(token.balanceOf(RECOVERY), initialRecoveryBalance + recoveredAmount);
        
        console.log("=== Malicious User Recovery Complete ===");
    }
    
    // ========== STRESS TESTS ==========
    
    function test_LargeScaleDenylistOperations() public {
        console.log("=== Testing Large Scale Denylist Operations ===");
        
    uint256 initialLength = token.getDenylistLength();
        uint256 usersToAdd = 100;
        
        // Add many users to deny list
        vm.startPrank(ADMIN);
        for (uint256 i = 0; i < usersToAdd; i++) {
            address newUser = address(uint160(0x1000 + i));
            token.addToDenylist(newUser);
        }
        vm.stopPrank();
        
        assertEq(token.getDenylistLength(), initialLength + usersToAdd);
        
        // Verify random users in the list
        for (uint256 i = 0; i < 10; i++) {
            address randomUser = address(uint160(0x1000 + (i * 10)));
            assertTrue(token.isDenied(randomUser));
        }
        
        // Remove half of them from deny list
        vm.startPrank(ADMIN);
        for (uint256 i = 0; i < usersToAdd / 2; i++) {
            address userToRemove = address(uint160(0x1000 + i));
            token.removeFromDenylist(userToRemove);
        }
        vm.stopPrank();
        
        assertEq(token.getDenylistLength(), initialLength + (usersToAdd / 2));
        
        console.log("Large scale denylist operations completed successfully");
    }
    
    function test_HighVolumeTransactions() public {
        string memory ref = "VOLUME-TEST";
        
        console.log("=== Testing High Volume Transactions ===");
        
        // Setup: Mint large amount to USER_A
        vm.prank(MINTER);
        token.mintRef(USER_A, LARGE_AMOUNT, ref);
        
        uint256 numTransfers = 50;
        uint256 transferAmount = LARGE_AMOUNT / numTransfers;
        
        // Perform many transfers
        vm.startPrank(USER_A);
        for (uint256 i = 0; i < numTransfers; i++) {
            address recipient = (i % 2 == 0) ? USER_B : USER_C;
            
            if (token.balanceOf(USER_A) >= transferAmount) {
                token.transfer(recipient, transferAmount);
            }
        }
        vm.stopPrank();
        
        // Verify final balances
        uint256 totalDistributed = token.balanceOf(USER_B) + token.balanceOf(USER_C);
        uint256 remaining = token.balanceOf(USER_A);
        
        assertEq(totalDistributed + remaining, LARGE_AMOUNT);
        assertEq(token.totalSupply(), LARGE_AMOUNT);
        
        console.log("High volume transactions completed successfully");
    }
    
    // ========== EDGE CASE TESTS ==========
    
    function test_ZeroAmountOperations() public {
        string memory ref = "ZERO-TEST";
        
        // Test zero amount mint
        vm.prank(MINTER);
        token.mintRef(USER_A, 0, ref);
        assertEq(token.balanceOf(USER_A), 0);
        
        // First mint some tokens for burn test
        vm.prank(MINTER);
        token.mintRef(USER_A, SMALL_AMOUNT, ref);
        
        // Test zero amount burn (should revert)
        vm.startPrank(RECOVERY);
        vm.expectRevert(abi.encodeWithSignature("ZeroAmount()"));
        token.recoverTokens(USER_A, ref, 0);
        vm.stopPrank();
        
        // Test zero amount transfer
        vm.prank(USER_A);
        bool success = token.transfer(USER_B, 0);
        assertTrue(success);
        assertEq(token.balanceOf(USER_B), 0);
    }
    
    function test_MaximumDenylistSize() public {
        console.log("=== Testing Maximum Denylist Size ===");
        
    uint256 initialSize = token.getDenylistLength();
        uint256 maxNewUsers = 500; // Reasonable test size
        
        vm.startPrank(ADMIN);
        
        // Add users up to reasonable limit
        for (uint256 i = 0; i < maxNewUsers; i++) {
            address newUser = address(uint160(0x2000 + i));
            token.addToDenylist(newUser);
            
            // Verify every 100th user to save gas
            if (i % 100 == 0) {
                assertTrue(token.isDenied(newUser));
            }
        }
        
        vm.stopPrank();
        
        assertEq(token.getDenylistLength(), initialSize + maxNewUsers);
        
        console.log("Maximum denylist size test completed");
    }
    
    function test_RoleTransition() public {
        console.log("=== Testing Role Transition ===");
        
        address newAdmin = address(0x200);
        address newMinter = address(0x201);
        
        bytes32 DEFAULT_ADMIN_ROLE = token.DEFAULT_ADMIN_ROLE();
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        
        // Current admin grants roles to new addresses
        vm.startPrank(ADMIN);
        token.grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        token.grantRole(MINTER_ROLE, newMinter);
        
    // (Optional) could deny addresses here; not needed for permission
        vm.stopPrank();
        
        // New admin can perform an admin operation (grant MINTER role to itself again - harmless)
        vm.prank(newAdmin);
        token.grantRole(MINTER_ROLE, newAdmin);
        
        // New minter can mint tokens
        vm.prank(newMinter);
        token.mintRef(USER_A, SMALL_AMOUNT, "ROLE-TRANSITION");
        
        // Verify both old and new have roles
        assertTrue(token.hasRole(DEFAULT_ADMIN_ROLE, ADMIN));
        assertTrue(token.hasRole(DEFAULT_ADMIN_ROLE, newAdmin));
        assertTrue(token.hasRole(MINTER_ROLE, MINTER));
        assertTrue(token.hasRole(MINTER_ROLE, newMinter));
        
        console.log("Role transition test completed");
    }
    
    // ========== SECURITY TESTS ==========
    
    function test_ReentrancyProtection() public {
        // This is a basic test - full reentrancy testing would require malicious contracts
        string memory ref = "REENTRANCY-TEST";
        
        vm.prank(MINTER);
        token.mintRef(USER_A, MEDIUM_AMOUNT, ref);
        
        // Attempt rapid successive operations
        vm.startPrank(USER_A);
        
        uint256 amount = SMALL_AMOUNT;
        token.transfer(USER_B, amount);
        
        // Immediately attempt another transfer
        token.transfer(USER_C, amount);
        
        vm.stopPrank();
        
        // Verify state consistency
        assertEq(token.balanceOf(USER_A), MEDIUM_AMOUNT - (2 * amount));
        assertEq(token.balanceOf(USER_B), amount);
        assertEq(token.balanceOf(USER_C), amount);
    }
    
    function test_AccessControlEdgeCases() public {
        // Test renouncing roles
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        
        vm.prank(MINTER);
        token.renounceRole(MINTER_ROLE, MINTER);
        
        assertFalse(token.hasRole(MINTER_ROLE, MINTER));
        
        // Verify minter can no longer mint
        vm.startPrank(MINTER);
        vm.expectRevert();
        token.mintRef(USER_A, SMALL_AMOUNT, "SHOULD-FAIL");
        vm.stopPrank();
        
        // Admin can re-grant the role
        vm.prank(ADMIN);
        token.grantRole(MINTER_ROLE, MINTER);
        
        assertTrue(token.hasRole(MINTER_ROLE, MINTER));
    }
    
    // ========== GAS OPTIMIZATION TESTS ==========
    
    function test_GasEfficiency_DenylistOperations() public {
        uint256 gasBefore;
        uint256 gasAfter;
        
        address testUser = address(0x300);
        
    // Measure gas for adding to deny list
        gasBefore = gasleft();
        vm.prank(ADMIN);
    token.addToDenylist(testUser);
        gasAfter = gasleft();
        
        uint256 gasUsedAdd = gasBefore - gasAfter;
    console.log("Gas used for addToDenylist:", gasUsedAdd);
        
    // Measure gas for checking deny list
        gasBefore = gasleft();
    token.isDenied(testUser);
        gasAfter = gasleft();
        
        uint256 gasUsedCheck = gasBefore - gasAfter;
    console.log("Gas used for isDenied:", gasUsedCheck);
        
        // Basic assertions (these values would need to be calibrated based on expected performance)
        assertLt(gasUsedAdd, 100000); // Should be reasonable
        assertLt(gasUsedCheck, 10000); // Should be very efficient for reads
    }
    
    // ========== COMPATIBILITY TESTS ==========
    
    function test_ERC20Compatibility() public {
        // Test standard ERC20 functions work correctly
        vm.prank(MINTER);
        token.mintRef(USER_A, MEDIUM_AMOUNT, "ERC20-TEST");
        
        // Test approve/transferFrom workflow
        vm.prank(USER_A);
        token.approve(USER_B, SMALL_AMOUNT);
        
        assertEq(token.allowance(USER_A, USER_B), SMALL_AMOUNT);
        
        vm.prank(USER_B);
        token.transferFrom(USER_A, USER_C, SMALL_AMOUNT);
        
        assertEq(token.balanceOf(USER_C), SMALL_AMOUNT);
        assertEq(token.allowance(USER_A, USER_B), 0);
    }
    
    function test_PermitFunctionality() public {
        // Test EIP-2612 permit functionality
        uint256 ownerPrivateKey = 0x1234;
        address owner = vm.addr(ownerPrivateKey);
        
    // Owner is allowed by default (not in deny list)
        
        vm.prank(MINTER);
        token.mintRef(owner, MEDIUM_AMOUNT, "PERMIT-TEST");
        
        // Create permit signature
        uint256 value = SMALL_AMOUNT;
        uint256 deadline = block.timestamp + 1 hours;
        
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 structHash = keccak256(abi.encode(
            keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
            owner,
            USER_B,
            value,
            token.nonces(owner),
            deadline
        ));
        
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        
        // Execute permit
        token.permit(owner, USER_B, value, deadline, v, r, s);
        
        assertEq(token.allowance(owner, USER_B), value);
        assertEq(token.nonces(owner), 1);
    }
}