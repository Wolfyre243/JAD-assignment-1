<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<h1>Edit Service</h1>
<a href="<%= request.getContextPath() %>/admin/services">Back to Services</a>

<%
    java.util.Map<String,Object> service = (java.util.Map<String,Object>) request.getAttribute("service");
    java.util.List<java.util.Map<String,Object>> categories = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("categories");
    String serviceError = (String) request.getAttribute("serviceError");
    if (serviceError != null) {
%>
    <p style="color:red;"><%= serviceError %></p>
<%
    } else if (service == null) {
%>
    <p><em>No service selected.</em></p>
<%
    } else {
        int productId = (Integer) service.get("productId");
        String name = (String) service.get("name");
        int selectedCat = (Integer) service.get("categoryId");
        String description = (String) service.get("description");
        double price = (Double) service.get("price");
        boolean isActive = (Boolean) service.get("isActive");
%>
    <form action="<%= request.getContextPath() %>/admin/service" method="post">
        <input type="hidden" name="action" value="edit">
        <input type="hidden" name="productId" value="<%= productId %>">
        <table>
            <tr>
                <td>Name</td>
                <td><input type="text" name="name" value="<%= name %>" required></td>
            </tr>
            <tr>
                <td>Category</td>
                <td>
                    <select name="categoryId" required>
                        <% if (categories != null) {
                            for (java.util.Map<String,Object> c : categories) {
                                int catId = (Integer) c.get("categoryId");
                                String catName = (String) c.get("categoryName");
                                boolean selected = (catId == selectedCat);
                        %>
                                <option value="<%= catId %>" <%= selected ? "selected" : "" %>><%= catName %></option>
                        <%   }
                        } %>
                    </select>
                </td>
            </tr>
            <tr>
                <td>Description</td>
                <td><textarea name="description" rows="5" cols="50"><%= description != null ? description : "" %></textarea></td>
            </tr>
            <tr>
                <td>Price</td>
                <td><input type="number" name="price" step="0.01" min="0" value="<%= String.format("%.2f", price) %>" required></td>
            </tr>
            <tr>
                <td>Active</td>
                <td>
                    <input type="radio" name="isActive" value="true" <%= isActive ? "checked" : "" %>> Yes
                    <input type="radio" name="isActive" value="false" <%= !isActive ? "checked" : "" %>> No
                </td>
            </tr>
            <tr>
                <td></td>
                <td>
                    <button type="submit">Save</button>
                    <a href="<%= request.getContextPath() %>/admin/services">Cancel</a>
                </td>
            </tr>
        </table>
    </form>
<%
    }
%>

<%@ include file="/WEB-INF/components/common/footer.jsp" %>