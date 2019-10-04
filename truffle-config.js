/**
 * Truffle configuration
 *
 * @see https://github.com/trufflesuite/truffle-config/blob/master/index.js
 * @see https://github.com/trufflesuite/truffle/releases
 */

const HDWalletProvider = require('truffle-hdwallet-provider');

module.exports = {

    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    networks: {
        _development: {
            host: 'localhost',
            port: 9545,
            network_id: 4447,
            gasPrice: 1,
            gas: 4700000
        },
        local: {
            host: 'localhost',
            port: 8547,
            network_id: '*',
            gasPrice: 1,
            gas: 6712390
        },
        ropsten: {
            provider: new HDWalletProvider("C59941399279F52ADB318E5C922920C89CED2D2F42D1ADE6F59A8C8E929B3E72", "https://ropsten.infura.io/"),
            network_id: 3,
            gasPrice: 10000000000,
            gas: 4712394
        }
    },
    compilers: {
        solc: {
            version: '0.5.6',
            docker: false,
            optimizer: {
                enabled: true,
                runs: 400
            }
        }
    }
};
