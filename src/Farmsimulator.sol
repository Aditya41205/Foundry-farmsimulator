// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract FarmSimulation {
    // Variables
    struct Farmer {
        string name;
        string cropType;
        uint256 cropCount;
        uint256 tokens;
        uint256 harvestTime;
    }

    mapping(address => Farmer) public farmers;
    string[] public cropAvailable = ["Wheat", "Rice", "Corn", "Cotton"];
    address[] public leaderboard;
    uint256 public plantingCost = 1 ether; // Cost to plant a crop

    // Events
    event CropPlanted(address indexed farmer, string cropType, uint256 cropCount);
    event CropHarvested(address indexed farmer, string cropType, uint256 cropCount);
    event CropTraded(address indexed seller, address indexed buyer, string cropType, uint256 cropCount);

    // Function to register a farmer
    function registerFarmer(string memory _name) public {
        require(bytes(farmers[msg.sender].name).length == 0, "Farmer already registered");
        farmers[msg.sender] = Farmer(_name, "", 0, 0, 0);
    }

    // Function to plant crops
    function plantCrop(string memory _cropType, uint256 _cropCount) public payable {
        require(msg.value == plantingCost * _cropCount, "Insufficient funds for planting");
        require(isValidCrop(_cropType), "Invalid crop type");

        Farmer storage farmer = farmers[msg.sender];
        farmer.cropType = _cropType;
        farmer.cropCount += _cropCount;
        farmer.harvestTime = block.timestamp + 1 days; // Set harvest time for 1 day

        emit CropPlanted(msg.sender, _cropType, _cropCount);
    }

    // Function to harvest crops
    function harvestCrop() public {
        Farmer storage farmer = farmers[msg.sender];
        require(farmer.cropCount > 0, "No crops to harvest");
        require(block.timestamp >= farmer.harvestTime, "Crops are not ready for harvest yet");

       
        uint256 tokensEarned = farmer.cropCount * 10; // 10 tokens per crop
        farmer.tokens += tokensEarned;

        emit CropHarvested(msg.sender, farmer.cropType, farmer.cropCount);
        farmer.cropCount = 0; // Reset crop count after harvesting
    }

    // Function to trade crops
    function tradeCrop(address _buyer, uint256 _cropCount) public {
        Farmer storage seller = farmers[msg.sender];
        Farmer storage buyer = farmers[_buyer];
        require(seller.cropCount >= _cropCount, "Insufficient crops to trade");

        seller.cropCount -= _cropCount;
        buyer.cropCount += _cropCount;

        emit CropTraded(msg.sender, _buyer, seller.cropType, _cropCount);
    }

    // Function to check if a crop type is valid
    function isValidCrop(string memory _cropType) internal view returns (bool) {
        for (uint256 i = 0; i < cropAvailable.length; i++) {
            if (keccak256(abi.encodePacked(cropAvailable[i])) == keccak256(abi.encodePacked(_cropType))) {
                return true;
            }
        }
        return false;
    }

    // Function to update leaderboard 
    function updateLeaderboard() public {
       
        leaderboard.push(msg.sender);
    }

    // Function to get leaderboard
    function getLeaderboard() public view returns (address[] memory) {
        return leaderboard;
    }
}