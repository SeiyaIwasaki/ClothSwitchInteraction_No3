/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/


/** アプリケーション：「ブックプレイヤー」 **/
class AppBookPlayer{
    /*-- Field --*/
    private Rectangle appField;             // アプリケーション描画用画面割り当て
    private Point fieldCenter;              // 画面中心位置
    private Book book;                      // ブック
    private int activePageNum;              // 現在選択中のページ数


    /*-- Constractor --*/
    AppBookPlayer(){
        initBook();
        activePageNum = 0;
    }

    // アプリの描画位置を入力
    public void inputPosition(int id, int qty){
        appField = new Rectangle((width / qty) * (id - 1), 0, width / qty, height);
        fieldCenter = new Point(appField.x + appField.width / 2, appField.y + appField.height / 2);
    }

    // 選択中の本の初期化
    public void initBook(){
        book = null;
        book = new Book("Not Selected Book", "None", true, null);
    }

    // 再生する本の入力
    public void inputBook(Book book){
        if(!this.book.compBook(book)){
            this.book = book;
            activePageNum = 0;
        }
    }


    /*-- Draw --*/
    public void draw(){
        // draw page image
        if(getPageImage() != null){
            imageMode(CENTER);
            image(getPageImage(), fieldCenter.x, fieldCenter.y);
        }

        // draw book title and author name
        fill(#3c3c3c);
        textAlign(CENTER);
        textSize(22);
        text(book.getBookTitle() + " / " + book.getAuthorName(), fieldCenter.x, height - 70);
    }


    /*-- Method --*/

    // 選択中のページの画像を取得
    private PImage getPageImage(){
        return book.getPageImage(activePageNum);
    }
    private PImage getPrePageImage(){
        if(activePageNum == 0){
            return book.getPageImage(book.getPageQty() - 1);
        }else{
            return book.getPageImage(activePageNum - 1);
        }
    }
    public PImage getNextPageImage(){
        if(activePageNum == book.getPageQty() - 1){
            return book.getPageImage(0);
        }else{
            return book.getPageImage(activePageNum + 1);
        }
    }

    // ページの変更
    public void changePage(int direction){
        if(!book.getDirection()) direction *= -1;
        activePageNum += direction;
        if(activePageNum > book.getPageQty() - 1){
            activePageNum = book.getPageQty() - 1;
        }else if(activePageNum < 0){
            activePageNum = 0;
        }
    }


}

class Book{
    /*-- Fieled --*/
    private String bookTitle;           // 書名
    private String authorName;          // 著者名
    private boolean direction;          // ページ送りの方向 true:左, false:右
    private ArrayList<PImage> pages;    // 本の各ページの画像イメージ

    /*-- Constractor --*/
    Book(String title, String name, boolean d, PImage... pageImages){
        bookTitle = title;
        authorName = name;
        direction = d;
        pages = new ArrayList<PImage>();
        if(pageImages != null){
            for(int i = 0; i < pageImages.length; i++){
                pages.add(pageImages[i]);
            }
        }
    }

    /*-- Method --*/

    // 書名を返す
    public String getBookTitle(){
        return bookTitle;
    }

    // 著者名を返す
    public String getAuthorName(){
        return authorName;
    }

    // 書籍のページ数を返す
    public int getPageQty(){
        return pages.size();
    }

    // 本のページイメージを追加
    public void addPageImage(PImage img){
        pages.add(img);
    }

    // 本のページイメージを返す
    public PImage getPageImage(int index){
        if(pages.size() != 0) return pages.get(index);
        else return null;
    }

    // 本のページイメージをリサイズ
    public void resizePageImage(int w){
        for(PImage img : pages){
            img.resize(w, img.height * (w / img.width));
        }
    }

    // 本の比較
    public boolean compBook(Book book){
        return this.bookTitle.equals(book.getBookTitle());
    }

    // ページ送りの方向を返す
    public boolean getDirection(){
        return direction;
    }

}