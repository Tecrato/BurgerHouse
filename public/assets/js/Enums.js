
export class Response {
  constructor(status, data) {
    this.__status = status;
    this.__data = data;
  }
  json() {
    return JSON.parse(this.__data);
  }
  get text() {
    return this.__data;
  }
  get data() {
    return this.__data;
  }
  toString() {
    return this.__data;
  }
  get length() {
    return this.__data.toString().length;
  }
  get status() {
    return this.__status;
  }
  get code() {
    return this.__status;
  }
}
