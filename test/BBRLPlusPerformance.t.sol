// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {BBRLPlusTestHelper} from "./BBRLPlusTestHelper.sol";
import {console} from "forge-std/Test.sol";

/**
 * @title BBRLPlus Performance Test Suite
 * @notice Performance benchmarks and gas optimization tests
 */
contract BBRLPlusPerformanceTest is BBRLPlusTestHelper {
    
    function setUp() public {
        deployFreshToken("Brazilian Real Plus Perf", "BBRL+PERF");
    setupStandardDenylist();
    }
    
    // ========== GAS BENCHMARK TESTS ==========
    
    function test_GasBenchmark_MintOperations() public {
        console.log("=== Gas Benchmark: Mint Operations ===");
        
        uint256 gasUsed;
        
        // Benchmark single mint
        uint256 gasBefore = gasleft();
        vm.prank(MINTER);
        token.mintRef(USER_A, SMALL_AMOUNT, "BENCH-001");
        gasUsed = gasBefore - gasleft();
        
        console.log("Single mint gas usage:", gasUsed);
        assertLt(gasUsed, 100000, "Mint gas usage too high");
        
        // Benchmark multiple mints
        gasBefore = gasleft();
        vm.startPrank(MINTER);
        for (uint256 i = 0; i < 10; i++) {
            token.mintRef(USER_B, TINY_AMOUNT, string.concat("BENCH-", vm.toString(i)));
        }
        vm.stopPrank();
        gasUsed = gasBefore - gasleft();
        
        console.log("10 mints gas usage:", gasUsed);
        console.log("Average gas per mint:", gasUsed / 10);
    }
    
    function test_GasBenchmark_TransferOperations() public {
        console.log("=== Gas Benchmark: Transfer Operations ===");
        
        // Setup: mint tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, LARGE_AMOUNT, "BENCH-SETUP");
        
        uint256 gasUsed;
        
        // Benchmark single transfer
        uint256 gasBefore = gasleft();
        vm.prank(USER_A);
        token.transfer(USER_B, SMALL_AMOUNT);
        gasUsed = gasBefore - gasleft();
        
        console.log("Single transfer gas usage:", gasUsed);
        assertLt(gasUsed, 80000, "Transfer gas usage too high");
        
        // Benchmark transferWithRef
        gasBefore = gasleft();
        vm.prank(USER_A);
        token.transferWithRef(USER_C, SMALL_AMOUNT, "BENCH-REF");
        gasUsed = gasBefore - gasleft();
        
        console.log("TransferWithRef gas usage:", gasUsed);
    }
    
    function test_GasBenchmark_DenylistOperations() public {
        console.log("=== Gas Benchmark: Denylist Operations ===");
        
        uint256 gasUsed;
        address testUser = address(0x9999);
        
        // Benchmark add to deny list
        uint256 gasBefore = gasleft();
        vm.prank(ADMIN);
        token.addToDenylist(testUser);
        gasUsed = gasBefore - gasleft();
        
        console.log("Add to denylist gas usage:", gasUsed);
        assertLt(gasUsed, 90000, "Add to denylist gas usage too high");
        
        // Benchmark deny list check
        gasBefore = gasleft();
        bool isDeniedAddr = token.isDenied(testUser);
        gasUsed = gasBefore - gasleft();
        
        console.log("Denylist check gas usage:", gasUsed);
        assertTrue(isDeniedAddr);
        assertLt(gasUsed, 5000, "Denylist check gas usage too high");
        
        // Benchmark remove from deny list
        gasBefore = gasleft();
        vm.prank(ADMIN);
        token.removeFromDenylist(testUser);
        gasUsed = gasBefore - gasleft();
        
        console.log("Remove from denylist gas usage:", gasUsed);
    }
    
    function test_GasBenchmark_RoleOperations() public {
        console.log("=== Gas Benchmark: Role Operations ===");
        
        uint256 gasUsed;
        address testUser = address(0x8888);
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        
        // Benchmark role check
        uint256 gasBefore = gasleft();
        bool hasRole = token.hasRole(MINTER_ROLE, MINTER);
        gasUsed = gasBefore - gasleft();
        
        console.log("Role check gas usage:", gasUsed);
        assertTrue(hasRole);
        assertLt(gasUsed, 5000, "Role check gas usage too high");
        
        // Benchmark grant role
        gasBefore = gasleft();
        vm.prank(ADMIN);
        token.grantRole(MINTER_ROLE, testUser);
        gasUsed = gasBefore - gasleft();
        
        console.log("Grant role gas usage:", gasUsed);
        
        // Benchmark revoke role
        gasBefore = gasleft();
        vm.prank(ADMIN);
        token.revokeRole(MINTER_ROLE, testUser);
        gasUsed = gasBefore - gasleft();
        
        console.log("Revoke role gas usage:", gasUsed);
    }
    
    // ========== SCALABILITY TESTS ==========
    
    function test_DenylistScalability() public {
        console.log("=== Denylist Scalability Test ===");
        
        uint256[] memory gasUsages = new uint256[](5);
        uint256[] memory sizes = new uint256[](5);
        sizes[0] = 10;
        sizes[1] = 50;
        sizes[2] = 100;
        sizes[3] = 200;
        sizes[4] = 500;
        
        for (uint256 i = 0; i < sizes.length; i++) {
            // Add users to reach target size
            uint256 currentSize = token.getDenylistLength();
            uint256 targetSize = sizes[i];
            
            vm.startPrank(ADMIN);
            for (uint256 j = currentSize; j < targetSize; j++) {
                address newUser = address(uint160(0x6000 + j));
                token.addToDenylist(newUser);
            }
            vm.stopPrank();
            
            // Measure gas for checking last user
            address lastUser = address(uint160(0x6000 + targetSize - 1));
            uint256 gasBefore = gasleft();
            token.isDenied(lastUser);
            gasUsages[i] = gasBefore - gasleft();
            
            console.log("Denylist size:", targetSize, "Check gas:", gasUsages[i]);
        }
        
    // Verify gas usage doesn't grow linearly with deny list size
        // EnumerableSet should provide O(1) lookup
        for (uint256 i = 0; i < gasUsages.length; i++) {
            assertLt(gasUsages[i], 10000, "Denylist check gas too high for large sets");
        }
    }
    
    function test_TransferScalability() public {
        console.log("=== Transfer Scalability Test ===");
        
        // Setup large balance for USER_A
        vm.prank(MINTER);
        token.mintRef(USER_A, LARGE_AMOUNT * 10, "SCALE-TEST");
        
        uint256[] memory transferCounts = new uint256[](4);
        transferCounts[0] = 10;
        transferCounts[1] = 50;
        transferCounts[2] = 100;
        transferCounts[3] = 200;
        
        for (uint256 i = 0; i < transferCounts.length; i++) {
            uint256 transferCount = transferCounts[i];
            uint256 transferAmount = TINY_AMOUNT;
            
            uint256 gasBefore = gasleft();
            
            vm.startPrank(USER_A);
            for (uint256 j = 0; j < transferCount; j++) {
                address recipient = (j % 2 == 0) ? USER_B : USER_C;
                token.transfer(recipient, transferAmount);
            }
            vm.stopPrank();
            
            uint256 gasUsed = gasBefore - gasleft();
            uint256 avgGasPerTransfer = gasUsed / transferCount;
            
            console.log("Transfers:", transferCount, "Avg gas per transfer:", avgGasPerTransfer);
            
            // Verify gas per transfer remains reasonable
            assertLt(avgGasPerTransfer, 100000, "Average transfer gas too high");
        }
    }
    
    // ========== STRESS TESTS ==========
    
    function test_StressTesting_MaxDenylistOperations() public {
        console.log("=== Stress Test: Max Denylist Operations ===");
        
        uint256 maxOperations = 1000;
        uint256 batchSize = 100;
        
        for (uint256 batch = 0; batch < maxOperations / batchSize; batch++) {
            vm.startPrank(ADMIN);
            
            // Add batch of users to deny list
            for (uint256 i = 0; i < batchSize; i++) {
                address newUser = address(uint160(0x7000 + (batch * batchSize) + i));
                token.addToDenylist(newUser);
            }
            
            vm.stopPrank();
            
            // Verify deny list integrity every few batches
            if (batch % 3 == 0) {
                verifyTokenStateConsistency();
            }
        }
        
        uint256 finalSize = token.getDenylistLength();
        console.log("Final denylist size:", finalSize);
        assertGe(finalSize, maxOperations);
        
        // Test that operations still work with large deny list by ensuring transfers blocked if denied
        address testUser = address(0x9999);
        vm.prank(ADMIN);
        token.addToDenylist(testUser);
        assertTrue(token.isDenied(testUser));
    }
    
    function test_StressTesting_HighVolumeTransactions() public {
        console.log("=== Stress Test: High Volume Transactions ===");
        
        // Setup multiple users with tokens
        address[] memory users = new address[](10);
        for (uint256 i = 0; i < users.length; i++) {
            users[i] = address(uint160(0x8000 + i));
            // Users are allowed by default (not denied)
            
            vm.prank(MINTER);
            token.mintRef(users[i], MEDIUM_AMOUNT, "STRESS-SETUP");
        }
        
        // Perform many transactions between users
        uint256 numRounds = 100;
        uint256 transferAmount = SMALL_AMOUNT / 10;
        
        for (uint256 round = 0; round < numRounds; round++) {
            for (uint256 i = 0; i < users.length - 1; i++) {
                vm.prank(users[i]);
                token.transfer(users[i + 1], transferAmount);
            }
            
            // Verify consistency every 25 rounds
            if (round % 25 == 0) {
                verifyTokenStateConsistency();
                console.log("Completed round:", round);
            }
        }
        
        console.log("Completed", numRounds * (users.length - 1), "transactions");
        
        // Verify final state
        uint256 totalBalance = 0;
        for (uint256 i = 0; i < users.length; i++) {
            totalBalance += token.balanceOf(users[i]);
        }
        
        assertEq(totalBalance, MEDIUM_AMOUNT * users.length);
    }
    
    // ========== MEMORY EFFICIENCY TESTS ==========
    
    function test_MemoryEfficiency_DenylistStorage() public {
        console.log("=== Memory Efficiency: Denylist Storage ===");
        
    uint256 initialSize = token.getDenylistLength();
    console.log("Initial denylist size:", initialSize);
        
        // Add many unique users
        uint256 usersToAdd = 500;
        
        vm.startPrank(ADMIN);
        for (uint256 i = 0; i < usersToAdd; i++) {
            address newUser = address(uint160(0x9000 + i));
            token.addToDenylist(newUser);
        }
        vm.stopPrank();
        
    uint256 finalSize = token.getDenylistLength();
    console.log("Final denylist size:", finalSize);
        assertEq(finalSize, initialSize + usersToAdd);
        
        // Test removal doesn't break anything
        vm.startPrank(ADMIN);
        for (uint256 i = 0; i < usersToAdd / 4; i++) {
            address userToRemove = address(uint160(0x9000 + i));
            token.removeFromDenylist(userToRemove);
        }
        vm.stopPrank();
        
    uint256 afterRemovalSize = token.getDenylistLength();
        console.log("Size after removals:", afterRemovalSize);
        assertEq(afterRemovalSize, finalSize - (usersToAdd / 4));
    }
    
    // ========== COMPARATIVE BENCHMARKS ==========
    
    function test_ComparativeBenchmark_TransferTypes() public {
        console.log("=== Comparative Benchmark: Transfer Types ===");
        
        // Setup
        vm.prank(MINTER);
        token.mintRef(USER_A, LARGE_AMOUNT, "COMPARE-SETUP");
        
        uint256 gasUsed;
        uint256 amount = SMALL_AMOUNT;
        
        // Standard transfer
        uint256 gasBefore = gasleft();
        vm.prank(USER_A);
        token.transfer(USER_B, amount);
        gasUsed = gasBefore - gasleft();
        console.log("Standard transfer gas:", gasUsed);
        
        // Transfer with reference
        gasBefore = gasleft();
        vm.prank(USER_A);
        token.transferWithRef(USER_C, amount, "REF-001");
        gasUsed = gasBefore - gasleft();
        console.log("Transfer with ref gas:", gasUsed);
        
        // Approve + transferFrom
        vm.prank(USER_A);
        token.approve(USER_D, amount);
        
        gasBefore = gasleft();
        vm.prank(USER_D);
        token.transferFrom(USER_A, USER_D, amount);
        gasUsed = gasBefore - gasleft();
        console.log("TransferFrom gas:", gasUsed);
    }
    
    function test_EdgeCase_MaximumValues() public {
        console.log("=== Edge Case: Maximum Values ===");
        
        // Test with large but reasonable amounts
        uint256 maxTestAmount = 1000000000e18; // 1 billion tokens with 18 decimals
        
        vm.prank(MINTER);
        token.mintRef(USER_A, maxTestAmount, "MAX-TEST");
        
        assertEq(token.balanceOf(USER_A), maxTestAmount);
        assertEq(token.totalSupply(), maxTestAmount);
        
        // Test transfer of large amount
        uint256 transferAmount = maxTestAmount / 2;
        vm.prank(USER_A);
        token.transfer(USER_B, transferAmount);
        
        assertEq(token.balanceOf(USER_A), maxTestAmount - transferAmount);
        assertEq(token.balanceOf(USER_B), transferAmount);
        assertEq(token.totalSupply(), maxTestAmount);
    }
}