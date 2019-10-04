pragma solidity ^0.4.21;

contract WineTracker {

    // Contract owner address
    address owner;

    // Production fee for producing a wine shipment unit
    uint productionFee = 0.0001 ether;

    // This modifier restricts a function usage to be only accessible by
    // this contract owner, in the current case the quota authority agency.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // This modifier restricts a function usage to be only accessible by
    // the associated wine producer.
    modifier isProducer(uint _producerId) {
        require(msg.sender == producers[_producerId].producerAddress);
        _;
    }

    // Wine producer representation
    struct WineProducer {
        // IPFS hash for extended info, stored off-chain for costs
        string extendedInfo;

        // Balance of allowed wine production left
        // Unit : centiliters (1/100th of a liter)
        uint32 clBalance;

        // Address of producer account
        // Only this account may emit shipment traces on this producer's behalf
        address producerAddress;
    }

    // Tracing certificate representation
    struct WineShipmentTrace {

        // Producer ID reference
        uint producerId;

        // IPFS hash for extended info of this certificate.
        // Data includes eventual traceability event log
        // Off-chain storage
        string extendedInfo;

        // Container capacity in 1/100th of a liter
        // Example : standard wine bottle has a capacity of 75
        uint16 clCapacity;

        // Validity flag
        // True by default. Set to false in case the shipment compliance with the authority
        // requirement is compromised. This prevents the winemaker from compromising quality
        // even after being awarded the production allowance
        bool is_valid

        // Production date (timestamp)
        uint productionDate;

    }

    // The producers storage
    WineProducer[] producers;

    // The shipment traces storage
    WineShipmentTrace[] shipmentTraces;

    uint producerCount = 0;
    uint tracesCount = 0;

    // Register new producer. Only runnable by the authority.
    function registerProducer(address _producerAddress, string _producerInfoHash) onlyOwner returns(uint) {
        producerCount++;
        producers.push(WineProducer (_producerInfoHash, 0, _producerAddress);
        return (producerCount - 1);
    }

    // Increase producer wine output allowance by the specified value in 1/100th of liter
    function increaseProducerQuota(uint _producerId, uint32 _clQuota) onlyOwner {
        producers[_producerId].clBalance += _clQuota;
    }

    // Set producer wine output allowance by the specified value in 1/100th of liter
    function setProducerQuota(uint _producerId, uint32 _clQuota) onlyOwner {
        producers[_producerId].clBalance = _clQuota;
    }

    // Action from the producer to emit a wine shipment
    // Payable with the appropriate fee
    function emitWineShipment(uint _producerId, uint16 _clContainerCapacity, string _extendedInfoHash) isProducer(_producerId) payable {
        require(msg.value == productionFee);
        require(producers[_producerId].clBalance >= _clContainerCapacity);
        // Withdraw capacity from total allowance
        producers[_producerId].clBalance -= _clContainerCapacity;
        // Emit certificate
        shipmentTraces.push(WineShipmentTrace(_producerId, _extendedInfo, _clContainerCapacity, true, now));
    }

    // Action available for everyone to retrieve traceability info from a wine shipment
    // Useful for customer verification
    function getWineShipmentInfo(uint _shipmentId) external view returns (string, string, uint16, bool, uint) {
        WineShipmentTrace trace = shipmentTraces[_shipmentId];

        return (trace.extendedInfo, trace.extendedInfo, trace.clCapacity, trace.isValid, trace.productionDate);
    }


}
