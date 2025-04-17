// Ensure the Account class is correctly exported
export class Account {
  // Explicit types for each member
  id: number;
  username: string;
  password: string;

  // Constructor with types explicitly defined
  constructor(id: number, username: string, password: string) {
    this.id = id;
    this.username = username;
    this.password = password;
  }
}
