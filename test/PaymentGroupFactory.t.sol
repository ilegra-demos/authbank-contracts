// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/NewGroup.sol";

contract PaymentGroupFactoryTest is Test {
    PaymentGroupFactory factory;

    address deployer = address(1);
    address creator = address(2);
    address admin = address(3);
    address nonAuthorized = address(4);

    address mockOriginToken = address(0x100);
    address mockPaymentToken = address(0x200);

    uint256 rewardPercent = 50000; // 5%

    function setUp() public {
        vm.prank(deployer);
        factory = new PaymentGroupFactory();

        // Grant creator role to creator
        vm.prank(deployer);
        factory.grantCreatorRole(creator);
    }

    function testConstructor() public {
        assertTrue(factory.hasRole(factory.DEFAULT_ADMIN_ROLE(), deployer));
        assertTrue(factory.hasRole(factory.CREATOR_ROLE(), deployer));
    }

    function testCreatePaymentGroup() public {
        vm.prank(creator);
        address newGroup = factory.createPaymentGroup(
            mockOriginToken,
            mockPaymentToken,
            admin,
            rewardPercent
        );

        assertTrue(newGroup != address(0));

        // Check stored info
        PaymentGroupFactory.PaymentGroupInfo memory info = factory.getGroupInfo(newGroup);
        assertEq(info.contractAddress, newGroup);
        assertEq(info.originToken, mockOriginToken);
        assertEq(info.paymentToken, mockPaymentToken);
        assertEq(info.admin, admin);
        assertEq(info.rewardPercentBps, rewardPercent);
        assertEq(info.createdAt, block.timestamp);

        // Check count
        assertEq(factory.getCreatedGroupsCount(), 1);
    }

    function testCreatePaymentGroupZeroAdmin() public {
        vm.prank(creator);
        vm.expectRevert("Admin address cannot be zero");
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, address(0), rewardPercent);
    }

    function testCreatePaymentGroupInvalidPercent() public {
        vm.prank(creator);
        vm.expectRevert("Reward percentage cannot exceed 100%");
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, 1000001);

        vm.prank(creator);
        vm.expectRevert("Reward percentage must be greater than 0");
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, 0);
    }

    function testCreatePaymentGroupUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);
    }

    function testGetCreatedGroupsCount() public {
        assertEq(factory.getCreatedGroupsCount(), 0);

        vm.prank(creator);
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        assertEq(factory.getCreatedGroupsCount(), 1);
    }

    function testGetGroupInfo() public {
        vm.prank(creator);
        address newGroup = factory.createPaymentGroup(
            mockOriginToken,
            mockPaymentToken,
            admin,
            rewardPercent
        );

        PaymentGroupFactory.PaymentGroupInfo memory info = factory.getGroupInfo(newGroup);
        assertEq(info.contractAddress, newGroup);
        assertEq(info.originToken, mockOriginToken);
        assertEq(info.paymentToken, mockPaymentToken);
        assertEq(info.admin, admin);
        assertEq(info.rewardPercentBps, rewardPercent);
    }

    function testGetGroupInfoNotFound() public {
        vm.expectRevert("Contract not found");
        factory.getGroupInfo(address(0x123));
    }

    function testGetCreatedGroups() public {
        // Create multiple groups
        vm.prank(creator);
        address group1 = factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        vm.prank(creator);
        address group2 = factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        // Get all
        PaymentGroupFactory.PaymentGroupInfo[] memory groups = factory.getCreatedGroups(0, 10);
        assertEq(groups.length, 2);
        assertEq(groups[0].contractAddress, group1);
        assertEq(groups[1].contractAddress, group2);
    }

    function testGetCreatedGroupsPagination() public {
        // Create 5 groups
        for (uint i = 0; i < 5; i++) {
            vm.prank(creator);
            factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);
        }

        // Get first 2
        PaymentGroupFactory.PaymentGroupInfo[] memory groups = factory.getCreatedGroups(0, 2);
        assertEq(groups.length, 2);

        // Get next 2
        groups = factory.getCreatedGroups(2, 2);
        assertEq(groups.length, 2);

        // Get last 1
        groups = factory.getCreatedGroups(4, 2);
        assertEq(groups.length, 1);
    }

    function testGetCreatedGroupsOffsetOutOfBounds() public {
        vm.expectRevert("Offset out of bounds");
        factory.getCreatedGroups(1, 1);
    }

    function testGetAllCreatedGroups() public {
        vm.prank(creator);
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        vm.prank(creator);
        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        PaymentGroupFactory.PaymentGroupInfo[] memory groups = factory.getAllCreatedGroups();
        assertEq(groups.length, 2);
    }

    function testGrantCreatorRole() public {
        vm.prank(deployer);
        factory.grantCreatorRole(nonAuthorized);

        assertTrue(factory.hasRole(factory.CREATOR_ROLE(), nonAuthorized));
    }

    function testGrantCreatorRoleUnauthorized() public {
        vm.prank(nonAuthorized);
        vm.expectRevert();
        factory.grantCreatorRole(address(5));
    }

    function testRevokeCreatorRole() public {
        vm.prank(deployer);
        factory.grantCreatorRole(nonAuthorized);

        vm.prank(deployer);
        factory.revokeCreatorRole(nonAuthorized);

        assertFalse(factory.hasRole(factory.CREATOR_ROLE(), nonAuthorized));
    }

    function testRevokeCreatorRoleUnauthorized() public {
        vm.prank(deployer);
        factory.grantCreatorRole(nonAuthorized);

        vm.prank(nonAuthorized);
        vm.expectRevert();
        factory.revokeCreatorRole(nonAuthorized);
    }

    function testMultipleCreators() public {
        vm.prank(deployer);
        factory.grantCreatorRole(creator);

        vm.prank(deployer);
        factory.grantCreatorRole(nonAuthorized);

        // Both should be able to create
        vm.prank(creator);
        address group1 = factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        vm.prank(nonAuthorized);
        address group2 = factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);

        assertEq(factory.getCreatedGroupsCount(), 2);
    }

    function testEventEmission() public {
        vm.prank(creator);

        vm.expectEmit(false, true, true, true);
        emit PaymentGroupFactory.PaymentGroupCreated(
            address(0), // We don't know the address yet
            mockOriginToken,
            mockPaymentToken,
            admin,
            rewardPercent
        );

        factory.createPaymentGroup(mockOriginToken, mockPaymentToken, admin, rewardPercent);
    }
}