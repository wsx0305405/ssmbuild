package com.service;

import com.pojo.Books;
import org.apache.ibatis.annotations.Param;

import java.util.List;

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

    // 根據名字查詢書籍
    Books queryBookByName(String bookName);
}
