import { u128 } from "near-sdk-as";
//The u128 data type represents an unsigned 128-bit integer that can take values ranging from 0 to 2^128-1.
// This data type is used in many cases, such as representing money and balances in smart contracts,
// where the money and balances can be stored as u128 values.

@nearBindgen
export class Request {
  id: string;
  borrower: string;
  lender: string;
  desc: string;
  paybackTimestamp: u64;
  amount: u128;

  constructor(
    id: string,
    borrower: string,
    lender: string,
    desc: string,
    paybackTimestamp: u64,
    amount: u128
  ) {
    this.id = id;
    this.borrower = borrower;
    this.lender = lender;
    this.desc = desc;
    this.paybackTimestamp = paybackTimestamp;
    this.amount = amount;
  }
}