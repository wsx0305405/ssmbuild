<%--
  Created by IntelliJ IDEA.
  User: wsx03
  Date: 2022/1/12
  Time: 下午 09:56
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title> 修改書籍 </title>
</head>
<body>

<form action="${pageContext.request.contextPath}/book/updateBook" method="post">
<%--  更新資料 根據 where bookID=#{bookId}  --%>
<%--  需要添加id決定更新的書籍  --%>
<%--  前端傳遞隱藏域  由後端自動運行傳遞id --%>
    <input type="hidden" name="bookID" value="${Qbook.bookID}">

    <div class="form-group">
        <label> 書籍名稱: </label>
        <input type="text" name="bookName" class="form-control" value="${Qbook.bookName}" required>
    </div>
    <div class="form-group">
        <label> 書籍數量: </label>
        <input type="text" name="bookCounts" class="form-control" value="${Qbook.bookCounts}" required>
    </div>
    <div class="form-group">
        <label> 書籍描述: </label>
        <input type="text" name="detail" class="form-control" value="${Qbook.detail}" required>
    </div>
    <div class="form-group">
        <input type="submit" class="form-control" value="修改書籍">
    </div>
</form>


</body>
</html>
