package models;

public class Role {
  private int roleId;
  private String name;

  public Role(int roleId, String name) {
    super();
    this.roleId = roleId;
    this.name = name;
  }

  public int getRoleId() {
    return roleId;
  }

  public String getRoleName() {
    return name;
  }
}
