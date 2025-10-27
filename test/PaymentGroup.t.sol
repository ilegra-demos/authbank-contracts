// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/PaymentGroup.sol";
import "../src/interfaces/IMintableERC20.sol";

// Mock ERC20 token for testing
contract MockERC20 is IMintableERC20 {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // Stub implementations for IERC20
    function allowance(address owner, address spender) external view returns (uint256) {
        return 0;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        return true;
    }
}

contract PaymentGroupTest is Test {
    PaymentGroup paymentGroup;
    MockERC20 originToken;
    MockERC20 paymentToken;

    address admin = address(1);
    address operator = address(2);
    address participant1 = address(3);
    address participant2 = address(4);
    address nonAuthorized = address(5);

    uint256 rewardPercent = 50000; // 5%

    function setUp() public {
        originToken = new MockERC20();
        paymentToken = new MockERC20();

        paymentGroup = new PaymentGroup(
            address(originToken),
            address(paymentToken),
            admin,
            rewardPercent
        );

        // Setup roles
        vm.prank(admin);
        paymentGroup.grantOperator(operator);

        // Add participants
        vm.prank(operator);
        paymentGroup.addParticipant(participant1);

        vm.prank(operator);
        paymentGroup.addParticipant(participant2);

        // Give some balance to participants
        originToken.mint(participant1, 1000 ether);
        originToken.mint(participant2, 2000 ether);
    }

    function testConstructor() public {
        assertEq(paymentGroup.rewardPercentBps(), rewardPercent);
        assertEq(address(paymentGroup.originToken()), address(originToken));
        assertEq(address(paymentGroup.paymentToken()), address(paymentToken));
        assertTrue(paymentGroup.hasRole(paymentGroup.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(paymentGroup.hasRole(paymentGroup.OPERATOR_ROLE(), admin));
    }

    function testConstructorZeroAdmin() public {
        vm.expectRevert("Admin address cannot be zero");
        new PaymentGroup(address(originToken), address(paymentToken), address(0), rewardPercent);
    }

    function testConstructorInvalidPercent() public {
        vm.expectRevert("Reward percentage cannot exceed 100%");
        new PaymentGroup(address(originToken), address(paymentToken), admin, 1000001);

        vm.expectRevert("Reward percentage must be greater than 0");
        new PaymentGroup(address(originToken), address(paymentToken), admin, 0);
    }

    function testSetTokens() public {
        MockERC20 newOrigin = new MockERC20();
        MockERC20 newPayment = new MockERC20();

        vm.prank(admin);
        paymentGroup.setTokens(address(newOrigin), address(newPayment));

        assertEq(address(paymentGroup.originToken()), address(newOrigin));
        assertEq(address(paymentGroup.paymentToken()), address(newPayment));
    }

    function testSetTokensZeroAddress() public {
        vm.prank(admin);
        vm.expectRevert("Token addresses cannot be zero");
        paymentGroup.setTokens(address(0), address(paymentToken));

        vm.prank(admin);
        vm.expectRevert("Token addresses cannot be zero");
        paymentGroup.setTokens(address(originToken), address(0));
    }

    function testSetTokensUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.setTokens(address(originToken), address(paymentToken));
    }

    function testSetRewardPercentBps() public {
        uint256 newPercent = 100000; // 10%

        vm.prank(admin);
        paymentGroup.setRewardPercentBps(newPercent);

        assertEq(paymentGroup.rewardPercentBps(), newPercent);
    }

    function testSetRewardPercentBpsInvalid() public {
        vm.prank(admin);
        vm.expectRevert("Reward percentage cannot exceed 100%");
        paymentGroup.setRewardPercentBps(1000001);

        vm.prank(admin);
        vm.expectRevert("Reward percentage must be greater than 0");
        paymentGroup.setRewardPercentBps(0);
    }

    function testSetRewardPercentBpsUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.setRewardPercentBps(100000);
    }

    function testPauseUnpause() public {
        vm.prank(admin);
        paymentGroup.pause();
        assertTrue(paymentGroup.paused());

        vm.prank(admin);
        paymentGroup.unpause();
        assertFalse(paymentGroup.paused());
    }

    function testPauseUnpauseUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.pause();

        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.unpause();
    }

    function testGrantOperator() public {
        vm.prank(admin);
        paymentGroup.grantOperator(nonAuthorized);

        assertTrue(paymentGroup.hasRole(paymentGroup.OPERATOR_ROLE(), nonAuthorized));
    }

    function testGrantOperatorUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.grantOperator(address(6));
    }

    function testAddParticipant() public {
        vm.prank(operator);
        paymentGroup.addParticipant(nonAuthorized);

        assertEq(paymentGroup.participantsCount(), 3);
    }

    function testAddParticipantZeroAddress() public {
        vm.prank(operator);
        vm.expectRevert("Participant address cannot be zero");
        paymentGroup.addParticipant(address(0));
    }

    function testAddParticipantAlreadyAdded() public {
        vm.prank(operator);
        vm.expectRevert("Account is already a participant");
        paymentGroup.addParticipant(participant1);
    }

    function testAddParticipantPaused() public {
        vm.prank(admin);
        paymentGroup.pause();

        vm.prank(operator);
        vm.expectRevert("Contract is paused");
        paymentGroup.addParticipant(nonAuthorized);
    }

    function testAddParticipantUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.addParticipant(address(6));
    }

    function testRemoveParticipant() public {
        vm.prank(operator);
        paymentGroup.removeParticipant(participant1);

        assertEq(paymentGroup.participantsCount(), 1);
    }

    function testRemoveParticipantNotParticipant() public {
        vm.prank(operator);
        vm.expectRevert("Account is not a participant");
        paymentGroup.removeParticipant(nonAuthorized);
    }

    function testRemoveParticipantPaused() public {
        vm.prank(admin);
        paymentGroup.pause();

        vm.prank(operator);
        vm.expectRevert("Contract is paused");
        paymentGroup.removeParticipant(participant1);
    }

    function testRemoveParticipantUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.removeParticipant(participant1);
    }

    function testGetParticipants() public {
        address[] memory participants = paymentGroup.getParticipants();
        assertEq(participants.length, 2);
        // Note: Order may vary due to EnumerableSet
    }

    function testParticipantsCount() public {
        assertEq(paymentGroup.participantsCount(), 2);
    }

    function testTriggerPayment() public {
        uint256 initialBalance1 = paymentToken.balanceOf(participant1);
        uint256 initialBalance2 = paymentToken.balanceOf(participant2);

        vm.prank(operator);
        paymentGroup.triggerPayment();

        uint256 expectedReward1 = (1000 ether * rewardPercent) / 1000000; // 50 ether
        uint256 expectedReward2 = (2000 ether * rewardPercent) / 1000000; // 100 ether

        assertEq(paymentToken.balanceOf(participant1), initialBalance1 + expectedReward1);
        assertEq(paymentToken.balanceOf(participant2), initialBalance2 + expectedReward2);
    }

    function testTriggerPaymentPaused() public {
        vm.prank(admin);
        paymentGroup.pause();

        vm.prank(operator);
        vm.expectRevert("Contract is paused");
        paymentGroup.triggerPayment();
    }

    function testTriggerPaymentUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        paymentGroup.triggerPayment();
    }

    function testTriggerPaymentTokensNotConfigured() public {
        PaymentGroup newGroup = new PaymentGroup(address(0), address(0), admin, rewardPercent);
        vm.prank(admin);
        vm.expectRevert("Tokens not configured");
        newGroup.triggerPayment();
    }

    function testPreviewUserReward() public {
        (uint256 balance, uint256 reward) = paymentGroup.previewUserReward(participant1);
        assertEq(balance, 1000 ether);
        assertEq(reward, (1000 ether * rewardPercent) / 1000000);
    }

    function testPreviewUserRewardZeroBalance() public {
        (uint256 balance, uint256 reward) = paymentGroup.previewUserReward(nonAuthorized);
        assertEq(balance, 0);
        assertEq(reward, 0);
    }

    function testPreviewUserRewardTokenNotConfigured() public {
        PaymentGroup newGroup = new PaymentGroup(address(0), address(paymentToken), admin, rewardPercent);
        vm.expectRevert("Origin token not configured");
        newGroup.previewUserReward(participant1);
    }

    function testPreviewAllRewards() public {
        (address[] memory accounts, uint256[] memory rewards) = paymentGroup.previewAllRewards();
        assertEq(accounts.length, 2);
        assertEq(rewards.length, 2);
        assertEq(rewards[0] + rewards[1], (1000 ether + 2000 ether) * rewardPercent / 1000000);
    }

    function testPreviewAllRewardsTokenNotConfigured() public {
        PaymentGroup newGroup = new PaymentGroup(address(0), address(paymentToken), admin, rewardPercent);
        vm.expectRevert("Origin token not configured");
        newGroup.previewAllRewards();
    }
}