// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedRideSharing {
    // Struct to represent a ride
    struct Ride {
        address driver;
        uint256 price;
        string startLocation;
        string endLocation;
        bool isAvailable;
        address passenger;
        bool isCompleted;
    }

    // Mapping to store rides
    mapping(uint256 => Ride) public rides;
    uint256 public rideCounter;

    // Events to log important actions
    event RideOffered(uint256 rideId, address driver, uint256 price, string startLocation, string endLocation);
    event RideBooked(uint256 rideId, address passenger);
    event RideCompleted(uint256 rideId);

    // Modifier to ensure only the driver can perform certain actions
    modifier onlyDriver(uint256 rideId) {
        require(msg.sender == rides[rideId].driver, "Only the driver can perform this action");
        _;
    }

    // Modifier to ensure only the passenger can perform certain actions
    modifier onlyPassenger(uint256 rideId) {
        require(msg.sender == rides[rideId].passenger, "Only the passenger can perform this action");
        _;
    }

    // Function to offer a new ride
    function offerRide(uint256 price, string memory startLocation, string memory endLocation) public {
        rideCounter++;
        rides[rideCounter] = Ride({
            driver: msg.sender,
            price: price,
            startLocation: startLocation,
            endLocation: endLocation,
            isAvailable: true,
            passenger: address(0),
            isCompleted: false
        });

        emit RideOffered(rideCounter, msg.sender, price, startLocation, endLocation);
    }

    // Function to book a ride
    function bookRide(uint256 rideId) public payable {
        Ride storage ride = rides[rideId];
        
        require(ride.isAvailable, "Ride is not available");
        require(msg.value >= ride.price, "Insufficient payment");
        
        ride.passenger = msg.sender;
        ride.isAvailable = false;

        emit RideBooked(rideId, msg.sender);
    }

    // Function for the driver to confirm ride completion
    function completeRide(uint256 rideId) public onlyDriver(rideId) {
        Ride storage ride = rides[rideId];
        
        require(!ride.isCompleted, "Ride already completed");
        require(ride.passenger != address(0), "No passenger for this ride");

        // Transfer funds to the driver
        payable(ride.driver).transfer(ride.price);
        
        ride.isCompleted = true;

        emit RideCompleted(rideId);
    }

    // Function to get ride details
    function getRideDetails(uint256 rideId) public view returns (
        address driver,
        uint256 price,
        string memory startLocation,
        string memory endLocation,
        bool isAvailable,
        address passenger,
        bool isCompleted
    ) {
        Ride memory ride = rides[rideId];
        return (
            ride.driver,
            ride.price,
            ride.startLocation,
            ride.endLocation,
            ride.isAvailable,
            ride.passenger,
            ride.isCompleted
        );
    }

    // Fallback function to reject direct sends
    receive() external payable {
        revert("Direct sends not allowed");
    }
}