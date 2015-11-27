/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/

/** ユーザ設定 1 : Taro のプレイリスト **/
Playlist taroList = new Playlist("Taro's Top 3", 
    new MusicInfo("Minute Waltz", "Chopin", "\\Chopin\\Minute Waltz.mp3"),
    new MusicInfo("Nocturne Op.9-2", "Chopin", "\\Chopin\\Nocturne Op.9-2.mp3"),
    new MusicInfo("Symphony No.40 Mov1", "Mozart", "\\Mozart\\Symphony No.40 Mov1.mp3"));

Book taroBook;
void setupTaroBook(){
    taroBook = new Book("Wagahai ha neko dearu", "Natsume Soseki", true,
        loadImage("\\Wagahai\\wagahai (1).jpg"), 
        loadImage("\\Wagahai\\wagahai (2).jpg"), 
        loadImage("\\Wagahai\\wagahai (3).jpg"), 
        loadImage("\\Wagahai\\wagahai (4).jpg"), 
        loadImage("\\Wagahai\\wagahai (5).jpg"), 
        loadImage("\\Wagahai\\wagahai (6).jpg"), 
        loadImage("\\Wagahai\\wagahai (7).jpg"), 
        loadImage("\\Wagahai\\wagahai (8).jpg"), 
        loadImage("\\Wagahai\\wagahai (9).jpg"), 
        loadImage("\\Wagahai\\wagahai (10).jpg"), 
        loadImage("\\Wagahai\\wagahai (11).jpg"));
}