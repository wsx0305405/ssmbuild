package com.controller;

import com.pojo.Books;
import com.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;

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

    @RequestMapping("toUpdate")
    // 跳轉至修改頁面
    public String toUpdate(int id,Model model){
        Books books = bookService.queryBookById(id);
        model.addAttribute("Qbook",books);
        return "updateBook";
    }

    // 修改書籍
    @RequestMapping("/updateBook")
    public String update(Books books){
        System.out.println("updateBook=>" + books);
        bookService.updateBook(books);

        return "redirect:/book/allbook";
    }

    // 刪除書籍
    @RequestMapping("/deleteBook/{bookID}")
    public String deleteBook(@PathVariable("bookID") int id){
        System.out.println("deleteBookid=>" + id);
        bookService.deleteBookById(id);
        return "redirect:/book/allbook";
    }

    // 查詢書籍
    @RequestMapping("/queryBook")
    public String queryBook(String queryBookName,Model model){
        Books books = bookService.queryBookByName(queryBookName);
        List<Books> list = new ArrayList<>();
        list.add(books);
        model.addAttribute("list",list);
        return "allbook";
    }
}
