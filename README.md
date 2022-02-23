## 書籍管理系統

整合了 MySQL Mybatis Spring SpringMVC 的練習專案



#### 環境設置

- MySQL資料庫

```mysql
create database `ssmbuild`;
use `ssmbuild`;

select * from `books`;
drop table if exists `books`;

create table `books`(
	`bookID` int(10) not null auto_increment comment '書id',
    `bookName` varchar(100) not null comment '書名',
	`bookCounts` int(11) not null comment '數量',
    `detail` varchar(200) not null comment '描述',
    key `bookID` (`bookID`)
)engine=innodb default charset=utf8;

insert into `books` 
(`bookID`,`bookName`,`bookCounts`,`detail`) values
(1,'java',1,'從入門到放棄'),
(2,'MySql',10,'從刪庫到跑路'),
(3,'Linux',5,'從進門到進牢');
```

- IDEA中對應的資料庫連接數據 database.properties
  - 必須按照官方的寫法 jdbc.屬性名

```properties
jdbc.driver=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://localhost:3306/ssmbuild?useSSL=true&useUnicode=true&characterEncoding=utf8&serverTimezone=UTC
jdbc.username=root
jdbc.password=123456
```

- 對應資料庫的實體類 Books

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Books {
    private int bookID;
    private String bookName;
    private int bookCounts;
    private String detail;
}
```



#### Mybatis層

- Dao層  BookMapper 
  - 介面 基本操作方法

```java
public interface BookMapper {

    // 增加一本書
    int addBook(Books books);

    // 刪除一本書
    int deleteBookById(@Param("bookID") int id);

    // 更新一本書
    int updateBook(Books books);

    // 查詢一本書
    Books queryBookById(@Param("bookID") int id);

    // 查詢全部的書
    List<Books> queryAllBook();

}
```

- 配置對應的Dao實現類  BookMapper.xml
  - 方法的實現
  - 使用Mybatis 配置 BookMapper.xml檔案

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.dao.BookMapper">
    <insert id="addBook" parameterType="com.pojo.Books">
        insert into books (bookName,bookCounts,detail)
        values (#{bookName},#{bookCounts},#{detail});
    </insert>
    <delete id="deleteBookById" parameterType="int">
        delete from books where bookID=#{bookId}
    </delete>

    <update id="updateBook" parameterType="com.pojo.Books">
        update books
        set bookName = #{bookName},bookCounts=#{bookCounts},detail=#{detail}
        where bookID=#{bookID};
    </update>

    <select id="queryBookById" resultType="com.pojo.Books">
        select * from books
        where bookID=#{bookID};
    </select>

    <select id="queryAllBook" resultType="com.pojo.Books">
        select * from books;
    </select>
</mapper>
```

- Service層  BookService
  - 連接Dao層 --> 使用Serivce調用Dao層 組合
- 介面

```java
public interface BookService {

    // 增加一本書
    int addBook(Books books);

    // 刪除一本書
    int deleteBookById(int id);

    // 更新一本書
    int updateBook(Books books);

    // 查詢一本書
    Books queryBookById(int id);

    // 查詢全部的書
    List<Books> queryAllBook();
}
```

- 實作類  BookServiceImpl
  - 建立一個Dao的介面 執行Dao的方法

```java
public class BookServiceImpl implements BookService{

    // Service調用Dao層 : 組合Dao
    private BookMapper bookMapper;

    public void setBookMapper(BookMapper bookMapper) {
        this.bookMapper = bookMapper;
    }

    @Override
    public int addBook(Books books) {
        return bookMapper.addBook(books);
    }

    @Override
    public int deleteBookById(int id) {
        return bookMapper.deleteBookById(id);
    }

    @Override
    public int updateBook(Books books) {
        return bookMapper.updateBook(books);
    }

    @Override
    public Books queryBookById(int id) {
        return bookMapper.queryBookById(id);
    }

    @Override
    public List<Books> queryAllBook() {
        return bookMapper.queryAllBook();
    }
}
```

- Mybatis配置文件 mybatis-config.xml
  - 綁定dao介面

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

<!-- 配置資料源 交給Spring做   -->
    <typeAliases>
        <package name="com.pojo"/>
    </typeAliases>

    <mappers>
        <mapper resource="com/dao/BookMapper"></mapper>
    </mappers>

</configuration>
```



#### Spring層

- spring-dao層  spring-dao.xml
  - 關聯資料庫的配置文件
    - 連接至設置好的配置文件 properties
  - 連接池
    - 選擇一種連接池的支持
    - 連接資料庫對應的數據
  - SqlSessionFactory
    - 由SqlSessionFactoryBean建立
    - property -> dataSource參考上方配置的資料庫對應數據
    - 綁定Mybatis文件
  - 配置dao介面掃描包 動態實現Dao介面注入Spring容器中
    - MapperScannerConfigurer
      - MapperScannerConfigurer掃描這個包中的所有介面  把每個介面都執行一次getMapper()方法 得到每個介面的dao對象
    - 注入sqlSessionFactory
    - 指定要掃描的dao包

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

<!-- 1 關聯資料庫配置文件   -->
<context:property-placeholder location="classpath:database.properties"></context:property-placeholder>

<!-- 2 連接池
       dbcp 半自動化操作 不能自動連接
       c3p0 自動化操作 自動化的載入配置文件 並且可以自動設置到對象中
       druid
       hikari
-->
    <bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
        <property name="driverClass" value="${jdbc.driver}"></property>
        <property name="jdbcUrl" value="${jdbc.url}"></property>
        <property name="user" value="${jdbc.username}"></property>
        <property name="password" value="${jdbc.password}"></property>

        <!--   c3p0連接池的私有屬性   -->
        <property name="maxPoolSize" value="30"></property>
        <property name="minPoolSize" value="10"></property>
        <!--   關閉連接後不自動commit     -->
        <property name="autoCommitOnClose" value="false"></property>
        <!--   獲取連接超時時間     -->
        <property name="checkoutTimeout" value="10000"></property>
        <!--   當獲取連接失敗重試次數     -->
        <property name="acquireRetryAttempts" value="2"></property>

    </bean>

<!-- 3 SqlSessionFactory  -->
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"></property>
<!--   綁定Mybatis的配置文件     -->
        <property name="configLocation" value="classpath:mybatis-config.xml"></property>
     </bean>

<!-- 4 配置dao介面掃描包 動態的實現Dao介面可以注入到Spring容器中  -->
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
<!--  注入 sqlSessionFactory      -->
<!--  通過掃描value(String)       -->
        <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory"></property>
<!--  要掃描的dao包  -->
        <property name="basePackage" value="com.dao"></property>
    </bean>


</beans>
```

- Serivce層  sping-service.xml
  - 掃描Service下的包
  - 將業務注入到Spring
  - 聲明式事務配置
  - aop事務

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

<!-- 1 掃描service下的包   -->
    <context:component-scan base-package="com.service"></context:component-scan>
<!-- 2 將我們的所有業務 注入到spring 可以通過配置 或是 註解實現-->
<!--  <import resource="classpath:spring-dao.xml"></import> IDEA配置 或是引入dao層文件  -->
    <bean id="BookServiceImpl" class="com.service.BookServiceImpl">
        <property name="bookMapper" ref="bookMapper"></property>
    </bean>
<!-- 3 聲明式事務配置 -->
    <bean id="TransactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
<!--   注入數據源     -->
        <property name="dataSource" ref="dataSource"></property>
    </bean>
<!-- 4 aop事務支持   -->

</beans>
```



#### SpringMVC層 

- 增加web支持   web.xml
- 配置web.xml
  - 載入 DispatchServlet
    - 連接spring-mvc.xml (applicationContext.xml) bean
  - 亂碼過濾
    - 配置路徑 /* 包含jsp的過濾
  - Session時效過期配置

```xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
         version="4.0">

<!-- DispatchServlet   -->
    <servlet>
        <servlet-name>springmvc</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>classpath:applicationContext.xml</param-value>
        </init-param>
    </servlet>
    <servlet-mapping>
        <servlet-name>springmvc</servlet-name>
        <url-pattern>/</url-pattern>
    </servlet-mapping>

<!-- 亂碼過濾   -->
    <filter>
        <filter-name>encodingFilter</filter-name>
        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>utf-8</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>encodingFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>
    
<!-- Session -->
<session-config>
    <session-timeout>15</session-timeout>
</session-config>

</web-app>
```

- 配置spring-mvc.xml
  - 註解驅動
  - 靜態資源過濾
  - 掃描包 controller
    - 指定路徑
  - 視圖解析器
    - 前綴
    - 後綴

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd 
        http://www.springframework.org/schema/mvc 
        https://www.springframework.org/schema/mvc/spring-mvc.xsd 
        http://www.springframework.org/schema/context 
        https://www.springframework.org/schema/context/spring-context.xsd">

<!-- 註解驅動   -->
<mvc:annotation-driven></mvc:annotation-driven>
<!-- 靜態資源過濾   -->
<mvc:default-servlet-handler></mvc:default-servlet-handler>
<!-- 掃描包 controller   -->
<context:component-scan base-package="com.controller"></context:component-scan>
<!-- 視圖解析器   -->
    <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
<!--   前綴  後綴     -->
        <property name="prefix" value="/WEB-INF/jsp/"></property>
        <property name="suffix" value=".jsp"></property>
    </bean>

</beans>
```



#### 查詢書籍功能

- Controller -->  BookController
  - 視圖跳轉管理


```java
@Controller
@RequestMapping("/book")
public class BookController {
    // controller 調 service層

    @Autowired
    @Qualifier("BookServiceImpl")
    private BookService bookService;

    // 查詢全部的書籍 並且返回一個書籍展示頁面
    @RequestMapping("/allbook")
    public String list(Model model){
        List<Books> list = bookService.queryAllBook();
        model.addAttribute("list",list);
        return "allbook";
    }
}
```

- 首頁  index.jsp
  - 點擊移動到 /book/allbook 進行controller方法內
  - controller方法執行完return回視圖

```jsp
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>$Title$</title>
    <style>
      a{
        text-decoration: none;
        color: black;
        font-size: 18px;
      }
      h3{
        width: 180px;
        height: 38px;
        margin: 100px auto;
        text-align: center;
        line-height: 38px;
        background: moccasin;
        border-radius: 5px;
      }
    </style>

  </head>
  <body>
  <h3>
    <a href="${pageContext.request.contextPath}/book/allbook"> 進入書籍頁面 </a>
  </h3>
  </body>
</html>
```

- allbook.jsp

```jsp
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
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>
```



#### 排錯思路

- bean不存在
  - 查看這個bean是否注入成功
  - Junit單元測試  測試是否能夠查詢出來結果
  - 問題不在底層  尋找Spring中的問題
  - SpringMVC 整合的時候沒調用到我們的service層的bean
    - applicationContext.xml 沒有注入bean
    - web.xml中 我們也綁定過配置文件





#### 添加書籍功能

- allbook.jsp中新增 增加書籍按鈕
  - 移動到路徑 /book/toAddBook 

```jsp
<div class="container">
    <div class="row clearfix">
        <div class="page-header">
            <h1>
                <small> 書籍列表 -- 顯示所有書籍  </small>
            </h1>
        </div>
        <div class="row">
            <div class="col-md-5 column">
<%--           toaddBook     --%>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/toAddBook">新增書籍</a>
            </div>
        </div>
    </div>
```

- Controller
  - toAddPaper() 接收 /book/toAddBook 路徑的請求
    - 傳遞視圖/book/addBook
    - addBook方法處理由表單傳遞的資料
      - 調用Service層對應的 addBook方法將資料傳遞與資料庫連接
      - 最後重定向回 redirect:/book/allbook

```java
// 跳轉到增加書籍頁面
    @RequestMapping("/toAddBook")
    public String toAddPaper(){
        return "addBook";
    }    
    
// 添加書籍的請求
@RequestMapping("/addBook")
public String addBook(Books books){
    System.out.println("addBook=>"+books);
    bookService.addBook(books);
    // 重定向到 @RequestMapping("/allbook")請求
    return "redirect:/book/allbook";
}
```



- addBook.jsp 視圖
  - 提供一個表單傳遞新增的書籍
  - form action="${pageContext.request.contextPath}/book/addBook" 將路徑傳回 
  - 由 /book/addBook 中  controller的 addBook 處理傳遞的資料

```jsp
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
```



#### 修改刪除書籍

- allbook.jsp
  - 在每個欄位後面加入 修改 刪除 的選項
    - 以及為這兩個選項定義跳轉的頁面 帶入book.bookID參數
    - 跳轉至 /book/deleteBook/${book.bookID} 並帶入book.bookID

```jsp
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
```

- Controller
  - 

```java
// 刪除書籍
@RequestMapping("/deleteBook/{bookID}")
public String deleteBook(@PathVariable("bookID") int id){
    System.out.println("deleteBookid=>" + id);
    bookService.deleteBookById(id);
    return "redirect:/book/allbook";
}
```

- BookMapper
  - 與SQL語句傳入的參數對應
    - where id = #{id}

```xml
<delete id="deleteBookById" parameterType="int">
    delete from books where bookID=#{bookId}
</delete>
```



#### 查詢書籍

- 設計思維 由底層往上設計
- dao

```java
// 根據名字查詢書籍
Books queryBookByName(@Param("bookName") String bookName);
```

- 對應dao的Mapper
  - 設計對應的SQL語句 使用模糊查詢
  - 模糊查詢 判斷為空 : if(list.size()==0)

```xml
<select id="queryBookByName" resultType="com.pojo.Books">
    select * from books
    where bookName like concat('%',#{bookName},'%');
</select>
```

- Service層
  - 調用dao層的方法
  - private BookMapper bookMapper;

```java
@Override
public Books queryBookByName(String bookName) {
    return bookMapper.queryBookByName(bookName);
}
```

- allbook
  - 在首頁allbook中加入查詢按鈕
  - 將結果提交 action="${pageContext.request.contextPath}/book/queryBook" 

```jsp
<div class="col-md-8 column"></br></br>
    <%--           查詢     --%>
    <form action="${pageContext.request.contextPath}/book/queryBook" method="" style="float: right" class="form-inline">
        <input type="text" name="queryBookName" class="form-control" placeholder="請輸入要查詢的書籍名稱" size="15px" required>
        <input type="submit" value="查詢" class="btn btn-primary">
    </form>
</div>
```

- controller
  - controller中接收對應的提交路徑 /book/queryBook
  - 與查詢所有書籍相同 使用list將符合結果的資料放入 由前端顯示

```java
// 查詢書籍
@RequestMapping("/queryBook")
public String queryBook(String queryBookName,Model model){
    Books books = bookService.queryBookByName(queryBookName);
    List<Books> list = new ArrayList<>();
    list.add(books);
    model.addAttribute("list",list);
    return "allbook";
}
```

- 加入顯示所有書籍的按鈕
  - 將路徑導向 @RequestMapping("/allbook") 實行一遍查詢所有書籍

```jsp
<a class="btn btn-primary pull-right" href="${pageContext.request.contextPath}/book/allbook">顯示全部書籍</a>
```
