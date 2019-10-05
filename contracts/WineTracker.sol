pragma solidity ^0.5.6;

contract WineTracker {

    // Wine producer representation
    struct Producer {
        // Address of producer account
        // Only this account may emit shipment traces on this producer's behalf
        address account;

        // IPFS hash for extended info, stored off-chain for costs
        string extendedInfo;

        // Balance of allowed wine production left
        // Unit : centiliters (1/100th of a liter)
        uint32 clBalance;
    }

    // Tracing certificate representation
    struct ShipmentTrace {

        uint32 producerId;

        // Container capacity in 1/100th of a liter
        // Example : standard wine bottle has a capacity of 75
        uint16 clCapacity;

        // Production date (timestamp)
        uint productionDate;

        // IPFS hash for extended info of this certificate.
        // Data includes eventual traceability event log
        // Off-chain storage
        string extendedInfo;

        // Validity flag
        // True by default. Set to false in case the shipment compliance with the authority
        // requirement is compromised. This prevents the winemaker from compromising quality
        // even after being awarded the production allowance
        bool isValid;
    }

    // Contract owner address
    address public owner;

    // Production fee for producing a wine shipment unit
    uint constant productionFee = 0.0001 ether;

    // The producers storage
    Producer[] producers;

    // The shipment traces storage
    ShipmentTrace[] shipmentTraces;

    uint producerCount = 0;
    uint tracesCount = 0;

    // This modifier restricts a function usage to be only accessible by
    // this contract owner, in the current case the quota authority agency.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // This modifier restricts a function usage to be only accessible by
    // the associated wine producer.
    modifier isProducer(uint _id) {
        require(msg.sender == producers[_id].account);
        _;
    }

    // Register new producer. Only runnable by the authority.
    function registerProducer(address _address, string memory _infoHash) onlyOwner public returns (uint) {
        producers.push(Producer(_address, _infoHash, 0));
        return producerCount++;
    }

    // Set producer wine output allowance by the specified value in 1/100th of liter
    function setProducerQuota(uint _id, uint32 _clQuota) onlyOwner public {
        producers[_id].clBalance = _clQuota;
    }

    // Action from the producer to emit a wine shipment
    // Payable with the appropriate fee
    function emitWineShipment(uint32 _producerId, uint16 _clContainerCapacity, string memory _extendedInfoHash) isProducer(_producerId) payable public {
        require(msg.value == productionFee);
        require(producers[_producerId].clBalance >= _clContainerCapacity);
        // Withdraw capacity from total allowance
        producers[_producerId].clBalance -= _clContainerCapacity;
        // Emit certificate
        shipmentTraces.push(ShipmentTrace(_producerId, _clContainerCapacity, now, _extendedInfoHash, true));
    }

    // Action available for everyone to retrieve traceability info from a wine shipment
    // Useful for customer verification
    function getWineShipmentInfo(uint _shipmentId) external view returns (string memory, string memory, uint16, bool, uint) {
        ShipmentTrace memory trace = shipmentTraces[_shipmentId];
        return (trace.extendedInfo, trace.extendedInfo, trace.clCapacity, trace.isValid, trace.productionDate);
    }
}