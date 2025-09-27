// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import {DEMOBR} from "../src/BBRLPlus.sol";
import {LibErrors} from "../src/Utils/Errors.sol";

/**
 * @title BBRLPlus Test Suite
 * @notice Comprehensive tests for the BBRLPlus token contract
 */
contract BBRLPlusTest is Test {
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
    address public constant UNAUTHORIZED_USER = address(0x99);
    
    // Test constants
    string public constant TOKEN_NAME = "Brazilian Real Plus Test";
    string public constant TOKEN_SYMBOL = "BBRL+TEST";
    uint256 public constant INITIAL_SUPPLY = 0;
    uint256 public constant TEST_AMOUNT = 1000e18;
    string public constant TEST_REF = "TEST-REF-001";
    
    // Events to test
    event TokensMinted(address indexed to, string indexed ref, uint256 amount);
    event TokensBurned(address indexed from, string indexed ref, uint256 amount);
    event TokensTransferred(address indexed to, string indexed ref, uint256 amount);
    event TokensRecovered(address indexed account, string indexed ref, uint256 amount);
    
    function setUp() public {
        // Deploy the contract with role assignments
        token = new DEMOBR(
            ADMIN,      // defaultAdmin
            PAUSER,     // pauser
            MINTER,     // minter
            BURNER,     // burner
            RECOVERY,   // recovery
            TOKEN_NAME,
            TOKEN_SYMBOL
        );
        
    // Setup: initially deny list is empty (addresses are allowed unless denied)
        vm.startPrank(ADMIN);
    // No addresses added to deny list in setup
        vm.stopPrank();
    }
    
    // ========== DEPLOYMENT TESTS ==========
    
    function test_Deployment() public view {
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.paused(), false);
    assertEq(token.getDenylistLength(), 0); // deny list starts empty
    }
    
    function test_InitialRoles() public view {
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
    
    // ========== MINT TESTS ==========
    
    function test_MintRef_Success() public {
        vm.startPrank(MINTER);
        
        // Expect the events
        vm.expectEmit(true, true, false, true);
        emit TokensMinted(USER_A, TEST_REF, TEST_AMOUNT);
        
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        assertEq(token.balanceOf(USER_A), TEST_AMOUNT);
        assertEq(token.totalSupply(), TEST_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_MintRef_UnauthorizedCaller() public {
        vm.startPrank(USER_A);
        
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                USER_A, 
                MINTER_ROLE
            )
        );
        
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_MintRef_ContractPaused() public {
        // Pause the contract
        vm.prank(PAUSER);
        token.pause();
        
        vm.startPrank(MINTER);
        
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.stopPrank();
    }
    
    function test_MintRef_ZeroAmount() public {
        vm.startPrank(MINTER);
        
        // Should succeed with zero amount
        token.mintRef(USER_A, 0, TEST_REF);
        
        assertEq(token.balanceOf(USER_A), 0);
        assertEq(token.totalSupply(), 0);
        
        vm.stopPrank();
    }
    
    function test_MintRef_ToZeroAddress() public {
        vm.startPrank(MINTER);
        
        // Should revert when minting to zero address
        vm.expectRevert(abi.encodeWithSignature("ERC20InvalidReceiver(address)", address(0)));
        token.mintRef(address(0), TEST_AMOUNT, TEST_REF);
        
        vm.stopPrank();
    }
    
    // ========== BURN TESTS ==========
    
    function test_BurnFromRef_Success() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.startPrank(BURNER);
        
        uint256 burnAmount = TEST_AMOUNT / 2;
        
        // Expect the events
        vm.expectEmit(true, true, false, true);
        emit TokensBurned(USER_A, TEST_REF, burnAmount);
        
        token.burnFromRef(USER_A, TEST_REF, burnAmount);
        
        assertEq(token.balanceOf(USER_A), TEST_AMOUNT - burnAmount);
        assertEq(token.totalSupply(), TEST_AMOUNT - burnAmount);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_BurnFromRef_UnauthorizedCaller() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.startPrank(USER_A);
        
        bytes32 BURNER_ROLE = token.BURNER_ROLE();
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                USER_A, 
                BURNER_ROLE
            )
        );
        
        token.burnFromRef(USER_A, TEST_REF, TEST_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_BurnFromRef_InsufficientBalance() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.startPrank(BURNER);
        
        vm.expectRevert(abi.encodeWithSignature("ERC20InsufficientBalance(address,uint256,uint256)", USER_A, TEST_AMOUNT, TEST_AMOUNT + 1));
        token.burnFromRef(USER_A, TEST_REF, TEST_AMOUNT + 1);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_BurnFromRef_ContractPaused() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        // Pause the contract
        vm.prank(PAUSER);
        token.pause();
        
        vm.startPrank(BURNER);
        
        vm.expectRevert(abi.encodeWithSignature("EnforcedPause()"));
        token.burnFromRef(USER_A, TEST_REF, TEST_AMOUNT);
        
        vm.stopPrank();
    }
    
    // ========== TRANSFER TESTS ==========
    
    function test_Transfer_Success() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.startPrank(USER_A);
        
        uint256 transferAmount = TEST_AMOUNT / 2;
        
        bool success = token.transfer(USER_B, transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(USER_A), TEST_AMOUNT - transferAmount);
        assertEq(token.balanceOf(USER_B), transferAmount);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_Transfer_DeniedSender() public {
        // Mint tokens to user then deny them
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        vm.prank(ADMIN);
        token.addToDenylist(USER_A);
        vm.startPrank(USER_A);
        vm.expectRevert(abi.encodeWithSignature("UnauthorizedCaller()"));
        token.transfer(USER_B, TEST_AMOUNT / 2);
        vm.stopPrank();
    }
    
    function test_RevertWhen_Transfer_DeniedReceiver() public {
        // Mint tokens to sender and deny receiver
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        vm.prank(ADMIN);
        token.addToDenylist(USER_B);
        vm.startPrank(USER_A);
        vm.expectRevert(abi.encodeWithSignature("UnauthorizedReceiver()"));
        token.transfer(USER_B, TEST_AMOUNT / 2);
        vm.stopPrank();
    }
    
    function test_TransferWithRef_Success() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.startPrank(USER_A);
        
        uint256 transferAmount = TEST_AMOUNT / 2;
        
        // Expect the events
        vm.expectEmit(true, true, false, true);
        emit TokensTransferred(USER_B, TEST_REF, transferAmount);
        
        bool success = token.transferWithRef(USER_B, transferAmount, TEST_REF);
        
        assertTrue(success);
        assertEq(token.balanceOf(USER_A), TEST_AMOUNT - transferAmount);
        assertEq(token.balanceOf(USER_B), transferAmount);
        
        vm.stopPrank();
    }
    
    function test_TransferFrom_Success() public {
        // First mint some tokens
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        // Approve USER_B to spend USER_A's tokens
        vm.prank(USER_A);
        token.approve(USER_B, TEST_AMOUNT);
        
        vm.startPrank(USER_B);
        
        uint256 transferAmount = TEST_AMOUNT / 2;
        
        bool success = token.transferFrom(USER_A, USER_C, transferAmount);
        
        assertTrue(success);
        assertEq(token.balanceOf(USER_A), TEST_AMOUNT - transferAmount);
        assertEq(token.balanceOf(USER_C), transferAmount);
        assertEq(token.allowance(USER_A, USER_B), TEST_AMOUNT - transferAmount);
        
        vm.stopPrank();
    }
    
    // ========== DENYLIST TESTS ==========
    
    function test_AddToDenylist_Success() public {
        vm.startPrank(ADMIN);
        
        address newUser = address(0x123);
        
        token.addToDenylist(newUser);
        
        assertTrue(token.isDenied(newUser));
        assertEq(token.getDenylistLength(), 1);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_AddToDenylist_UnauthorizedCaller() public {
        vm.startPrank(USER_A);
        
        address newUser = address(0x123);
        bytes32 DEFAULT_ADMIN_ROLE = token.DEFAULT_ADMIN_ROLE();
        
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                USER_A, 
                DEFAULT_ADMIN_ROLE
            )
        );
        
    token.addToDenylist(newUser);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_AddToDenylist_ZeroAddress() public {
        vm.startPrank(ADMIN);
        
        vm.expectRevert("Cannot add zero address");
        token.addToDenylist(address(0));
        
        vm.stopPrank();
    }
    
    function test_RemoveFromDenylist_Success() public {
        vm.startPrank(ADMIN);
        
        token.addToDenylist(USER_C);
        assertTrue(token.isDenied(USER_C));
        
        token.removeFromDenylist(USER_C);
        
        assertFalse(token.isDenied(USER_C));
        assertEq(token.getDenylistLength(), 0);
        
        vm.stopPrank();
    }
    
    function test_GetDenylistAddress_RevertsWhenEmpty() public {
        vm.expectRevert();
        token.getDenylistAddress(0);
    }
    
    function test_RevertWhen_GetDenylistAddress_IndexOutOfBounds() public {
        vm.startPrank(ADMIN);
        token.addToDenylist(USER_A);
        vm.stopPrank();
        uint256 length = token.getDenylistLength();
        vm.expectRevert();
        token.getDenylistAddress(length);
    }
    
    // ========== PAUSE/UNPAUSE TESTS ==========
    
    function test_Pause_Success() public {
        vm.startPrank(PAUSER);
        
        assertFalse(token.paused());
        
        token.pause();
        
        assertTrue(token.paused());
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_Pause_UnauthorizedCaller() public {
        vm.startPrank(USER_A);
        
        bytes32 PAUSER_ROLE = token.PAUSER_ROLE();
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                USER_A, 
                PAUSER_ROLE
            )
        );
        
        token.pause();
        
        vm.stopPrank();
    }
    
    function test_Unpause_Success() public {
        // First pause
        vm.prank(PAUSER);
        token.pause();
        
        vm.startPrank(PAUSER);
        
        assertTrue(token.paused());
        
        token.unpause();
        
        assertFalse(token.paused());
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_Unpause_UnauthorizedCaller() public {
        // First pause
        vm.prank(PAUSER);
        token.pause();
        
        vm.startPrank(USER_A);
        
        bytes32 PAUSER_ROLE = token.PAUSER_ROLE();
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                USER_A, 
                PAUSER_ROLE
            )
        );
        
        token.unpause();
        
        vm.stopPrank();
    }
    
    // ========== RECOVERY TESTS ==========
    
    function test_RecoverTokens_Success() public {
    // First mint tokens to a user then add them to deny list to simulate violation
        vm.prank(MINTER);
        token.mintRef(UNAUTHORIZED_USER, TEST_AMOUNT, TEST_REF);
        
        vm.prank(ADMIN);
    token.addToDenylist(UNAUTHORIZED_USER);
        
        vm.startPrank(RECOVERY);
        
        uint256 initialRecovererBalance = token.balanceOf(RECOVERY);
        
        // Expect the events
        vm.expectEmit(true, true, false, true);
        emit TokensRecovered(UNAUTHORIZED_USER, TEST_REF, TEST_AMOUNT);
        
        token.recoverTokens(UNAUTHORIZED_USER, TEST_REF, TEST_AMOUNT);
        
        assertEq(token.balanceOf(UNAUTHORIZED_USER), 0);
        assertEq(token.balanceOf(RECOVERY), initialRecovererBalance + TEST_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_RecoverTokens_UnauthorizedCaller() public {
        vm.startPrank(USER_A);
        
        bytes32 RECOVERY_ROLE = token.RECOVERY_ROLE();
        vm.expectRevert(
            abi.encodeWithSignature(
                "AccessControlUnauthorizedAccount(address,bytes32)", 
                USER_A, 
                RECOVERY_ROLE
            )
        );
        
        token.recoverTokens(UNAUTHORIZED_USER, TEST_REF, TEST_AMOUNT);
        
        vm.stopPrank();
    }
    
    function test_RevertWhen_RecoverTokens_ZeroAmount() public {
        vm.startPrank(RECOVERY);
        
        vm.expectRevert(abi.encodeWithSignature("ZeroAmount()"));
        token.recoverTokens(UNAUTHORIZED_USER, TEST_REF, 0);
        
        vm.stopPrank();
    }
    
    // ========== ROLE MANAGEMENT TESTS ==========
    
    function test_GrantRole_Success() public {
        vm.startPrank(ADMIN);
        
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        address newMinter = address(0x456);
        
        assertFalse(token.hasRole(MINTER_ROLE, newMinter));
        
        token.grantRole(MINTER_ROLE, newMinter);
        
        assertTrue(token.hasRole(MINTER_ROLE, newMinter));
        
        vm.stopPrank();
    }
    
    function test_RevokeRole_Success() public {
        vm.startPrank(ADMIN);
        
        bytes32 MINTER_ROLE = token.MINTER_ROLE();
        
        assertTrue(token.hasRole(MINTER_ROLE, MINTER));
        
        token.revokeRole(MINTER_ROLE, MINTER);
        
        assertFalse(token.hasRole(MINTER_ROLE, MINTER));
        
        vm.stopPrank();
    }
    
    // ========== ERC20 PERMIT TESTS ==========
    
    function test_Permit_Success() public {
        uint256 ownerPrivateKey = 0x123;
        address owner = vm.addr(ownerPrivateKey);
        address spender = USER_B;
        uint256 value = TEST_AMOUNT;
        uint256 deadline = block.timestamp + 1 hours;
        
    // Owner is allowed by default (not on deny list)
        
        // Create permit signature
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
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        
        // Execute permit
        token.permit(owner, spender, value, deadline, v, r, s);
        
        assertEq(token.allowance(owner, spender), value);
    }
    
    // ========== FUZZ TESTS ==========
    
    function testFuzz_MintRef(address to, uint256 amount, string memory ref) public {
        vm.assume(to != address(0));
        vm.assume(amount <= type(uint256).max / 2); // Prevent overflow
        
    // 'to' address is allowed by default (not denied)
        
        vm.startPrank(MINTER);
        
        uint256 initialSupply = token.totalSupply();
        uint256 initialBalance = token.balanceOf(to);
        
        token.mintRef(to, amount, ref);
        
        assertEq(token.balanceOf(to), initialBalance + amount);
        assertEq(token.totalSupply(), initialSupply + amount);
        
        vm.stopPrank();
    }
    
    function testFuzz_Transfer(uint256 amount) public {
        vm.assume(amount > 0 && amount <= TEST_AMOUNT);
        
        // Setup: mint tokens to USER_A
        vm.prank(MINTER);
        token.mintRef(USER_A, TEST_AMOUNT, TEST_REF);
        
        vm.startPrank(USER_A);
        
        uint256 initialBalanceA = token.balanceOf(USER_A);
        uint256 initialBalanceB = token.balanceOf(USER_B);
        
        token.transfer(USER_B, amount);
        
        assertEq(token.balanceOf(USER_A), initialBalanceA - amount);
        assertEq(token.balanceOf(USER_B), initialBalanceB + amount);
        
        vm.stopPrank();
    }
    
    // ========== INVARIANT TESTS ==========
    
    function invariant_TotalSupplyEqualsBalances() public view {
        uint256 totalSupply = token.totalSupply();
        uint256 sumOfBalances = 0;
        
        // Sum balances of all known addresses
        sumOfBalances += token.balanceOf(USER_A);
        sumOfBalances += token.balanceOf(USER_B);
        sumOfBalances += token.balanceOf(USER_C);
        sumOfBalances += token.balanceOf(MINTER);
        sumOfBalances += token.balanceOf(BURNER);
        sumOfBalances += token.balanceOf(RECOVERY);
        sumOfBalances += token.balanceOf(UNAUTHORIZED_USER);
        
        // Note: This is a simplified invariant test
        // In a full test suite, you'd track all addresses that received tokens
        assertGe(totalSupply, sumOfBalances);
    }
    
    function invariant_DenylistIntegrity() public view {
    uint256 length = token.getDenylistLength();
        
        // Verify we can access all indices
        for (uint256 i = 0; i < length; i++) {
            address addr = token.getDenylistAddress(i);
            assertTrue(token.isDenied(addr));
        }
    }
}