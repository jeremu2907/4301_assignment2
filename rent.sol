// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RentManagementSystem {
    address public landlord;
    
    struct Property {
        string name;
        uint256 monthlyRent;
        uint256 securityDeposit;
        uint256 timestamp;
        bool isOccupied;
        address tenant;
    }
    
    mapping(uint256 => Property) public properties;
    uint256 public propertyCount;
    
    modifier onlyLandlord() {
        require(msg.sender == landlord, "Only landlord can perform this action");
        _;
    }
    
    constructor() {
        landlord = msg.sender;
    }

    function getAllProperties() public view returns (Property[] memory) {
        Property[] memory allProperties = new Property[](propertyCount);
        
        for (uint256 i = 1; i <= propertyCount; i++) {
            allProperties[i - 1] = properties[i];
        }
        
        return allProperties;
    }

    function getAllTenants() public view returns (address[] memory) {
        address [] memory allTenants = new address[](propertyCount);

        for (uint256 i = 1; i <= propertyCount; i++) {
            allTenants[i - 1] = properties[i].tenant;
        }

        return allTenants;
    }
    
    function addProperty(string memory _name, uint256 _monthlyRent, uint256 _securityDeposit) public onlyLandlord {
        propertyCount++;
        properties[propertyCount] = Property(_name, _monthlyRent, _securityDeposit, block.timestamp, false, address(0));
    }
    
    function addTenantToProperty(uint256 _propertyId, address _tenant) public onlyLandlord {
        require(_propertyId <= propertyCount, "Invalid property ID");
        require(properties[_propertyId].isOccupied == false, "Property is already occupied");
        properties[_propertyId].isOccupied = true;
        properties[_propertyId].tenant = _tenant;
    }
    
    function paySecurityDeposit(uint256 _propertyId) public payable {
        require(_propertyId <= propertyCount, "Invalid property ID");
        require(properties[_propertyId].isOccupied == true, "Property is not occupied");
        require(msg.value == properties[_propertyId].securityDeposit, "Incorrect security deposit amount");
        payable(landlord).transfer(msg.value);
    }
    
    function payRent(uint256 _propertyId) public payable {
        require(_propertyId <= propertyCount, "Invalid property ID");
        require(properties[_propertyId].isOccupied == true, "Property is not occupied");
        require(msg.value == properties[_propertyId].monthlyRent, "Incorrect rent amount");
    }
    
    function withdrawRent(uint256 _amount) public onlyLandlord {
        require(_amount <= address(this).balance, "Insufficient contract balance");
        payable(landlord).transfer(_amount);
    }
    
    function terminateLease(uint256 _propertyId) public onlyLandlord {
        require(_propertyId <= propertyCount, "Invalid property ID");
        require(properties[_propertyId].isOccupied == true, "Property is not occupied");
        properties[_propertyId].isOccupied = false;
        payable(properties[_propertyId].tenant).transfer(properties[_propertyId].securityDeposit);
        properties[_propertyId].tenant = address(0);
    }
}
