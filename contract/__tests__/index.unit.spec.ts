import { Contract } from "../assembly/index";
import { VMContext } from "near-sdk-as";
let contract: Contract;

beforeAll(() => {
    contract = new Contract();
    VMContext.setBlock_timestamp(1656691204149000000); //2022-07-01T16:00:00.000 UTC
});

describe("Main Flow", () => {
    it('Tests the main flow of the app', () => {
    });
});``