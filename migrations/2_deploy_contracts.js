var WineTracker = artifacts.require("WineTracker");

module.exports = function(deployer) {
  deployer.deploy(WineTracker);
};