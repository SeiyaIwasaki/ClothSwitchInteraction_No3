/******************************************
        Reconfigurable Interaction
        No.3
        2015 Seiya Iwasaki
******************************************/


/** アプリケーション：「ミュージックコントローラー」 **/
class AppMusicControler{
    /*-- Field --*/
    private Rectangle appField;             // アプリケーション描画用画面割り当て
    private Point fieldCenter;              // 画面中心位置
    private Minim minim;                    // 音源ファイル読み込み
    private Playlist playlist;              // 保存されている楽曲のプレイリスト
    private AudioPlayer playingMusic;       // 再生中の音源
    private boolean activePlaying;          // 再生状態
    private int activeMusic;                // 選択中の音源のインデックス
    private float musicVolume;              // 音量
    private PImage playImage;
    private PImage pauseImage;
    private PImage preImage;
    private PImage nextImage;

    /*-- Constractor --*/
    AppMusicControler(Minim minim){
        this.minim = minim;
        initPlaylist();
        activePlaying = true;
        activeMusic = 0;
        musicVolume = 0;
        playImage = loadImage("play.png");
        pauseImage = loadImage("pause.png");
        preImage = loadImage("pre.png");
        nextImage = loadImage("next.png");
        playImage.resize(60, 60);
        pauseImage.resize(60, 60);
        preImage.resize(60, 60);
        nextImage.resize(60, 60);
    }

    // アプリの描画位置を入力
    public void inputPosition(int id, int qty){
        appField = new Rectangle((width / qty) * (id - 1), 0, width / qty, height);
        fieldCenter = new Point(appField.x + appField.width / 2, appField.y + appField.height / 2);
    }

    // プレイリストの初期化
    public void initPlaylist(){
        playlist = new Playlist("Not Selected Playlist");
        playlist.addMusic(new MusicInfo("none", "None", null));
        if(activePlaying){
            stopMusic();
        }
    }

    // ミュージックプレイヤーが再生するプレイリストを入力
    public void inputPlaylist(Playlist playlist){
        if(!this.playlist.compPlaylist(playlist)){
            this.playlist = playlist;
            loadMusicFile();
            playMusic();
        }
    }


    /*-- Draw --*/
    public void draw(){
        // draw music title and artist name
        fill(#3c3c3c);
        textAlign(CENTER);
        textSize(22);
        text(playlist.getMusicTitle(activeMusic), fieldCenter.x, fieldCenter.y - 20);
        textSize(28);
        text(playlist.getArtistName(activeMusic), fieldCenter.x, fieldCenter.y + 20);
        
        // draw playlist titles
        fill(#3c3c3c);
        textSize(18);
        textAlign(CENTER);
        text(playlist.getListTitle(), fieldCenter.x, fieldCenter.y - 100);
        stroke(#888888);
        strokeWeight(1);
        line(fieldCenter.x - playImage.width * 4, fieldCenter.y - 90, fieldCenter.x + playImage.width * 4, fieldCenter.y - 90);
        noStroke();
        
        // draw UI Images
        imageMode(CENTER);
        if(activePlaying){
            image(pauseImage, fieldCenter.x, fieldCenter.y + 100);
        }else{
            image(playImage, fieldCenter.x, fieldCenter.y + 100);
        }
        image(preImage, fieldCenter.x - playImage.width * 2, fieldCenter.y + 100);
        image(nextImage, fieldCenter.x + playImage.width * 2, fieldCenter.y + 100);
        textSize(14);
        textAlign(LEFT);
        text(playlist.getPreMusicTitle(activeMusic), fieldCenter.x - playImage.width * 2.5, fieldCenter.y + 100 + playImage.height * 0.6);
        textAlign(RIGHT);
        text(playlist.getNextMusicTitle(activeMusic), fieldCenter.x + playImage.width * 2.5, fieldCenter.y + 100 + playImage.height * 0.6);

        // draw Volume UI
        stroke(#888888);
        strokeWeight(1);
        line(fieldCenter.x + playImage.width * 4 - 20, fieldCenter.y - 90 + 50, fieldCenter.x + playImage.width * 4 - 20, fieldCenter.y + 100 + playImage.height * 0.6);
        stroke(#3c3c3c);
        strokeWeight(2);
        fill(#ffffff);
        ellipseMode(CENTER);
        int mapping = (int)map(musicVolume, 50, -50, fieldCenter.y - 90 + 50, fieldCenter.y + 100 + playImage.height * 0.6);
        ellipse(fieldCenter.x + playImage.width * 4 - 20, mapping, 10, 10);
        noStroke();
        fill(#3c3c3c);
        textSize(14);
        textAlign(CENTER);
        mapping = (int)map(musicVolume, -50, 50, 0, 100);
        text(mapping, fieldCenter.x + playImage.width * 4 - 20, fieldCenter.y - 90 + 50 - 10);
    }


    /*-- Method --*/

    // 選択中の音源ファイルを読み込む
    private void loadMusicFile(){
        if(playlist.getMusicFilePath(activeMusic) != null){
            if(playingMusic != null){
                playingMusic.close();
                playingMusic = null;
            } 
            playingMusic = minim.loadFile(playlist.getMusicFilePath(activeMusic));
            playingMusic.setGain(musicVolume);
        }
    }

    // 音源の再生
    public void playMusic(){
        playingMusic.play();
        activePlaying = true;
    }

    // 音源の一時停止
    public void stopMusic(){
        playingMusic.pause();
        activePlaying = false;
    }

    // 再生の切替
    public void turnPlaying(){
        if(activePlaying){
            playingMusic.pause();
            activePlaying = false;  
        }else{
            playingMusic.play();
            activePlaying = true;
        }
    }

    // プレイリストの変更
    // public void changePlaylist(int direction){
    //     activeList += direction;
    //     if(activeList > playlist.length - 1){
    //         activeList = 0;
    //     }else if(activeList < 0){
    //         activeList = playlist.length - 1;
    //     }
    //     activeMusic = 0;
    //     playingMusic.close();
    //     loadMusicFile();
    //     if(activePlaying) playMusic();
    // }

    // 音源の変更
    public void changeMusic(int direction){
        activeMusic += direction;
        if(activeMusic > playlist.getListLength() - 1){
            activeMusic = 0;
        }else if(activeMusic < 0){
            activeMusic = playlist.getListLength() - 1;
        }
        playingMusic.close();
        loadMusicFile();
        if(activePlaying) playMusic();
    }


    // 音量の変更
    public void changeVolume(int direction){
        musicVolume += direction;
        if(musicVolume > 50) musicVolume = 50;
        else if(musicVolume < -50) musicVolume = -50;
        playingMusic.setGain(musicVolume);
    }

    // アプリケーション終了処理
    public void stop(){
        playingMusic.close();
    }
}

class Playlist{
    /*-- Field --*/
    private String listTitle;               // プレイリスト名
    private ArrayList<MusicInfo> musics;    // プレイリストに含まれる楽曲

    /*-- Constractor --*/
    Playlist(String title, MusicInfo... musics){
        listTitle = title;
        this.musics = new ArrayList<MusicInfo>();
        for(int i = 0; i < musics.length; i++){
            this.musics.add(musics[i]);
        }
    }

    /*-- Method --*/

    // 楽曲をプレイリストに追加
    public void addMusic(MusicInfo music){
        musics.add(music);
    }

    // 楽曲をプレイリストから削除
    public void removeMusic(int index){
        musics.remove(index);
    }
    public void removeMusic(String title){
        int index = getMusicIndex(title);
        if(index != -1) musics.remove(index);
    }
    public void removeMusic(MusicInfo music){
        int index = getMusicIndex(music);
        if(index != -1) musics.remove(index);
    }

    // プレイリスト名の取得
    public String getListTitle(){
        return listTitle;
    }

    // プレイリストの長さを取得
    public int getListLength(){
        return musics.size();
    }

    // 曲名の取得
    public String getMusicTitle(int index){
        return musics.get(index).getTitle();
    }
    public String getPreMusicTitle(int index){
        if(index == 0) return musics.get(musics.size() - 1).getTitle();
        else return musics.get(index - 1).getTitle();
    }
    public String getNextMusicTitle(int index){
        if(index == musics.size() - 1) return musics.get(0).getTitle();
        else return musics.get(index + 1).getTitle();
    }

    // アーティスト名の取得
    public String getArtistName(int index){
        return musics.get(index).getArtist();
    }

    // 楽曲のファイルパス取得
    public String getMusicFilePath(int index){
        return musics.get(index).getFilePath();
    }

    // プレイリストに指定した楽曲が含まれるか調べる
    public boolean contains(String title){
        for(MusicInfo info : musics){
            if(info.compMusic(title)) return true;
        }
        return false;
    }
    public boolean contains(MusicInfo music){
        for(MusicInfo info : musics){
            if(info.compMusic(music)) return true;
        }
        return false;
    }

    // プレイリストに含まれる楽曲のインデックスを返す
    public int getMusicIndex(String title){
        int index = 0;
        for(MusicInfo info : musics){
            if(info.compMusic(title)) return index;
            index++;
        }
        return -1;
    }
    public int getMusicIndex(MusicInfo music){
        int index = 0;
        for(MusicInfo info : musics){
            if(info.compMusic(music)) return index;
            index++;
        }
        return -1;
    }

    // プレイリストの比較
    public boolean compPlaylist(Playlist list){
        return listTitle.equals(list.getListTitle());
    }
}

class MusicInfo{
    /*-- Field --*/
    private String title;       // 楽曲のタイトル
    private String artist;      // 楽曲の作者名
    private String filePath;    // 楽曲ファイルのパス

    /*-- Constractor --*/
    MusicInfo(String title, String artist, String filePath){
        this.title = title;
        this.artist = artist;
        this.filePath = filePath;
    }

    /*-- Method --*/

    // 楽曲名の取得
    public String getTitle(){
        return title;
    }

    // 作者名の取得
    public String getArtist(){
        return artist;
    }

    // ファイルパスの取得
    public String getFilePath(){
        return filePath;
    }

    // 楽曲の比較（一致しているかどうか）
    public boolean compMusic(String title){
        return this.title.equals(title);
    }
    public boolean compMusic(MusicInfo info){
        return this.title.equals(info.title);
    }
}