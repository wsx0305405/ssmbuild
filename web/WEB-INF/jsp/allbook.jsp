<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: wsx03
  Date: 2022/1/8
  Time: 下午 09:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title> 查詢全部書籍 </title>
<%-- BootStrap 美化介面   --%>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
</head>
<body>

<div class="container">
    <div class="row clearfix">
        <div class="page-header">
            <h1>
                <small> 書籍列表 -- 顯示所有書籍  </small>
            </h1>
        </div>
        <div class="row text-right">
            <div class="col-md-10 column">
                <%--           新增     --%>
                <a class="btn btn-primary pull-right" href="${pageContext.request.contextPath}/book/toAddBook">新增書籍</a>
                <a class="btn btn-primary pull-right" href="${pageContext.request.contextPath}/book/allbook">顯示全部書籍</a>
            </div>
        </div>

            <div class="col-md-8 column"></br></br>
                <%--           查詢     --%>
                <form action="${pageContext.request.contextPath}/book/queryBook" method="" style="float: right" class="form-inline">
                    <input type="text" name="queryBookName" class="form-control" placeholder="請輸入要查詢的書籍名稱" size="15px" required>
                    <input type="submit" value="查詢" class="btn btn-primary">
                </form>
            </div>

    </div>

    <div class="row clearfix">
        <div class="col-md-12 column">
            <table class="table table-hover table-striped">
                <thead>
                    <tr>
                        <th>書籍編號</th>
                        <th>書籍名稱</th>
                        <th>書籍數量</th>
                        <th>書籍詳情</th>
                    </tr>
                </thead>
<%--                書籍從資料庫中查詢書來 從這個list遍歷 foreach--%>
                <tbody>
                    <c:forEach var="book" items="${list}">
                        <tr>
                            <td>${book.bookID}</td>
                            <td>${book.bookName}</td>
                            <td>${book.bookCounts}</td>
                            <td>${book.detail}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/book/toUpdate?id=${book.bookID}">修改</a>
                                &nbsp; | &nbsp;
                                <a href="${pageContext.request.contextPath}/book/deleteBook/${book.bookID}">刪除</a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>









</body>
</html>
