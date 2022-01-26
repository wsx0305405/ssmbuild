<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
    <%-- BootStrap 美化介面   --%>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">

</head>
<body>

<div class="container">
    <div class="row clearfix">
        <div class="page-header">
            <h1>
                <small> 書籍列表 -- 新增書籍  </small>
            </h1>
        </div>
    </div>
</div>

<form action="${pageContext.request.contextPath}/book/addBook" method="post">
    <div class="form-group">
        <label> 書籍名稱: </label>
        <input type="text" name="bookName" class="form-control" required>
    </div>
    <div class="form-group">
        <label> 書籍數量: </label>
        <input type="text" name="bookCounts" class="form-control" required>
    </div>
    <div class="form-group">
        <label> 書籍描述: </label>
        <input type="text" name="detail" class="form-control" required>
    </div>
    <div class="form-group">
        <input type="submit" class="form-control" value="添加書籍">
    </div>
</form>

</body>
</html>
