import { context, ContractPromiseBatch, PersistentMap, PersistentSet } from "near-sdk-as";
import { Request } from "./models";
// context: يستخدم للوصول إلى معلومات العقد الذكي الحالي، مثل عنوان العقد والمرسل والرسالة الحالية.
// ContractPromiseBatch: يستخدم لإدارة دفعات من العمليات المتعددة على الشبكة.
// PersistentMap: يستخدم لإنشاء خرائط ثابتة (لا يمكن تغييرها) للمفاتيح والقيم.
// PersistentSet: يستخدم لإنشاء مجموعات ثابتة (لا يمكن تغييرها) من القيم الفريدة.
@nearBindgen
export class Contract {

  //immutability map
  requests: PersistentMap<string, Request> = new PersistentMap<string, Request>("requests");
  //immutability set
  unfulfilledRequestIds: PersistentSet<string> = new PersistentSet<string>("unfulfilledRequestIds");
  fulfilledRequestIds: PersistentSet<string> = new PersistentSet<string>("fulfilledRequestIds");
  payedbackRequestIds: PersistentSet<string> = new PersistentSet<string>("payedbackRequestIds");

  @mutateState()//بتحديث حالة العقد الذكي
  postBorrowRequest(request: Request): Request {
    //if false return message
    assert(request.paybackTimestamp > context.blockTimestamp, 'Payback time is in the past!');
    assert(request.lender != context.predecessor, 'Cannot borrow from yourself!');
    request.borrower = context.predecessor;//عنوان الحساب الذي قام بإجراء العملية الحالية.
    request.id = context.predecessor + '_' + context.blockTimestamp.toString();
    this.requests.set(request.id, request);//map
    this.unfulfilledRequestIds.add(request.id);//set
    return request;
  }

  @mutateState()
  lend(requestId: string): Request {
    var request: Request = this.requests.getSome(requestId);
    assert(context.attachedDeposit == request.amount, "Attached deposit not equal to request amount!");
    request.lender = context.predecessor;
    this.requests.set(requestId, request);
    ContractPromiseBatch.create(request.borrower).transfer(request.amount);//لإدارة دفعات من العمليات
    this.unfulfilledRequestIds.delete(request.id);
    this.fulfilledRequestIds.add(request.id);
    return request;
  }

  @mutateState()
  payback(requestId: string): Request {
    var request: Request = this.requests.getSome(requestId);
    assert(context.attachedDeposit == request.amount, "Attached deposit not equal to request amount!");
    ContractPromiseBatch.create(request.lender).transfer(request.amount);
    this.fulfilledRequestIds.delete(request.id);
    this.payedbackRequestIds.add(request.id);
    return request;
  }
  //method call in LendListProvider
  getUnfulfilledRequests(): Array<Request> {
    var requests: Array<Request> = new Array<Request>();
    var unfulfilledRequestIds: string[] = this.unfulfilledRequestIds.values();
    for (let i = 0; i < unfulfilledRequestIds.length; i++) {
      requests.push(this.requests.getSome(unfulfilledRequestIds[i]));
    }
    return requests;
  }

  getAccountFulfilledRequests(accountId: string): Array<Request> {
    var requests: Array<Request> = new Array<Request>();
    var fulfilledRequestIds: string[] = this.fulfilledRequestIds.values();
    for (let i = 0; i < fulfilledRequestIds.length; i++) {
      var request = this.requests.getSome(fulfilledRequestIds[i]);
      if (request.borrower == accountId || request.lender == accountId) {
        requests.push(request);
      }
    }
    return requests;
  }
}