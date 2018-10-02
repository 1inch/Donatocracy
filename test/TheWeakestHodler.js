// @flow

// const EVMRevert = require('./helpers/EVMRevert');

require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

// const Donatocracy = artifacts.require('Donatocracy');

contract('Donatocracy', function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    // let hodl;

    beforeEach(async function () {
        // donatocracy = await Donatocracy.new();
    });
});
