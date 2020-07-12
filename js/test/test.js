
const { pow } = require('../pow.js');

var assert = require('assert');

describe('Array', () => {
    describe('#indexOf()', () => {
        it('should return -1 when value not present', () => {
            assert.equal([1, 2, 3].indexOf(4), -1);
        })
    })
})

describe ("pow", () => {

    it("raises to the n-th power", () => {
        assert.equal(pow(2, 3), 8);
        assert.equal(pow(3, 4), 81);
    })
})