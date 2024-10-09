// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import { FarmSimulation} from "../src/Farmsimulator.sol";

contract mocks is Test{
     FarmSimulation farmsimulation;
      address USER = makeAddr("user");
             uint256 plantingCost = 1 ether;
    

      function setUp() external  {
        farmsimulation = new FarmSimulation();
       
        vm.deal(USER,1000e18);
        vm.deal(address(this),100e18);
      }


    function testResgisterfarmer() public {
        vm.prank(USER);
        farmsimulation.registerFarmer("Alice");
        (string memory name, string memory cropType, uint256 cropCount, uint256 tokens, uint256 harvestTime) = 
            farmsimulation.farmers(USER);


            assertEq(name,"Alice");
            assertEq(cropType, "");
            assertEq(cropCount, 0);
            assertEq(tokens, 0);
            assertEq(harvestTime, 0);




    }



    function testPlantCrop() public {
    

    farmsimulation.registerFarmer("Alice");
    
     uint256 cropCount =5;
    // Send enough ether to cover planting costs for 5 crops
      vm.prank(USER);
     farmsimulation.plantCrop{value: plantingCost * cropCount}("Wheat", 5);  
    (, string memory cropType, ,,) =  farmsimulation.farmers(USER);
  
           
            
           
            assertEq(cropType, "Wheat");
            assertEq(cropCount, 5);
            
           



    }



   function testharvestcrop() public {
    farmsimulation.registerFarmer("Alice");
    
     uint256 cropCount =5;
    // Send enough ether to cover planting costs for 5 crops
      vm.prank(USER);
     farmsimulation.plantCrop{value: plantingCost * cropCount}("Wheat", 5);  
    (, string memory cropType, ,,) =  farmsimulation.farmers(USER);
  
           
            
           
            assertEq(cropType, "Wheat");
            assertEq(cropCount, 5);
     
    vm.warp(block.timestamp + 1 days);
     vm.prank(USER);
     farmsimulation.harvestCrop();
      
    (, , ,uint256 tokens,) =  farmsimulation.farmers(USER);


  
            assertEq(tokens, 50);
           

   }


   function testUpdateLeaderboard() public {
        vm.prank(USER);
        farmsimulation.registerFarmer("Alice");
        
        vm.prank(USER);
        farmsimulation.updateLeaderboard();

        address[] memory leaderboard = farmsimulation.getLeaderboard();
        assertEq(leaderboard[0], USER);
    }
}









