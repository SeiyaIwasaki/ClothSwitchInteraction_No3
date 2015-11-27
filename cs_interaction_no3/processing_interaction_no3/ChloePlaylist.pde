/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/

/** ユーザ設定 1 : Taro のプレイリスト **/
Playlist chloeList = new Playlist("Chloe's Top 3",
    new MusicInfo("Clair de lune", "Debussy", "\\Debussy\\Clair de lune.mp3"),
    new MusicInfo("Raindrop", "Chopin", "\\Chopin\\Raindrop.mp3"),
    new MusicInfo("Prelude", "Debussy", "\\Debussy\\Prelude.mp3"));

Book chloeBook;
void setupChloeBook(){
    chloeBook = new Book("Alice's Adventures in Wonderland", "Charles Lutwidge", false,
        loadImage("\\Alice\\alice (1).jpg"),
        loadImage("\\Alice\\alice (2).jpg"),
        loadImage("\\Alice\\alice (3).jpg"),
        loadImage("\\Alice\\alice (4).jpg"),
        loadImage("\\Alice\\alice (5).jpg"),
        loadImage("\\Alice\\alice (6).jpg"),
        loadImage("\\Alice\\alice (7).jpg"),
        loadImage("\\Alice\\alice (8).jpg"),
        loadImage("\\Alice\\alice (9).jpg"),
        loadImage("\\Alice\\alice (10).jpg"),
        loadImage("\\Alice\\alice (11).jpg"));
}