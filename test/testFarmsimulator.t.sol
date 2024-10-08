// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Farmsimulator.sol"; // Adjust the path based on your structure

contract FarmSimulationTest is Test {
    FarmSimulation farmSimulation;
    address farmer1 = address(0x1);
    address farmer2 = address(0x2);

    function setUp() public {
        farmSimulation = new FarmSimulation();
    }

    function testRegisterFarmer() public {
        vm.prank(farmer1);
        farmSimulation.registerFarmer("Alice");

        // Accessing farmer details
        (string memory name, string memory cropType, uint256 cropCount, uint256 tokens, uint256 harvestTime) = 
            farmSimulation.farmers(farmer1);
        
        assertEq(name, "Alice");
        assertEq(cropType, "");
        assertEq(cropCount, 0);
        assertEq(tokens, 0);
        assertEq(harvestTime, 0);
    }

    function testPlantCrop() public {
        vm.prank(farmer1);
        farmSimulation.registerFarmer("Alice");
        
        // Set the balance for farmer1 to have enough Ether
        vm.deal(farmer1, 100 ether);

        // Call plantCrop normally
        vm.prank(farmer1);
        farmSimulation.plantCrop("Wheat", 5); // Sending Ether should happen implicitly

        // Accessing farmer details
        (string memory name, string memory cropType, uint256 cropCount, uint256 tokens, uint256 harvestTime) = 
            farmSimulation.farmers(farmer1);

        assertEq(cropType, "Wheat");
        assertEq(cropCount, 5);
        assertTrue(harvestTime > block.timestamp);
    }

    function testHarvestCrop() public {
        vm.prank(farmer1);
        farmSimulation.registerFarmer("Alice");
        
        // Set the balance for farmer1 to have enough Ether
        vm.deal(farmer1, 100 ether);
        
        vm.prank(farmer1);
        farmSimulation.plantCrop("Wheat", 5);

        // Fast forward time to ensure crops can be harvested
        vm.warp(block.timestamp + 1 days);
        
        vm.prank(farmer1);
        farmSimulation.harvestCrop();

        // Accessing farmer details
        (string memory name, string memory cropType, uint256 cropCount, uint256 tokens, uint256 harvestTime) = 
            farmSimulation.farmers(farmer1);

        assertEq(cropCount, 0);
        assertEq(tokens, 50); // 5 crops * 10 tokens
    }

    function testTradeCrop() public {
        vm.prank(farmer1);
        farmSimulation.registerFarmer("Alice");
        
        // Set the balance for farmer1 to have enough Ether
        vm.deal(farmer1, 100 ether);
        
        vm.prank(farmer1);
        farmSimulation.plantCrop("Wheat", 10);

        vm.warp(block.timestamp + 1 days);
        vm.prank(farmer1);
        farmSimulation.harvestCrop();

        vm.prank(farmer2);
        farmSimulation.registerFarmer("Bob");
        
        vm.prank(farmer1);
        farmSimulation.tradeCrop(farmer2, 5);

        // Accessing farmer details
        (string memory name, string memory cropType, uint256 sellerCropCount, uint256 sellerTokens, uint256 sellerHarvestTime) = 
            farmSimulation.farmers(farmer1);
        
        (string memory buyerName, string memory buyerCropType, uint256 buyerCropCount, uint256 buyerTokens, uint256 buyerHarvestTime) = 
            farmSimulation.farmers(farmer2);

        assertEq(sellerCropCount, 5);
        assertEq(buyerCropCount, 5);
    }

    function testUpdateLeaderboard() public {
        vm.prank(farmer1);
        farmSimulation.registerFarmer("Alice");
        
        vm.prank(farmer1);
        farmSimulation.updateLeaderboard();

        address[] memory leaderboard = farmSimulation.getLeaderboard();
        assertEq(leaderboard[0], farmer1);
    }
}
