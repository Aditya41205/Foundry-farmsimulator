// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FarmSimulation} from "../src/Farmsimulator.sol";

contract deploy is Script{
     function run() external returns(FarmSimulation){
       vm.startBroadcast();
       FarmSimulation farmsimulation= new FarmSimulation();
       vm.stopBroadcast();
       return farmsimulation;
     }

}